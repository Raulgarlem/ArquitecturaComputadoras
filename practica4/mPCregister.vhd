library IEEE;
 use IEEE.STD_LOGIC_1164.ALL;
 use IEEE.STD_LOGIC_ARITH.ALL;
 use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
entity mPCregister is
		Port ( 
		clk : in  STD_LOGIC;
		reset : in  STD_LOGIC;
		increment : in  std_logic_vector (11 downto 0); 
		mPC : out  std_logic_vector (11 downto 0));
		
end mPCregister;
 
architecture Behavioral of mPCregister is
	constant s0 :  std_logic_vector(11 downto 0) := B"000000000000";
		begin
			process (clk,reset) 
				begin
					if reset='0' then mPC <= s0;
					elsif rising_edge (clk)  then
						 mPC <= increment;
					end if;
 end process;
 
 end Behavioral;