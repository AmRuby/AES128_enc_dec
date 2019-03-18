

library ieee;
use ieee.std_logic_1164.all;

entity Inv_Sub_4bytes is
port(
     word_in: in std_logic_vector(31 downto 0);
	 word_out: out std_logic_vector(31 downto 0)
     );
end Inv_Sub_4bytes;

architecture Inv_Sub_4bytes_beh of Inv_Sub_4bytes is
   signal b0,b1,b2,b3: std_logic_vector(7 downto 0);
begin

   b0<=word_in(31 downto 24);
   b1<=word_in(23 downto 16);
   b2<=word_in(15 downto 8);
   b3<=word_in(7 downto 0);
   
   Inst1: entity work.Inv_Sbox
      port map(data_in=>b0,data_out=>word_out(31 downto 24));
   Inst2: entity work.Inv_Sbox
      port map(data_in=>b1,data_out=>word_out(23 downto 16));
   Inst3: entity work.Inv_Sbox
      port map(data_in=>b2,data_out=>word_out(15 downto 8));
   Inst4: entity work.Inv_Sbox
      port map(data_in=>b3,data_out=>word_out(7 downto 0));
	  
end Inv_Sub_4bytes_beh;