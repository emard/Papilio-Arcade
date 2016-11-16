IMAGE=scramble.bin
SOURCE1=scramble.zip
SOURCE2=scrambles.zip

all: $(IMAGE)

clean:
	rm -rf extract $(IMAGE) $(CONVERTER) *~

CONVERTER=../converter/make_vhdl_prom

$(CONVERTER): $(CONVERTER).c
	gcc -Os -lm $< -o $@

$(IMAGE): $(SOURCE1) $(CONVERTER)
	rm -rf extract
	mkdir extract
	cd extract; unzip ../$(SOURCE1)
	rm -f extract/readme.html
	cd extract; unzip ../$(SOURCE2)
	# game program rom
	cd extract; cat 2d 2e 2f 2h 2j 2l 2m 2p > $(IMAGE)
	./$(CONVERTER) extract/$(IMAGE) rom_pgm.vhd
	# place 2K char rom  at offset 0xD000..0xD7FF (dec 13*4   = 52K)
	#cd extract; dd if=5h of=../$(IMAGE) bs=1K seek=52 count=2 conv=sync
	./$(CONVERTER) extract/5h rom_obj_0.vhd
	# place 2K char rom  at offset 0xD800..0xDFFF (dec 13*4+2 = 54K)
	#cd extract; dd if=5f of=../$(IMAGE) bs=1K seek=54 count=2 conv=sync
	./$(CONVERTER) extract/5f rom_obj_1.vhd
	# place 2K audio rom at offset 0xE000..0xE7FF (dec 14*4   = 56K)
	#cd extract; dd if=ot1.5c of=../$(IMAGE) bs=1K seek=56 count=2 conv=sync
	./$(CONVERTER) extract/ot1.5c rom_snd_0.vhd
	# place 2K audio rom at offset 0xE800..0xEFFF (dec 14*4+2 = 58K)
	#cd extract; dd if=ot2.5d of=../$(IMAGE) bs=1K seek=58 count=2 conv=sync
	./$(CONVERTER) extract/ot2.5d rom_snd_1.vhd
	# place 2K audio rom at offset 0xF000..0xF7FF (dec 14*4+4 = 58K)
	#cd extract; dd if=ot3.5e of=../$(IMAGE) bs=1K seek=60 count=2 conv=sync
	./$(CONVERTER) extract/ot3.5e rom_snd_2.vhd
	# place 32 byte color rom at offset 0xFF00, pad to 64K
	#cd extract; dd if=c01s.6e of=../$(IMAGE) bs=256 seek=255 count=2 conv=sync
	./$(CONVERTER) extract/c01s.6e rom_lut.vhd
