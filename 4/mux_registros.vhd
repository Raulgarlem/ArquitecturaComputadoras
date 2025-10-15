library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_Registros is
    Port (
        D_in_Memory 	: in  STD_LOGIC_VECTOR(11 downto 0);  -- Estado Actual Registro Memoria
		D_in_Transf 	: in  STD_LOGIC_VECTOR(11 downto 0);  -- Estado Actual Registro Transformación
		D_in_Interrupt 	: in  STD_LOGIC_VECTOR(11 downto 0);  -- Estado Actual Registro Interrupciones

        PL_n 	: in  STD_LOGIC;  	-- De la memoria
		MAP_n 	: in  STD_LOGIC;  	-- Del Registro de Transformacion
		VECT_n  : in  STD_LOGIC;  	-- Del Registro de Interrupciones
		
        D : out STD_LOGIC_VECTOR(11 downto 0)     -- dirección de salida
    );
end mux_Registros;

architecture Behavioral of mux_Registros is
begin
    process(MAP_n, VECT_n, PL_n, D_in_Transf, D_in_Interrupt, D_in_Memory)
    begin
		if(MAP_n = '0') then
			D <= D_in_Transf;
		elsif(VECT_n = '0') then
			D <= D_in_Interrupt;
		elsif(PL_n = '0') then
			D <= D_in_Memory;
		end if;
    end process;
end Behavioral;