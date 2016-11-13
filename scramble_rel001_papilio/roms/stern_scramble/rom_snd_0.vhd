library ieee;
use ieee.std_logic_1164.all,ieee.numeric_std.all;

entity rom_snd_0 is
port (
	clk  : in  std_logic;
	ena  : in  std_logic;
	addr : in  std_logic_vector(10 downto 0);
	data : out std_logic_vector(7 downto 0)
);
end entity;

architecture prom of rom_snd_0 is
	type rom is array(0 to 2047) of std_logic_vector(7 downto 0);
	signal rom_data: rom := (
		x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
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
