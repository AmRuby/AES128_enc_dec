@echo off
set xv_path=C:\\Programs\\XilinxVivado2015.2\\Vivado\\2015.2\\bin
echo "xvhdl -m64 --relax -prj tb_aes_vhdl.prj"
call %xv_path%/xvhdl  -m64 --relax -prj tb_aes_vhdl.prj -log compile.log
if "%errorlevel%"=="1" goto END
if "%errorlevel%"=="0" goto SUCCESS
:END
exit 1
:SUCCESS
exit 0
