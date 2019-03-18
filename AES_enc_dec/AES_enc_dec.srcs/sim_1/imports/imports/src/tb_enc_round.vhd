

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
  
ENTITY tb_aes_enc IS
END tb_aes_enc;
 
ARCHITECTURE behavior OF tb_aes_enc IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT aes_enc
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         block_in : IN  std_logic_vector(127 downto 0);
         sub_key : IN std_logic_vector(127 downto 0);
         load : IN  std_logic;
         enc : IN  std_logic;
         last : IN std_logic;
         
         block_out : OUT  std_logic_vector(127 downto 0));
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal block_in : std_logic_vector(127 downto 0) := (others => '0');
   signal sub_key : std_logic_vector(127 downto 0) := (others=> '0');
   signal load : std_logic := '0';
   signal enc : std_logic := '0';
   signal last : std_logic := '0';

 	--Outputs
   signal block_out : std_logic_vector(127 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: aes_enc PORT MAP (
          clk => clk,
          rst => rst,
          block_in => block_in,
          sub_key => sub_key,
          load => load,
          enc => enc,
          last => last,
          block_out => block_out);
        

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
		
		wait for clk_period/2 + clk_period*2;
		rst <= '1';
		
		wait for clk_period;
		rst <= '0';
		load <= '1';
		
		block_in <= X"0848f8e92a8dc69a2be2f4a0bee33d19";
		sub_key  <= X"05766c2a3939a323b12c548817fefaa0";
		
		wait for clk_period;
		
		load <= '0';
		enc <= '1';
      
        wait for clk_period*5; 
        
        enc <= '0'; 
--		wait for clk_period;
      
--		wait for clk_period;
      
--        wait for clk_period;

--		load <= '1';
		
--		block_in <= X"add6b976204688966765efb4cb5f01d1";
--		sub_key  <= X"fd8d05fdbc326cf9033e3595bcf7f747";

--		wait for clk_period;
		
--		load <= '0';
--		enc <= '1';

        wait;
   end process;

END;
