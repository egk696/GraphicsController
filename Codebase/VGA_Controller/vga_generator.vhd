library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;
use work.vga_pack.all;

entity vga_generator is
    Port ( clk : in std_logic := '0';
           rst : in std_logic := '0';
           en : in std_logic := '0';
			  sel_resol : in std_logic_vector(1 downto 0) := (others=>'0');
			  vga_x, vga_y : out unsigned(DISP_BIT_WIDTH-1 downto 0) := (others=>'0');
			  disp_width, disp_height : out unsigned(DISP_BIT_WIDTH-1 downto 0) := (others=>'0');
			  VGA_DE : out std_logic := '0';
           VGA_BLANK : out std_logic := '0';
			  VGA_SYNC : out std_logic := '0';
           VGA_HS : out std_logic := '0';
           VGA_VS : out std_logic := '0');
end vga_generator;

architecture Behavioral of vga_generator is

--components declaration
component vga_settings_rom is
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
end component vga_settings_rom;

--components signals
signal h_fr_porch, h_sync_pulse, h_b_porch : unsigned (PARAM_BIT_WIDTH-1 downto 0) := (others=>'0');
signal v_fr_porch, v_sync_pulse, v_b_porch : unsigned (PARAM_BIT_WIDTH-1 downto 0) := (others=>'0');
signal h_sync_polar, v_sync_polar : std_logic := '0';

--internal signals
signal current_disp_width : unsigned(DISP_BIT_WIDTH-1 downto 0) := X"0320";
signal current_disp_height : unsigned(DISP_BIT_WIDTH-1 downto 0) := X"0258";
signal counterX, counterY : unsigned(DISP_BIT_WIDTH-1 downto 0) := (others=>'0');
signal hSync, vSync, sync : std_logic := '0';
signal red, green, blue : unsigned(COLOR_BIT_WIDTH-1 downto 0) := (others=>'0');
signal drawEn : std_logic := '0';
signal rst_int : std_logic := '0';


begin

--current_resolution <= unsigned(std_logic_vector(current_disp_width) & std_logic_vector(current_disp_height));
--area_width <= current_disp_width + h_fr_porch + h_sync_pulse + h_b_porch;
--area_height <= current_disp_height + v_fr_porch + v_sync_pulse + v_b_porch; 

vga_set_rom_u0: vga_settings_rom port map(
           clk => clk,
			  refresh => rst_int,
           sel_resol => unsigned(sel_resol),
			  h_display => current_disp_width,
           h_fr_porch => h_fr_porch,
           h_sync_pulse => h_sync_pulse,
           h_b_porch => h_b_porch,
			  v_display => current_disp_height,
           v_fr_porch => v_fr_porch,
           v_sync_pulse => v_sync_pulse,
           v_b_porch => v_b_porch,
           h_sync_polar => h_sync_polar,
           v_sync_polar => v_sync_polar
			);

counterX_logic: process(clk, rst, rst_int, counterX, counterY, current_disp_width, current_disp_height, h_fr_porch, v_fr_porch, h_sync_pulse, v_sync_pulse, en)
begin
	if rising_edge(clk) then
		if rst_int='1' or rst='1' then
        counterX <= (others=>'0');
		  counterY <= (others=>'0');
		else
			if counterX >= (current_disp_width + h_fr_porch + h_sync_pulse + h_b_porch)-1 then
            counterX <= (others=>'0');
				if counterY >= (current_disp_height + v_fr_porch + v_sync_pulse + v_b_porch)-1 then
					counterY <= (others=>'0');
				else
					counterY <= counterY + 1;
				end if;
			else
				counterX <= counterX + 1;
			end if;
		end if;
	end if;
end process;

sync_logic: process(clk, rst, rst_int, counterX, counterY, current_disp_width, h_sync_polar, h_fr_porch, h_sync_pulse, current_disp_height, v_sync_polar, v_fr_porch, v_sync_pulse, en)
begin
--    if rising_edge(clk) then
--			if rst_int='1' or rst='1' then
--				hSync <= not(h_sync_polar);
--				vSync <= not(v_sync_polar);
--			else
				if (counterX >= current_disp_width+h_fr_porch) AND (counterX < current_disp_width+h_fr_porch+h_sync_pulse) then
					hSync <= h_sync_polar;
				else
					hSync <= not(h_sync_polar);
				end if;
				if (counterY >= current_disp_height+v_fr_porch) AND (counterY < current_disp_height+v_fr_porch+v_sync_pulse) then
					vSync <= v_sync_polar;
				else
					vSync <= not(v_sync_polar);
				end if;
--			end if;
--    end if;
end process;

drawEn <= (hSync xor h_sync_polar) and (vSync xor v_sync_polar);

--drive outputs
vga_x <= counterX;
vga_y <= counterY;
disp_width <= current_disp_width;
disp_height <= current_disp_height;
VGA_HS <= hSync;
VGA_VS <= vSync;
VGA_BLANK <= not(drawEn);

end Behavioral;
