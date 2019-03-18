library ieee;
use ieee.std_logic_1164.all;

entity tb_dec_round is 
end tb_dec_round;

architecture beh_tb_dec_round of tb_dec_round is

   signal clk,rst,last: std_logic;
   signal cipher,text_out: std_logic_vector(127 downto 0);
   signal round_key:std_logic_vector(127 downto 0);
   signal clk_period: time := 10 ns;
   
begin
    uut:entity work.dec_round
	port map(clk,rst,cipher,round_key,'0','0',last,text_out);
	
	-- Clock process definitions
    clk_process :process
    begin
       clk <= '0';
       wait for clk_period/2;
       clk <= '1';
       wait for clk_period/2;
    end process;
	
	process
	begin
	   
	   rst <= '1'; 
	   last <= '0';
	   cipher<=x"940709af5f892e3d722c32cbb57d31e9";
	   round_key<=x"6e005c574129d12821dcfa19f36677ac";
	   wait for clk_period; 
	   rst <= '0';
	   wait for clk_period; 
	   cipher<=x"1a96de77f1d2027f895339453b87db49";
       round_key<=x"05766c2a3939a323b12c548817fefaa0";
       wait for clk_period; 
       last <= '1'; 
       cipher <= x"e598271ef11141b8ae52b4e0305dbfd4";
       round_key <= x"3c4fcf098815f8aba6d2ae2816157e2b";
       wait for clk_period; 
       rst <= '1'; 
       last <= '0'; 
	   wait;
	end process;
	

end beh_tb_dec_round;