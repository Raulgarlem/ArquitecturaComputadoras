library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 

entity micro68HC11 is
  port(
    clk, reset      : in  std_logic;
    nIRQ, nXIRQ     : in  std_logic;
    ce              : in  std_logic := '1'; --Clock enable
    Data_in         : in  unsigned(7 downto 0); -- Bus de datos
    Data_out        : out unsigned(7 downto 0); -- Bus de direcciones
    Dir             : out unsigned(15 downto 0);
    nRW             : out std_logic := '1'; -- Señal para escribir en memoria

    -- salidas de depuración
    PC_low_out      : out unsigned(7 downto 0);
    e_presente_out  : out unsigned(7 downto 0);
    A_out, B_out    : out unsigned(7 downto 0);
    X_low_out, X_high_out : out unsigned(7 downto 0);
    Y_low_out       : out unsigned(7 downto 0);
    flags           : out std_logic_vector(7 downto 0) -- S X H I N Z V C
  );
end micro68HC11;

architecture Behavioral of micro68HC11 is
  -- Estados actual y siguiente
  signal e_presente: unsigned(11 downto 0) := X"000";
  signal e_siguiente: unsigned(11 downto 0);

  -- PC
  signal PC: unsigned (15 downto 0):= X"0014";

  -- Registros y Banderas
  signal estados: STD_LOGIC_VECTOR (7 downto 0):= X"FF";
  signal A, B, Q, Yupa, XH, XL, YH, YL, AuxH, AuxL: unsigned (7 downto 0);
  signal Aux: unsigned (15 downto 0);

  -- Stack
  signal PCH: unsigned (7 downto 0) := X"00";
  signal PCL: unsigned (7 downto 0) := X"14";
  signal SPH: unsigned (7 downto 0) := X"FF";
  signal SPL: unsigned (7 downto 0) := X"FF";

  -- Interrupciones
  signal microI: unsigned (11 downto 0) := X"333";
  signal microX: unsigned (11 downto 0) := X"444";
  signal IntRI, IntRX: unsigned (15 downto 0);
  signal IRQ, XIRQ: STD_LOGIC := '0';

  -- MUL
  signal startMUL: STD_LOGIC := '0';
  signal D: unsigned (15 downto 0);

  constant ZERO : unsigned (7 downto 0) := "00000000";

  -- Control Escritura/Lectura Interno
  signal varRW: STD_LOGIC := '1';
  signal indY: STD_LOGIC := '0';
  signal saved_pc: unsigned(15 downto 0);

begin
  process(clk, reset)
  begin
    if (reset = '1') then
      e_presente  <= X"000";
      e_siguiente <= X"000";
      PC          <= X"0014";
	  Dir         <= (others => '0');
      varRW       <= '1';
    else
      if (rising_edge(clk)) then
		if ce = '1' then
			if (nIRQ = '0' and estados(4) = '0') then
                IRQ <= '1';
            end if;
            if (nXIRQ = '0' and estados(6) = '0') then
                XIRQ <= '1';
            end if;
			
			case e_presente is
				when X"000" => 
					Dir <= PC;
					nRW <= '1';
					e_siguiente <= X"001";
					
				when X"001" => 
					PC <= PC + 1;
					e_siguiente <= X"002";
					
				when X"002" => 
					e_siguiente <= (Data_in & ZERO(3 downto 0));
				
				
				--------------------------------------------------------------------------------------------------------------------
				when X"860" => -- LDAA IMM
					Dir <= PC;
					nRW <= '1';
					e_siguiente <= X"861";

				when X"861" => -- LDAA
					PC <= PC + 1;
					e_siguiente <= X"862";

				when X"862" => -- LDAA
					A <= Data_in;
					estados(3) <= Data_in(7); --N
					
					if(Data_in = ZERO) then 
						estados(2) <= '1'; 
					else 
						estados(2) <= '0';
					end if; --Z
					
					estados(1) <= '0'; --V
					if (XIRQ = '1') then
					  e_siguiente <= microX;
					elsif (IRQ = '1') then
						e_siguiente <= microI;
					else
						Dir <= PC;
						e_siguiente <= X"001";
					end if;

			  -----------------------------------------

			  when X"C60" => -- LDAB
				Dir <= PC;
				nRW <= '1';
				e_siguiente <= X"C61";

			  when X"C61" => -- LDAB
				PC <= PC + 1;
				e_siguiente <= X"C62";

			  when X"C62" => -- LDAB
				B <= Data_in;
				estados(3) <= Data_in(7);
				if(Data_in = ZERO) then 
					estados(2) <= '1';
				else 
					estados(2) <= '0';
				end if;
				
				estados(1) <= '0';
				if (XIRQ = '1') then
				  e_siguiente <= microX;
				else
				  if (IRQ = '1') then
					e_siguiente <= microI;
				  else
					Dir <= PC;
					e_siguiente <= X"001";
				  end if;
				end if;

				-- LDX #$0010 (opcode CE)
			  when X"CE0" => 
				Dir <= PC;
				nRW <= '1';
				e_siguiente <= X"CE1";
				
			  when X"CE1" => 
				PC <= PC + 1;
				AuxH <= Data_in;
				e_siguiente <= X"CE2";
			  
			  when X"CE2" =>
				PC <= PC + 1;
				AuxL <= Data_in;
				XH <= AuxH;
				XL <= AuxL;
				Dir <= PC;
				e_siguiente <= X"001";
				
			  when X"CE3" =>
                PC <= PC + 1;
                e_siguiente <= X"CE4";
                    
              when X"CE4" =>
                XL <= Data_in;
                estados(3) <= Data_in(7);
                if(Data_in = ZERO and XH = ZERO) then
                    estados(2) <= '1';
                else
                    estados(2) <= '0';
                end if;
                estados(1) <= '0';
                if (XIRQ = '1') then
                    e_siguiente <= microX;
                elsif (IRQ = '1') then
                    e_siguiente <= microI;
                else
                    Dir <= PC;
                    e_siguiente <= X"001";
                end if;  

			  -- ABA - opcode $1B
                when X"1B0" =>
                    Aux <= ("00000000" & A) + ("00000000" & B);
                    AuxL <= A + B;  -- Calcular primero el resultado
                    A <= A + B;
                    e_siguiente <= X"1B1";
                    
                when X"1B1" =>
                    -- Actualizar flags
                    estados(3) <= AuxL(7);  -- N flag
                    if(AuxL = ZERO) then
                        estados(2) <= '1';  -- Z flag
                    else
                        estados(2) <= '0';
                    end if;
                    estados(0) <= Aux(8);  -- C flag
                    if (XIRQ = '1') then
                        e_siguiente <= microX;
                    elsif (IRQ = '1') then
                        e_siguiente <= microI;
                    else
                        Dir <= PC;
                        e_siguiente <= X"001";
                    end if;
                
			  -- BNE - opcode $26
                when X"260" =>
                    Dir <= PC;
                    nRW <= '1';
                    e_siguiente <= X"261";
                    
                when X"261" =>
                    PC <= PC + 1;
                    e_siguiente <= X"262";
                    
                when X"262" =>
                    if(estados(2)='0') then
                        if (Data_in(7) = '1') then
                            PC <= PC - unsigned(not(Data_in-1));
                        else
                            PC <= PC + Data_in;
                        end if;
                    end if;
                    e_siguiente <= X"263";
                    
                when X"263" =>
                    if (XIRQ = '1') then
                        e_siguiente <= microX;
                    elsif (IRQ = '1') then
                        e_siguiente <= microI;
                    else
                        Dir <= PC;
                        e_siguiente <= X"001";
                    end if;

			  -- STAA indexed,X - opcode $A7
                when X"A70" =>
                    Dir <= PC;
                    nRW <= '1';
                    e_siguiente <= X"A71";
                    
                when X"A71" =>
                    PC <= PC + 1;
                    AuxL <= Data_in;
                    e_siguiente <= X"A72";
                    
                when X"A72" =>
                    Dir <= (XH & XL) + ("00000000" & AuxL);
                    Data_out <= A;
                    nRW <= '0';
                    e_siguiente <= X"A73";
                    
                when X"A73" =>
                    nRW <= '1';
                    if (XIRQ = '1') then
                        e_siguiente <= microX;
                    elsif (IRQ = '1') then
                        e_siguiente <= microI;
                    else
                        Dir <= PC;
                        e_siguiente <= X"001";
                    end if;

				-- STAB indexed,X - opcode $E7
                when X"E70" =>
                    Dir <= PC;
                    nRW <= '1';
                    e_siguiente <= X"E71";
                    
                when X"E71" =>
                    PC <= PC + 1;
                    AuxL <= Data_in;
                    e_siguiente <= X"E72";
                    
                when X"E72" =>
                    Dir <= (XH & XL) + ("00000000" & AuxL);
                    Data_out <= B;
                    nRW <= '0';
                    e_siguiente <= X"E73";
                    
                when X"E73" =>
                    nRW <= '1';
                    if (XIRQ = '1') then
                        e_siguiente <= microX;
                    elsif (IRQ = '1') then
                        e_siguiente <= microI;
                    else
                        Dir <= PC;
                        e_siguiente <= X"001";
                    end if;

				  -- BRA - opcode $20
                when X"200" =>
                    Dir <= PC;
                    nRW <= '1';
                    e_siguiente <= X"201";
                    
                when X"201" =>
                    PC <= PC + 1;
                    e_siguiente <= X"202";
                    
                when X"202" =>
                    if (Data_in(7) = '1') then
                        PC <= PC - unsigned(not(Data_in-1));
                    else
                        PC <= PC + Data_in;
                    end if;
                    e_siguiente <= X"203";
                    
                when X"203" =>
                    if (XIRQ = '1') then
                        e_siguiente <= microX;
                    elsif (IRQ = '1') then
                        e_siguiente <= microI;
                    else
                        Dir <= PC;
                        e_siguiente <= X"001";
                    end if;
                    
              -- MUL: D ? A × B, A ? D[15:8], B ? D[7:0]
			  when X"3D0" =>
                    D <= A * B;
                    e_siguiente <= X"3D1";
                    
              when X"3D1" =>
                    A <= D(15 downto 8);
                    B <= D(7 downto 0);
                    if(D(7) = '1') then
                        estados(0) <= '1';
                    else
                        estados(0) <= '0';
                    end if;
                    if (XIRQ = '1') then
                        e_siguiente <= microX;
                    elsif (IRQ = '1') then
                        e_siguiente <= microI;
                    else
                        Dir <= PC;
                        e_siguiente <= X"001";
                    end if;
				  
				  -- RTI - opcode $3B
                when X"3B0" =>
                    Dir <= (SPH & SPL);
                    SPL <= SPL + 1;
                    nRW <= '1';
                    e_siguiente <= X"3B1";
                    
                when X"3B1" =>
                    estados <= std_logic_vector(Data_in);
                    Dir <= (SPH & SPL);
                    SPL <= SPL + 1;
                    e_siguiente <= X"3B2";
                    
                when X"3B2" =>
                    PCH <= Data_in;
                    Dir <= (SPH & SPL);
                    SPL <= SPL + 1;
                    e_siguiente <= X"3B3";
                    
                when X"3B3" =>
                    PCL <= Data_in;
                    PC <= PCH & Data_in;
                    IRQ <= '0';
                    XIRQ <= '0';
                    Dir <= PCH & Data_in;
                    e_siguiente <= X"001";
                    
                -- Driver XIRQ
                when X"444" =>
                    saved_pc <= PC;
                    SPL <= SPL - 1;
                    Dir <= (SPH & SPL);
                    Data_out <= PC(7 downto 0);
                    nRW <= '0';
                    e_siguiente <= X"445";
                    
                when X"445" =>
                    SPL <= SPL - 1;
                    Dir <= (SPH & SPL);
                    Data_out <= PC(15 downto 8);
                    nRW <= '0';
                    e_siguiente <= X"446";
                    
                when X"446" =>
                    SPL <= SPL - 1;
                    Dir <= (SPH & SPL);
                    Data_out <= unsigned(estados);
                    nRW <= '0';
                    PC <= IntRX;
                    e_siguiente <= X"447";
                    
                when X"447" =>
                    nRW <= '1';
                    Dir <= PC;
                    e_siguiente <= X"001";
                    
                -- Driver IRQ
                when X"333" =>
                    saved_pc <= PC;
                    SPL <= SPL - 1;
                    Dir <= (SPH & SPL);
                    Data_out <= PC(7 downto 0);
                    nRW <= '0';
                    e_siguiente <= X"334";
                    
                when X"334" =>
                    SPL <= SPL - 1;
                    Dir <= (SPH & SPL);
                    Data_out <= PC(15 downto 8);
                    nRW <= '0';
                    e_siguiente <= X"335";
                    
                when X"335" =>
                    SPL <= SPL - 1;
                    Dir <= (SPH & SPL);
                    Data_out <= unsigned(estados);
                    nRW <= '0';
                    PC <= IntRI;
                    e_siguiente <= X"336";
                    
                when X"336" =>
                    nRW <= '1';
                    Dir <= PC;
                    e_siguiente <= X"001";
                    
                    ------------------------
				  when others =>
					e_siguiente <= X"000";
					PC <= X"0000";
			end case;
			e_presente <= e_siguiente;
		end if;
	  end if;
    end if;

    -- debug vals
    --e_presente <= e_siguiente;
    A_out <= A;
    B_out <= B;
    e_presente_out <= e_presente(11 downto 4);
    PC_low_out <= PC(7 downto 0);
    X_low_out <= XL;
    X_high_out <= XH;
    Y_low_out <= YL;
    flags <= estados;
    nRW <= varRW;
  end process;
end Behavioral;
  