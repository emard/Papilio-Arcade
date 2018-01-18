IMAGE=frogger.bin
SOURCE1=froggers2.zip

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
	# game program rom
	cd extract; cat epr-1012.ic5 epr-1013a.ic6 epr-1014.ic7 epr-1015.ic8 > $(IMAGE)
	./$(CONVERTER) extract/$(IMAGE) rom_pgm.vhd
	# place 2K char rom  at offset 0xD000..0xD7FF (dec 13*4   = 52K)
	#cd extract; dd if=5h of=../$(IMAGE) bs=1K seek=52 count=2 conv=sync
	./$(CONVERTER) extract/epr-606.ic102 rom_obj_0.vhd
	# place 2K char rom  at offset 0xD800..0xDFFF (dec 13*4+2 = 54K)
	#cd extract; dd if=5f of=../$(IMAGE) bs=1K seek=54 count=2 conv=sync
	./$(CONVERTER) extract/epr-607.ic101 rom_obj_1.vhd
	# place 2K audio rom at offset 0xE000..0xE7FF (dec 14*4   = 56K)
	#cd extract; dd if=ot1.5c of=../$(IMAGE) bs=1K seek=56 count=2 conv=sync
	./$(CONVERTER) extract/epr-608.ic32 rom_snd_0.vhd
	# place 2K audio rom at offset 0xE800..0xEFFF (dec 14*4+2 = 58K)
	#cd extract; dd if=ot2.5d of=../$(IMAGE) bs=1K seek=58 count=2 conv=sync
	./$(CONVERTER) extract/epr-609.ic33 rom_snd_1.vhd
	# place 2K audio rom at offset 0xF000..0xF7FF (dec 14*4+4 = 58K)
	#cd extract; dd if=ot3.5e of=../$(IMAGE) bs=1K seek=60 count=2 conv=sync
	./$(CONVERTER) extract/epr-610.ic34 rom_snd_2.vhd
	# place 32 byte color rom at offset 0xFF00, pad to 64K
	#cd extract; dd if=c01s.6e of=../$(IMAGE) bs=256 seek=255 count=2 conv=sync
	./$(CONVERTER) c01s.6e rom_lut.vhd
