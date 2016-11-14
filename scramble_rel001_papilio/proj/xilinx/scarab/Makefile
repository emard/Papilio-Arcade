project = miniSpartan6-plus
vendor = xilinx
family = spartan6
MODEL ?= xc6slx25
part = ${MODEL}-ftg256-3 # last number -3 is speed grade
flashsize = 8192 # KB (kilobytes) - SPI flash device is M25P40
top_module = scramble_scarab
isedir = /opt/Xilinx/ISE/14.7/ISE_DS
xil_env = . $(isedir)/settings64.sh
SHELL = /bin/bash
openocd_interface = ../include/remote.ocd
# openocd_interface = interface/altera-usb-blaster.cfg
# openocd_interface = ../include/ft2232-fpu1.ocd
# openocd_interface = programmer/ft2232-generic.ocd
xc3sprog_interface = ftdi

include ../include/xilinx.mk

vfiles = \
../../../source/vga/hdmi-audio/hdmidataencoder.v \

# top/hdmiaudio_scarab.vhd \

vhdfiles = \
top/scramble_scarab.vhd \
clocks/clk_50M_100M_125Mp_125Mn_25M.vhd \
clocks/scramble_clocks.vhd \
../../../source/glue/scramble_glue.vhd \
../../../source/scramble.vhd \
../../../source/ram/bram_true2p_1clk.vhd \
../../../source/ram/scramble_ram_generic.vhd \
../../../source/scramble_video.vhd \
../../../source/scramble_dblscan.vhd \
../../../source/scramble_debounce.vhd \
../../../source/scramble_audio.vhd \
../../../source/dac.vhd \
../../../source/YM2149_linmix_sep.vhd \
../../../source/i82c55.vhd \
../../../source/T80/T80.vhd \
../../../source/T80/T80sed.vhd \
../../../source/T80/T80_ALU.vhd \
../../../source/T80/T80_MCode.vhd \
../../../source/T80/T80_Pack.vhd \
../../../source/T80/T80_Reg.vhd \
../../../roms/stern_scramble/rom_pgm.vhd \
../../../roms/stern_scramble/rom_obj_0.vhd \
../../../roms/stern_scramble/rom_obj_1.vhd \
../../../roms/stern_scramble/rom_lut.vhd \
../../../roms/stern_scramble/rom_snd_0.vhd \
../../../roms/stern_scramble/rom_snd_1.vhd \
../../../roms/stern_scramble/rom_snd_2.vhd \
../../../source/osd/osd.vhd \
../../../source/osd/char_rom.vhd \
../../../source/vga/vga.vhd \
../../../source/vga/hdmi/vga2dvid.vhd \
../../../source/vga/hdmi/tmds_encoder.vhd \
../../../source/vga/hdmi_out.vhd \
../../../source/vga/hdmi-audio/av_hdmi.vhd \
../../../source/vga/hdmi-audio/encoder.vhd \
../../../source/vga/hdmi-audio/hdmidelay.vhd \
../../../source/vga/hdmi-audio/serializer_generic.vhd \
../../../source/vga/xilinx/xc6/ddr_out.vhd \
../../../source/vga/xilinx/xc6/hdmi_out_xc6.vhd \

