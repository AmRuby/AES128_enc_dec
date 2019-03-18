@echo off
set xv_path=C:\\Programs\\XilinxVivado2015.2\\Vivado\\2015.2\\bin
call %xv_path%/xsim tb_aes_behav -key {Behavioral:sim_1:Functional:tb_aes} -tclbatch tb_aes.tcl -view C:/Users/abdel_000/Documents/Vivado_Projects/DPRonAESwithLFSR/DPRonAESwithLFSR/DPRonAESwithLFSR.sim/sim_1/tb_aes_behav.wcfg -view C:/Users/abdel_000/Documents/Vivado_Projects/AES_enc_dec/AES_enc_dec.sim/sim_1/tb_aes_behav1.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
