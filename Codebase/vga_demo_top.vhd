
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.vga_pack.all;

entity vga_demo_top is
	port(
		EN: in std_logic;
		CLK: in std_logic;
		RST: in std_logic;
		SEL: in std_logic_vector(1 downto 0);
		--
		VGA_CLK : out std_logic;
		VGA_R, VGA_G, VGA_B : out std_logic_vector(7 downto 0);
		VGA_HSYNC : out std_logic;
		VGA_VSYNC : out std_logic;
		VGA_SYNC : out std_logic;
		VGA_BLANK : out std_logic
	);
end vga_demo_top;

architecture behave of vga_demo_top is

signal clk_200 : std_logic := '0';
signal pixel_clk_vector : std_logic_vector(2 downto 0);
signal pixel_clk : std_logic := '0';
signal pll_locked : std_logic_vector(1 downto 0) := (others=>'0');
signal vga_rst : std_logic := '0';
signal blanking : std_logic := '0';
signal vga_x_int, vga_y_int : unsigned(15 downto 0);
signal disp_width_int, disp_height_int : unsigned(15 downto 0);
signal drawEn : std_logic := '0';

type canvas_t is array (0 to 2) of pixel_color;
signal painters_canvas : canvas_t := (others=>(others=>(others=>'0')));


begin

drawEn <= not(blanking) and EN;

vga_rst <= not(pll_locked(0)) or not(pll_locked(1)) or not(RST);
pixel_clk <= pixel_clk_vector(0) when SEL="00" else pixel_clk_vector(1) when SEL="01" else pixel_clk_vector(2);

pll_4065_inst : entity work.vga_pll PORT MAP (
	areset	 => not(RST),
	inclk0	 => CLK,
	c0	 => pixel_clk_vector(0),
	c1 => pixel_clk_vector(1),
	locked	 => pll_locked(0)
);

pll_108_inst : entity work.vga_pll_108 PORT MAP (
	areset	 => not(RST),
	inclk0	 => CLK,
	c0	 => pixel_clk_vector(2),
	c1  => clk_200,
	locked	 => pll_locked(1)
);

VGA_BLANK <= not(blanking); --invert blanking;
VGA_CLK <= pixel_clk;
VGA_SYNC <= '0';

VGA_R <= std_logic_vector(painters_canvas(0).RED or painters_canvas(1).RED or painters_canvas(2).RED);
VGA_G <= std_logic_vector(painters_canvas(0).GREEN or painters_canvas(1).GREEN or painters_canvas(2).GREEN);
VGA_B <= std_logic_vector(painters_canvas(0).BLUE or painters_canvas(1).BLUE or painters_canvas(2).BLUE);

vga_gen_inst: entity work.vga_generator port map(
	clk=>pixel_clk,
	rst=>vga_rst,
	en=>EN,
	sel_resol=>SEL,
	vga_x=>vga_x_int,
	vga_y=>vga_y_int,
	disp_width=>disp_width_int,
	disp_height=>disp_height_int,
	VGA_BLANK=>blanking,
	VGA_HS=>VGA_HSYNC,
	VGA_VS=>VGA_VSYNC
);

rect_paint_inst: entity work.rect_painter 
generic map(
	anim_speed	=> X"00051615",
	speed			=> X"0004",
	color => X"0000FF",
	box_width	=> X"00C8",
	box_height	=> X"00C8" --x"01C2"
)
port map(
	clk=>pixel_clk,
	rst=>vga_rst,
	drawEn=>drawEn,
	vga_x=>vga_x_int,
	vga_y=>vga_y_int,
	disp_width=>disp_width_int,
	disp_height=>disp_height_int,
	R=>painters_canvas(0).RED,
	G=>painters_canvas(0).GREEN,
	B=>painters_canvas(0).BLUE
);

rect_paint_inst_big: entity work.rect_painter 
generic map(
	anim_speed	=> X"00051615",
	speed			=> X"0002",
	init_x		=> X"0200",
	init_y		=> X"0100",
	color => X"FF0000",
	box_width	=> X"00FF",
	box_height	=> X"00FF" --x"01C2"
)
port map(
	clk=>pixel_clk,
	rst=>vga_rst,
	drawEn=>drawEn,
	vga_x=>vga_x_int,
	vga_y=>vga_y_int,
	disp_width=>disp_width_int,
	disp_height=>disp_height_int,
	R=>painters_canvas(1).RED,
	G=>painters_canvas(1).GREEN,
	B=>painters_canvas(1).BLUE
);

circle_paint_inst: entity work.circle_painter 
generic map(
	anim_speed	=> X"00051615",
	speed			=> X"0001",
	radius	=> X"0064",
	color => X"00FF00"
)
port map(
	clk=>pixel_clk,
	rst=>vga_rst,
	drawEn=>drawEn,
	vga_x=>vga_x_int,
	vga_y=>vga_y_int,
	disp_width=>disp_width_int,
	disp_height=>disp_height_int,
	R=>painters_canvas(2).RED,
	G=>painters_canvas(2).GREEN,
	B=>painters_canvas(2).BLUE
);

end behave;