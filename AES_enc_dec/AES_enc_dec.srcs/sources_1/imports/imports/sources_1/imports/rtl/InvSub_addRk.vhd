

library ieee;
use ieee.std_logic_1164.all;

entity InvSub_addRk is
   port(
        state_in : in std_logic_vector(127 downto 0);
        state_out : out std_logic_vector(127 downto 0);
		key : in std_logic_vector(127 downto 0)
        );
end InvSub_addRk;

architecture beh_InvSub_addRk of InvSub_addRk is

signal k0,k1,k2,k3 : std_logic_vector(31 downto 0);
signal isb0,isb1,isb2,isb3:std_logic_vector(31 downto 0);
signal w0,w1,w2,w3 : std_logic_vector(31 downto 0);
signal state_out_tmp: std_logic_vector(127 downto 0);

begin
   Inv_Sub_4bytes_complete_inst: entity work.Inv_Sub_4bytes_complete
   port map(state_in=> state_in, state_out=>state_out_tmp);
   
   k0 <= key(127 downto 96);
   k1 <= key(95 downto 64);
   k2 <= key(63 downto 32);
   k3 <= key(31 downto 0);
   
   isb0 <= state_out_tmp(127 downto 96);
   isb1 <= state_out_tmp(95 downto 64);
   isb2 <= state_out_tmp(63 downto 32);
   isb3 <= state_out_tmp(31 downto 0);
   
   w0 <= isb0 xor k0;
   w1 <= isb1 xor k1;
   w2 <= isb2 xor k2;
   w3 <= isb3 xor k3;
   
   state_out <= w0 & w1 & w2 & w3;
   
end beh_InvSub_addRk;