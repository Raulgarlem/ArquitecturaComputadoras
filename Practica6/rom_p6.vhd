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
begin
  process(addr)
  begin
    case addr is
      -- LDAA #$FF ? estados 860, 861, 862
      when x"0014" => datao <= x"86";
      when x"0015" => datao <= x"FF";

      -- LDAB #$01 ? estados C60, C61, C62
      when x"0016" => datao <= x"C6";
      when x"0017" => datao <= x"01";

      -- LDX #$0010 ? estados CE0, CE1, CE2
      when x"0018" => datao <= x"CE";
      when x"0019" => datao <= x"00";
      when x"001A" => datao <= x"10";

      -- ABA ? estado 1B0
      when x"001B" => datao <= x"1B";

      -- BNE ET1 ? estados 260, 261, 262, 263
      when x"001C" => datao <= x"26";
      when x"001D" => datao <= x"02"; -- salto relativo (+2)

      -- STAA 0,X ? estados A700, A701
      when x"001E" => datao <= x"A7";
      when x"001F" => datao <= x"00";

      -- BRA ET2 ? estados 200, 201
      when x"0020" => datao <= x"20";
      when x"0021" => datao <= x"02";

      -- ET1: STAB 0,X ? estados E700, E701
      when x"0022" => datao <= x"E7";
      when x"0023" => datao <= x"00";

      -- ET2: LDAA #$07 ? estados 860, 861, 862
      when x"0024" => datao <= x"86";
      when x"0025" => datao <= x"07";

      -- LDAB #$02 ? estados C60, C61, C62
      when x"0026" => datao <= x"C6";
      when x"0027" => datao <= x"02";

      -- MUL ? estado 3D0
      when x"0028" => datao <= x"3D";

      -- STAA 1,X ? estados A701, A702
      when x"0029" => datao <= x"A7";
      when x"002A" => datao <= x"01";

      -- STAB 2,X ? estados E702, E703
      when x"002B" => datao <= x"E7";
      when x"002C" => datao <= x"02";

      -- FIN: BRA FIN ? estados 200, 201
      when x"002D" => datao <= x"20";
      when x"002E" => datao <= x"FE"; -- salto relativo (-2)

      when others => datao <= x"00";
    end case;
  end process;
end Behavioral;

