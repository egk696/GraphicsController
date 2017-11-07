library IEEE;
use work.vga_pack.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_settings_rom is
	port(
		clk : in STD_LOGIC;
		refresh : out std_logic;
      sel_resol : in UNSIGNED(1 downto 0);
		h_display : out UNSIGNED(DISP_BIT_WIDTH-1 downto 0);
      h_fr_porch : out UNSIGNED (PARAM_BIT_WIDTH-1 downto 0);
      h_sync_pulse : out UNSIGNED (PARAM_BIT_WIDTH-1 downto 0);
      h_b_porch : out UNSIGNED (PARAM_BIT_WIDTH-1 downto 0);
		v_display : out UNSIGNED(DISP_BIT_WIDTH-1 downto 0);
      v_fr_porch : out UNSIGNED (PARAM_BIT_WIDTH-1 downto 0);
      v_sync_pulse : out UNSIGNED (PARAM_BIT_WIDTH-1 downto 0);
      v_b_porch : out UNSIGNED (PARAM_BIT_WIDTH-1 downto 0);
      h_sync_polar : out std_logic;
      v_sync_polar : out std_logic
	);
end vga_settings_rom;

architecture Behavioral of vga_settings_rom is

constant VGA_MODES_ROM : VGA_MODES_TYPE := (
			(to_unsigned(800,DISP_BIT_WIDTH),	to_unsigned(40,PARAM_BIT_WIDTH),		to_unsigned(128,PARAM_BIT_WIDTH), 	to_unsigned(88,PARAM_BIT_WIDTH),		to_unsigned(600,DISP_BIT_WIDTH),		to_unsigned(1,PARAM_BIT_WIDTH),	to_unsigned(4,PARAM_BIT_WIDTH),	to_unsigned(23,PARAM_BIT_WIDTH), '1', '1'), --800x600
			(to_unsigned(1024,DISP_BIT_WIDTH),	to_unsigned(24,PARAM_BIT_WIDTH),		to_unsigned(136,PARAM_BIT_WIDTH), 	to_unsigned(160,PARAM_BIT_WIDTH),	to_unsigned(768,DISP_BIT_WIDTH),		to_unsigned(3,PARAM_BIT_WIDTH),	to_unsigned(6,PARAM_BIT_WIDTH),	to_unsigned(29,PARAM_BIT_WIDTH), '0', '0'), --1024x768
			(to_unsigned(1152,DISP_BIT_WIDTH), 	to_unsigned(64,PARAM_BIT_WIDTH),		to_unsigned(128,PARAM_BIT_WIDTH), 	to_unsigned(256,PARAM_BIT_WIDTH),	to_unsigned(864,DISP_BIT_WIDTH),		to_unsigned(1,PARAM_BIT_WIDTH),	to_unsigned(3,PARAM_BIT_WIDTH),	to_unsigned(32,PARAM_BIT_WIDTH), '1', '1'), --1152x864
			(to_unsigned(1280,DISP_BIT_WIDTH), 	to_unsigned(48,PARAM_BIT_WIDTH),		to_unsigned(112,PARAM_BIT_WIDTH), 	to_unsigned(248,PARAM_BIT_WIDTH),	to_unsigned(1024,DISP_BIT_WIDTH),	to_unsigned(1,PARAM_BIT_WIDTH),	to_unsigned(3,PARAM_BIT_WIDTH),	to_unsigned(38,PARAM_BIT_WIDTH), '1', '1') --1280x1024
);

signal current_sel_resol : unsigned(1 downto 0) := (others=>'0');

begin

rom_logic: process(clk, sel_resol, current_sel_resol)
begin
    if rising_edge(clk) then
		h_display <= VGA_MODES_ROM(to_integer(sel_resol)).h_display;
		h_fr_porch <= VGA_MODES_ROM(to_integer(sel_resol)).h_fr_porch;
		h_sync_pulse <= VGA_MODES_ROM(to_integer(sel_resol)).h_sync_pulse;
		h_b_porch <= VGA_MODES_ROM(to_integer(sel_resol)).h_b_porch;
		v_display <= VGA_MODES_ROM(to_integer(sel_resol)).v_display;
		v_fr_porch <= VGA_MODES_ROM(to_integer(sel_resol)).v_fr_porch;
		v_sync_pulse <= VGA_MODES_ROM(to_integer(sel_resol)).v_sync_pulse;
		v_b_porch <= VGA_MODES_ROM(to_integer(sel_resol)).v_b_porch;
		h_sync_polar <= VGA_MODES_ROM(to_integer(sel_resol)).h_sync_polar;
		v_sync_polar <= VGA_MODES_ROM(to_integer(sel_resol)).v_sync_polar;
		--refresh logic
		if sel_resol /= current_sel_resol then
			current_sel_resol <= sel_resol;
			refresh <= '1';
		else
			refresh <= '0';
		end if;
    end if;
end process;

end Behavioral;
