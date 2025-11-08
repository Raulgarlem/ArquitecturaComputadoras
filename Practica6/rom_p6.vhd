library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom_p6 is
  port(
    addr  : in  unsigned(15 downto 0);
    datao : out unsigned(7 downto 0)
  );
end rom_p6;

architecture rtl of rom_p6 is
  -- 256 bytes
  type rom_t is array (0 to 255) of std_logic_vector(7 downto 0);
  signal ROM : rom_t := (others => (others => '0'));

  -- dile a Quartus que lo llene con tu .hex
  attribute ram_init_file : string;
  attribute ram_init_file of ROM : signal is "programa68hc11.hex";
begin
  -- usamos solo los 8 bits bajos de la dirección
  datao <= unsigned(ROM(to_integer(addr(7 downto 0))));
end rtl;
