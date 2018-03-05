IMAGE=pacman.bin
#SOURCE1=scramble.zip
#SOURCE2=scrambles.zip

all: rom_pgm.vhd

clean:
	rm -rf $(IMAGE) $(CONVERTER) *.vhd *~

CONVERTER=../../../scramble_rel001_papilio/roms/converter/make_vhdl_prom

$(CONVERTER): $(CONVERTER).c
	gcc -Os -lm $< -o $@

rom_pgm.vhd: $(CONVERTER)
	#rm -rf extract
	#mkdir extract
	#cd extract; unzip ../$(SOURCE1)
	#rm -f extract/readme.html
	#cd extract; unzip ../$(SOURCE2)
	# game program rom
	#cd extract; cat 2d 2e 2f 2h 2j 2l 2m 2p > $(IMAGE)
	cat pacman.6e pacman.6f pacman.6h pacman.6j > $(IMAGE)
	./$(CONVERTER) $(IMAGE) rom_pgm.vhd
	# character rom
	cat pacman.5e pacman.5f > $(IMAGE)
	./$(CONVERTER) $(IMAGE) gfx1.vhd
	# sound rom
	cat pacman.4a pacman.4a > $(IMAGE)
	./$(CONVERTER) $(IMAGE) prom1_dst.vhd
	./$(CONVERTER) pacman.4a prom4_dst.vhd
	./$(CONVERTER) pacman.7f prom7_dst.vhd
	rm $(IMAGE)
