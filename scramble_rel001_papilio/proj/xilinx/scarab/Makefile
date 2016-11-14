project = miniSpartan6-plus
vendor = xilinx
family = spartan6
MODEL ?= xc6slx25
part = ${MODEL}-ftg256-3 # last number -3 is speed grade
flashsize = 8192 # KB (kilobytes) - SPI flash device is M25P40
top_module = hdmiaudio_scarab
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

vhdfiles = \
top/hdmiaudio_scarab.vhd \
clocks/clk_50M_100M_125Mp_125Mn_25M.vhd \
../../../source/osd/osd.vhd \
../../../source/osd/char_rom.vhd \
../../../source/vga/vga.vhd \
../../../source/vga/hdmi-audio/av_hdmi.vhd \
../../../source/vga/hdmi-audio/encoder.vhd \
../../../source/vga/hdmi-audio/hdmidelay.vhd \
../../../source/vga/hdmi-audio/serializer_generic.vhd \
../../../source/vga/xilinx/xc6/ddr_out.vhd \
../../../source/vga/xilinx/xc6/hdmi_out_xc6.vhd \

