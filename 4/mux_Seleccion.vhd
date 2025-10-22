library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_Seleccion is
    Port (
        Qx 	: in  STD_LOGIC;  -- Estado mPC
        X   : in  STD_LOGIC;  -- Estado X
        Y 	: in  STD_LOGIC;  -- Estado Y
		INT : in  STD_LOGIC;  -- Estado de interrupción
		
		prueba : in STD_LOGIC_VECTOR(1 downto 0);
		
        Seleccion : out STD_LOGIC     -- salida seleccionada
    );
end mux_Seleccion;

architecture Behavioral of mux_Seleccion is
begin
		with prueba select
		Seleccion <= Qx  when "00",
                 X   when "01",
                 Y   when "10",
                 INT when "11";
end Behavioral;
