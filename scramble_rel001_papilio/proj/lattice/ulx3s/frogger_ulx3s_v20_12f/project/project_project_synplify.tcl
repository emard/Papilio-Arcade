#-- Lattice Semiconductor Corporation Ltd.
#-- Synplify OEM project file

#device options
set_option -technology ECP5U
set_option -part LFE5U_12F
set_option -package BG381C
set_option -speed_grade -6

#compilation/mapping options
set_option -symbolic_fsm_compiler true
set_option -resource_sharing true

#use verilog 2001 standard option
set_option -vlog_std v2001

#map options
set_option -frequency auto
set_option -maxfan 1000
set_option -auto_constrain_io 0
set_option -disable_io_insertion false
set_option -retiming false; set_option -pipe true
set_option -force_gsr false
set_option -compiler_compatible 0
set_option -dup false

set_option -default_enum_encoding default

#simulation options


#timing analysis options



#automatic place and route (vendor) options
set_option -write_apr_constraint 1

#synplifyPro options
set_option -fix_gated_and_generated_clocks 1
set_option -update_models_cp 0
set_option -resolve_multiple_driver 0


#-- add_file options
set_option -include_path {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/proj/lattice/ulx3s/frogger_ulx3s_v20_12f}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/proj/lattice/ulx3s/frogger_ulx3s_v20_12f/top/scramble_ulx3s.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/proj/lattice/ulx3s/frogger_ulx3s_v20_12f/clocks/clk_25M_125Mpn_25M_7M5.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/proj/lattice/ulx3s/frogger_ulx3s_v20_12f/clocks/scramble_clocks.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/glue/scramble_glue.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/scramble.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/ram/scramble_ram_generic.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/ram/gen_ram.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/ram/bram_true2p_1clk.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/scramble_video.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/scramble_dblscan.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/scramble_debounce.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/YM2149_linmix_sep.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/scramble_audio.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/dac.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/i82c55.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/T80/T80.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/T80/T80sed.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/T80/T80_ALU.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/T80/T80_MCode.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/T80/T80_Pack.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/T80/T80_Reg.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/vga/vga.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/vga/hdmi/vga2dvid.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/vga/hdmi/tmds_encoder.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/vga/hdmi_out.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/vga/hdmi/ddr_dvid_out_se.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/vga/lattice/ecp5u/ddr_out.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/vga/hdmi-audio/av_hdmi.vhd}
add_file -verilog {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/vga/hdmi-audio/hdmidataencoder.v}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/vga/hdmi-audio/encoder.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/vga/hdmi-audio/hdmidelay.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/vga/hdmi-audio/serializer_generic.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/osd/osd.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/osd/char_rom.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/autofire/autofire.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/usbhid/usbhid_host.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/usbhid/usb_req_gen_func_pack.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/usbhid/usb_enum_saitek_minimal_pack.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/usbhid/report_decoded_pack_saitek.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/usbhid/usbhid_report_decoder_saitek.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/source/spdif/spdif_tx.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/roms/sega_frogger_real/rom_pgm.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/roms/sega_frogger_real/rom_obj_0.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/roms/sega_frogger_real/rom_obj_1.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/roms/sega_frogger_real/rom_lut.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/roms/sega_frogger_real/rom_snd_0.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/roms/sega_frogger_real/rom_snd_1.vhd}
add_file -vhdl -lib "work" {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/roms/sega_frogger_real/rom_snd_2.vhd}

#-- top module name
set_option -top_module scramble_ulx3s

#-- set result format/file last
project -result_file {/home/guest/src/fpga/arcade/Papilio-Arcade/scramble_rel001_papilio/proj/lattice/ulx3s/frogger_ulx3s_v20_12f/project/project_project.edi}

#-- error message log file
project -log_file {project_project.srf}

#-- set any command lines input by customer


#-- run Synplify with 'arrange HDL file'
project -run hdl_info_gen -fileorder
project -run
