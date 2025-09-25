library IEEE;
	 use IEEE.STD_LOGIC_1164.ALL;
	 use IEEE.STD_LOGIC_ARITH.ALL;
	 use IEEE.STD_LOGIC_UNSIGNED.ALL;
	 

entity conector4x2a6 is
		  Port ( liga : in  STD_LOGIC_VECTOR (3 downto 0);
		        s : in  STD_LOGIC_VECTOR (1 downto 0);
		        output : out  STD_LOGIC_VECTOR (5 downto 0));
 end conector4x2a6;
 
 architecture Behavioral of conector4x2a6 is
		begin
			process(liga,s)
				begin
					output <= liga&s;
			end process;
 end Behavioral;