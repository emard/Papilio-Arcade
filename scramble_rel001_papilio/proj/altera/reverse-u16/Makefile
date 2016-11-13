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
joystick/joystick_saitek_cyborg_rumble.vhd \
../../../source/glue/scramble.vhd \
../../../source/T80/T80_ALU.vhd \
../../../source/T80/T80_MCode.vhd \
../../../source/T80/T80_Pack.vhd \
../../../source/T80/T80_Reg.vhd \
../../../source/T80/T80.vhd \
../../../source/T80/T80s.vhd \
../../../source/T80/T8080se.vhd \
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

#../../../tools/phoenix_unzip/roms/phoenix_prog.vhd \
#../../../tools/phoenix_unzip/roms/prom_ic23.vhd \
#../../../tools/phoenix_unzip/roms/prom_ic24.vhd \
#../../../tools/phoenix_unzip/roms/prom_ic39.vhd \
#../../../tools/phoenix_unzip/roms/prom_ic40.vhd \
#../../../tools/phoenix_unzip/roms/prom_palette_ic40.vhd \
#../../../tools/phoenix_unzip/roms/prom_palette_ic41.vhd \

#../../../rtl_dar/gen_ram.vhd \
#../../../rtl_dar/io_ps2_keyboard.vhd \
#../../../rtl_dar/kbd_joystick.vhd \
#../../../rtl_dar/phoenix_effect1.vhd \
#../../../rtl_dar/phoenix_effect2.vhd \
#../../../rtl_dar/phoenix_effect3.vhd \
#../../../rtl_dar/phoenix_music.vhd \
#../../../rtl_dar/phoenix_video.vhd \
#../../../rtl_dar/wm8731_dac.vhd \
