SOURCE1=lizwiz.zip

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
	cd extract; cat 6e.cpu 6f.cpu 6h.cpu 6j.cpu wiza wizb > ../$(IMAGE)
	./$(CONVERTER) $(IMAGE) rom_pgm.vhd
	# character rom
	cd extract; cat 5e.cpu 5f.cpu > ../$(IMAGE)
	./$(CONVERTER) $(IMAGE) gfx1.vhd
	# sound rom
	cd extract; cat 82s126.1m 82s126.3m > ../$(IMAGE)
	./$(CONVERTER) $(IMAGE) prom1_dst.vhd

	cd extract; cat 4a.cpu > ../$(IMAGE)
	./$(CONVERTER) $(IMAGE) prom4_dst.vhd

	cd extract; cat 7f.cpu > ../$(IMAGE)
	./$(CONVERTER) $(IMAGE) prom7_dst.vhd

	rm $(IMAGE)
