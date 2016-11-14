# Scarab Scramble

It doesn't work. On the screen there are numbers 00000...
nothing changes, no self-test initial screen.

CPU accesses large amount of ROM address address
centered around 0x2000.
Data bus traffic doesn't change much, it mostly
reads 0xFF and writes 0x0x (last digit changes)
