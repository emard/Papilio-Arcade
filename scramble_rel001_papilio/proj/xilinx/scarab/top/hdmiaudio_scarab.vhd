-- HDMI-audio test

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;

entity hdmiaudio_scarab is
generic
(
  C_osd: boolean := true; -- lattice diamond 3.7 may fail with internal error compiling char_rom.vhd
  C_audio_islands: boolean := false;
  C_hdmi_generic_serializer: boolean := true;
  C_hdmi_ddr: boolean := true
);
port
(
    clk_50MHz: in std_logic;
    porta: in std_logic_vector(6 downto 0);
    sw: in std_logic_vector(4 downto 1);
    AUDIO_L, AUDIO_R: out std_logic := '0';
    --sdram_clk: out std_logic;
    --sdram_cke: out std_logic;
    --sdram_csn: out std_logic;
    --sdram_rasn: out std_logic;
    --sdram_casn: out std_logic;
    --sdram_wen: out std_logic;
    --sdram_a: out std_logic_vector (12 downto 0);
    --sdram_ba: out std_logic_vector(1 downto 0);
    --sdram_dqm: out std_logic_vector(1 downto 0);
    --sdram_d: inout std_logic_vector (15 downto 0);
    --rs232_tx: out std_logic;
    --rs232_rx: in std_logic;
    --flash_cs, flash_cclk, flash_mosi: out std_logic;
    --flash_miso: in std_logic;
    --sd_clk, sd_cd_dat3, sd_cmd: out std_logic;
    --sd_dat0, sd_dat1, sd_dat2: in std_logic;
    leds: out std_logic_vector(7 downto 0) := (others => '0');
    --porta, portb, portc: inout std_logic_vector(11 downto 0);
    --portd: inout std_logic_vector(3 downto 0); -- fm and cw antennas are here
    --porte, portf: inout std_logic_vector(11 downto 0);
    --audio1, audio2: out std_logic; -- 3.5mm audio jack
    -- warning TMDS_in is used as output
    --TMDS_in_P, TMDS_in_N: out std_logic_vector(2 downto 0);
    --TMDS_in_CLK_P, TMDS_in_CLK_N: out std_logic;
    --FPGA_SDA, FPGA_SCL: inout std_logic; -- i2c on TMDS_in
    TMDS_out_P, TMDS_out_N: out std_logic_vector(2 downto 0);
    TMDS_out_CLK_P, TMDS_out_CLK_N: out std_logic
);
end;

architecture struct of hdmiaudio_scarab is
  constant C_resolution_x: integer := 640;
  signal clk_pixel, clk_pixel_shift, clk_pixel_shift_n: std_logic;

  signal S_vga_r, S_vga_g, S_vga_b: std_logic_vector(7 downto 0);
  signal S_vga_g_overlay: std_logic_vector(7 downto 0);
  signal S_vga_vsync, S_vga_hsync: std_logic;
  signal S_vga_vblank, S_vga_blank: std_logic;
  signal S_audio: std_logic_vector(15 downto 0);
  signal S_audio_enable: std_logic;

  signal S_hdmi_pd0, S_hdmi_pd1, S_hdmi_pd2: std_logic_vector(9 downto 0);
  --signal S_hdmi_d0, S_hdmi_d1, S_hdmi_d2: std_logic;
  signal S_hdmi_d: std_logic_vector(3 downto 0);
  signal S_hdmi_clk: std_logic;
  signal S_hdmi_bits: std_logic_vector(39 downto 0);
  signal tmds_d: std_logic_vector(7 downto 0);

  signal reset        : std_logic;
  signal clock_stable : std_logic;

  signal JOY1: std_logic_vector(4 downto 0);
  signal JOY2: std_logic_vector(4 downto 0);

  signal joy_report: std_logic_vector(71 downto 0);

  signal R_pixel_blink: std_logic_vector(25 downto 0) := (others => '0');
  signal R_pixel_shift_blink: std_logic_vector(28 downto 0) := (others => '0');
  signal S_vga_fetch_next: std_logic;
  signal S_osd_pixel: std_logic;
  signal S_osd_green: std_logic_vector(7 downto 0); -- OSD byte signal

  signal R_beep: std_logic_vector(14 downto 0);
begin
  G_hdmi_ddr:
  if C_hdmi_ddr generate
    clkgen100_125_25: entity work.clk_50M_100M_125Mp_125Mn_25M
      port map
      (
        reset => '0', locked => clock_stable,
        clk_50M_in => clk_50MHz, clk_100M => open, clk_25M => clk_pixel, 
        clk_125Mp => clk_pixel_shift, clk_125Mn => clk_pixel_shift_n
      );
  end generate;

  reset <= not clock_stable;

  -- VGA video generator - pixel clock synchronous
  vgabitmap: entity work.vga
  generic map -- workaround for wrong video size
  (
    C_resolution_x => C_resolution_x
  )
  port map
  (
      clk_pixel => clk_pixel,
      test_picture => '1', -- shows test picture when VGA is disabled (on startup)
      fetch_next => S_vga_fetch_next,
      line_repeat => open,
      red_byte    => (others => '0'), -- framebuffer inputs not used
      green_byte  => (others => '0'), -- rgb signal is synchronously generated
      blue_byte   => (others => '0'), -- and replaced
      beam_x => open,
      beam_y => open,
      vga_r => S_vga_r,
      vga_g => S_vga_g,
      vga_b => S_vga_b,
      vga_hsync => S_vga_hsync,
      vga_vsync => S_vga_vsync,
      vga_blank => S_vga_blank, -- '1' when outside of horizontal or vertical graphics area
      vga_vblank => S_vga_vblank -- '1' when outside of vertical graphics area (used for vblank interrupt)
  );

  -- OSD overlay for the green channel
  G_bad_lattice: if C_osd generate
  I_osd: entity work.osd
  generic map -- workaround for wrong video size
  (
    C_digits => 16,
    C_resolution_x => C_resolution_x
  )
  port map
  (
    clk_pixel => clk_pixel,
    vsync => S_vga_vsync,
    fetch_next => S_vga_fetch_next,
    probe_in(63 downto 48) => R_pixel_shift_blink(R_pixel_shift_blink'high downto R_pixel_shift_blink'high-15), -- diamond 3.7 crash
    probe_in(47 downto 16) => (others => '0'),
    probe_in(15 downto 0) => R_pixel_blink(R_pixel_blink'high downto R_pixel_blink'high-15), -- diamond 3.7 crash
    -- probe_in(15 downto 0) => x"1234",
    -- probe_in(31 downto 0) => x"ABCD1234",
    --probe_in(63 downto 0) => x"0123456789ABCDEF",
    osd_out => S_osd_pixel
  );
  S_osd_green <= (others => S_osd_pixel);
  end generate;

  process(clk_pixel)
  begin
    if rising_edge(clk_pixel) then
      R_pixel_blink <= R_pixel_blink+1;
    end if;
  end process;

  process(clk_pixel_shift)
  begin
    if rising_edge(clk_pixel_shift) then
      R_pixel_shift_blink <= R_pixel_shift_blink+1;
    end if;
  end process;

  -- beep generator (sawtooth)
  process(clk_pixel)
  begin
    if rising_edge(clk_pixel) then
      R_beep <= R_beep+1;
    end if;
  end process;

  -- sw(2) mutes the beep sound
  S_audio(15 downto 4) <= R_beep(R_beep'high downto R_beep'high-11) when sw(2)='1'
             else (others => '0');

  S_audio_enable <= sw(1); -- sw(1) enables audio islands
  S_vga_g_overlay <= S_vga_g or S_osd_green;
  -- HDMI
  hdmi_out: entity work.av_hdmi
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
    I_R            => S_vga_r,
    I_G	           => S_vga_g_overlay,
    I_B            => S_vga_b,
    I_BLANK        => S_vga_blank,
    I_HSYNC        => not S_vga_hsync,
    I_VSYNC        => not S_vga_vsync,
    I_AUDIO_ENABLE => S_audio_enable, -- '1' to enable audio islands
    I_AUDIO_PCM_L  => S_audio,
    I_AUDIO_PCM_R  => S_audio,
    O_TMDS_PD0      => S_HDMI_PD0,
    O_TMDS_PD1      => S_HDMI_PD1,
    O_TMDS_PD2      => S_HDMI_PD2
  );

  -- S_hdmi_bits <= S_HDMI_PD2 & S_HDMI_PD1 & S_HDMI_PD0; -- this would be normal bit order, but
  -- generic serializer follows vendor specific serializer style
  S_hdmi_bits <=  "0000011111" &
                  S_HDMI_PD2(0) & S_HDMI_PD2(1) & S_HDMI_PD2(2) & S_HDMI_PD2(3) & S_HDMI_PD2(4) & S_HDMI_PD2(5) & S_HDMI_PD2(6) & S_HDMI_PD2(7) & S_HDMI_PD2(8) & S_HDMI_PD2(9) &
                  S_HDMI_PD1(0) & S_HDMI_PD1(1) & S_HDMI_PD1(2) & S_HDMI_PD1(3) & S_HDMI_PD1(4) & S_HDMI_PD1(5) & S_HDMI_PD1(6) & S_HDMI_PD1(7) & S_HDMI_PD1(8) & S_HDMI_PD1(9) &
                  S_HDMI_PD0(0) & S_HDMI_PD0(1) & S_HDMI_PD0(2) & S_HDMI_PD0(3) & S_HDMI_PD0(4) & S_HDMI_PD0(5) & S_HDMI_PD0(6) & S_HDMI_PD0(7) & S_HDMI_PD0(8) & S_HDMI_PD0(9);

  G_generic_serializer: if C_hdmi_generic_serializer generate
    generic_serializer_inst: entity work.serializer_generic
    GENERIC MAP
    (
      C_output_bits => 2
    )
    PORT MAP
    (
      tx_in => S_hdmi_bits,
      tx_inclock => CLK_PIXEL_SHIFT, -- NOTE: generic serializer needs CLK_PIXEL x10
      tx_syncclock => CLK_PIXEL,
      tx_out => tmds_d
    );
    G_hdmi_ddr: for i in 0 to 3 generate
      ddr_bit: entity work.ddr_out
      port map
      (
        iclkp => clk_pixel_shift,
        iclkn => clk_pixel_shift_n,
        ireset => '0',
        idata => tmds_d(i*2+1 downto i*2),
        odata => S_hdmi_d(i)
      );
    end generate;
    I_hdmi_out: entity work.hdmi_out
      port map
      (
        tmds_in_clk    => S_hdmi_d(3),
        tmds_out_clk_p => tmds_out_clk_p,
        tmds_out_clk_n => tmds_out_clk_n,
        tmds_in_rgb    => S_hdmi_d(2 downto 0),
        tmds_out_rgb_p => tmds_out_p,
        tmds_out_rgb_n => tmds_out_n
      );
    
  end generate;

end struct;
