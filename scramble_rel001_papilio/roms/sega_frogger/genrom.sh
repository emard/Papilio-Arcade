#!/bin/sh
rm -rf extract
mkdir extract
cd extract
unzip ../froggers2.zip
# game program rom 12K, 2d-2p start from address 0x0000
cat epr-1012.ic5 epr-1013a.ic6 epr-1014.ic7 epr-1015.ic8 > frogger.bin
#../convbin2latticehex.sh frogger.bin rom_pgm.mem
# zero pad to 64K (not needed)
# dd if=rom_pgm.bin of=scramble.bin ibs=64K obs=64K count=1 conv=sync
# place 2K char rom  at offset 0xD000..0xD7FF (dec 13*4   = 52K)
dd if=epr-606.ic102 of=frogger.bin bs=1K seek=52 count=2 conv=sync
# place 2K char rom  at offset 0xD800..0xDFFF (dec 13*4+2 = 54K)
dd if=epr-607.ic101 of=frogger.bin bs=1K seek=54 count=2 conv=sync
# place 2K audio rom at offset 0xE000..0xE7FF (dec 14*4   = 56K)
dd if=epr-608.ic32 of=frogger.bin bs=1K seek=56 count=2 conv=sync
# place 2K audio rom at offset 0xE800..0xEFFF (dec 14*4+2 = 58K)
dd if=epr-609.ic33 of=frogger.bin bs=1K seek=58 count=2 conv=sync
# place 2K audio rom at offset 0xF000..0xF7FF (dec 14*4+4 = 58K)
dd if=epr-610.ic34 of=frogger.bin bs=1K seek=60 count=2 conv=sync
# zero-padding ROM file for ulx2s_4m.img flash
# dd if=frogger.bin of=ulx2s_4m.img ibs=4M obs=4M count=1 conv=sync
# video object 0 rom ic31
#../convbin2latticehex.sh ic31_1c.bin rom_obj_0.mem
# video object 1 rom ic30
#../convbin2latticehex.sh ic30_2c.bin rom_obj_1.mem
# sound rom 0-1-2 rom ic55 ic56 ic56
#../convbin2latticehex.sh ic55_2.bin rom_snd_0.mem
#../convbin2latticehex.sh ic56_1.bin rom_snd_1.mem
#../convbin2latticehex.sh ic56_1.bin rom_snd_2.mem
# color rom 6e
../convbin2vhex.sh pr-91.6l  rom_lut.vhex
