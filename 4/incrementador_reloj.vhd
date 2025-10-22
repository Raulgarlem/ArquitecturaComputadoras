-- counter_inc.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter_inc is
  generic ( N : integer := 8 );
  port (
    clk  : in  std_logic;
    rstn : in  std_logic;  -- reset activo en 0
    en   : in  std_logic;
    Q    : out std_logic_vector(N-1 downto 0);
    ovf  : out std_logic   -- overflow (carry)
  );
end entity;

architecture rtl of counter_inc is
  signal r : unsigned(N-1 downto 0);
  signal c : std_logic;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rstn = '0' then
        r <= (others => '0');
      elsif en = '1' then
        r <= r + 1;
      end if;
    end if;
  end process;

  Q   <= std_logic_vector(r);
  ovf <= '1' when (en='1' and r = (others => '1')) else '0';
end architecture;