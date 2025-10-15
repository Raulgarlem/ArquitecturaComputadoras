library ieee;
use ieee.std_logic_1164.all;

entity registroTransformacion is
  generic (
    ADDR0 : std_logic_vector(11 downto 0) := "000000000011";
    ADDR_DEFAULT : std_logic_vector(11 downto 0) := "000000001000"
  );
  port (
    MAP_n  : in  std_logic;         
    D : out std_logic_vector(11 downto 0)
  );
end entity;

architecture comb of registroTransformacion is
begin
  D <= ADDR0    when MAP_n = '0' else
       ADDR_DEFAULT;
end architecture;