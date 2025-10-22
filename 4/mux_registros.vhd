library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_Registros is
    Port (
        D_in_Memory 	: in  STD_LOGIC_VECTOR(11 downto 0);  -- Estado Actual Registro Memoria
		D_in_Transf 	: in  STD_LOGIC_VECTOR(11 downto 0);  -- Estado Actual Registro Transformaci�n
		D_in_Interrupt 	: in  STD_LOGIC_VECTOR(11 downto 0);  -- Estado Actual Registro Interrupciones

        PL_n 	: in  STD_LOGIC;  	-- De la memoria
		MAP_n 	: in  STD_LOGIC;  	-- Del Registro de Transformacion
		VECT_n  : in  STD_LOGIC;  	-- Del Registro de Interrupciones
		
        D : out STD_LOGIC_VECTOR(11 downto 0)     -- direcci�n de salida
    );
end mux_Registros;

architecture Behavioral of mux_Registros is
begin
  process(MAP_n, VECT_n, PL_n, D_in_Transf, D_in_Interrupt, D_in_Memory)
  begin
    -- Valor por defecto: evita latch cuando todas est�n en '1'
    D <= D_in_Memory;  -- o (others => '0'), seg�n prefieras

    -- Prioridad: VECT (INT) > MAP (TRANSF) > PL (LIGA/MEM)
    if (VECT_n = '0') then
      D <= D_in_Interrupt;
    elsif (MAP_n = '0') then
      D <= D_in_Transf;
    elsif (PL_n = '0') then
      D <= D_in_Memory;
    end if;

    -- (Opcional) Depuraci�n: exige exclusividad (s�lo una en '0')
    -- if ((VECT_n = '0') and ((MAP_n = '0') or (PL_n = '0'))) or
    --    ((MAP_n = '0') and (PL_n = '0')) then
    --   report "mux_Registros: M�s de una l�nea activa (esperaba una sola)!"
    --     severity warning;
    -- end if;
  end process;
end Behavioral;