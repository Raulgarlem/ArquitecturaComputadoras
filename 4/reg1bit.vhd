library IEEE;
	 use IEEE.STD_LOGIC_1164.ALL;
	 use IEEE.STD_LOGIC_ARITH.ALL;
	 use IEEE.STD_LOGIC_UNSIGNED.ALL;
	 
 entity reg1bit is
		 Port ( 
		 clk : in  STD_LOGIC;
		 valor : in  STD_LOGIC;
		 actualState : out  STD_LOGIC);
 end reg1bit;
 
 architecture Behavioral of reg1bit is
		begin
			process(clk,valor)
				begin
					if rising_edge (clk) then
						actualState <= valor;
						end if;
			end process;
 end Behavioral;