---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;

entity autofire is
generic
(
  C_fire_delay_bits: integer := 23;
  C_bomb_delay_bits: integer := 24;
  C_autofire: boolean := true
);
port
(
  clk: in std_logic;
  btn_bomb: in std_logic;
  auto_bomb: out std_logic;
  btn_fire: in std_logic;
  auto_fire: out std_logic
);
end;

architecture struct of autofire is
  signal R_autofire: std_logic_vector(C_fire_delay_bits-1 downto 0);
  signal R_autobomb: std_logic_vector(C_bomb_delay_bits-1 downto 0);
begin
  G_not_autofire: if not C_autofire generate
    auto_fire <= btn_fire;
    auto_bomb <= btn_bomb;
  end generate;
  G_yes_autofire: if C_autofire generate
    process(clk)
    begin
      if rising_edge(clk) then
        if btn_fire='1' then
          R_autofire <= R_autofire-1;
        else
          R_autofire <= (others => '0');
        end if;
      end if;
    end process;
    auto_fire <= R_autofire(R_autofire'high);
    process(clk)
    begin
      if rising_edge(clk) then
        if btn_bomb='1' then
          R_autobomb <= R_autobomb-1;
        else
          R_autobomb <= (others => '0');
        end if;
      end if;
    end process;
    auto_bomb <= R_autobomb(R_autobomb'high);
  end generate;
end struct;
