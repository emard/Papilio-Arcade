SOURCE1=gorkans.zip

IMAGE=pacman.bin

all: rom_pgm.vhd

clean:
	rm -rf $(IMAGE) $(CONVERTER) *.vhd *~

CONVERTER=../../../scramble_rel001_papilio/roms/converter/make_vhdl_prom

$(CONVERTER): $(CONVERTER).c
	gcc -Os -lm $< -o $@

rom_pgm.vhd: $(CONVERTER)
	rm -rf extract
	mkdir extract
	cd extract; unzip ../$(SOURCE1)
	# rm -f extract/readme.html
	# game program rom
	cd extract; cat gorkans1.rom gorkans2.rom gorkans3.rom gorkans4.rom gorkans5.rom gorkans6.rom gorkans7.rom gorkans8.rom  > ../$(IMAGE)
	./$(CONVERTER) $(IMAGE) rom_pgm.vhd
	# character rom
	cd extract; cat gorkgfx1.rom gorkgfx2.rom gorkgfx3.rom gorkgfx4.rom > ../$(IMAGE)
	./$(CONVERTER) $(IMAGE) gfx1.vhd
	# sound rom
	cd extract; cat gorkprom.1 gorkprom.2 > ../$(IMAGE)
	./$(CONVERTER) $(IMAGE) prom1_dst.vhd

	cd extract; cat gorkprom.3 > ../$(IMAGE)
	./$(CONVERTER) $(IMAGE) prom4_dst.vhd

	cd extract; cat gorkprom.4 > ../$(IMAGE)
	./$(CONVERTER) $(IMAGE) prom7_dst.vhd

	rm $(IMAGE)
