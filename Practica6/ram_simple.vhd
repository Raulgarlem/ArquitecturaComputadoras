library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram_simple is
  port(
    clk   : in  std_logic;
    we    : in  std_logic;  -- write enable (cuando nRW='0')
    addr  : in  unsigned(15 downto 0);
    din   : in  unsigned(7 downto 0);
    dout  : out unsigned(7 downto 0)
  );
end ram_simple;

architecture Behavioral of ram_simple is
  type ram_type is array (0 to 255) of unsigned(7 downto 0);
  signal ram : ram_type := (others => x"00");
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if we = '1' then
        ram(to_integer(addr(7 downto 0))) <= din;
      end if;
      dout <= ram(to_integer(addr(7 downto 0)));
    end if;
  end process;
end Behavioral;