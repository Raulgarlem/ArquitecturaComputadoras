library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram_dp8x256 is
  port(
    clk     : in  std_logic;
    -- Puerto A: CPU
    a_addr  : in  unsigned(7 downto 0);
    a_din   : in  unsigned(7 downto 0);
    a_dout  : out unsigned(7 downto 0);
    a_we    : in  std_logic;                -- '1' escribe en flanco
    -- Puerto B: Debug/LEDs
    b_addr  : in  unsigned(7 downto 0);
    b_dout  : out unsigned(7 downto 0)
  );
end ram_dp8x256;

architecture rtl of ram_dp8x256 is
  type ram_t is array (0 to 255) of unsigned(7 downto 0);
  signal mem : ram_t := (others => (others => '0'));
begin
  -- Puerto A (sincrónico: write-first)
  process(clk)
  begin
    if rising_edge(clk) then
      if a_we = '1' then
        mem(to_integer(a_addr)) <= a_din;
      end if;
      a_dout <= mem(to_integer(a_addr));
    end if;
  end process;

  -- Puerto B (asíncrono de solo lectura —válido para debug)
  b_dout <= mem(to_integer(b_addr));
end rtl;