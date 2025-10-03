library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity direccion_control is
    Port (
        I1, I0 : in STD_LOGIC;
        CC     : in STD_LOGIC;
        Selector : out STD_LOGIC;
        PL, MAP_CTRL, VECT_CTRL : out STD_LOGIC
    );
end direccion_control;

architecture Behavioral of direccion_control is
    signal instr : STD_LOGIC_VECTOR(1 downto 0);
begin
    instr <= I1 & I0;

    process(instr, CC)
    begin
        case (instr & CC) is
            when "000" =>  -- C con CC=0
                Selector  <= '0';
                PL        <= '1';
                MAP_CTRL  <= '1';
                VECT_CTRL <= '1';

            when "001" =>  -- C con CC=1
                Selector  <= '0';
                PL        <= '1';
                MAP_CTRL  <= '1';
                VECT_CTRL <= '1';

            when "010" =>  -- SCC con CC=0
                Selector  <= '1';
                PL        <= '0';
                MAP_CTRL  <= '1';
                VECT_CTRL <= '1';

            when "011" =>  -- SCC con CC=1
                Selector  <= '0';
                PL        <= '0';
                MAP_CTRL  <= '1';
                VECT_CTRL <= '1';

            when "100" =>  -- ST con CC=0
                Selector  <= '1';
                PL        <= '1';
                MAP_CTRL  <= '0';
                VECT_CTRL <= '1';

            when "101" =>  -- ST con CC=1
                Selector  <= '1';
                PL        <= '1';
                MAP_CTRL  <= '0';
                VECT_CTRL <= '1';

            when "110" =>  -- SCI con CC=0
                Selector  <= '1';
                PL        <= '1';
                MAP_CTRL  <= '1';
                VECT_CTRL <= '0';

            when "111" =>  -- SCI con CC=1
                Selector  <= '0';
                PL        <= '1';
                MAP_CTRL  <= '1';
                VECT_CTRL <= '0';

            when others =>
                Selector  <= '0';
                PL        <= '0';
                MAP_CTRL  <= '0';
                VECT_CTRL <= '0';
        end case;
    end process;
end Behavioral;

