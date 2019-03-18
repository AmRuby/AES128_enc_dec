

library ieee;
use ieee.std_logic_1164.all;

entity GF_mul is
   port(
        in_byte: in std_logic_vector(7 downto 0);
		out_word: out std_logic_vector(31 downto 0)--0x0E,0x09,0x0D,0x0B
        );
end GF_mul;

architecture beh_GF_mul of GF_mul is    
	signal b0,b1,b2,b3:std_logic_vector(7 downto 0);
begin
   xD_inst:entity work.xD
   port map(data_in=>in_byte,data_out=>b2);
   
   xE_inst:entity work.xE
   port map(data_in=>in_byte,data_out=>b0);
   
   x9_inst:entity work.x9
   port map(data_in=>in_byte,data_out=>b1);
   
   xB_inst:entity work.xB
   port map(data_in=>in_byte,data_out=>b3);
   
   out_word <= b0&b1&b2&b3;--0x0E,0x09,0x0D,0x0B
   
end beh_GF_mul;
