library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity conectormemoria is
    Port (
        valor25     : in  STD_LOGIC_VECTOR (24 downto 0);
        liga        : out STD_LOGIC_VECTOR (11 downto 0);
        instruccion : out STD_LOGIC_VECTOR(1 downto 0);
        Prueba      : out STD_LOGIC_VECTOR(1 downto 0);
        VF          : out STD_LOGIC_VECTOR(0 downto 0);
        Salidas     : out STD_LOGIC_VECTOR(7 downto 0)
    );
end conectormemoria;

architecture Behavioral of conectormemoria is
begin
    process(valor25)
    begin
        liga        <= valor25(24 downto 13);
        instruccion <= valor25(12 downto 11);
        Prueba      <= valor25(10 downto 9);
        VF          <= valor25(8 downto 8);
        Salidas     <= valor25(7 downto 0);
    end process;
end Behavioral;
