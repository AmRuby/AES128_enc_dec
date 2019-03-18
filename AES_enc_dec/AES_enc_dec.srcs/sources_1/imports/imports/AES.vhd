-----------------------------------AES-128 encryptor/decryptor-----------------------------------Created by: Abdelrahman Ruby / OpenCores.org -------------------------------------------Date: September 2018----------------------------------
-- This project is a non-pipelined AES-128 module, this is the top module.                                    
-- One module that does the 4 functions of AES is port-mapped once, and using a process with a clock, its inputs are varied.
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- It consists of 3 modules: 
-- 1) KEY_SCHEDULING module: this module takes the input key and generate and save all the sub-keys (10 sub-keys) to a Dram. 
-- 2) SUB_KEYS_DRAM: it is the module that saves the sub-keys.
-- 3) AES_ROUND: it is the module the does the 4 functions of each round of AES. 
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Encryption process: 
-- 1) first the KEY_SCHEDULING module generates and saves all the 10 sub_keys in the Dram.
-- 2) then the first round of AES (ADD_ROUND_KEY only) is done in this module (the top module) using the input plain text and the input round key. 
-- 3) the output of the first round is then fed to the AES_ROUND module, and using a process, the output of the old cycle is the input to the new one, with a new sub-key loaded from the dram (old output of AES_ROUND is its new input).
-- hint: each input to the AES_ROUND takes 7 clock cycles to get encrypted (using the 7 states n_round_i). 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Decryption process: 
-- 1) first the KEY_SCHEDULING module generates and saves all the 10 sub_keys in the Dram.
-- 2) then the first round of AES (ADD_ROUND_KEY only) is done in this module (the top module) using the input cipher text and the input round key. 
-- 3) the output of the first round is then fed to the AES_ROUND module, and using a process, the output of the old cycle is the input to the new one, with a new sub-key loaded from the dram (old output of AES_ROUND is its new input).
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_ARITH.ALL;
use IEEE.std_logic_UNSIGNED.ALL;

use ieee.numeric_std.all;

use work.aes_lib.all;


entity AES is
    generic (width : integer := 128);
	port( clk: in std_logic;
		  rst : in std_logic;
		  block_in : in std_logic_vector(width-1 downto 0);                -- input plain text for encrypt / cipher text for decrypt
		  key : in std_logic_vector(127 downto 0);                         -- input round key
		  enc : in std_logic;                                              -- encrypt or decrypt
		  dec : in std_logic;
		  
		  block_out : out std_logic_vector(127 downto 0);                  -- output cipher text for encrypt / plain text for decrypt
          block_ready : out std_logic);
	end AES;


architecture Behavioral of AES is


  -- Key_scheduling module signals (for port mapping). 
  signal load_KS : std_logic := '0';                                    -- load_KS loads the key in the module input registers.                                       
  signal start_KS : std_logic := '0';                                   -- start_KS starts the key scheduling process. 
  signal flag_KS : std_logic := '0';                                    -- is a signal to allow the key schedule to have its load_KS phase (load_KS <= '1', start_KS <= '0') for the first clock cycle (or after reset). 
  signal key_ready : std_logic := '0';                                  -- is '1' when one sub-key is generated (output for the key_scheduling module). 
  signal key_out : std_logic_vector(127 downto 0);                      -- the generated sub-key.
   
   
  -- Sub_keys_dram module signals
  signal we : std_logic := '0';                                         -- write enable .. for when the key expansion module is working and we want to save the sub-keys in the dram. 
  signal data_in : std_logic_vector(127 downto 0);                      -- the data input that is going to be written on the dram. 
  signal key_addr_1, key_addr_2 : std_logic_vector(3 downto 0);         -- are the two addresses of the dram (only one is needed for the sub-keys, the other one is cloned). 
  signal count_tmp : natural range 0 to 10;                             -- is the actual address of the Dram that either saves in or loads from the dram, it chooses between two signals. 
                                                                        -- when in the KEY_SCHEDULING phase, it chooses a counter (count_key) that counts up to 10 when the key_ready signal is '1' (to save the 10 sub-keys in the Dram in positions from 0 to 9) 
                                                                        -- when in the ADD_ROUND_N phase, it chooses a counter (count_enc or count_dec) that counts up to 10 when the process has waited 7 clock cycles for each new input text (to load the 10 sub-keys from the dram in position from 0 to 9).
  signal key_data_1, key_data_2 : std_logic_vector(127 downto 0);       -- are the two outputs corresponding to the two addresses of the Dram. 
 
    
  -- AES_round signals. 
  type state_type is (idle, n_round_1, n_round_2, n_round_3, n_round_4, n_round_5, n_round_6, n_round_7, last_round_1, last_round_2, last_round_3, last_round_4, last_round_5, last_round_6, pre, pre_delay, dec_round_n, dec_round_n_delay1, dec_round_n_delay2, dec_round_last, dec_round_last_done, dec_round_last_done_delay1, dec_round_last_done_delay2);  
  signal state: state_type ;                                            -- those are the states that counts the 7 cycles taken by the AES_ROUND to encrypt each input, and when finishing the 7 cycles 9 round, the last round starts. 
  signal block_in_AES :  std_logic_vector(127 downto 0);                -- input to the AES_ROUND that changes each round (7 clock cycles) and takes its old value. 
  signal sub_key_AES :  std_logic_vector(127 downto 0);                 -- is equal to the key_data_1 (the output of the SUB_KEYS_DRAM module), it gets the corresponding sub-key for the current input. 
  signal load_AES :  std_logic;                                         -- is '1' at the first clock cycle when an input enters the AES_ROUND (to load the input data in the internal registers of the module to start operating on it).                                        
  signal enc_AES :  std_logic;                                          -- starts at the next clock cycle when the data is loaded. 
  signal last_AES :  std_logic;                                         -- is '1' when we want the AES_ROUND module to perform the last round of AES (without mix columns). 
  signal block_out_enc :  std_logic_vector(127 downto 0);               -- is the output of the AES_ROUND, become its input in the next round (after 7 clock cycles from the current cycle). 
  signal block_out_dec :  std_logic_vector(127 downto 0);               -- is the output of the AES_ROUND, become its input in the next round (after 7 clock cycles from the current cycle). 
  
  
  -- additional signals for this module. 
  signal sub_keys_ready : std_logic := '0';                             -- is '1' when the key_scheduling module finishes saving 10 keys in the Dram. 
  signal flag_key_changed : std_logic := '0';                        -- flag that allows changing "sub_keys_ready" only when the key has changed.
  signal flag_rst_KS : std_logic := '0';                                -- flag that resets the process if the key has changed.  
  signal block_ready_clone : std_logic := '0';                          -- is equal to the "block_ready". 
  signal flag_block_in_changed : std_logic := '0';                      -- flag that allows changing "block_ready_clone" only when the "block-in" has changed
  signal flag_rst_AES : std_logic := '0';                               -- flag that resets the process if the "block-in" has changed.  
  signal count_key : natural range 0 to 10;                             -- counter to save the sub-keys in.
  signal count_enc: natural range 0 to 10;                              -- counter for the encryption to load the sub-keys with. 
  signal count_dec: natural range 10 downto 0 := 8;                     -- counter for the decryption to load the sub-keys with. 
  signal rst_cnt_enc : std_logic;                                       -- it resets the "count_enc" signal. 
  signal rst_cnt_dec : std_logic;                                       -- it resets the "count_dec" signal. 
  signal rst_key_scheduling: std_logic; 
  signal flag_dec : std_logic := '0';                                   -- flag for decryption.                                                     
   
   
begin
    
  KEY_SCHEDULING : entity work.key_schedule(Behavioral) port map (clk,rst_key_scheduling,load_KS,start_KS,key,key_ready,key_out);            -- port mapping for the KEY_SCHEDULING module. 
  
  key_addr_1 <= std_logic_vector(to_unsigned(count_tmp, key_addr_1'length));                                            -- is the std_logic_vector of the count_tmp.
  key_addr_2 <= std_logic_vector(to_unsigned(count_dec, key_addr_2'length));  
  
  SUB_KEYS_DRAM : entity work.dual_mem(rtl) generic map (4, 128, 10)                                                    -- port mapping of the Dram (generic map for making it having 10 slots with 128 bit data_in each). 
                                            port map (clk, we, key_addr_1, key_addr_2, data_in, key_data_1, key_data_2);
                                            
  ENC_ROUND : entity work.enc_round(Behavioral) port map (clk, rst, block_in_AES, sub_key_AES, load_AES, enc_AES, last_AES, block_out_enc);
                                                                                                                        -- port mapping for the AES_ROUND. 
  
  DEC_ROUND : entity work.dec_round(Behavioral) port map (clk, rst, block_in_AES, sub_key_AES,load_AES, enc_AES, last_AES, block_out_dec); 
  
  Main_process: process(clk, state, enc, dec, block_in, key_data_2, key)                                                -- the main processes that stalls the AES_ROUND module until the KEY_SCHEDULING module saves the sub-keys in the Dram. Then starts the AES_ROUND (after doing the first round). 
  variable block_out_firstRound : std_logic_vector(127 downto 0);                                                       -- variable that saves the first round output (ADD_ROUND_KEY only). 
  variable last_key_holder : std_logic_vector(127 downto 0);
  begin 
    if rising_edge(clk) then
        if flag_key_changed = '1' then                                                                                  -- "flag_key_changed" is only '1' when the key changes and "sub_keys_ready" is '1'.
            flag_rst_KS <= '1';                                                                                         -- this flag resets the process when the key changes. 
            sub_keys_ready <= '0';
            block_ready_clone <= '0';
            
        elsif flag_block_in_changed = '1' then                                                                          -- "flag_block_in_changed" is only '1' when the block_in changes and "block_ready_clone" is '1'.
            flag_rst_AES <= '1';                                                                                        -- this flag resets the process when the block_in changes.
            block_ready_clone <= '0'; 
                                                                     -- This is the reset phase (idle phase, the algorithm does nothing).
        elsif (rst = '1' or block_ready_clone = '1' or flag_rst_KS = '1' or flag_rst_AES = '1') then                   -- if rst (an input) or block_ready (an output, is '1' if this module completely finishes encrypting or decrypting an input) is '1' it resets everything for the new input and key.
            rst_key_scheduling <= '1'; 
            count_key <= 0; 
            rst_cnt_enc <= '1';
            rst_cnt_dec <= '1'; 
            flag_rst_KS <= '0'; 
            flag_rst_AES <= '0';
            state <= idle; 
            flag_KS <= '0'; 
            load_KS <= '0';
            start_KS <= '0';
            load_AES <= '0';
            enc_AES <= '0';
            last_AES <= '0';
            flag_dec <= '0';
                                                                     -- Reset phase ends here. 
        else                                                         -- Key Scheduling process starts from here. 
            if sub_keys_ready <= '0' then                                                                             -- sub_keys_ready is '0' means that sub-keys are not fully generated and saved in the dram, so the KEY_SCHEDULING module will keep working.
                rst_key_scheduling <= '0';
                count_tmp <= count_key;                                                                               -- when KEY_SCHEDULING module is actived the address (count_tmp) of the Dram is the count_key
                if flag_KS = '0' then                                                                                 -- flag_KS is '0' in the first clock cycle only or after reset. 
                    load_KS <= '1';                                                                                   -- to load the input key in the internal registers of the KEY_SCHEDULING module.
                    start_KS <= '0';                                                                                  -- to not start generating keys before loading. 
                    flag_KS <= '1';                                                                                   -- to start generating keys. 
                else 
                    load_KS <= '0';                                                                                      
                    start_KS <= '1';                                                                                  -- to start generating keys.
                    if key_ready = '1' then                                                                           -- key_ready is '1' if a sub-key is ready.
                        we <= '1';                                                                                    -- write enable is '1' to write the sub-key in the Dram.
                        data_in <= key_out;                                                                           -- input data to Dram is the output key from KEY_SCHEDULING module.
                        if (count_key = 9) then                                                                       -- if count_key = 9 then 10 sub-keys are generated and saved.
                            count_key <= 0; 
                            sub_keys_ready <= '1';                                                                    -- so sub_keys_ready is '1'. 
                            start_KS <= '0';
                            rst_key_scheduling <= '1';              
                        else count_key <= count_key + 1;                                                              -- if not equal 9 and key is ready, save in the next address.                   
                        end if;     
                    end if; 
                end if;                                              -- Key Scheduling process ends here. 
                                                                     -- encryption or decryption phase starts from here.
            elsif block_ready_clone = '0' then
                we <= '0' ;                                                                                           -- we don't need to write in the memory.                                                                                                
                block_out_firstRound := (others => '0');                                                              -- variable for the first round.  
                block_in_AES <= (others => '0');                                                                      -- signal entering the ADD_ROUND_N module.        
                sub_key_AES <= (others => '0');                                                                       -- signal entering the ADD_ROUND_N module.
                enc_AES <= '0';                                                                                       -- all controllers of AES_ROUND module are '0'
                last_AES <= '0';
                
                if enc = '1' then              
                    count_tmp <= count_enc; 
                    load_AES <= '0'; 
                elsif dec = '1' then 
                    rst_cnt_dec <= '0'; 
                    load_AES <= '1';
                end if; 
                case state is  
                
                  when idle =>                                                                                        -- idle case to check if enc or dec = '1' and starts encrypting or decrypting.
                    if (enc ='1' or dec = '1') then  
                      state <= pre;
                    else
                      state <= idle;
                    end if; 
                    
                  when pre =>   
                  
                    rst_cnt_enc <= '0';  
                    rst_cnt_dec <= '0'; 
                    if dec = '1' then  
                        for i in 0 to 127 loop
                            block_out_firstRound(i) := block_in(i) xor key_data_1(i);
                        end loop;  
                        block_in_AES <= block_out_firstRound;                                                         -- input block to AES_ROUND module is the output of first round.  
                        sub_key_AES <= key_data_2; 
                        state <= pre_delay;
                    else 
                        state <= pre_delay;
                    end if;
                    
                  when pre_delay =>                                                                                   -- first round (ADD_ROUND_KEY) and first clock cycle for AES_ROUND.
                    
                    if (enc = '1') then 
                        for i in 0 to 127 loop
                            block_out_firstRound(i) := block_in(i) xor key(i);                                    
                        end loop;  
                        load_AES <= '1';            
                        enc_AES <= '0';
                        block_in_AES <= block_out_firstRound;                                                         -- input block to AES_ROUND module is the output of first round.  
                        sub_key_AES <= key_data_1;                                                                    -- input sub-key to AES_ROUND module (with the corresponding address). 
                        state <= n_round_1; 
                    elsif dec = '1' then 
                        load_AES <= '0'; 
                        state <= dec_round_n;
                    end if; 
                    
                  when dec_round_n => 
                   
                    load_AES <= '1';
                    if count_dec = 0 then 
                        state <= dec_round_n_delay1; 
                    else 
                        state <= dec_round_n;
                    end if; 
                    if flag_dec = '0' then 
                        flag_dec <= '1'; 
                    else flag_dec <= '0'; 
                    end if; 
                    block_in_AES <= block_out_dec;                                                                    -- the new input is the old output of the AES_ROUND module.                                                  
                    sub_key_AES <=  key_data_2;                                                                       -- the new key (with the corresponding address).
                    
                  when dec_round_n_delay1 => 
                    if flag_dec = '0' then 
                      flag_dec <= '1'; 
                    else 
                      flag_dec <= '0'; 
                    end if; 
                    block_in_AES <= block_out_dec;                                                                    -- the new input is the old output of the AES_ROUND module.                                                  
                    sub_key_AES <=  key_data_2;    
                    state <= dec_round_n_delay2; 
                    
                  when dec_round_n_delay2 => 
                    if flag_dec = '0' then 
                      flag_dec <= '1'; 
                    else 
                      flag_dec <= '0'; 
                    end if; 
                    block_in_AES <= block_out_dec;                                                                    -- the new input is the old output of the AES_ROUND module.                                                  
                    sub_key_AES <=  key_data_2;    
                    state <= dec_round_last;  
                     
                  when dec_round_last => 
                    if flag_dec = '0' then 
                      flag_dec <= '1'; 
                    else 
                      flag_dec <= '0'; 
                    end if; 
                    last_AES <= '1';
                    block_in_AES <= block_out_dec;
                    sub_key_AES <= key;                                                                            
                    state <= dec_round_last_done;
                        
                  when dec_round_last_done => 
                    block_in_AES <= block_out_dec;
                    load_AES <= '0'; 
                    block_ready_clone <= '1';
                    state <= dec_round_last_done_delay1; 
                    
                  when dec_round_last_done_delay1 =>                                                                  -- Those two delay states are specifically made to hold the right output when the "block_ready_clone" is '1' (before the right output showed only with the rising edge if it).
                    block_in_AES <= block_out_dec;
                    state <= dec_round_last_done_delay2; 
                    
                  when dec_round_last_done_delay2 => 
                    block_in_AES <= block_out_dec;
                    state <= idle;
                  
                  when n_round_1 =>                                                                                   -- next states are done for delaying 7 clock cycles. 
                    enc_AES <= '1';
                    load_AES <= '0';
                    
                    state <= n_round_2;
                  when n_round_2 =>
                    enc_AES <= '1';
                    load_AES <= '0';
                    
                    state <= n_round_3;
                  when n_round_3 =>
                    enc_AES <= '1';
                    load_AES <= '0';
            
                    state <= n_round_4;
                  when n_round_4 =>
            
                    enc_AES <= '1';
                    load_AES <= '0';
                    
                    state <= n_round_5; 
                  when n_round_5 =>
                    enc_AES <= '1';
                    load_AES <= '0';
                      
                    state <= n_round_6;
                  when n_round_6 =>
                    enc_AES <= '1';
                    load_AES <= '0';
                      
                    state <= n_round_7;  
                  when n_round_7 =>                                                                                   -- in the 7th clock cycle (the cipher text is generated).                                                                                                       
                    enc_AES <= '1';
                    load_AES <= '1';                                                                                  -- to load the new input and sub-key to AES_ROUND module.
                    
                    block_in_AES <= block_out_enc;                                                                    -- the new input is the old output of the AES_ROUND module.                                                  
                    sub_key_AES <=  key_data_1;                                                                       -- the new key (with the corresponding address).
                    
                    if count_enc = 9 then                                                                             -- means that 7 cycles were done 9 times, so no the last round should be done.
                      state <= last_round_1;
                    else            
                      state <= n_round_1;
                    end if;                         
                  when last_round_1 =>                                                                                -- next states are done for delaying 6 clock cycles.
                    enc_AES <= '1';
                    load_AES <= '0';
                    last_AES <= '1';                                                                                  -- this controller makes the AES_ROUND disables the mix_columns. 
                    
                    state <= last_round_2;
                  when last_round_2 =>
                    enc_AES <= '1';
                    load_AES <= '0';
                    last_AES <= '1';
            
                    state <= last_round_3;
                  when last_round_3 =>
                    enc_AES <= '1';
                    load_AES <= '0';
                    last_AES <= '1';
            
                    state <= last_round_4;
                  when last_round_4 =>
                    enc_AES <= '1';
                    load_AES <= '0';
                    last_AES <= '1';
            
                    state <= last_round_5;
                  when last_round_5 =>
                    enc_AES <= '1';
                    load_AES <= '0';
                    last_AES <= '1';      
                    
                    state <= last_round_6;
                  when last_round_6 =>
                    enc_AES <= '0';
                    load_AES <= '0';
                    last_AES <= '0';
                    block_ready_clone <= '1';        
                    
                    state <= idle;
                end case;  
             end if;
        end if;
    end if;
  end process Main_process; 
  
  KS_if_key_changed : process(key, flag_rst_KS)                                                                       -- "sub_keys_ready" become '0' only when the key changes otherwise its '1' ('1' means that the keys are ready), to not enter the key scheduling process unless the key changes (before this, process the algorithm made the key scheduling process after each "block_ready" signal even if the key didn't change). 
    begin 
      if (sub_keys_ready = '1') then 
        flag_key_changed <= '1';                                                                                      -- this flag controlls when "sub_keys_ready" change.
      else flag_key_changed <= '0'; 
      end if;  
    end process KS_if_key_changed;
  
  AES_if_block_in_changed : process(block_in, flag_rst_AES, enc, dec)                                                -- "block_ready_clone" become '0' only when the block_in or key changes otherwise its '1' ('1' means that the input is already encrypted or decrypted), to not enter the encryption or decryption phase unless the block_in changes (before this process, the algorithm entered the encryption or decryption phase even if the block_in or key didn't change).
    begin
      if(block_ready_clone = '1') then
         flag_block_in_changed <= '1';                                                                               -- this flag controlls when "block_ready_clone" change.
      else flag_block_in_changed <= '0';  
      end if;
    end process AES_if_block_in_changed;
  
  cnt_10_enc : process(clk)                                                                                           -- process for the "count_enc" signal that counts up to 10 for loading the sub-keys from the Dram.
    begin
      if rising_edge(clk) then
        if (rst_cnt_enc = '1') then
          count_enc <= 0;
        elsif(state = n_round_1) then 
          if (count_enc = 9) then
            count_enc <= 0;
          else
            count_enc <= count_enc + 1;
          end if;
        end if;
       end if; 
    end process cnt_10_enc;
    
  cnt_10_dec : process(clk)                                                                                           -- process for the "count_dec" signal that counts down to 0 for loading the sub-keys from the Dram.
    begin   
      if rising_edge(clk) then 
        if (rst_cnt_dec = '1') then 
          count_dec <= 8; 
        elsif (state = pre or (state = dec_round_n and flag_dec = '0')) then 
          if count_dec = 0 then 
             count_dec <= 8; 
          else 
             count_dec <= count_dec - 1; 
          end if;
        end if;
      end if; 
      
    end process cnt_10_dec; 
    
  block_ready <= block_ready_clone;                                                                        
  block_out <= block_out_enc when enc = '1' else block_out_dec when dec = '1';                                    -- the output of the AES_ROUND module is our final output.                                                                                                  
   
      
end Behavioral;