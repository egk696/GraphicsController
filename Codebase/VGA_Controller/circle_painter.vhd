library IEEE;
use work.vga_pack.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
use work.vga_pack.all;
use work.math_pack.all;

entity circle_painter is
	generic(
		anim_speed : unsigned(31 downto 0) := X"000A2C2B";
		fill : std_logic := '1';
		speed : unsigned(DISP_BIT_WIDTH-1 downto 0) := X"0002";
		init_x : unsigned(DISP_BIT_WIDTH-1 downto 0) := X"0000";
		init_y : unsigned(DISP_BIT_WIDTH-1 downto 0) := X"0000";
		radius : unsigned(DISP_BIT_WIDTH-1 downto 0) := X"00C8";
		color : unsigned(3*COLOR_BIT_WIDTH-1 downto 0) := X"FFFFFF"
	);
	port(
		clk, rst, drawEn : in std_logic := '0';
		vga_x, vga_y : in unsigned(DISP_BIT_WIDTH-1 downto 0) := (others=>'0');
		disp_width, disp_height : in unsigned(DISP_BIT_WIDTH-1 downto 0) := (others=>'0'); 
		R, G, B : out unsigned(COLOR_BIT_WIDTH-1 downto 0) := (others=>'0')
	);
end circle_painter;

architecture behave of circle_painter is

--demo signals
signal center_x : unsigned(DISP_BIT_WIDTH-1 downto 0) := init_x;
signal center_y : unsigned(DISP_BIT_WIDTH-1 downto 0) := init_y; --X"0096"
signal box_color : unsigned(3*COLOR_BIT_WIDTH-1 downto 0) := color;
signal time_counter : unsigned(31 downto 0) := (others=>'0');
signal anim_update : std_logic := '0';

signal cos_value, sin_value : integer := 0;
signal angle : unsigned(8 downto 0) := (others=>'0');

begin

--cos_lut_inst: entity work.sincos_lut_rom
--port map(
--	clock=>clk,
--	address=>'1' & angle,
--	data_out=>cos_value
--);
--
--sin_lut_inst: entity work.sincos_lut_rom
--port map(
--	clock=>clk,
--	address=>'0' & angle,
--	data_out=>sin_value
--);

area_draw: process(clk, rst, vga_x, vga_y)
	variable sqr_xxc, sqr_yyc, sqr_radius : integer := 0;
begin
    if rising_edge(clk) then
		R <= (others=>'0');
		G <= (others=>'0');
		B <= (others=>'0');
		if drawEn='1' then
			sqr_radius := to_integer(radius)*to_integer(radius);
			sqr_xxc := (to_integer(vga_x) - to_integer(center_x)) * (to_integer(vga_x) - to_integer(center_x));
			sqr_yyc := (to_integer(vga_y) - to_integer(center_y)) * (to_integer(vga_y) - to_integer(center_y));
			--case fill is
				--when '0'=>
--					if sqr_xxc + sqr_yyc = sqr_radius then
--						R <= std_logic_vector(box_color(23 downto 16));
--						G <= std_logic_vector(box_color(15 downto 8));
--						B <= std_logic_vector(box_color(7 downto 0));
--					end if;
				--when '1'=>
					if sqr_xxc + sqr_yyc < sqr_radius then
						R <= (box_color(23 downto 16));
						G <= (box_color(15 downto 8));
						B <= (box_color(7 downto 0));
					elsif sqr_xxc + sqr_yyc = sqr_radius then
						R <= (box_color(23 downto 16)/2);
						G <= (box_color(15 downto 8)/2);
						B <= (box_color(7 downto 0)/2);
					end if;
			--end case;
		end if;
    end if;
end process;

anim_step: process(clk, rst)
begin
	if rst='1' then
		time_counter <= (others=>'0');
	elsif rising_edge(clk) then
			if drawEn='1' then
				if time_counter = anim_speed-1 then
					time_counter <= (others=>'0');
					anim_update <= '1';
				else
					time_counter <= time_counter + 1;
					anim_update <= '0';
				end if;
			end if;
	end if;
end process;

--per second
play_anim: process(clk, rst, disp_width, time_counter, vga_x, vga_y)
	variable positive_x : std_logic := '1';
	variable positive_y : std_logic := '0';
	variable color_per_pixel : unsigned(15 downto 0) := (others=>'0');
begin
	if rst='1' then
			center_x <= (others=>'0');
			center_y <= (others=>'0');
			--positive_x := '1';
			--positive_y := '0';
	elsif rising_edge(clk) then
			--bounds
			if center_x + radius/2 >= disp_width and positive_x='1' then
				positive_x := '0';
			elsif center_x - radius/2 <= 0 and positive_x='0' then
				positive_x := '1';
			end if;
			if center_y + radius/2 >= disp_height and positive_y='0' then
				positive_y := '1';
			elsif center_y - radius/2 <= 0 and positive_y='1' then
				positive_y := '0';
			end if;
			--update animation
			if anim_update='1' and drawEn = '1' then
				if positive_x = '1' then
					center_x <= center_x + speed;
				else
					center_x <= center_x - speed;
				end if;
				if positive_y = '1' then
					center_y <= center_y - speed;
				else
					center_y <= center_y + speed;
				end if;
			end if;
	end if;

--	--update color
--	color_per_pixel := (vga_x(15 downto 0) + vga_y(15 downto 0));
--	box_color(23 downto 20) <= not(vga_y(11 downto 8));
--	box_color(19 downto 16) <= (vga_x(11 downto 8));--(others=>'0');
--	box_color(15 downto 12) <= vga_y(7 downto 4);
--	box_color(11 downto 8) <= vga_x(7 downto 4);
--	box_color(7 downto 4) <= vga_y(3 downto 0);
--	box_color(3 downto 0) <= vga_x(3 downto 0);
end process;

end behave;