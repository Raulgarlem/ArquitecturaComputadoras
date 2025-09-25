library IEEE;
	 use IEEE.STD_LOGIC_1164.ALL;
	 use IEEE.STD_LOGIC_ARITH.ALL;
	 use IEEE.STD_LOGIC_UNSIGNED.ALL;
	 
 entity conector8a4x4 is
		 Port ( valor8 : in  STD_LOGIC_VECTOR (7 downto 0);
		 liga : out  STD_LOGIC_VECTOR (3 downto 0);
		 salidas : out  STD_LOGIC_VECTOR (3 downto 0));
 end conector8a4x4;
 
 architecture Behavioral of conector8a4x4 is
		begin
			process(valor8)
				begin
					liga <= valor8(7 downto 4);
					salidas <= valor8(3 downto 0);
			end process;
 end Behavioral;