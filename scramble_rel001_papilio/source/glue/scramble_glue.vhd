---------------------------------------------------------------------------------
-- DE2-35 Top level for Phoenix by Dar (darfpga@aol.fr)
-- http://darfpga.blogspot.fr
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;

entity scramble_glue is
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
 clk_pixel    : in std_logic; -- 25 MHz for VGA
 reset        : in std_logic;

 osd_hex      : in std_logic_vector(63 downto 0) := (others => '0');

 dip_switch   : in std_logic_vector(7 downto 0);
 -- game controls, normal logic '1':pressed, '0':released
 btn_coin: in std_logic;
 btn_player_start: in std_logic_vector(1 downto 0);
 btn_fire, btn_left, btn_right, btn_barrier: in std_logic;

 vga_r, vga_g, vga_b: out std_logic_vector(3 downto 0);
 vga_hsync, vga_vsync, vga_blank, vga_vblank: out std_logic;

 o_audio_l, o_audio_r: out std_logic; -- audio PWM outputs
 audio_pcm: out std_logic_vector(11 downto 0)
);
end;

architecture struct of scramble_glue is
 signal reset_n: std_logic;

 signal hclk   : std_logic;
 signal hclk_n : std_logic;
 signal hclk_div: std_logic;
 signal hcnt: std_logic_vector(9 downto 1);
 signal vcnt: std_logic_vector(8 downto 1);
 signal sync   : std_logic;
 signal S_vga_blank, S_vga_vblank: std_logic;
 signal S_vga_vsync, S_vga_hsync: std_logic;
 signal S_vga_fetch_next: std_logic;
 signal S_osd_pixel: std_logic;
 signal S_osd_green: std_logic_vector(3 downto 0) := (others => '0');
 signal S_vga_r, S_vga_g, S_vga_b: std_logic_vector(3 downto 0);

 signal coin         : std_logic;
 signal player_start : std_logic_vector(1 downto 0);
 signal buttons      : std_logic_vector(3 downto 0);
 signal R_autofire   : std_logic_vector(21 downto 0);
 
 -- signals for the game itself
  -- this MUST be set true for frogger
  -- this MUST be set false for scramble, the_end, amidar
  constant I_HWSEL_FROGGER  : boolean := false;

  signal I_RESET_L        : std_logic;
  signal clk              : std_logic;
  signal ena_12           : std_logic;
  signal ena_6            : std_logic;
  signal ena_6b           : std_logic;
  signal ena_1_79         : std_logic;
  -- ip registers
  signal button_in        : std_logic_vector(7 downto 0);
  signal button_debounced : std_logic_vector(7 downto 0);
  signal ip_1p            : std_logic_vector(6 downto 0);
  signal ip_2p            : std_logic_vector(6 downto 0);
  signal ip_service       : std_logic;
  signal ip_coin1         : std_logic;
  signal ip_coin2         : std_logic;
  signal ip_dip_switch    : std_logic_vector(5 downto 1);

  -- video signals
  signal video_r          : std_logic_vector(3 downto 0);
  signal video_g          : std_logic_vector(3 downto 0);
  signal video_b          : std_logic_vector(3 downto 0);
  signal hsync            : std_logic;
  signal vsync            : std_logic;
  signal blank            : std_logic;
  -- scan doubler signals
  signal video_r_x2       : std_logic_vector(3 downto 0);
  signal video_g_x2       : std_logic_vector(3 downto 0);
  signal video_b_x2       : std_logic_vector(3 downto 0);
  signal hsync_x2         : std_logic;
  signal vsync_x2         : std_logic;
  -- registered video output signals
  signal R_video_r        : std_logic_vector(3 downto 0);
  signal R_video_g        : std_logic_vector(3 downto 0);
  signal R_video_b        : std_logic_vector(3 downto 0);
  signal R_hsync          : std_logic;
  signal R_vsync          : std_logic;
  signal R_blank          : std_logic;
  -- ties to audio board
  signal audio_addr       : std_logic_vector(15 downto 0);
  signal audio_data_out   : std_logic_vector(7 downto 0);
  signal audio_data_in    : std_logic_vector(7 downto 0);
  signal audio_data_oe_l  : std_logic;
  signal audio_rd_l       : std_logic;
  signal audio_wr_l       : std_logic;
  signal audio_iopc7      : std_logic;
  signal audio_reset_l    : std_logic;

  -- audio
  signal audio            : std_logic_vector(9 downto 0);
  signal audio_pwm        : std_logic;
  signal dbl_scan        : std_logic;
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
  u_clocks : entity work.scramble_clocks
    port map
    (
      I_CLK_25   => clk_pixel, -- 25 MHz
      I_RESET_L  => reset_n,
      --
      O_ENA_12   => ena_12,   -- 6.25 x 2
      O_ENA_6B   => ena_6b,   -- 6.25 (inverted)
      O_ENA_6    => ena_6,    -- 6.25
      O_ENA_1_79 => ena_1_79, -- 1.786
      O_CLK      => clk,
      O_RESET    => open
    );

  u_scramble : entity work.SCRAMBLE
    generic map (
      C_external_video_timing => false
    )
    port map (
      I_HWSEL_FROGGER       => I_HWSEL_FROGGER,
      --
      O_VIDEO_R             => video_r,
      O_VIDEO_G             => video_g,
      O_VIDEO_B             => video_b,
      O_HSYNC               => hsync,
      O_VSYNC               => vsync,
      O_BLANK               => blank,
      --
      -- to audio board
      --
      O_ADDR                => audio_addr,
      O_DATA                => audio_data_out,
      I_DATA                => audio_data_in,
      I_DATA_OE_L           => audio_data_oe_l,
      O_RD_L                => audio_rd_l,
      O_WR_L                => audio_wr_l,
      O_IOPC7               => audio_iopc7,
      O_RESET_WD_L          => audio_reset_l,
      --
      ENA                   => ena_6,
      ENAB                  => ena_6b,
      ENA_12                => ena_12,
      --
      RESET                 => reset,
      CLK                   => clk
      );

  u_scan_doubler : entity work.SCRAMBLE_DBLSCAN
    port map (
      I_R          => video_r,
      I_G          => video_g,
      I_B          => video_b,
      I_HSYNC      => hsync,
      I_VSYNC      => vsync,
      --
      O_R          => video_r_x2,
      O_G          => video_g_x2,
      O_B          => video_b_x2,
      O_HSYNC      => hsync_x2,
      O_VSYNC      => vsync_x2,
      --
      ENA_X2       => ena_12,
      ENA          => ena_6,
      CLK          => clk
      );

  p_video_output : process
  begin
    wait until rising_edge(clk);
      R_VIDEO_R(3 downto 0) <= video_r_x2;
      R_VIDEO_G(3 downto 0) <= video_g_x2;
      R_VIDEO_B(3 downto 0) <= video_b_x2;
      R_HSYNC   <= hsync_x2;
      R_VSYNC   <= vsync_x2;
      R_BLANK   <= blank; -- may need fixing
  end process;
  --
  --
  -- audio subsystem
  --
  u_audio : entity work.SCRAMBLE_AUDIO
    port map (
      I_HWSEL_FROGGER    => I_HWSEL_FROGGER,
      --
      I_ADDR             => audio_addr,
      I_DATA             => audio_data_out,
      O_DATA             => audio_data_in,
      O_DATA_OE_L        => audio_data_oe_l,
      --
      I_RD_L             => audio_rd_l,
      I_WR_L             => audio_wr_l,
      I_IOPC7            => audio_iopc7,
      --
      O_AUDIO            => audio,
      --
      I_1P_CTRL          => ip_1p, -- start, shoot1, shoot2, left,right,up,down
      I_2P_CTRL          => ip_2p, -- start, shoot1, shoot2, left,right,up,down
      I_SERVICE          => ip_service,
      I_COIN1            => ip_coin1,
      I_COIN2            => ip_coin2,
      O_COIN_COUNTER     => open,
      --
      I_DIP              => ip_dip_switch,
      --
      I_RESET_L          => audio_reset_l,
      ENA                => ena_6,
      ENA_1_79           => ena_1_79,
      CLK                => clk
      );

  --
  -- Audio DAC
  --
  u_dac : entity work.dac
    generic map(
      msbi_g => 9
    )
    port  map(
      clk_i   => clk_pixel,
      res_n_i => I_RESET_L,
      dac_i   => audio,
      dac_o   => audio_pwm
    );
  O_AUDIO_L <= audio_pwm;
  O_AUDIO_R <= audio_pwm;

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
      beam_y(8 downto 1) => vcnt,
      beam_y(0 downto 0) => open,
      vga_r(7 downto 4) => S_vga_r, vga_r(3 downto 0) => open,
      vga_g(7 downto 4) => S_vga_g, vga_g(3 downto 0) => open,
      vga_b(7 downto 4) => S_vga_b, vga_b(3 downto 0) => open,
      vga_hsync => S_vga_hsync,
      vga_vsync => S_vga_vsync,
      vga_blank => S_vga_blank, -- '1' when outside of horizontal or vertical graphics area
      vga_vblank => S_vga_vblank -- '1' when outside of vertical graphics area (used for vblank interrupt)
  );

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
    vga_r      <= S_vga_r;
    vga_g      <= S_vga_g or S_osd_green;
    vga_b      <= S_vga_b;
    vga_hsync  <= S_vga_hsync;
    vga_vsync  <= S_vga_vsync;
    vga_blank  <= S_vga_blank;
    vga_vblank <= S_vga_vblank;
  end generate;
  G_no_test_picture: if not C_test_picture generate
    -- normal game picture
    vga_r      <= R_VIDEO_R;
    vga_g      <= R_VIDEO_G;
    vga_b      <= R_VIDEO_B;
    vga_hsync  <= R_HSYNC;
    vga_vsync  <= R_VSYNC;
    vga_blank  <= R_BLANK;
    --vga_vblank <= S_vga_vblank;
  end generate;
end generate;

end struct;
