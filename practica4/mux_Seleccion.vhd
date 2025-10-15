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
    process(Qx, X, Y, INT)
    begin
		case (prueba) is
        -- Qx   = 00
        -- X 	= 01
        -- Y  	= 10
        -- INT 	= 11
        
            when "00" =>
                Seleccion <= Qx;

            when "01" =>
                Seleccion <= X;

            when "10" =>
                Seleccion <= Y;

            when "11" =>
                Seleccion <= INT;
        end case;
    end process;
end Behavioral;
