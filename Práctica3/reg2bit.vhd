library IEEE;
 use IEEE.STD_LOGIC_1164.ALL;
 use IEEE.STD_LOGIC_ARITH.ALL;
 use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
entity register2 is
		Port ( clk : in  STD_LOGIC;
		reset : in  STD_LOGIC;
		D : in  std_logic_vector (2 downto 0); 
		Q : out  std_logic_vector (2 downto 0));
		
end register2;
 
architecture Behavioral of register2 is
	constant s0 :  std_logic_vector(2 downto 0) := B"000";
		begin
			process (clk,reset) 
				begin
					if reset='0' then Q <=s0;
					elsif rising_edge (clk)  then
						 Q <= D;
					end if;
 end process;
 
 end Behavioral;