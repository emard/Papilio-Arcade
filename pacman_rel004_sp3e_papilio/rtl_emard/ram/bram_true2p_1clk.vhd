-- Generated by Quartus II Template

-- File->New File->VHDL File
-- Edit->Insert Template->VHDL->Full designs->RAMs and ROMs->True dual port RAM (singled clock)

-- True Dual-Port RAM with single clock

-- when pass_thru enabled on port
-- then Read-during-write on port should return newly written data

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity bram_true2p_1clk is
	generic 
	(
		dual_port: boolean := True; -- set to False for single port A
		pass_thru_a, pass_thru_b: boolean := True;
		data_width: natural := 8;
		addr_width: natural := 6
	);
	port 
	(
		clk: in std_logic;
		addr_a: in std_logic_vector((addr_width-1) downto 0);
		addr_b: in std_logic_vector((addr_width-1) downto 0) := (others => '-');
		we_a: in std_logic := '0';
		we_b: in std_logic := '0';
		data_in_a: in std_logic_vector((data_width-1) downto 0);
		data_in_b: in std_logic_vector((data_width-1) downto 0) := (others => '-');
		data_out_a: out std_logic_vector((data_width -1) downto 0);
		data_out_b: out std_logic_vector((data_width -1) downto 0)
	);
end;

architecture rtl of bram_true2p_1clk is
	-- Build a 2-D array type for the RAM
	subtype word_t is std_logic_vector((data_width-1) downto 0);
	type memory_t is array(2**addr_width-1 downto 0) of word_t;

	-- Declare the RAM 
	shared variable ram: memory_t;
begin
	-- Port A
	G_port_a_passthru: if pass_thru_a generate
	process(clk)
	begin
	if(rising_edge(clk)) then 
	    if(we_a = '1') then
		ram(conv_integer(addr_a)) := data_in_a;
	    end if;
	    data_out_a <= ram(conv_integer(addr_a));
	end if;
	end process;
	end generate;

	G_port_a_not_passthru: if not pass_thru_a generate
	process(clk)
	begin
	if(rising_edge(clk)) then 
	    data_out_a <= ram(conv_integer(addr_a));
	    if(we_a = '1') then
		ram(conv_integer(addr_a)) := data_in_a;
	    end if;
	end if;
	end process;
	end generate;

	-- Port B 
	G_port_b_passthru: if dual_port and pass_thru_b generate
	process(clk)
	begin
	if(rising_edge(clk)) then 
	    if(we_b = '1') then
		ram(conv_integer(addr_b)) := data_in_b;
	    end if;
	    data_out_b <= ram(conv_integer(addr_b));
	end if;
	end process;
	end generate;

	G_port_b_not_passthru: if dual_port and not pass_thru_b generate
	process(clk)
	begin
	if(rising_edge(clk)) then 
	    data_out_b <= ram(conv_integer(addr_b));
	    if(we_b = '1') then
		ram(conv_integer(addr_b)) := data_in_b;
	    end if;
	end if;
	end process;
	end generate;
end rtl;
