

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
  
ENTITY tb_aes IS
END tb_aes;
 
ARCHITECTURE behavior OF tb_aes IS     

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal block_in : std_logic_vector(127 downto 0) := (others => '0');
   signal key : std_logic_vector(127 downto 0) := (others=> '0');
   signal enc : std_logic := '0';
   signal dec : std_logic := '0';

 	--Outputs
   signal block_out : std_logic_vector(127 downto 0);
   signal block_ready : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.AES PORT MAP (
          clk => clk,
          rst => rst,
          block_in => block_in,
          key => key,
          enc => enc,
          dec => dec,
          block_out => block_out,
          block_ready => block_ready);

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
------------------------------------------------------------------- This is the encryption test -------------------------------------------------
		
		rst <= '1';
		
		wait for 2*clk_period;
		rst <= '0';
        enc <= '1';
                		
		block_in <= X"340737e0a29831318d305a88a8f64332";
		key      <= X"3c4fcf098815f7aba6d2ae2816157e2b";
		wait for 1.3 us; 
		
        block_in <= X"0f0d0c0b0a0908070605040302010000";
        key      <= X"3c4fcf098815f7aba6d2ae2816157e3e";
        wait for 1.3 us; 
        
        block_in <= X"0e0d0c0b0a0908070605040302010000";
        wait for 1.3 us; 
        
        key      <= X"3c4fcf098815f7aba6d2ae2816157e7a";
        wait for 1.3 us; 
        
        enc <= '0'; 
        wait for clk_period; 
------------------------------------------------------------------- End of encryption test ------------------------------------------------------
------------------------------------------------------------------- This is the decryption test -------------------------------------------------
        
        dec <= '1';
        block_in <= X"320b6a19978511dcfb09dc021d842539";
        wait for 1 us; 
        
        block_in <= X"320b6a19978511dcfb09dc021d842539";
        key      <= X"3c4fcf098815f7aba6d2ae2816157e2b";
        wait for 1 us;
        
        block_in <= X"0f0d0c0b0a0908070605040302010000";
        key      <= X"3c4fcf098815f7aba6d2ae2816157e3e";
        wait for 1 us; 
        
        block_in <= X"0e0d0c0b0a0908070605040302010000";
        wait for 1.005 us;
         
        key <= X"3c4fcf098815f7aba6d2ae2816157e7a";
        
------------------------------------------------------------------- End of decryption test ------------------------------------------------------

        wait;
   end process;

END;
