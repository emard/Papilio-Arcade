---------------------------------------------------------------------------------
-- DE2-35 Top level for Phoenix by Dar (darfpga@aol.fr)
-- http://darfpga.blogspot.fr
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;

entity scramble is
generic
(
  C_test_picture: boolean := false;
  -- reduce ROMs: 14 is normal game, 13 will draw initial screen, 12 will repeatedly blink 1 line of garbage
  C_autofire: boolean := false;
  C_audio: boolean := true;
  C_prog_rom_addr_bits: integer range 12 to 14 := 14; -- allow ROM size reduction for small boards
  C_osd: boolean := false;
  C_vga: boolean := true
);
port
(
 clk_pixel    : in std_logic; -- 11 MHz for TV, 25 MHz for VGA
 reset        : in std_logic;

 osd_hex      : in std_logic_vector(63 downto 0) := (others => '0');

 dip_switch   : in std_logic_vector(7 downto 0);
 -- game controls, normal logic '1':pressed, '0':released
 btn_coin: in std_logic;
 btn_player_start: in std_logic_vector(1 downto 0);
 btn_fire, btn_left, btn_right, btn_barrier: in std_logic;

 vga_r, vga_g, vga_b: out std_logic_vector(1 downto 0);
 vga_hsync, vga_vsync, vga_blank, vga_vblank: out std_logic;

 audio        : out std_logic_vector(11 downto 0)
);
end;

architecture struct of scramble is

 signal reset_n: std_logic;

 signal hclk   : std_logic;
 signal hclk_n : std_logic;
 signal hclk_div: std_logic;
 signal hcnt, S_hcnt   : std_logic_vector(9 downto 1);
 signal vcnt   : std_logic_vector(8 downto 1);
 signal S_vcnt: std_logic_vector(9 downto 1);
 signal sync   : std_logic;
 signal vblank       : std_logic;
 signal hblank_bkgrd : std_logic;
 signal hblank_frgrd : std_logic; 
 signal S_vga_blank, S_vga_vblank: std_logic;
 signal S_vga_vsync, S_vga_hsync: std_logic;
 signal S_vga_fetch_next: std_logic;
 signal S_osd_pixel: std_logic;
 signal S_osd_green: std_logic_vector(1 downto 0) := (others => '0');
 signal S_vga_r, S_vga_g, S_vga_b: std_logic_vector(1 downto 0);

 signal coin         : std_logic;
 signal player_start : std_logic_vector(1 downto 0);
 signal buttons      : std_logic_vector(3 downto 0);
 signal R_autofire   : std_logic_vector(21 downto 0);
begin

-- game core uses inverted control logic
coin <= not btn_coin; -- insert coin
player_start <= not btn_player_start; -- select 1 or 2 players
buttons(1) <= not btn_right; -- Right
buttons(2) <= not btn_left; -- Left
buttons(3) <= not btn_barrier; -- Protection 

G_not_autofire: if not C_autofire generate
  buttons(0) <= not btn_fire; -- Fire
end generate;

G_yes_autofire: if C_autofire generate
  process(clk_pixel)
  begin
    if rising_edge(clk_pixel) then
      if btn_fire='1' then
        R_autofire <= R_autofire-1;
      else
        R_autofire <= (others => '0');
      end if;
    end if;
  end process;
  buttons(0) <= not R_autofire(R_autofire'high);
end generate;

G_vga: if C_vga generate
  --G_tv_vga_helper:
  --entity work.phoenix_video_vga
  --port map
  --(
  --  clk11    => clk_pixel,
  --  hcnt     => hcnt,
  --  vcnt     => S_vcnt,
  --  sync     => sync,
  --  vsync    => video_vs,
  --  hsync    => video_hs,
  --  vblank   => vblank,
  --  hblank_frgrd => hblank_frgrd,
  --  hblank_bkgrd => hblank_bkgrd,
  --  reset    => reset
  --);
  reset_n <= not reset;

  process(clk_pixel)
  begin
    if rising_edge(clk_pixel) then
      hclk <= not hclk;
      hclk_n <= not hclk;
    end if;
  end process;

  -- VGA video generator - pixel clock synchronous
  vgabitmap: entity work.vga
  --generic map -- workaround for wrong video size
  --(
  --  C_resolution_x => 638,
  --  C_hsync_front_porch => 18
  --)
  port map
  (
      clk_pixel => clk_pixel,
      test_picture => '1', -- shows test picture when VGA is disabled (on startup)
      fetch_next => S_vga_fetch_next,
      line_repeat => open,
      red_byte    => (others => '0'), -- framebuffer inputs not used
      green_byte  => (others => '0'), -- rgb signal is synchronously generated
      blue_byte   => (others => '0'), -- and replaced
      beam_x(9 downto 1) => hcnt,
      beam_x(0 downto 0) => open,
      beam_y(9 downto 9) => open,
      beam_y(8 downto 0) => S_vcnt,
      vga_r(7 downto 6) => S_vga_r, vga_r(5 downto 0) => open,
      vga_g(7 downto 6) => S_vga_g, vga_g(5 downto 0) => open,
      vga_b(7 downto 6) => S_vga_b, vga_b(5 downto 0) => open,
      vga_hsync => S_vga_hsync,
      vga_vsync => S_vga_vsync,
      vga_blank => S_vga_blank, -- '1' when outside of horizontal or vertical graphics area
      vga_vblank => S_vga_vblank -- '1' when outside of vertical graphics area (used for vblank interrupt)
  );
  vga_hsync <= S_vga_hsync;
  vga_vsync <= S_vga_vsync;
  vcnt <= S_vcnt(8 downto 1);

  -- OSD overlay for the green channel
  G_osd: if C_osd generate
  I_osd: entity work.osd
  --generic map -- workaround for wrong video size
  --(
  --  C_resolution_x => C_resolution_x
  --)
  port map
  (
    clk_pixel => clk_pixel,
    vsync => S_vga_vsync,
    fetch_next => S_vga_fetch_next,
    probe_in(63 downto 0) => osd_hex(63 downto 0),
    osd_out => S_osd_pixel
  );
  S_osd_green <= (others => S_osd_pixel);
  end generate;

  G_yes_test_picture: if C_test_picture generate
    -- only test picture, no game
    vga_r     <= S_vga_r;
    vga_g     <= S_vga_g or S_osd_green;
    vga_b     <= S_vga_b;
  end generate;
  G_no_test_picture: if not C_test_picture generate
    -- normal game picture
    --vga_r     <= rgb_1(0) & rgb_0(0);
    --vga_g     <= (rgb_1(2) & rgb_0(2)) or S_osd_green;
    --vga_b     <= rgb_1(1) & rgb_0(1);
  end generate;
  vga_blank <= S_vga_blank;
  vga_vblank <= S_vga_vblank;
end generate;

end struct;
