library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_direccion_12bits is
    Port (
        mPC : in  STD_LOGIC_VECTOR(11 downto 0);  -- dirección desde µPC
        D   : in  STD_LOGIC_VECTOR(11 downto 0);  -- dirección desde Entrada_D
        Selector : in  STD_LOGIC;                 -- controla la selección
        Y : out STD_LOGIC_VECTOR(11 downto 0)     -- salida seleccionada
    );
end mux_direccion_12bits;

architecture Behavioral of mux_direccion_12bits is
begin
    process(mPC, D, Selector)
    begin
        if Selector = '0' then
            Y <= mPC;
        else
            Y <= D;
        end if;
    end process;
end Behavioral;
