

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity inv_mix_column_complete is
    Port (
            state_in: in std_logic_vector(127 downto 0);
            state_out: out std_logic_vector(127 downto 0)
            );
end inv_mix_column_complete;

architecture Behavioral of inv_mix_column_complete is
    signal p00,p01,p02,p03,
           p10,p11,p12,p13,
           p20,p21,p22,p23,
           p30,p31,p32,p33: std_logic_vector(7 downto 0);
    signal c0,c1,c2,c3:std_logic_vector(31 downto 0);

begin

    inv_mix_column_inst0: entity work.inv_mix_column(beh_inv_mix_column)
	port map(column=>c0,p0=>p00,p1=>p01,p2=>p02,p3=>p03);
	
	inv_mix_column_inst1: entity work.inv_mix_column(beh_inv_mix_column)
	port map(column=>c1,p0=>p10,p1=>p11,p2=>p12,p3=>p13);
	
	inv_mix_column_inst2: entity work.inv_mix_column(beh_inv_mix_column)
	port map(column=>c2,p0=>p20,p1=>p21,p2=>p22,p3=>p23);
	
	inv_mix_column_inst3: entity work.inv_mix_column(beh_inv_mix_column)
	port map(column=>c3,p0=>p30,p1=>p31,p2=>p32,p3=>p33);
	
	c0<=state_in(127 downto 96);
	c1<=state_in(95 downto 64);
	c2<=state_in(63 downto 32);
	c3<=state_in(31 downto 0);

    state_out <= p00 & p01 & p02 & p03 & p10 & p11 &p12 &p13 &p20 &p21 &p22 &p23 &p30 &p31 &p32 &p33;
    
end Behavioral;
