library IEEE;
use work.vga_pack.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.vga_pack.all;

entity rect_painter is
	generic(
		anim_speed : unsigned(31 downto 0) := X"000A2C2B";
		speed : unsigned(DISP_BIT_WIDTH-1 downto 0) := X"0002";
		init_x : unsigned(DISP_BIT_WIDTH-1 downto 0) := X"0000";
		init_y : unsigned(DISP_BIT_WIDTH-1 downto 0) := X"0000";
		color : unsigned(3*COLOR_BIT_WIDTH-1 downto 0) := X"FFFFFF";
		box_width : unsigned(DISP_BIT_WIDTH-1 downto 0) := X"00C8";
		box_height : unsigned(DISP_BIT_WIDTH-1 downto 0) := X"00C8" --x"01C2"
	);
	port(
		clk, rst, drawEn : in std_logic := '0';
		vga_x, vga_y : in unsigned(DISP_BIT_WIDTH-1 downto 0) := (others=>'0');
		disp_width, disp_height : in unsigned(DISP_BIT_WIDTH-1 downto 0) := (others=>'0'); 
		R, G, B : out unsigned(COLOR_BIT_WIDTH-1 downto 0) := (others=>'0')
	);
end rect_painter;

architecture behave of rect_painter is

--demo signals
signal box_x : unsigned(DISP_BIT_WIDTH-1 downto 0) := init_x;
signal box_y : unsigned(DISP_BIT_WIDTH-1 downto 0) := init_y; --X"0096"
signal box_color : unsigned(3*COLOR_BIT_WIDTH-1 downto 0) := color;
signal time_counter : unsigned(31 downto 0) := (others=>'0');
signal anim_update : std_logic := '0';

begin

area_draw: process(clk, rst, vga_x, vga_y)
	variable vid_posX, vid_posY : unsigned(15 downto 0) := (others=>'0');
begin
    if rising_edge(clk) then
	   R <= (others=>'0');
		G <= (others=>'0');
		B <= (others=>'0');
		if drawEn='1' then	
			if vga_x >= (box_x) and vga_x < (box_x+box_width) then
				if vga_y >= box_y and vga_y < (box_y+box_height) then
					R <= (box_color(23 downto 16));
					G <= (box_color(15 downto 8));
					B <= (box_color(7 downto 0));
				end if;
			end if;
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
			box_x <= (others=>'0');
			box_y <= (others=>'0');
			--positive_x := '1';
			--positive_y := '0';
	elsif rising_edge(clk) then	
			--bounds
			if box_x + box_width >= disp_width and positive_x='1' then
				positive_x := '0';
			elsif box_x <= 0 and positive_x='0' then
				positive_x := '1';
			end if;
			if box_y + box_height >= disp_height and positive_y='0' then
				positive_y := '1';
			elsif box_y <= 0 and positive_y='1' then
				positive_y := '0';
			end if;
			--update animation
			if anim_update='1' and drawEn = '1' then
				if positive_x = '1' then
					box_x <= box_x + speed;
				else
					box_x <= box_x - speed;
				end if;
				if positive_y = '1' then
					box_y <= box_y - speed;
				else
					box_y <= box_y + speed;
				end if;
			end if;
	end if;
	--update color
--	color_per_pixel := (vga_x(15 downto 0) + vga_y(15 downto 0));
--	box_color(23 downto 20) <= not(vga_y(11 downto 8));
--	box_color(19 downto 16) <= (vga_x(11 downto 8));--(others=>'0');
--	box_color(15 downto 12) <= vga_y(7 downto 4);
--	box_color(11 downto 8) <= vga_x(7 downto 4);
--	box_color(7 downto 4) <= vga_y(3 downto 0);
--	box_color(3 downto 0) <= vga_x(3 downto 0);
end process;

end behave;