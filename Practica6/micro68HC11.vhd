library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity micro68HC11 is
  port(
    clk, reset      : in  std_logic;
    nIRQ, nXIRQ     : in  std_logic;
    Data_in         : in  unsigned(7 downto 0); -- Bus de datos
    Data_out        : out unsigned(7 downto 0); -- Bus de direcciones
    Dir             : out unsigned(15 downto 0);
    nRW             : out std_logic:='1'; -- Señal para escribir en memoria
    
    -- salidas de depuración
    PC_low_out      : out unsigned(7 downto 0);
    e_presente_out  : out unsigned(7 downto 0);
    A_out, B_out    : out unsigned(7 downto 0);
    X_low_out,
    X_high_out      : out unsigned(7 downto 0);
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
 signal A: unsigned (7 downto 0);
 signal B: unsigned (7 downto 0);
 signal Q: unsigned (7 downto 0);
 signal Yupa: unsigned (7 downto 0);
 signal XH: unsigned (7 downto 0);
 signal XL: unsigned (7 downto 0);
 signal YH: unsigned (7 downto 0);
 signal YL: unsigned (7 downto 0);
 signal AuxH: unsigned (7 downto 0);
 signal AuxL: unsigned (7 downto 0);
 signal Aux: unsigned (15 downto 0);
 
 -- Stack
 signal PCH: unsigned (7 downto 0) := X"00";
 signal PCL: unsigned (7 downto 0) := X"14";
 signal SPH: unsigned (7 downto 0) := X"FF"; -- Definir en qué lugar poner el stack...
 signal SPL: unsigned (7 downto 0) := X"FF"; -- de qué tamaño es la memoria y ponerlo-- en la última dirección
 
 -- Interrupciones
 signal microI: unsigned (11 downto 0) := X"333" ; -- Direccion del driver de I := X""
 signal microX: unsigned (11 downto 0) := X"444" ; -- Direccion del driver de I := X""
 signal IntRI: unsigned (15 downto 0);
 signal IntRX: unsigned (15 downto 0);
 signal IRQ: STD_LOGIC := '0';
 signal XIRQ: STD_LOGIC := '0';
 
 -- MUL
 signal startMUL: STD_LOGIC := '0';
 signal D: unsigned (15 downto 0);
 
 constant ZERO : unsigned (7 downto 0) := "00000000" ;
 
 -- Control Escritura/Lectura Interno
 signal varRW: STD_LOGIC := '1';
 signal indY: STD_LOGIC := '0';


 begin
	process(clk, reset, e_presente, e_siguiente)
	begin
		if (reset = '0') then
			e_siguiente <= X"000";
			PC <= X"0014";
			IRQ <= '0';
			XIRQ <= '0';
			indY <= '0';
		else
			 if (rising_edge(clk)) then
				case e_presente is
					when X"000" =>
						Dir <= PC;
						e_siguiente <= X"001";
					
					when X"001" =>
						PC <= PC + 1;
						e_siguiente <= e_presente + 1;
					
					when X"002" =>
						e_siguiente <= (Data_in & ZERO(3 downto 0));

--------------------------------------------------------------------------------------------------------------------
					when X"860" => -- LDAA IMM
						Dir <= PC;
						e_siguiente <= e_presente + 1;
					
					when X"861" => -- LDAA
						PC <= PC + 1;
						e_siguiente <= e_presente + 1;
					
					when X"862" => -- LDAA
						A <= Data_in;-- Actualiza N
						estados(3) <= Data_in(7);-- Actualiza Z
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

-----------------------------------------
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
						
----------------- Código de la instruccion de acceso relativo BNE
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

----------------------------------------------------------------------------------------------------------------------

---
--------------------------------------------------------------------------------------------------------------------
					when others =>
						e_siguiente <= X"000";
						PC <= X"0000";
				 end case;
			end if;
		end if;
		e_presente <= e_siguiente;
		
		-- debug vals
		A_out<=A;
		B_out<=B;
		e_presente_out<=e_presente(11 downto 4);
		PC_low_out <= PC(7 downto 0);
		X_low_out <= XL;
		X_high_out <= XH;
		Y_low_out <= YL;
		flags <= estados;
	end process;
end Behavioral;
