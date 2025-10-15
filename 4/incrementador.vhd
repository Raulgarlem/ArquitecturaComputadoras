library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity incrementador12 is
  port (
    Y   : in  std_logic_vector(11 downto 0);
    mPC : out std_logic_vector(11 downto 0)
    -- , COUT : out std_logic  -- (opcional) carry de salida
  );
end entity;

architecture rtl of incrementador12 is
  signal tmp : unsigned(12 downto 0);
begin
  -- Suma 1 y preserva el carry en tmp(12)
  tmp  <= unsigned('0' & Y) + 1;
  mPC  <= std_logic_vector(tmp(11 downto 0));
  -- COUT <= std_logic(tmp(12)); -- (opcional) útil si quieres detectar overflow
end architecture;