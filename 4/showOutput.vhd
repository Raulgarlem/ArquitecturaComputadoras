library IEEE;
	 use IEEE.STD_LOGIC_1164.ALL;
	 use IEEE.STD_LOGIC_ARITH.ALL;
	 use IEEE.STD_LOGIC_UNSIGNED.ALL;
	 
 entity showOutput is
		 Port ( valor12 : in  STD_LOGIC_VECTOR (11 downto 0);
		 actualState : out  STD_LOGIC_VECTOR (3 downto 0));
 end showOutput;
 
 architecture Behavioral of showOutput is
		begin
			process(valor12)
				begin
					actualState <= valor12(3 downto 0);
			end process;
 end Behavioral;