library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.system_config_pack.all;

package vga_pack is
    --constants
	constant COLOR_BIT_WIDTH : integer := 8;
	constant COLOR_DEPTH : integer := 24;
	constant DISP_BIT_WIDTH : integer := 16;
    constant PARAM_BIT_WIDTH : integer := 8;

	--types
	type pixel_color is record
		RED : unsigned(COLOR_BIT_WIDTH-1 downto 0);
		GREEN : unsigned(COLOR_BIT_WIDTH-1 downto 0);
		BLUE : unsigned(COLOR_BIT_WIDTH-1 downto 0);
	end record;

	type pixel_position is record
		x : unsigned(DISP_BIT_WIDTH-1 downto 0);
		y : unsigned(DISP_BIT_WIDTH-1 downto 0);
	end record;

	type pixel_size is record
		width : unsigned(DISP_BIT_WIDTH-1 downto 0);
		height : unsigned(DISP_BIT_WIDTH-1 downto 0);
	end record;
	 
	type VGA_MODES is record
		h_display		: unsigned(DISP_BIT_WIDTH-1 downto 0);
		h_fr_porch		: unsigned(PARAM_BIT_WIDTH-1 downto 0);
		h_sync_pulse	: unsigned(PARAM_BIT_WIDTH-1 downto 0);
		h_b_porch		: unsigned(PARAM_BIT_WIDTH-1 downto 0);
		v_display		: unsigned(DISP_BIT_WIDTH-1 downto 0);
		v_fr_porch		: unsigned(PARAM_BIT_WIDTH-1 downto 0);
		v_sync_pulse	: unsigned(PARAM_BIT_WIDTH-1 downto 0);
		v_b_porch		: unsigned(PARAM_BIT_WIDTH-1 downto 0);
		h_sync_polar	: std_logic;
		v_sync_polar	: std_logic;
    end record;
    type VGA_MODES_TYPE is array(natural range <>) of VGA_MODES;

	--functions
	function position_to_address(pos : pixel_position; display : pixel_size) return unsigned;
	function drawpixel(vga_x, vga_y, x, y : unsigned; color : pixel_color) return pixel_color;
	 
end package vga_pack;

package body vga_pack is

	function position_to_address(pos : pixel_position; display : pixel_size) return unsigned is
		variable address : unsigned(MEM_ADDRESS_BUS_WIDTH-1 downto 0) := (others=>'0');
	begin
		address := pos.x * display.width + pos.y;
		return address;
	end;
	
	function drawpixel(vga_x, vga_y, x, y : unsigned; color : pixel_color) return pixel_color is
		variable pixel : pixel_color := (others=>(others=>'0'));
	begin
		if x = vga_x and y = vga_x then
			pixel.RED := color.RED;
			pixel.GREEN := color.GREEN;
			pixel.BLUE := color.BLUE;
		else
			pixel.RED := (others=>'0');
			pixel.GREEN := (others=>'0');
			pixel.BLUE := (others=>'0');
		end if;
		return pixel;
	end;

end package body;

