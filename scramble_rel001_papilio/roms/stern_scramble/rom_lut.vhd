library ieee;
use ieee.std_logic_1164.all,ieee.numeric_std.all;

entity rom_lut is
port (
	clk  : in  std_logic;
	ena  : in  std_logic;
	addr : in  std_logic_vector(4 downto 0);
	data : out std_logic_vector(7 downto 0)
);
end entity;

architecture prom of rom_lut is
	type rom is array(0 to  31) of std_logic_vector(7 downto 0);
	signal rom_data: rom := (
		x"55",x"11",x"22",x"33",x"44",x"55",x"66",x"77",x"88",x"99",x"aa",x"bb",x"cc",x"dd",x"ee",x"ff",x"aa",x"11",x"22",x"33",x"44",x"55",x"66",x"77",x"88",x"99",x"aa",x"bb",x"cc",x"dd",x"ee",x"ff",
		others => x"00"
	);
begin
process(clk)
begin
	if rising_edge(clk) and ena='1' then
		data <= rom_data(to_integer(unsigned(addr)));
	end if;
end process;
end architecture;
