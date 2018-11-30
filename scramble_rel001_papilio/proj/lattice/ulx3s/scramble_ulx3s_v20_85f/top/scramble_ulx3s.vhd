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

-- package for usb joystick report decoded structure
use work.report_decoded_pack.all;

entity scramble_ulx3s is
generic
(
  C_frogger: boolean := false;
  C_usbhid_joystick: boolean := false;
  C_onboard_buttons: boolean := true;
  C_hdmi_generic_serializer: boolean := false; -- serializer type: false: vendor-specific, true: generic=vendor-agnostic
  C_hdmi_audio: boolean := false -- HDMI generator type: false: video only, true: video+audio capable
);
port
(
  clk_25mhz: in std_logic;

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
  
  usb_fpga_dp, usb_fpga_dn: inout std_logic;

  -- for vendor-specific serializer
  --hdmi_d0, hdmi_d1, hdmi_d2: out std_logic;
  --hdmi_clk: out std_logic

  -- Digital Video (differential outputs)
  gpdi_dp, gpdi_dn: out std_logic_vector(3 downto 0);

  -- i2c shared for digital video and RTC
  gpdi_scl, gpdi_sda: inout std_logic

);
end;

architecture struct of scramble_ulx3s is
  signal clk_pixel, clk_pixel_shift, clkn_pixel_shift, clk_usb: std_logic;

  signal R_usb_joy_coin: std_logic := '0';
  signal R_usb_joy_player: std_logic_vector(1 downto 0) := (others => '0');
  signal R_usb_joy_up, R_usb_joy_down, R_usb_joy_left, R_usb_joy_right, R_usb_joy_bomb, R_usb_joy_fire: std_logic := '0';
  signal R_usb_joy_reset: std_logic := '0';

  signal R_board_joy_coin: std_logic := '0';
  signal R_board_joy_player: std_logic_vector(1 downto 0) := (others => '0');
  signal R_board_joy_up, R_board_joy_down, R_board_joy_left, R_board_joy_right, R_board_joy_bomb, R_board_joy_fire: std_logic := '0';
  signal R_board_joy_reset: std_logic := '0';

  signal R_joy_coin: std_logic;
  signal R_joy_player: std_logic_vector(1 downto 0);
  signal R_joy_up, R_joy_down, R_joy_left, R_joy_right, R_joy_bomb, R_joy_fire: std_logic;
  signal R_joy_reset: std_logic;
  signal S_auto_bomb, S_auto_fire: std_logic;
  
  signal S_osd_hex: std_logic_vector(63 downto 0);

  signal S_audio_enable: std_logic := '0';
  signal S_audio_pcm: std_logic_vector(23 downto 0) := (others => '0');
  signal S_audio_pwm_l, S_audio_pwm_r, S_spdif_out: std_logic;
  
  signal dvid_red, dvid_green, dvid_blue, dvid_clock: std_logic_vector(1 downto 0);
  signal S_hdmi_pd0, S_hdmi_pd1, S_hdmi_pd2: std_logic_vector(9 downto 0);
  signal tmds_d: std_logic_vector(3 downto 0);
  signal tx_in: std_logic_vector(29 downto 0);

  signal ddr_d: std_logic_vector(3 downto 0);

  signal S_vga_r, S_vga_g, S_vga_b: std_logic_vector(3 downto 0);
  signal S_vga_r8, S_vga_g8, S_vga_b8: std_logic_vector(7 downto 0);
  signal S_vga_vsync, S_vga_hsync: std_logic;
  signal S_vga_vblank, S_vga_blank: std_logic;

  -- emard usb hid joystick
  signal S_hid_reset: std_logic;
  signal S_hid_report: std_logic_vector(63 downto 0);
  signal S_report_decoded: T_report_decoded;
  -- end emard usb hid joystick

  signal reset        : std_logic;
  signal clock_stable : std_logic := '1';
  signal dip_switch   : std_logic_vector(7 downto 0) := (others => '0');
begin
  G_ddr: if true generate
    clkgen_125_25_7M5: entity work.clk_25M_125Mpn_25M_7M5
    port map
    (
      clki => clk_25MHz,         --  25 MHz input from board
      clkop => clk_pixel_shift,  -- 125 MHz
      clkos => clkn_pixel_shift, -- 125 MHz inverted
      clkos2 => clk_pixel,       --  25 MHz
      clkos3 => clk_usb          --   7.5 MHz
    );
  end generate;

  reset <= R_joy_reset or not clock_stable;

  wifi_gpio0 <= btn(0); -- pressing BTN0 will escape to ESP32 file select menu

  G_hid_joystick: if C_usbhid_joystick generate
  usbhid_host_inst: entity usbhid_host
  port map
  (
    clk => clk_usb, -- 7.5 MHz for low-speed USB1.0 device or 60 MHz for full-speed USB1.1 device
    reset => S_hid_reset,
    usb_data(1) => usb_fpga_dp,
    usb_data(0) => usb_fpga_dn,
    hid_report => S_hid_report,
    leds => open -- debug
  );

  usbhid_report_decoder_inst: entity usbhid_report_decoder
  port map
  (
    clk => clk_usb,
    hid_report => S_hid_report,
    decoded => S_report_decoded
  );
  
  process(clk_pixel)
  begin
    if rising_edge(clk_pixel) then
      R_usb_joy_coin      <= S_report_decoded.btn_fps;       -- fps button: insert coin
      R_usb_joy_player(0) <= S_report_decoded.btn_start;     -- "start" : Start 1 Player
      R_usb_joy_player(1) <= S_report_decoded.btn_back;      -- "back"  : Start 2 Players
      R_usb_joy_up        <= S_report_decoded.lstick_up    or S_report_decoded.hat_up;     -- left stick move up
      R_usb_joy_down      <= S_report_decoded.lstick_down  or S_report_decoded.hat_down;   -- left stick move down
      R_usb_joy_left      <= S_report_decoded.lstick_left  or S_report_decoded.hat_left;   -- left stick move left
      R_usb_joy_right     <= S_report_decoded.lstick_right or S_report_decoded.hat_right;  -- left stick move right
      R_usb_joy_fire      <= S_report_decoded.btn_b or S_report_decoded.btn_rtrigger; -- btn1  : Fire
      R_usb_joy_bomb      <= S_report_decoded.btn_a or S_report_decoded.btn_rbumper;  -- btn2  : Protection 
    end if;
  end process;
  end generate;

  G_onboard_buttons: if C_onboard_buttons generate
    process(clk_pixel)
    begin
      if rising_edge(clk_pixel) then
        R_board_joy_reset <= '0';

        R_board_joy_coin <= not btn(0);
        R_board_joy_player <= btn(2 downto 1);

        R_board_joy_bomb <= btn(1);
        R_board_joy_fire <= btn(2);
        R_board_joy_up <= btn(3);
        R_board_joy_down <= btn(4);
        R_board_joy_left <= btn(5);
        R_board_joy_right <= btn(6);

        S_osd_hex(6 downto 0) <= btn;
      end if;
    end process;
  end generate;

  -- mix usb and onboard buttons
  process(clk_pixel)
  begin
    if rising_edge(clk_pixel) then
      R_joy_coin      <= R_usb_joy_coin    or R_board_joy_coin;
      R_joy_player    <= R_usb_joy_player  or R_board_joy_player;
      R_joy_up        <= R_usb_joy_up      or R_board_joy_up;
      R_joy_down      <= R_usb_joy_down    or R_board_joy_down;
      R_joy_left      <= R_usb_joy_left    or R_board_joy_left;
      R_joy_right     <= R_usb_joy_right   or R_board_joy_right;
      R_joy_fire      <= R_usb_joy_fire    or R_board_joy_fire;
      R_joy_bomb      <= R_usb_joy_bomb    or R_board_joy_bomb;
    end if;
  end process;

  I_autofire : entity work.autofire
  generic map
  (
    C_autofire => true
  )
  port map
  (
    clk => clk_pixel,
    btn_fire => R_joy_fire,
    auto_fire => S_auto_fire,
    btn_bomb => R_joy_bomb,
    auto_bomb => S_auto_bomb
  );

  scramble : entity work.scramble_glue
  generic map
  (
    C_frogger => C_frogger,
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
    btn_coin     => R_joy_coin,
    btn_player_start => R_joy_player,
    btn_up       => R_joy_up,
    btn_down     => R_joy_down,
    btn_left     => R_joy_left,
    btn_right    => R_joy_right,
    btn_bomb     => S_auto_bomb,
    btn_fire     => S_auto_fire,
    vga_r        => S_vga_r,
    vga_g        => S_vga_g,
    vga_b        => S_vga_b,
    vga_hsync    => S_vga_hsync,
    vga_vsync    => S_vga_vsync,
    vga_blank    => S_vga_blank,
    o_audio_l    => S_audio_pwm_l,
    o_audio_r    => S_audio_pwm_r,
    audio_pcm    => S_audio_pcm(23 downto 12)
  );

  G_spdif_out: entity work.spdif_tx
  generic map
  (
    C_clk_freq => 25000000,  -- Hz
    C_sample_freq => 48000   -- Hz
  )
  port map
  (
    clk => clk_pixel,
    data_in => S_audio_pcm,
    spdif_out => S_spdif_out
  );
  --audio_l(1 downto 0) <= (others => S_audio_pwm_l);
  --audio_r(1 downto 0) <= (others => S_audio_pwm_r);
  audio_l(3 downto 0) <= S_audio_pcm(23 downto 20);
  audio_r(3 downto 0) <= S_audio_pcm(23 downto 20);
  audio_v(1 downto 0) <= (others => S_spdif_out);

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
    out_clock => ddr_d(3)
  );

  gpdi_data_channels: for i in 0 to 3 generate
    gpdi_diff_data: OLVDS
    port map(A => ddr_d(i), Z => gpdi_dp(i), ZN => gpdi_dn(i));
  end generate;

  end generate;

  G_hdmi_video_audio: if C_hdmi_audio generate
    S_vga_r8 <= S_vga_r & S_vga_r(0) & S_vga_r(0) & S_vga_r(0) & S_vga_r(0);
    S_vga_g8 <= S_vga_g & S_vga_g(0) & S_vga_g(0) & S_vga_g(0) & S_vga_g(0);
    S_vga_b8 <= S_vga_b & S_vga_b(0) & S_vga_b(0) & S_vga_b(0) & S_vga_b(0);
    

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
      gpdi_dp  <= tmds_d(3 downto 0);
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
