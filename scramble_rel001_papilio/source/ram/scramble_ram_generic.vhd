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
  use ieee.numeric_std.all;

entity SCRAMBLE_RAM is
  port (
    I_ADDR            : in    std_logic_vector(10 downto 0);
    I_DATA            : in    std_logic_vector( 7 downto 0);
    O_DATA            : out   std_logic_vector( 7 downto 0);
    I_RW_L            : in    std_logic;
    I_CS              : in    std_logic;
    ENA               : in    std_logic;
    CLK               : in    std_logic
    );
end;

architecture RTL of SCRAMBLE_RAM is
  signal we       : std_logic;
begin
  vram: entity work.bram_true2p_1clk
    generic map (
      dual_port => false,
      pass_thru_a => false,
      data_Width => I_DATA'length,
      addr_width => I_ADDR'length
    )
    port map (
      clk        => CLK,
      addr_a     => I_ADDR,
      data_in_a  => I_DATA,
      data_out_a => O_DATA,
      we_a       => we
    );
  p_we_comb: process(I_RW_L, I_CS, ENA)
  begin
    we <= I_CS and (not I_RW_L) and ENA;
  end process;
end architecture RTL;
