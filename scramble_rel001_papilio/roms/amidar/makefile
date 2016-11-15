IMAGE=the_end.bin
SOURCE1=amidars.zip

all: $(IMAGE)

CONVERTER=../converter/make_vhdl_prom

$(CONVERTER): $(CONVERTER).c
	gcc -Os -lm $< -o $@

clean:
	rm -rf extract $(IMAGE) $(CONVERTER) *~

$(IMAGE): $(SOURCE1) $(CONVERTER)
	rm -rf extract
	mkdir extract
	cd extract; unzip ../$(SOURCE1)
	# game program rom
	cd extract; cat am2d am2e am2f am2h am2j am2l am2m am2p > $(IMAGE)
	./$(CONVERTER) extract/$(IMAGE) rom_pgm.vhd
	# place 2K char rom  at offset 0xD000..0xD7FF (dec 13*4   = 52K)
	#cd extract; dd if=2716.a5 of=../$(IMAGE) bs=1K seek=52 count=2 conv=sync
	./$(CONVERTER) extract/2716.a5 rom_obj_0.vhd
	# place 2K char rom  at offset 0xD800..0xDFFF (dec 13*4+2 = 54K)
	#cd extract; dd if=2716.a6 of=../$(IMAGE) bs=1K seek=54 count=2 conv=sync
	./$(CONVERTER) extract/2716.a6 rom_obj_1.vhd
	# place 2K audio rom at offset 0xE000..0xE7FF (dec 14*4   = 56K)
	#cd extract; dd if=amidarus.5c of=../$(IMAGE) bs=1K seek=56 count=2 conv=sync
	#./$(CONVERTER) extract/amidarus.5c rom_snd_0.vhd
	# place 2K audio rom at offset 0xE800..0xEFFF (dec 14*4+2 = 58K)
	#cd extract; dd if=amidarus.5d of=../$(IMAGE) bs=1K seek=58 count=2 conv=sync
	#./$(CONVERTER) extract/amidarus.5d rom_snd_1.vhd
	# place 2K audio rom at offset 0xF000..0xF7FF (dec 14*4+4 = 58K)
	# cd extract; dd if=amidarus.5d of=../$(IMAGE) bs=1K seek=60 count=2 conv=sync
	#./$(CONVERTER) extract/amidarus.5d rom_snd_2.vhd
	# place 32 byte color rom at offset 0xFF00, pad to 64K
	#cd extract; dd if=amidar.clr of=../$(IMAGE) bs=256 seek=255 count=2 conv=sync
	./$(CONVERTER) extract/amidar.clr rom_lut.vhd
