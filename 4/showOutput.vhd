library IEEE;
	 use IEEE.STD_LOGIC_1164.ALL;
	 use IEEE.STD_LOGIC_ARITH.ALL;
	 use IEEE.STD_LOGIC_UNSIGNED.ALL;
	 
 entity showOutput is
		 Port ( 
		 clk : in  STD_LOGIC;
		 valor12 : in  STD_LOGIC_VECTOR (11 downto 0);
		 actualState : out  STD_LOGIC_VECTOR (3 downto 0));
 end showOutput;
 
 architecture Behavioral of showOutput is
		begin
			process(clk,valor12)
				begin
					if rising_edge (clk) then
						actualState <= valor12(3 downto 0);
						end if;
			end process;
 end Behavioral;