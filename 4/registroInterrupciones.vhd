library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Selecciona la dirección de salto según Vect_n (activo en bajo)
entity registroInterrupciones is
  generic (
    ADDR_IRQ     : std_logic_vector(11 downto 0) := "000000000110"
    
  );
  port (
    D      : out std_logic_vector(11 downto 0)    -- dirección deseada (12 bits)
  );
end entity;

architecture comb of registroInterrupciones is
begin
  D <= ADDR_IRQ;
end architecture;