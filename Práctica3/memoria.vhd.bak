library IEEE;
 use IEEE.STD_LOGIC_1164.ALL;
 use IEEE.STD_LOGIC_ARITH.ALL;
 use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
 entity memoria is
			 Port ( direccion : in  STD_LOGIC_VECTOR (5 downto 0);
			 output : out  STD_LOGIC_VECTOR (7 downto 0));
 end memoria;
 
 architecture Behavioral of memoria is
		begin
			process(direccion)
		begin 
		 -- La dirección se forma con la concatenación de la Liga y las entradas Si y Sd.
		 -- El contenido de la memoria esta formado por los 4 bits mas significativos que son la LIGA y los 4 menos las salidas:
         --adelante, atras, giro_der y giro_izq. Localidades de memoria que representan el estado 0
         
          if(direccion="000000") then output <=   "00001000";
		 elsif(direccion="000001") then output <= "00010100";
		 elsif(direccion="000010") then output <= "00110100";
		 elsif(direccion="000011") then output <= "01010100";
		 
		 -- Localidades de memoria que representan el estado 1	 
		 elsif(direccion="000100") then output <= "00100001";
		 elsif(direccion="000101") then output <= "00100001";
		 elsif(direccion="000110") then output <= "00100001";
		 elsif(direccion="000111") then output <= "00100001";

         -- Localidades de memoria que representan el estado 2
		 elsif(direccion="001000") then output <= "00000000";
		 elsif(direccion="001001") then output <= "00000000";
		 elsif(direccion="001010") then output <= "00000000";
		 elsif(direccion="001011") then output <= "00000000";

		-- Localidades de memoria que representan el estado 3
		elsif(direccion="001100") then output <= "01000010";
		elsif(direccion="001101") then output <= "01000010";
		elsif(direccion="001110") then output <= "01000010";
		elsif(direccion="001111") then output <= "01000010";
		
		---- Localidades de memoria que representan el estado 4
		elsif(direccion="010000") then output <= "00000000";
		elsif(direccion="010001") then output <= "00000000";
		elsif(direccion="010010") then output <= "00000000";
		elsif(direccion="010011") then output <= "00000000";

		-- Localidades de memoria que representan el estado 5
		 elsif(direccion="010100") then output <= "01100001";
		 elsif(direccion="010101") then output <= "01100001";
		 elsif(direccion="010110") then output <= "01100001";
		 elsif(direccion="010111") then output <= "01100001";
		---- Localidades de memoria que representan el estado 6
		 elsif(direccion="011000") then output <= "01110001";
		 elsif(direccion="011001") then output <= "01110001";
		 elsif(direccion="011010") then output <= "01110001";
		 elsif(direccion="011011") then output <= "01110001";

		-- Localidades de memoria que representan el estado 7
		 elsif(direccion="011100") then output <= "10001000";
		 elsif(direccion="011101") then output <= "10001000";
		 elsif(direccion="011110") then output <= "10001000";
		 elsif(direccion="011111") then output <= "10001000";
		
		---- Localidades de memoria que representan el estado 8
		 elsif(direccion="100000") then output <= "10011000";
		 elsif(direccion="100001") then output <= "10011000";
		 elsif(direccion="100010") then output <= "10011000";
		 elsif(direccion="100011") then output <= "10011000";
		
		---- Localidades de memoria que representan el estado 9
		 elsif(direccion="100100") then output <= "10100010";
		 elsif(direccion="100101") then output <= "10100010";
		 elsif(direccion="100110") then output <= "10100010";
		 elsif(direccion="100111") then output <= "10100010";
		
		---- Localidades de memoria que representan el estado 10
		 elsif(direccion="101000") then output <= "10110010";
		 elsif(direccion="101001") then output <= "10110010";
		 elsif(direccion="101010") then output <= "10110010";
		 elsif(direccion="101011") then output <= "10110010";
		
		---- Localidades de memoria que representan el estado 11
		 elsif(direccion="101100") then output <= "00000000";
		 elsif(direccion="101101") then output <= "00000000";
		 elsif(direccion="101110") then output <= "00000000";
		 elsif(direccion="101111") then output <= "00000000";

		 end if;
 end process;
 end Behavioral;
