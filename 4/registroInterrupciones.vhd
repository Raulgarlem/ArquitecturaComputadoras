library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Selecciona la dirección de salto según Vect_n (activo en bajo)
entity registroInterrupciones is
  generic (
    ADDR_IRQ      : std_logic_vector(11 downto 0) := "000000000110"; -- 6
    ADDR_IRQ1     : std_logic_vector(11 downto 0) := "000000001011"; -- 11
    SELECT_ADDR : integer range 0 to 1 := 1                       -- <— cambia aquí
  );
  port (
    D : out std_logic_vector(11 downto 0)
  );
end entity;

architecture comb of registroInterrupciones is
begin
    with SELECT_ADDR select
    D <= ADDR_IRQ when 0,
         ADDR_IRQ1 when 1,
         ADDR_IRQ when others;
end architecture;