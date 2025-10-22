library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity memoriaASM is
    Port (
        direccion   : in  STD_LOGIC_VECTOR(11 downto 0);  -- 12 bits
        liga        : out STD_LOGIC_VECTOR(11 downto 0);  -- 12 bits
        instruccion : out STD_LOGIC_VECTOR(1 downto 0);   -- 2 bits
        prueba      : out STD_LOGIC_VECTOR(1 downto 0);   -- 2 bits
        VF          : out STD_LOGIC;
        salidas     : out STD_LOGIC_VECTOR(3 downto 0)    -- 8 bits
    );
end memoriaASM;

architecture Behavioral of memoriaASM is

    type memoria_tipo is array (0 to 4095) of STD_LOGIC_VECTOR(20 downto 0);
constant memoria : memoria_tipo := (
-- Formato por línea:
--         "liga[11:8]" &  "liga[7:4]" &  "liga[3:0]" & "instruccion" & "prueba" & "VF" & "salidas(3:0)"
    0  =>     "0000"    &    "0000"    &    "0000"    &     "00"      &   "00"   &  "0" &    "1100",   -- C
    1  =>     "0000"    &    "0000"    &    "0000"    &     "00"      &   "00"   &  "0" &    "0110",   -- C
    2  =>     "0000"    &    "0000"    &    "0000"    &     "10"      &   "00"   &  "0" &    "0001",   -- ST
    3  =>     "0000"    &    "0000"    &    "0011"    &     "01"      &   "01"   &  "0" &    "0010",   -- SCC
    4  =>     "0000"    &    "0000"    &    "0000"    &     "11"      &   "11"   &  "1" &    "1000",   -- SCI
    5  =>     "0000"    &    "0000"    &    "0001"    &     "01"      &   "00"   &  "0" &    "1100",   -- SCC
    6  =>     "0000"    &    "0000"    &    "0000"    &     "00"      &   "00"   &  "0" &    "0011",   -- C
    7  =>     "0000"    &    "0000"    &    "0000"    &     "01"      &   "00"   &  "0" &    "0001",   -- SCC
    8  =>     "0000"    &    "0000"    &    "0000"    &     "00"      &   "00"   &  "0" &    "1000",   -- C
    9  =>     "0000"    &    "0000"    &    "0000"    &     "11"      &   "11"   &  "1" &    "0000",   -- SCI
    10 =>     "0000"    &    "0000"    &    "0001"    &     "01"      &   "00"   &  "0" &    "1100",   -- SCC
    11 =>     "0000"    &    "0000"    &    "0000"    &     "00"      &   "00"   &  "0" &    "0101",   -- C
    12 =>     "0000"    &    "0000"    &    "0000"    &     "01"      &   "00"   &  "0" &    "0001",   -- SCC
    13 =>     "0000"    &    "0000"    &    "1101"    &     "01"      &   "10"   &  "1" &    "0010",   -- SCC
    14 =>     "0000"    &    "0000"    &    "1001"    &     "01"      &   "00"   &  "0" &    "0000",   -- SCC
    others => (others => '0')
);



begin
    process(direccion)
    variable temp : STD_LOGIC_VECTOR(20 downto 0);
    begin
		--if rising_edge (clk) then
			temp := memoria(to_integer(unsigned(direccion)));

			liga        <= temp(20 downto 9); 	-- 12 bits
			instruccion <= temp(8 downto 7); 	-- 2 bits
			prueba      <= temp(6 downto 5);	-- 2 bits
			VF          <= temp(4);            	-- 1 bit
			salidas     <= temp(3 downto 0);   	-- 4 bits completos
		--end if;
    end process;
end Behavioral;

