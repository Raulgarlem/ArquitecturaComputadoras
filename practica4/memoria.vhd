library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity memoriaASM is
    Port (
        direccion   : in  STD_LOGIC_VECTOR(11 downto 0);  -- 12 bits
        liga        : out STD_LOGIC_VECTOR(11 downto 0);  -- 12 bits
        instruccion : out STD_LOGIC_VECTOR(1 downto 0);
        prueba      : out STD_LOGIC_VECTOR(1 downto 0);
        VF          : out STD_LOGIC;
        salidas     : out STD_LOGIC_VECTOR(7 downto 0)    -- 8 bits
    );
end memoriaASM;

architecture Behavioral of memoriaASM is

    type memoria_tipo is array (0 to 4095) of STD_LOGIC_VECTOR(24 downto 0);
constant memoria : memoria_tipo := (
    0  => "0000" & "0000" & "0000" & "00" & "00" & "0" & "1100" & "0000", -- C
    1  => "0000" & "0000" & "0000" & "00" & "00" & "0" & "0110" & "0000", -- C
    2  => "0000" & "0000" & "0000" & "10" & "00" & "0" & "0001" & "0000", -- ST
    3  => "0000" & "0011" & "0000" & "01" & "01" & "0" & "0010" & "0000", -- SCC
    4  => "0000" & "0000" & "0000" & "11" & "11" & "1" & "1000" & "0000", -- SCI
    5  => "0000" & "0001" & "0000" & "01" & "00" & "0" & "1100" & "0000", -- SCC
    6  => "0000" & "0000" & "0000" & "00" & "00" & "0" & "0001" & "0000", -- C
    7  => "0000" & "0000" & "0000" & "01" & "00" & "0" & "0000" & "0000", -- SCC
    8  => "0000" & "0000" & "0000" & "00" & "00" & "0" & "1000" & "0000", -- C
    9  => "0000" & "0000" & "0000" & "11" & "11" & "1" & "0000" & "0000", -- SCI
    10 => "0000" & "0001" & "0000" & "01" & "00" & "0" & "1100" & "0000", -- SCC
    11 => "0000" & "0000" & "0000" & "00" & "00" & "0" & "0101" & "0000", -- C
    12 => "0000" & "0000" & "0000" & "01" & "00" & "0" & "0000" & "0000", -- SCC
    13 => "0000" & "1101" & "0000" & "01" & "10" & "1" & "0010" & "0000", -- SCC
    14 => "0000" & "1001" & "0000" & "01" & "00" & "0" & "0000" & "0000", -- SCC
    others => (others => '0')
);



begin
    process(direccion)
    variable temp : STD_LOGIC_VECTOR(24 downto 0);
    begin
        temp := memoria(to_integer(unsigned(direccion)));

        liga        <= temp(24 downto 13); -- 12 bits
        instruccion <= temp(12 downto 11); -- 2 bits
        prueba      <= temp(10 downto 9);  -- 2 bits
        VF          <= temp(8);            -- 1 bit
        salidas     <= temp(7 downto 0);   -- 8 bits completos
    end process;
end Behavioral;

