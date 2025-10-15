library ieee;
use ieee.std_logic_1164.all;

entity registroTransformacion is
  generic (
    ADDR0 : std_logic_vector(11 downto 0) := "000000000011"
    --ADDR0 : std_logic_vector(11 downto 0) := "000000001000"
    --ADDR0 : std_logic_vector(11 downto 0) := "000000001101"
  );
  port (       
    D : out std_logic_vector(11 downto 0)
  );
end entity;

architecture comb of registroTransformacion is
begin
  D <= ADDR0;
end architecture;