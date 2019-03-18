# 
# Synthesis run script generated by Vivado
# 

debug::add_scope template.lib 1
set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
create_project -in_memory -part xc7z020clg484-1

set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir C:/Users/abdel_000/Documents/Vivado_Projects/AES_enc_dec/AES_enc_dec.cache/wt [current_project]
set_property parent.project_path C:/Users/abdel_000/Documents/Vivado_Projects/AES_enc_dec/AES_enc_dec.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language VHDL [current_project]
set_property board_part xilinx.com:zc702:part0:1.2 [current_project]
read_vhdl -library xil_defaultlib {
  C:/Users/abdel_000/Documents/Vivado_Projects/AES_enc_dec/AES_enc_dec.srcs/sources_1/imports/imports/sources_1/imports/rtl/xE.vhd
  C:/Users/abdel_000/Documents/Vivado_Projects/AES_enc_dec/AES_enc_dec.srcs/sources_1/imports/imports/sources_1/imports/rtl/xD.vhd
  C:/Users/abdel_000/Documents/Vivado_Projects/AES_enc_dec/AES_enc_dec.srcs/sources_1/imports/imports/sources_1/imports/rtl/xB.vhd
  C:/Users/abdel_000/Documents/Vivado_Projects/AES_enc_dec/AES_enc_dec.srcs/sources_1/imports/imports/sources_1/imports/rtl/x9.vhd
  C:/Users/abdel_000/Documents/Vivado_Projects/AES_enc_dec/AES_enc_dec.srcs/sources_1/imports/imports/sources_1/imports/rtl/Inv_Sbox.vhd
  C:/Users/abdel_000/Documents/Vivado_Projects/AES_enc_dec/AES_enc_dec.srcs/sources_1/imports/imports/sources_1/imports/rtl/Inv_Sub_4bytes.vhd
  C:/Users/abdel_000/Documents/Vivado_Projects/AES_enc_dec/AES_enc_dec.srcs/sources_1/imports/imports/sources_1/imports/rtl/gf_mul.vhd
  C:/Users/abdel_000/Documents/Vivado_Projects/AES_enc_dec/AES_enc_dec.srcs/sources_1/imports/imports/sources_1/new/Inv_Sub_4bytes_complete.vhd
  C:/Users/abdel_000/Documents/Vivado_Projects/AES_enc_dec/AES_enc_dec.srcs/sources_1/imports/imports/sources_1/imports/rtl/inv_mix_column.vhd
  C:/Users/abdel_000/Documents/Vivado_Projects/AES_enc_dec/AES_enc_dec.srcs/sources_1/imports/imports/sources_1/new/inv_mix_column_complete.vhd
  C:/Users/abdel_000/Documents/Vivado_Projects/AES_enc_dec/AES_enc_dec.srcs/sources_1/imports/imports/sources_1/imports/rtl/InvSub_addRk.vhd
  C:/Users/abdel_000/Documents/Vivado_Projects/AES_enc_dec/AES_enc_dec.srcs/sources_1/imports/imports/sources_1/imports/rtl/dec_round.vhd
}
read_xdc C:/Users/abdel_000/Documents/Vivado_Projects/AES_enc_dec/AES_enc_dec.srcs/constrs_1/new/lfsr.xdc
set_property used_in_implementation false [get_files C:/Users/abdel_000/Documents/Vivado_Projects/AES_enc_dec/AES_enc_dec.srcs/constrs_1/new/lfsr.xdc]

synth_design -top dec_round -part xc7z020clg484-1
write_checkpoint -noxdef dec_round.dcp
catch { report_utilization -file dec_round_utilization_synth.rpt -pb dec_round_utilization_synth.pb }
