###################################################################
# Project Configuration: 
# 
# Specify the name of the design (project) and the Quartus II
# Settings File (.qsf)
###################################################################

PROJECT = project
TOP_LEVEL_ENTITY = scramble_reverseu16
ASSIGNMENT_FILES = $(PROJECT).qpf $(PROJECT).qsf

###################################################################
# Part, Family, Boardfile
FAMILY = "Cyclone IV E"
PART = EP4CE22E22C8
BOARDFILE = reverse-u16.board
CONFIG_DEVICE = EPCS16
SERIAL_FLASH_LOADER_DEVICE = EP4CE22
OPENOCD_BOARD=reverse-u16.ocd
# OPENOCD_INTERFACE=interface/altera-usb-blaster.cfg
# OPENOCD_INTERFACE=ftdi-fpu1.ocd
OPENOCD_INTERFACE=../include/remote.ocd

###################################################################
#
# Quartus shell environment vars
#
###################################################################

quartus_env ?= . ../include/quartus_env.sh

# include makefile which does it all
include ../include/altera.mk

###################################################################
# Setup your sources here
SRCS = \
top/scramble_reverseu16.vhd \
clocks/clk_50M_125M_25M.vhd \
clocks/pll_50M_250M_25M_83M333.vhd \
clocks/scramble_clocks.vhd \
joystick/joystick_saitek_cyborg_rumble.vhd \
../../../source/glue/scramble_glue.vhd \
../../../source/scramble.vhd \
../../../source/ram/scramble_ram_generic.vhd \
../../../source/ram/gen_ram.vhd \
../../../source/ram/bram_true2p_1clk.vhd \
../../../source/scramble_video.vhd \
../../../source/scramble_dblscan.vhd \
../../../source/scramble_debounce.vhd \
../../../source/YM2149_linmix_sep.vhd \
../../../source/scramble_audio.vhd \
../../../source/dac.vhd \
../../../source/i82c55.vhd \
../../../source/T80/T80.vhd \
../../../source/T80/T80sed.vhd \
../../../source/T80/T80_ALU.vhd \
../../../source/T80/T80_MCode.vhd \
../../../source/T80/T80_Pack.vhd \
../../../source/T80/T80_Reg.vhd \
../../../source/vga/vga.vhd \
../../../source/vga/hdmi/vga2dvid.vhd \
../../../source/vga/hdmi/tmds_encoder.vhd \
../../../source/vga/hdmi_out.vhd \
../../../source/vga/hdmi-audio/av_hdmi.vhd \
../../../source/vga/hdmi-audio/hdmidataencoder.v \
../../../source/vga/hdmi-audio/encoder.vhd \
../../../source/vga/altera/cyclone4/serializer.vhd \
../../../source/vga/hdmi-audio/hdmidelay.vhd \
../../../source/vga/hdmi-audio/serializer_generic.vhd \
../../../source/vnc2hid/uart_deserializer.vhd \
../../../source/vnc2hid/vnc2hid.vhd \
../../../source/osd/osd.vhd \
../../../source/osd/char_rom.vhd \
../../../source/autofire/autofire.vhd \
../../../roms/stern_scramble/rom_pgm.vhd \
../../../roms/stern_scramble/rom_obj_0.vhd \
../../../roms/stern_scramble/rom_obj_1.vhd \
../../../roms/stern_scramble/rom_lut.vhd \
../../../roms/stern_scramble/rom_snd_0.vhd \
../../../roms/stern_scramble/rom_snd_1.vhd \
../../../roms/stern_scramble/rom_snd_2.vhd \
