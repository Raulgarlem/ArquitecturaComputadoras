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
  --signal PC: unsigned (15 downto 0):= X"0014";

  -- Registros y Banderas
  signal estados: STD_LOGIC_VECTOR (7 downto 0):= X"FF";
  signal A, B, Q, Yupa, XH, XL, YH, YL, AuxH, AuxL: unsigned (7 downto 0);
  signal Aux: unsigned (15 downto 0);

  -- Stack
  --signal PCH: unsigned (7 downto 0) := X"00";
  --signal PCL: unsigned (7 downto 0) := X"14";
  signal PC: unsigned (15 downto 0):= X"C000";  -- o X"F000"
  signal PCL: unsigned (7 downto 0) := X"00";
  signal PCH: unsigned (7 downto 0) := X"C0";   -- o X"F0"
  signal SPH: unsigned (7 downto 0) := X"FF";
  signal SPL: unsigned (7 downto 0) := X"FF";
  signal SP: unsigned (15 downto 0):= X"FFFF";

  -- Interrupciones
  signal microI: unsigned (11 downto 0) := X"330";
  signal microX: unsigned (11 downto 0) := X"440";
  signal IntRI: unsigned (15 downto 0):=X"0070";
  signal IntRX: unsigned (15 downto 0):=x"0080";
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
      --e_presente  <= X"000";
      --e_siguiente <= X"000";
      --PC          <= X"0014";
      e_presente  <= X"000";
    e_siguiente <= X"000";
    PC          <= X"C000";
	  Dir         <= (others => '0');
      varRW       <= '1';
      
        A   <= (others => '0');     -- Acumulador A = 0x00
  B   <= (others => '0');     -- Acumulador B = 0x00
  XH  <= (others => '0');     -- Opcional: X = 0x0000
  XL  <= (others => '0');
  YH  <= (others => '0');     -- Opcional: Y = 0x0000 (si lo usas)
  YL  <= (others => '0');

  PCH <= X"00";               -- Opcional: reflejar PC inicial en registros
  PCL <= X"14";
  SPH <= X"FF";               -- Opcional: reiniciar stack
  SPL <= X"FF";
      
    else
      if (rising_edge(clk)) then
		if ce = '1' then
			case e_presente is
					when X"000" =>
						Dir <= PC;
						e_siguiente <= X"001";
					when X"001" =>
						PC <= PC + 1;
						e_siguiente <= e_presente + 1;
					when X"002" =>
						e_siguiente <= (Data_in & ZERO(3 downto 0));
						
---------------------------------------------------------------------------------------------------------------------
-- LOAD ACCUMULATOR A FROM MEMORY
					when X"860" => -- LDAA IMM
						Dir <= PC;
						e_siguiente <= e_presente + 1;
					when X"861" => -- LDAA
						PC <= PC + 1;
						e_siguiente <= e_presente + 1;
					when X"862" => -- LDAA
						A <= Data_in; 
						-- Actualiza N
						estados(3) <= Data_in(7);
						-- Actualiza Z
						if(Data_in = ZERO) then
							estados(2) <= '1';
						else
							estados(2) <= '0';
						end if;
						-- Actualiza V
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
---------------------------------------------------------------------------------------------------------------------
-- LOAD ACCUMULATOR B FROM MEMORY
					when X"C60" => -- LDAB
						Dir <= PC;
						e_siguiente <= e_presente + 1;
					when X"C61" => -- LDAB
						PC <= PC + 1;
						e_siguiente <= e_presente + 1;
					when X"C62" => -- LDAB
						B <= Data_in;
						-- Actualiza N
						estados(3) <= Data_in(7);
						-- Actualiza Z
						if(Data_in = ZERO) then
							estados(2) <= '1';
						else
							estados(2) <= '0';
						end if;
						-- Actualiza V
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
---------------------------------------------------------------------------------------------------------------------
-- BRANCH ALWAYS 
					when X"200" =>
						Dir <= PC;
						e_siguiente <= e_presente + 1;
					when X"201" =>
						PC <= PC + 1;
						e_siguiente <= e_presente + 1;
					when X"202" =>
						if (Data_in(7) = '1') then
							PC <= PC - unsigned(not(Data_in-1));
						else
							PC <= PC + Data_in;
						end if;
						e_siguiente <= e_presente + 1;
					when X"203" =>
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
---------------------------------------------------------------------------------------------------------------------
-- BRANCH IF NOT EQUAL
					when X"260" =>
						Dir <= PC;
						e_siguiente <= e_presente + 1;
					when X"261" =>
						PC <= PC + 1;
						e_siguiente <= e_presente + 1;
					when X"262" =>
						if(estados(2)='0') then
							if (Data_in(7) = '1') then
								PC <= PC - unsigned(not(Data_in-1));
							else
								PC <= PC + Data_in;
							end if;
						end if;
						e_siguiente <= e_presente + 1;
					when X"263" =>
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
---------------------------------------------------------------------------------------------------------------------
-- LOAD ACCUMULATOR X FROM MEMORY
					when X"CE0" => -- LDX IMM
						Dir <= PC;
						e_siguiente <= e_presente + 1;
					when X"CE1" => -- LDX
						PC <= PC + 1;
						e_siguiente <= e_presente + 1;
					when X"CE2" => -- LDX IMM
						XH <= Data_in; 
						e_siguiente <= e_presente + 1;
					when X"CE3" => -- LDX IMM
						Dir <= PC;
						e_siguiente <= e_presente + 1;
					when X"CE4" => -- LDX
						PC <= PC + 1;
						e_siguiente <= e_presente + 1;
					when X"CE5" => -- LDX
						XL <= Data_in; 
						-- Actualiza N
						estados(3) <= XL(7);
						-- Actualiza Z
						if(XL = ZERO and XH = ZERO) then
							estados(2) <= '1';
						else
							estados(2) <= '0';
						end if;
						-- Actualiza V
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
---------------------------------------------------------------------------------------------------------------------
-- ADD ACCUMULATOR A+B AND STORE IN A
					when X"1B0" => -- ABA INH
						A <= A+B;
						e_siguiente <= e_presente + 1;
					when X"1B1" => -- 
						-- Actualiza N
						estados(3) <= A(7);
						-- Actualiza Z
						if(A = ZERO) then
							estados(2) <= '1';
						else
							estados(2) <= '0';
						end if;
						-- Actualiza V
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
---------------------------------------------------------------------------------------------------------------------
-- STORE ACCUMULATOR A TO MEMORY
					when X"A70" => -- STAA IND, X
						Dir <= PC;
						e_siguiente <= e_presente + 1;
					when X"A71" => -- 
						PC <= PC + 1;
						e_siguiente <= e_presente + 1;
					when X"A72" => -- 
						if (Data_in(7) = '1') then
							Dir <= unsigned(XH & XL) - unsigned(not(Data_in-1));
						else
							Dir <= unsigned(XH & XL) + Data_in;
						end if;
						e_siguiente <= e_presente + 1;
					when X"A73" => --
						Data_out <= A;
						nRW <= '0';
						e_siguiente <= e_presente + 1;
					when X"A74" => --
						nRW <= '1';
						-- Actualiza N
						estados(3) <= Data_in(7);
						-- Actualiza Z
						if(Data_in = ZERO) then
							estados(2) <= '1';
						else
							estados(2) <= '0';
						end if;
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
---------------------------------------------------------------------------------------------------------------------
-- STORE ACCUMULATOR B TO MEMORY
					when X"E70" => -- STAB IND, X
						Dir <= PC;
						e_siguiente <= e_presente + 1;
					when X"E71" => -- 
						PC <= PC + 1;
						e_siguiente <= e_presente + 1;
					when X"E72" => -- 
						if (Data_in(7) = '1') then
							Dir <= unsigned(XH & XL) - unsigned(not(Data_in-1));
						else
							Dir <= unsigned(XH & XL) + Data_in;
						end if;
						e_siguiente <= e_presente + 1;
					when X"E73" => --
						Data_out <= B; 
						nRW <= '0';
						e_siguiente <= e_presente + 1;
					when X"E74" => --
						nRW <= '1';
						-- Actualiza N
						estados(3) <= XH(7);
						-- Actualiza Z
						if(XH = ZERO) and (XL = ZERO) then
							estados(2) <= '1';
						else
							estados(2) <= '0';
						end if;
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
---------------------------------------------------------------------------------------------------------------------
-- MULTIPLY A*B AND STORE IN D
					when X"3D0" => -- MUL INH
						Aux <= A*B;
						e_siguiente <= e_presente + 1;
					when X"3D1" => -- 
						A <= Aux(15 downto 8);
						e_siguiente <= e_presente + 1;
					when X"3D2" => -- 
						B <= Aux(7 downto 0);
						e_siguiente <= e_presente + 1;
					when X"3D3" => -- 
						-- Actualiza N
						estados(3) <= A(7);
						-- Actualiza Z
						if(A = ZERO) and (B = ZERO) then
							estados(2) <= '1';
						else
							estados(2) <= '0';
						end if;
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
---------------------------------------------------------------------------------------------------------------------
-- XIRQ INTERRUPTION 
					when X"330" => -- IRQ INH
						Dir <= SP;
						nRW <= '0';
						e_siguiente <= e_presente + 1;
					when X"331" => -- 
						Data_out <= PC(7 downto 0);
						SP <= SP - 1;
						e_siguiente <= e_presente + 1;
					when X"332" => --
						Dir <= SP;
						e_siguiente <= e_presente + 1;
					when X"333" => -- 
						Data_out <= PC(15 downto 8);
						SP <= SP - 1;
						e_siguiente <= e_presente + 1;
					when X"334" => -- 
						PC <= IntRX;
						Dir <= SP;
						e_siguiente <= e_presente + 1;
					when X"335" => -- 
						Data_out <= XL;
						SP <= SP - 1;
						e_siguiente <= e_presente + 1;
					when X"336" => --
						Dir <= SP;
						e_siguiente <= e_presente + 1;
					when X"337" => -- 
						Data_out <= XH;
						SP <= SP - 1;
						e_siguiente <= e_presente + 1;
					when X"338" => --
						Dir <= SP;
						e_siguiente <= e_presente + 1;
					when X"339" => -- 
						Data_out <= A;
						SP <= SP - 1;
						e_siguiente <= e_presente + 1;
					when X"33A" => --
						Dir <= SP;
						e_siguiente <= e_presente + 1;
					when X"33B" => -- 
						Data_out <= B;
						SP <= SP - 1;
						e_siguiente <= e_presente + 1;
					when X"33C" => --
						Dir <= SP;
						e_siguiente <= e_presente + 1;
					when X"33D" => -- 
						Data_out <= unsigned(estados);
						SP <= SP - 1;
						e_siguiente <= e_presente + 1;
					when X"33E" => --
						nRW <= '1';
						e_siguiente <= X"000";
---------------------------------------------------------------------------------------------------------------------
-- IRQ INTERRUPTION 
					when X"440" => -- IRQ INH
						Dir <= SP;
						nRW <= '0';
						e_siguiente <= e_presente + 1;
					when X"441" => -- 
						Data_out <= PC(7 downto 0);
						SP <= SP - 1;
						e_siguiente <= e_presente + 1;
					when X"442" => --
						Dir <= SP;
						e_siguiente <= e_presente + 1;
					when X"443" => -- 
						Data_out <= PC(15 downto 8);
						SP <= SP - 1;
						e_siguiente <= e_presente + 1;
					when X"444" => -- 
						PC <= IntRI;
						Dir <= SP;
						e_siguiente <= X"335";
---------------------------------------------------------------------------------------------------------------------
-- RETURN FROM INTERRUPTION 
					when X"3B0" => -- RTI INH
						SP <= SP + 1;
						nRW <= '1';
						e_siguiente <= e_presente + 1;
					when X"3B1" => -- 
						Dir <= SP;
						e_siguiente <= e_presente + 1;
					when X"3B2" => --
						SP <= SP + 1;
						e_siguiente <= e_presente + 1;
					when X"3B3" => -- 
						estados <= std_logic_vector(Data_in);
						e_siguiente <= e_presente + 1;
					when X"3B4" => --
						Dir <= SP;
						e_siguiente <= e_presente + 1;
					when X"3B5" => --
						SP <= SP + 1;
						e_siguiente <= e_presente + 1;
					when X"3B6" => -- 
						B <= Data_in;
						e_siguiente <= e_presente + 1;
					when X"3B7" => -- 
						Dir <= SP;
						e_siguiente <= e_presente + 1;
					when X"3B8" => --
						SP <= SP + 1;
						e_siguiente <= e_presente + 1;
					when X"3B9" => -- 
						A <= Data_in;
						e_siguiente <= e_presente + 1;
					when X"3BA" => --
						Dir <= SP;
						e_siguiente <= e_presente + 1;
					when X"3BB" => --
						SP <= SP + 1;
						e_siguiente <= e_presente + 1;
					when X"3BC" => -- 
						XH <= Data_in;
						e_siguiente <= e_presente + 1;
					when X"3BD" => --
						Dir <= SP;
						e_siguiente <= e_presente + 1;
					when X"3BE" => --
						SP <= SP + 1;
						e_siguiente <= e_presente + 1;
					when X"3BF" => -- 
						XL <= Data_in;
						e_siguiente <= e_presente + 1;
					when X"3C0" => --
						Dir <= SP;
						e_siguiente <= e_presente + 1;
					when X"3C1" => --
						SP <= SP + 1;
						e_siguiente <= e_presente + 1;
					when X"3C2" => -- 
						PC(15 downto 8) <= Data_in;
						e_siguiente <= e_presente + 1;
					when X"3C3" => --
						Dir <= SP;
						e_siguiente <= e_presente + 1;
					when X"3C4" => --
						nRW <= '1';
						e_siguiente <= e_presente + 1;
					when X"3C5" => -- 
						PC(7 downto 0) <= Data_in;
						e_siguiente <= e_presente + 1;
					when X"3C6" => -- 
						Dir <= PC;
						e_siguiente <= X"001";
---------------------------------------------------------------------------------------------------------------------
-- .
-- .
-- .
---------------------------------------------------------------------------------------------------------------------
					when others =>
						e_siguiente <= X"000";
						PC <= X"0000";
					end case;
			--e_presente <= e_siguiente;
		end if;
	  end if;
    end if;

    -- debug vals
    e_presente <= e_siguiente;
    A_out <= A;
    B_out <= B;
    e_presente_out <= e_presente(7 downto 0);
    PC_low_out <= PC(7 downto 0);
    X_low_out <= XL;
    X_high_out <= XH;
    Y_low_out <= YL;
    flags <= estados;
    nRW <= varRW;
  end process;
end Behavioral;
  