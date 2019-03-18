

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Inv_Sub_4bytes_complete is
  Port (
        state_in: in std_logic_vector(127 downto 0);
        state_out: out std_logic_vector(127 downto 0)
        );
end Inv_Sub_4bytes_complete;

architecture Behavioral of Inv_Sub_4bytes_complete is
signal shc0,shc1,shc2,shc3 : std_logic_vector(31 downto 0);--Inv shifted columns
signal c0,c1,c2,c3 : std_logic_vector(31 downto 0);
signal isb0,isb1,isb2,isb3:std_logic_vector(31 downto 0);
begin

   Inv_Sub_4bytes_inst1: entity work.Inv_Sub_4bytes
   port map(word_in=>shc0 , word_out=>isb0 );
   
   Inv_Sub_4bytes_inst2: entity work.Inv_Sub_4bytes
   port map(word_in=>shc1 , word_out=>isb1 );
   
   Inv_Sub_4bytes_inst3: entity work.Inv_Sub_4bytes
   port map(word_in=>shc2 , word_out=>isb2 );
   
   Inv_Sub_4bytes_inst4:entity work.Inv_Sub_4bytes
   port map(word_in=>shc3 , word_out=>isb3 );
   
   c0 <= state_in(127 downto 96);
   c1 <= state_in(95 downto 64);
   c2 <= state_in(63 downto 32);
   c3 <= state_in(31 downto 0);
    
   shc0 <= c3(31 downto 24) & c2(23 downto 16) & c1(15 downto 8) & c0(7 downto 0); 
   shc1 <= c0(31 downto 24) & c3(23 downto 16) & c2(15 downto 8) & c1(7 downto 0);
   shc2 <= c1(31 downto 24) & c0(23 downto 16) & c3(15 downto 8) & c2(7 downto 0);
   shc3 <= c2(31 downto 24) & c1(23 downto 16) & c0(15 downto 8) & c3(7 downto 0);
   
   state_out <= isb0 & isb1 & isb2 & isb3; 

end Behavioral;
