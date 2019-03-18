

library ieee;
use ieee.std_logic_1164.all;

entity dec_round is
   port(    
          clk: in std_logic; 
          rst: in std_logic; 
          block_in: in std_logic_vector(127 downto 0);  --cipher
          sub_key: in std_logic_vector(127 downto 0);   --round_key
          load: in std_logic;
          enc: in std_logic;
          last: in std_logic;
          
		  block_out: out std_logic_vector(127 downto 0)   -- text_out
       );
end dec_round;    

architecture Behavioral of dec_round is

signal p00,p01,p02,p03,
       p10,p11,p12,p13,
	   p20,p21,p22,p23,
	   p30,p31,p32,p33:std_logic_vector(31 downto 0);
	   
signal out0,out1,out2,out3: std_logic_vector(31 downto 0);
signal state_out: std_logic_vector(127 downto 0);
signal state_out_tmp: std_logic_vector(127 downto 0);

begin
    InvSub_addRk_inst: entity work.InvSub_addRk(beh_InvSub_addRk)
	port map(block_in,state_out=>state_out,key=>sub_key);
	
	inv_mix_column_complete_inst: entity work.inv_mix_column_complete(Behavioral)
    port map(state_in=>state_out,state_out=>state_out_tmp);
    
    process(clk) 
    begin 
        
        if rising_edge(clk) then 
            if rst = '1' then 
                block_out <= (others => '0');
            elsif load = '1' then  
                if last = '0' then 
                    block_out <= state_out_tmp;
                else 
                    block_out <= state_out; 
                end if;
            end if;
        end if; 
        
    end process;     
	
end  Behavioral;