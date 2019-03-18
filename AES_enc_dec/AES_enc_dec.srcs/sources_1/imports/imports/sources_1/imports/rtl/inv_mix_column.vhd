

library ieee;
use ieee.std_logic_1164.all;

entity inv_mix_column is
   port(
           column: in std_logic_vector(31 downto 0);
		   p0,p1,p2,p3: out std_logic_vector(7 downto 0)
        );
end inv_mix_column;

architecture beh_inv_mix_column of inv_mix_column is
   signal b0,b1,b2,b3: std_logic_vector(7 downto 0);
   signal k0,k1,k2,k3: std_logic_vector(31 downto 0);
begin
    
   GF_mul_inst1:entity work.GF_mul
   port map(in_byte=>b0,out_word=>k0);
   
   GF_mul_inst2:entity work.GF_mul
   port map(in_byte=>b1,out_word=>k1);
   
   GF_mul_inst3:entity work.GF_mul
   port map(in_byte=>b2,out_word=>k2);
   
   GF_mul_inst4:entity work.GF_mul
   port map(in_byte=>b3,out_word=>k3);
   
   b0 <= column(31 downto 24);
   b1 <= column(23 downto 16);
   b2 <= column(15 downto 8);
   b3 <= column(7 downto 0);
   
   p0 <= k3(7 downto 0) xor k2(15 downto 8) xor k1(23 downto 16) xor k0(31 downto 24);
   p1 <= k3(15 downto 8) xor k2(23 downto 16) xor k1(31 downto 24) xor k0(7 downto 0);
   p2 <= k3(23 downto 16) xor k2(31 downto 24) xor k1(7 downto 0) xor k0(15 downto 8);
   p3 <= k3(31 downto 24) xor k2(7 downto 0) xor k1(15 downto 8) xor k0(23 downto 16);
   
--   p0 <= k0;
--   p1 <= k1(7 downto 0) & k1(31 downto 8);
--   p2 <= k2(15 downto 0) & k2(31 downto 16);
--   p3 <= k3(23 downto 0) & k3(31 downto 24);
end beh_inv_mix_column; 