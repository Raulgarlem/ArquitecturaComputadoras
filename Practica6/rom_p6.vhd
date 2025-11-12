library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom_p6 is
  port(
    addr  : in  unsigned(15 downto 0);
    datao : out unsigned(7 downto 0)
  );
end rom_p6;

architecture Behavioral of rom_p6 is
signal data_int : unsigned(7 downto 0);
begin
  process(addr)
  begin
  
    
    case addr is
    -- Programa principal ahora en 0xC000+
    when x"C000" => data_int <= x"86"; --14 -- LDAA #$FF
    when x"C001" => data_int <= x"AA"; --15
    
    when x"C002" => data_int <= x"C6"; --16 -- LDAB #$01
    when x"C003" => data_int <= x"01"; --17
    
    when x"C004" => data_int <= x"CE"; --18 -- LDX #$0010
    when x"C005" => data_int <= x"00"; --19
    when x"C006" => data_int <= x"50"; --1A
    
    when x"C007" => data_int <= x"1B"; --1B -- ABA
    
    when x"C008" => data_int <= x"26"; --1C -- BNE ET1
    when x"C009" => data_int <= x"04"; --1D
    
    when x"C00A" => data_int <= x"A7"; --1E -- STAA 0,X
    when x"C00B" => data_int <= x"00"; --1F
    
    when x"C00C" => data_int <= x"20"; --20 -- BRA ET2
    when x"C00D" => data_int <= x"02"; --21
    
    when x"C00E" => data_int <= x"E7"; --22 -- ET1: STAB 0,X
    when x"C00F" => data_int <= x"00"; --23
    
    when x"C010" => data_int <= x"86"; --24 -- ET2: LDAA #$07
    when x"C011" => data_int <= x"07"; --25
    
    when x"C012" => data_int <= x"C6"; --26 -- LDAB #$02
    when x"C013" => data_int <= x"02"; --27
    
    when x"C014" => data_int <= x"3D"; --28 -- MUL
    
    when x"C015" => data_int <= x"A7"; --29 -- STAA 1,X
    when x"C016" => data_int <= x"01"; --2A
    
    when x"C017" => data_int <= x"E7"; --2B -- STAB 2,X
    when x"C018" => data_int <= x"02"; --2C
    
    when x"C019" => data_int <= x"20"; --2D -- FIN: BRA FIN
    when x"C01A" => data_int <= x"FE"; --2E
    
    -- Drivers de interrupción (mantener en 0x0050 y 0x0060)
    when x"0070" => data_int <= X"CE";
    when x"0071" => data_int <= X"00";
    when x"0072" => data_int <= X"20";
    when x"0073" => data_int <= X"86";
    when x"0074" => data_int <= X"30";
    when x"0075" => data_int <= X"A7";
    when x"0076" => data_int <= X"00";
    when x"0077" => data_int <= X"3B";
    
    when x"0080" => data_int <= X"CE";
    when x"0081" => data_int <= X"00";
    when x"0082" => data_int <= X"30";
    when x"0083" => data_int <= X"C6";
    when x"0084" => data_int <= X"20";
    when x"0085" => data_int <= X"E7";
    when x"0086" => data_int <= X"00";
    when x"0087" => data_int <= X"3B";
    
    when others => data_int <= x"00";
end case;
  end process;
  datao <= data_int;  -- Salida directa (puede tener glitches)
end Behavioral;

