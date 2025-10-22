library ieee;
use ieee.std_logic_1164.all;

entity registroTransformacion is
  generic (
    ADDR0       : std_logic_vector(11 downto 0) := "000000000011"; -- 3
    ADDR1       : std_logic_vector(11 downto 0) := "000000001000"; -- 8
    ADDR2       : std_logic_vector(11 downto 0) := "000000001101"; -- 13
    SELECT_ADDR : integer range 0 to 2 := 2                       -- <— cambia aquí
  );
  port (
    D : out std_logic_vector(11 downto 0)
  );
end entity;

architecture comb of registroTransformacion is
begin
  with SELECT_ADDR select
    D <= ADDR0 when 0,
         ADDR1 when 1,
         ADDR2 when 2,
         ADDR0 when others;
end architecture;