---------------------------------------------------------------------------------
-- ULX3S toplevel for scramble
--
-- Main features
--  NO board SDRAM used
--
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;

library ecp5u;
use ecp5u.components.all;

entity scramble_ulx3s is
generic
(
  C_hdmi_generic_serializer: boolean := false; -- serializer type: false: vendor-specific, true: generic=vendor-agnostic
  C_hdmi_audio: boolean := false -- HDMI generator type: false: video only, true: video+audio capable
);
port
(
  clk_25MHz: in std_logic;

  -- UART1 (WiFi serial)
  wifi_rxd: out   std_logic;
  wifi_txd: in    std_logic;
  -- WiFi additional signaling
  wifi_en: inout  std_logic := 'Z'; -- '0' will disable wifi by default
  wifi_gpio0, wifi_gpio2, wifi_gpio16, wifi_gpio17: inout std_logic := 'Z';

  -- Onboard blinky
  led: out std_logic_vector(7 downto 0);
  btn: in std_logic_vector(6 downto 0);
  sw: in std_logic_vector(3 downto 0);
  oled_csn, oled_clk, oled_mosi, oled_dc, oled_resn: out std_logic;

  -- GPIO
  gp, gn: inout std_logic_vector(27 downto 0);

  -- SHUTDOWN: logic '1' here will shutdown power on PCB >= v1.7.5
  shutdown: out std_logic := '0';

  -- Audio jack 3.5mm
  audio_l, audio_r, audio_v: inout std_logic_vector(3 downto 0) := (others => 'Z');

  -- for vendor-specific serializer
  --hdmi_d0, hdmi_d1, hdmi_d2: out std_logic;
  --hdmi_clk: out std_logic

  -- Digital Video (differential outputs)
  gpdi_dp, gpdi_dn: out std_logic_vector(2 downto 0);
  gpdi_clkp, gpdi_clkn: out std_logic;

  -- i2c shared for digital video and RTC
  gpdi_scl, gpdi_sda: inout std_logic

);
end;

architecture struct of scramble_ulx3s is
  signal clk_pixel, clk_pixel_shift, clkn_pixel_shift: std_logic;

  signal S_joy_coin: std_logic;
  signal S_joy_player: std_logic_vector(1 downto 0);
  signal S_joy_up, S_joy_down, S_joy_left, S_joy_right, S_joy_bomb, S_joy_fire: std_logic;
  signal S_joy_reset: std_logic;
  signal S_auto_bomb, S_auto_fire: std_logic;
  
  signal S_osd_hex: std_logic_vector(63 downto 0);

  signal S_audio: std_logic_vector(11 downto 0);
  signal S_audio_enable: std_logic;
  signal S_audio_pcm: std_logic_vector(15 downto 0) := (others => '0');
  
  signal dvid_red, dvid_green, dvid_blue, dvid_clock: std_logic_vector(1 downto 0);
  signal S_hdmi_pd0, S_hdmi_pd1, S_hdmi_pd2: std_logic_vector(9 downto 0);
  signal tmds_d: std_logic_vector(3 downto 0);
  signal tx_in: std_logic_vector(29 downto 0);

  signal ddr_d: std_logic_vector(2 downto 0);
  signal ddr_clk: std_logic;

  signal S_vga_r, S_vga_g, S_vga_b: std_logic_vector(3 downto 0);
  signal S_vga_r8, S_vga_g8, S_vga_b8: std_logic_vector(7 downto 0);
  signal S_vga_vsync, S_vga_hsync: std_logic;
  signal S_vga_vblank, S_vga_blank: std_logic;

  signal reset        : std_logic;
  signal clock_stable : std_logic := '1';
  signal dip_switch   : std_logic_vector(7 downto 0) := (others => '0');
begin
  G_ddr: if true generate
    clkgen_125_25: entity work.clk_25_100_125_25
    port map
    (
      clki => clk_25MHz,         --  25 MHz input from board
      clkop => clk_pixel_shift,  -- 125 MHz
      clkos => clkn_pixel_shift, -- 125 MHz inverted
      clkos2 => clk_pixel,       --  25 MHz
      clkos3 => open             -- 100 MHz
    );
  end generate;

  reset <= S_joy_reset or not clock_stable;

  wifi_gpio0 <= btn(0); -- pressing BTN0 will escape to ESP32 file select menu

  S_joy_reset <= '0';
  S_audio_enable <= '0';
  
  S_joy_coin <= btn(1);
  S_joy_player <= btn(6 downto 5);
  
  S_joy_bomb <= btn(1);
  S_joy_fire <= btn(2);
  S_joy_up <= btn(3);
  S_joy_down <= btn(4);
  S_joy_left <= btn(5);
  S_joy_right <= btn(6);
  
  S_osd_hex(6 downto 0) <= btn;
  
  I_autofire : entity work.autofire
  generic map
  (
    C_autofire => true
  )
  port map
  (
    clk => clk_pixel,
    btn_fire => S_joy_fire,
    auto_fire => S_auto_fire,
    btn_bomb => S_joy_bomb,
    auto_bomb => S_auto_bomb
  );

  scramble : entity work.scramble_glue
  generic map
  (
    C_frogger => false,
    C_test_picture => false,
    C_autofire => true,
    C_audio => true,
    C_osd => false, -- diamond will crash, debug joystick controls (green HEX on-screen display)
    C_vga => true
  )
  port map
  (
    clk_pixel    => clk_pixel,
    reset        => reset,
    osd_hex      => S_osd_hex,
    dip_switch   => dip_switch,
    btn_coin     => S_joy_coin,
    btn_player_start => S_joy_player,
    btn_up       => S_joy_up,
    btn_down     => S_joy_down,
    btn_left     => S_joy_left,
    btn_right    => S_joy_right,
    btn_bomb     => S_auto_bomb,
    btn_fire     => S_auto_fire,
    vga_r        => S_vga_r,
    vga_g        => S_vga_g,
    vga_b        => S_vga_b,
    vga_hsync    => S_vga_hsync,
    vga_vsync    => S_vga_vsync,
    vga_blank    => S_vga_blank,
    audio_pcm    => S_audio
  );

  G_hdmi_video_only: if not C_hdmi_audio generate
  vga2dvi_converter: entity work.vga2dvid
  generic map
  (
    C_ddr     => true,
    C_depth   => 4 -- 4bpp (4 bit per pixel)
  )
  port map
  (
    clk_pixel => clk_pixel, -- 25 MHz
    clk_shift => clk_pixel_shift, -- 125 MHz

    in_red   => S_vga_r,
    in_green => S_vga_g,
    in_blue  => S_vga_b,

    in_blank => S_vga_blank,
    in_hsync => S_vga_hsync,
    in_vsync => S_vga_vsync,

    -- single-ended output ready for differential buffers
    out_red   => dvid_red,
    out_green => dvid_green,
    out_blue  => dvid_blue,
    out_clock => dvid_clock
  );

  -- this module instantiates vendor specific modules ddr_out to
  -- convert SDR 2-bit input to DDR clocked 1-bit output (single-ended)
  G_vgatext_ddrout: entity work.ddr_dvid_out_se
  port map
  (
    clk       => clk_pixel_shift,
    clk_n     => clkn_pixel_shift,
    in_red    => dvid_red,
    in_green  => dvid_green,
    in_blue   => dvid_blue,
    in_clock  => dvid_clock,
    out_red   => ddr_d(2),
    out_green => ddr_d(1),
    out_blue  => ddr_d(0),
    out_clock => ddr_clk
  );

  gpdi_data_channels: for i in 0 to 2 generate
    gpdi_diff_data: OLVDS
    port map(A => ddr_d(i), Z => gpdi_dp(i), ZN => gpdi_dn(i));
  end generate;
  gpdi_diff_clock: OLVDS
  port map(A => ddr_clk, Z => gpdi_clkp, ZN => gpdi_clkn);

  end generate;

  G_hdmi_video_audio: if C_hdmi_audio generate
    S_vga_r8 <= S_vga_r & S_vga_r(0) & S_vga_r(0) & S_vga_r(0) & S_vga_r(0);
    S_vga_g8 <= S_vga_g & S_vga_g(0) & S_vga_g(0) & S_vga_g(0) & S_vga_g(0);
    S_vga_b8 <= S_vga_b & S_vga_b(0) & S_vga_b(0) & S_vga_b(0) & S_vga_b(0);
    
    S_audio_pcm <= S_audio & "0000";

    av_hdmi_out: entity work.av_hdmi
    generic map
    (
      FREQ => 25000000,
      FS => 48000,
      CTS => 25000,
      N => 6144
    )
    port map
    (
      I_CLK_PIXEL    => clk_pixel,
      I_R            => S_vga_r8,
      I_G            => S_vga_g8,
      I_B            => S_vga_b8,
      I_BLANK        => S_vga_blank,
      I_HSYNC        => not S_vga_hsync,
      I_VSYNC        => not S_vga_vsync,
      I_AUDIO_ENABLE => S_audio_enable,
      I_AUDIO_PCM_L  => S_audio_pcm,
      I_AUDIO_PCM_R  => S_audio_pcm,
      O_TMDS_PD0     => S_HDMI_PD0,
      O_TMDS_PD1     => S_HDMI_PD1,
      O_TMDS_PD2     => S_HDMI_PD2
    );

    -- tx_in <= S_HDMI_PD2 & S_HDMI_PD1 & S_HDMI_PD0; -- this would be normal bit order, but
    -- generic serializer follows vendor specific serializer style
    tx_in <=  S_HDMI_PD2(0) & S_HDMI_PD2(1) & S_HDMI_PD2(2) & S_HDMI_PD2(3) & S_HDMI_PD2(4) & S_HDMI_PD2(5) & S_HDMI_PD2(6) & S_HDMI_PD2(7) & S_HDMI_PD2(8) & S_HDMI_PD2(9) &
              S_HDMI_PD1(0) & S_HDMI_PD1(1) & S_HDMI_PD1(2) & S_HDMI_PD1(3) & S_HDMI_PD1(4) & S_HDMI_PD1(5) & S_HDMI_PD1(6) & S_HDMI_PD1(7) & S_HDMI_PD1(8) & S_HDMI_PD1(9) &
              S_HDMI_PD0(0) & S_HDMI_PD0(1) & S_HDMI_PD0(2) & S_HDMI_PD0(3) & S_HDMI_PD0(4) & S_HDMI_PD0(5) & S_HDMI_PD0(6) & S_HDMI_PD0(7) & S_HDMI_PD0(8) & S_HDMI_PD0(9);

    G_generic_serializer: if C_hdmi_generic_serializer generate
      generic_serializer_inst: entity work.serializer_generic
      PORT MAP
      (
        tx_in => tx_in,
        tx_inclock => CLK_PIXEL_SHIFT, -- NOTE: generic serializer needs CLK_PIXEL x10
        tx_syncclock => CLK_PIXEL,
        tx_out => tmds_d
      );
      gpdi_clkp <= tmds_d(3);
      gpdi_dp  <= tmds_d(2 downto 0);
    end generate;
    --G_vendor_specific_serializer: if not C_hdmi_generic_serializer generate
    --  vendor_specific_serializer_inst: entity work.serializer
    --  PORT MAP
    --  (
    --    tx_in => tx_in,
    --    tx_inclock => CLK_PIXEL_SHIFT, -- NOTE: vendor-specific serializer needs CLK_PIXEL x5
    --    tx_syncclock => CLK_PIXEL,
    --    tx_out => tmds_d(2 downto 0)
    --  );
    --  gpdi_clkp <= CLK_PIXEL;
    --  gpdi_dp  <= tmds_d;
    --end generate;
  end generate;
end struct;
