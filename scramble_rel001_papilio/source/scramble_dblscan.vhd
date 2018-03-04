--
-- A simulation model of Scramble hardware
-- Copyright (c) MikeJ - Feb 2007
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS CODE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- You are responsible for any legal issues arising from your use of this code.
--
-- The latest version of this file can be found at: www.fpgaarcade.com
--
-- Email support@fpgaarcade.com
--
-- Revision list
--
-- version 001 initial release
--

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.std_logic_arith.all;

entity SCRAMBLE_DBLSCAN is
  port (
	I_R               : in    std_logic_vector( 3 downto 0);
	I_G               : in    std_logic_vector( 3 downto 0);
	I_B               : in    std_logic_vector( 3 downto 0);
	I_HSYNC           : in    std_logic;
	I_VSYNC           : in    std_logic;

	O_R               : out   std_logic_vector( 3 downto 0);
	O_G               : out   std_logic_vector( 3 downto 0);
	O_B               : out   std_logic_vector( 3 downto 0);
	O_HSYNC           : out   std_logic;
	O_VSYNC           : out   std_logic;
	O_BLANK           : out   std_logic;

	ENA_X2            : in    std_logic;
	ENA               : in    std_logic;
	CLK               : in    std_logic
	);
end;

architecture RTL of SCRAMBLE_DBLSCAN is
  constant xsize: integer range 256 to 320 := 256; -- blank: HDMI picture size is 2x this value
  constant ysize: integer range 224 to 240 := 226; -- blank: HDMI picture size is 2x this value
  -- x/y center (shifts blank signal relative to rising edge of hsync/vsync signals)
  constant xcenter: integer := 87; -- increase -> picture moves left
  constant ycenter: integer := 29; -- increase -> picture moves up
  -- sync pulse width
  constant hsync_width: integer range 0 to xcenter := 15;
  constant vsync_width: integer range 0 to ycenter := 14;

  signal ram_ena_x2  : std_logic;
  signal ram_ena     : std_logic;
  --
  -- input timing
  --
  signal hsync_in_t1 : std_logic;
  signal vsync_in_t1 : std_logic;
  signal hpos_i      : std_logic_vector(8 downto 0) := (others => '0');    -- input capture postion
  signal hsize_i     : std_logic_vector(8 downto 0);
  signal bank_i      : std_logic;
  signal rgb_in      : std_logic_vector(15 downto 0);
  --
  -- output timing
  --
  signal hpos_o      : std_logic_vector(8 downto 0) := (others => '0');
  signal vpos_o      : std_logic_vector(8 downto 0) := (others => '0');
  signal ohs         : std_logic;
  signal ohs_t1      : std_logic;
  signal ovs         : std_logic;
  signal ovs_t1      : std_logic;
  signal bank_o      : std_logic;
  --
  --signal vs_cnt      : std_logic_vector(3 downto 0);
  signal rgb_out     : std_logic_vector(15 downto 0);
  
  signal vblank, hblank : std_logic;

  signal i_rising_h, i_rising_v, o_rising_h, o_rising_v: boolean;
begin

  i_rising_h <= (I_HSYNC = '1') and (hsync_in_t1 = '0');
  i_rising_v <= (I_VSYNC = '1') and (vsync_in_t1 = '0');

  p_input_timing : process
  begin
	wait until rising_edge (CLK);
	if (ENA = '1') then
	  hsync_in_t1 <= I_HSYNC;
	  vsync_in_t1 <= I_VSYNC;

	  if i_rising_v then
		bank_i <= '0';
	  elsif i_rising_h then
		bank_i <= not bank_i;
	  end if;

	  if i_rising_h then
		hpos_i <= (others => '0');
		hsize_i  <= hpos_i;
	  else
		hpos_i <= hpos_i + "1";
	  end if;
	end if;
  end process;

  rgb_in <= "0000" & I_B & I_G & I_R;

  u_ram: entity work.bram_true2p_1clk
    generic map
    (
      data_width => rgb_in'length,
      addr_width => 10
    )
    port map
    (
      clk                => CLK,
      -- write side, (delayed 1 clock)
      data_in_a          => rgb_in,
      data_out_a         => open,
      addr_a(9)          => bank_i,
      addr_a(8 downto 0) => hpos_i(8 downto 0),
      we_a               => ENA,
      -- read side
      data_in_b          => (others => '0'),
      data_out_b         => rgb_out,
      addr_b(9)          => bank_o,
      addr_b(8 downto 0) => hpos_o(8 downto 0),
      we_b               => '0'
    );

  o_rising_h <= (ohs = '1') and (ohs_t1 = '0');
  o_rising_v <= (ovs = '1') and (ovs_t1 = '0');

  p_output_timing : process
  begin
	wait until rising_edge (CLK);
	if  (ENA_X2 = '1') then

	  if o_rising_h or (hpos_o = hsize_i) then
		hpos_o <= (others => '0');
	  else
		hpos_o <= hpos_o + "1";
	  end if;

	  if o_rising_v then -- rising_v
		bank_o <= '1';
		vpos_o <= (others => '0');
	  elsif o_rising_h then
		bank_o <= not bank_o;
		vpos_o <= vpos_o + "1";
	  end if;

	  ohs <= I_HSYNC; -- reg on clk_12
	  ohs_t1 <= ohs;

	  ovs <= I_VSYNC; -- reg on clk_12
	  ovs_t1 <= ovs;
	end if;
  end process;

  p_op : process
  begin
	wait until rising_edge (CLK);
	if (ENA_X2 = '1') then
	  if hpos_o = conv_std_logic_vector(0,9) then
	    O_HSYNC <= '1';
	  elsif hpos_o = conv_std_logic_vector(hsync_width,9) then
	    O_HSYNC <= '0';
	  end if;

	  if hpos_o = conv_std_logic_vector(xcenter,9) then
	    hblank <= '0';
	  elsif hpos_o = conv_std_logic_vector(xcenter+xsize,9) then
	    hblank <= '1';
	  end if;

	  if vpos_o = conv_std_logic_vector(0,9) then
	    O_VSYNC <= '1';
	  elsif vpos_o = conv_std_logic_vector(vsync_width,9) then
	    O_VSYNC <= '0';
	  end if;

	  if vpos_o = conv_std_logic_vector(ycenter,9) then
	    vblank <= '0';
	  elsif vpos_o = conv_std_logic_vector(ycenter+ysize,9) then
	    vblank <= '1';
	  end if;
	  
	  O_BLANK <= hblank or vblank;

	  O_B <= rgb_out(11 downto 8);
	  O_G <= rgb_out(7 downto 4);
	  O_R <= rgb_out(3 downto 0);
	end if;
  end process;

end architecture RTL;

