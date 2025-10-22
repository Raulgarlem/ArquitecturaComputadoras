library IEEE;
 use IEEE.STD_LOGIC_1164.ALL;
 use IEEE.STD_LOGIC_ARITH.ALL;
 use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
entity outRegister is
		Port ( 
		clk 		: in  STD_LOGIC;
		Y_inReg		: in  std_logic_vector (11 downto 0);
		Y_outReg	: out  std_logic_vector (11 downto 0));
end outRegister;
 
architecture Behavioral of outRegister is
		begin
			process (clk,Y_inReg) 
				begin
					if rising_edge (clk)  then
						 Y_outReg <= Y_inReg;
					end if;
 end process;
 
 end Behavioral;