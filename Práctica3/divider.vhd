library IEEE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity divider is
    Port (
        clk     : in  std_logic;
        div_clk : out std_logic
    );
end divider;

architecture Behavioral of divider is
    signal cuenta : std_logic_vector(23 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            cuenta <= cuenta + 1;
        end if;
    end process;

    div_clk <= cuenta(23);  -- Pulso lento (~0.6 Hz con clk de 50 MHz)
end Behavioral;


