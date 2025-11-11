library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity p7 is
  port(
    clk50   : in  std_logic;
    reset_n : in  std_logic;
    sw      : in  std_logic_vector(1 downto 0); -- selector de dirección
    leds    : out std_logic_vector(7 downto 0)  -- salida a LEDs
  );
  
end p7;

architecture Behavioral of p7 is

  -- RAM simulada
  signal RAM_10 : unsigned(7 downto 0) := (others => '0');
  signal RAM_11 : unsigned(7 downto 0) := (others => '0');
  signal RAM_12 : unsigned(7 downto 0) := (others => '0');

  -- registros
  signal A, B : unsigned(7 downto 0) := (others => '0');
  signal D    : unsigned(15 downto 0) := (others => '0');

begin

  -- operaciones simuladas
  process(clk50, reset_n)
  begin
    if reset_n = '0' then
      A <= (others => '0');
      B <= (others => '0');
      D <= (others => '0');
      RAM_10 <= (others => '0');
      RAM_11 <= (others => '0');
      RAM_12 <= (others => '0');
    elsif rising_edge(clk50) then
      A <= x"05";  -- LDAA
      B <= x"0A";  -- LDAB
      D <= A * B;  -- MUL
      RAM_10 <= A;
      RAM_11 <= B;
      RAM_12 <= D(7 downto 0);
    end if;
  end process;

  -- visualización en LEDs según selector
  process(sw, RAM_10, RAM_11, RAM_12)
    variable show : unsigned(7 downto 0);
  begin
    case sw is
      when "00" => show := RAM_10; -- A
      when "01" => show := RAM_11; -- D alto
      when "10" => show := RAM_12; -- D bajo
      when others => show := (others => '0');
    end case;
    leds <= std_logic_vector(show);
  end process;

end Behavioral;

