library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Selecciona la dirección de salto según Vect_n (activo en bajo)
entity registroInterrupciones is
  generic (
    ADDR_IRQ     : std_logic_vector(11 downto 0) := "000000000110"; -- cuando Vect_n='0' (IRQ activa)
    ADDR_DEFAULT : std_logic_vector(11 downto 0) := "000000001011"  -- cuando Vect_n='1' (sin IRQ)
  );
  port (
    Vect_n : in  std_logic;                       -- línea de interrupción (activo en bajo)
    D      : out std_logic_vector(11 downto 0)    -- dirección deseada (12 bits)
  );
end entity;

architecture comb of registroInterrupciones is
begin
  -- Mux combinacional sin reloj
  D <= ADDR_IRQ     when Vect_n = '0' else
       ADDR_DEFAULT;
end architecture;