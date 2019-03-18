@echo off
set xv_path=C:\\Programs\\XilinxVivado2015.2\\Vivado\\2015.2\\bin
call %xv_path%/xelab  -wto c6f19cf0920947c59525a44e802688bc -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L secureip --snapshot tb_aes_behav xil_defaultlib.tb_aes -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
