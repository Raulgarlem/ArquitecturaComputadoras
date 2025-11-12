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
    when x"C000" => data_int <= x"86";  -- LDAA #$FF
    when x"C001" => data_int <= x"FF";
    
    when x"C002" => data_int <= x"C6";  -- LDAB #$01
    when x"C003" => data_int <= x"01";
    
    when x"C004" => data_int <= x"CE";  -- LDX #$0010
    when x"C005" => data_int <= x"00";
    when x"C006" => data_int <= x"10";
    
    when x"C007" => data_int <= x"1B";  -- ABA
    
    when x"C008" => data_int <= x"26";  -- BNE ET1
    when x"C009" => data_int <= x"03";
    
    when x"C00A" => data_int <= x"A7";  -- STAA 0,X
    when x"C00B" => data_int <= x"00";
    
    when x"C00C" => data_int <= x"20";  -- BRA ET2
    when x"C00D" => data_int <= x"02";
    
    when x"C00E" => data_int <= x"E7";  -- ET1: STAB 0,X
    when x"C00F" => data_int <= x"00";
    
    when x"C010" => data_int <= x"86";  -- ET2: LDAA #$07
    when x"C011" => data_int <= x"07";
    
    when x"C012" => data_int <= x"C6";  -- LDAB #$02
    when x"C013" => data_int <= x"02";
    
    when x"C014" => data_int <= x"3D";  -- MUL
    
    when x"C015" => data_int <= x"A7";  -- STAA 1,X
    when x"C016" => data_int <= x"01";
    
    when x"C017" => data_int <= x"E7";  -- STAB 2,X
    when x"C018" => data_int <= x"02";
    
    when x"C019" => data_int <= x"20";  -- FIN: BRA FIN
    when x"C01A" => data_int <= x"FE";
    
    -- Drivers de interrupción (mantener en 0x0050 y 0x0060)
    when x"0050" => data_int <= X"CE";
    when x"0051" => data_int <= X"00";
    when x"0052" => data_int <= X"20";
    when x"0053" => data_int <= X"B6";
    when x"0054" => data_int <= X"00";
    when x"0055" => data_int <= X"30";
    when x"0056" => data_int <= X"A7";
    when x"0057" => data_int <= X"00";
    when x"0058" => data_int <= X"3B";
    
    when x"0060" => data_int <= X"CE";
    when x"0061" => data_int <= X"00";
    when x"0062" => data_int <= X"30";
    when x"0063" => data_int <= X"F6";
    when x"0064" => data_int <= X"00";
    when x"0065" => data_int <= X"20";
    when x"0066" => data_int <= X"E7";
    when x"0067" => data_int <= X"00";
    when x"0068" => data_int <= X"3B";
    
    -- Vectores de interrupción
    when x"00F2" => data_int <= X"00";
    when x"00F3" => data_int <= X"60";
    when x"00F4" => data_int <= X"00";
    when x"00F5" => data_int <= X"50";
    
    -- Vector RESET ahora apunta a 0xC000
    when x"00FE" => data_int <= X"C0";
    when x"00FF" => data_int <= X"00";
    
    when others => data_int <= x"00";
end case;
  end process;
  datao <= data_int;  -- Salida directa (puede tener glitches)
end Behavioral;

