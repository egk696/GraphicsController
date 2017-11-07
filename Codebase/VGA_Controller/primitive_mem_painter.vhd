library IEEE;
use work.vga_pack.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.vga_pack.all;
use work.microcode_pack.all;
use work.system_config_pack.all;

entity primitive_mem_painter is
	port(
		--global
		clk, rst : in std_logic := '0';
		display_resolution : pixel_size := (others=>(others=>'0'));
		--color painting
		primitive_pos : in pixel_position := (others=>(others=>'0'));
		primitive_size : in pixel_size := (others=>(others=>'0'));
		primitive_color : in pixel_color := (others=>(others=>'0'));
		primitive_opcode : in std_logic_vector(PRIMITIVE_OPCODE_WIDTH-1 downto 0) := (others=>'0');
		--avalon master
		avm_write : out std_logic := '0';
		avm_read : out std_logic := '0';
		avm_writedata : out std_logic_vector(MEM_DATA_BUS_WIDTH-1 downto 0) := (others=>'0');
		avm_address : out std_logic_vector(MEM_ADDRESS_BUS_WIDTH-1 downto 0) := (others=>'0');
		avm_waitrequest : in std_logic := '0';
		avm_readdata : in std_logic_vector(MEM_DATA_BUS_WIDTH-1 downto 0) := (others=>'0');
		avm_readdatavalid : in std_logic := '0'
	);
end primitive_mem_painter;

architecture behave of primitive_mem_painter is

	--primitive instruction params
	signal current_primitive_pos : pixel_position := (others=>(others=>'0'));
	signal current_primitive_size : pixel_size := (others=>(others=>'0'));
	signal current_primitive_color : pixel_color := (others=>(others=>'0'));
	signal current_primitive_opcode : std_logic_vector(PRIMITIVE_OPCODE_WIDTH-1 downto 0) := (others=>'0');

	--signal rectangle properties
	signal rect_pos : pixel_position := (others=>(others=>'0'));
	signal rect_size : pixel_size := (others=>(others=>'0'));
	signal rect_color : pixel_color := (others=>(others=>'0'));

	--manage logic
	signal load_instruction : std_logic := '0';
	signal en_fetch, en_decode : std_logic := '0';
	signal en_draw_rect, en_draw_circ, en_draw_tria, en_draw_nop : std_logic := '0';
	signal busy_rect, busy_circ, busy_tria, busy_nop : std_logic := '0';
	
begin

ctrl_logic: process(clk, rst)
begin
	if rising_edge(clk) then
		en_fetch <= not(busy_nop or busy_rect or busy_circ or busy_tria); --stop fetching while executing anything (can be smarter with arbitration)
		if load_instruction='1' then
			en_decode <= '1';
		else
			en_decode <= '0';
		end if;
	end if;
end process;

fetch: process(clk, rst)
begin
	if rising_edge(clk) then
		load_instruction <= '0'; --toggle load instruction
		if en_fetch='1' then
			load_instruction <= '1';
		end if;
		if load_instruction = '1' then
			current_primitive_pos <= primitive_pos;
			current_primitive_size <= primitive_size;
			current_primitive_color <= primitive_color;
			current_primitive_opcode <= primitive_opcode;
		end if;
	end if;
end process;

decode: process(clk, rst)
begin
	if rising_edge(clk) then
		en_draw_rect <= '0';
		en_draw_circ <= '0';
		en_draw_tria <= '0';
		en_draw_nop <= '0';
		if en_decode = '1' then 
			case current_primitive_opcode is
				when OP_RECT=>
					en_draw_rect <= '1';
					en_draw_circ <= '0';
					en_draw_tria <= '0';
					en_draw_nop <= '0';
					rect_pos <= current_primitive_pos;
					rect_size <= current_primitive_size;
					rect_color <= current_primitive_color;
				when OP_CIRC=>
					en_draw_rect <= '0';
					en_draw_circ <= '1';
					en_draw_tria <= '0';
					en_draw_nop <= '0';
				when OP_TRIA=>
					en_draw_rect <= '0';
					en_draw_circ <= '0';
					en_draw_tria <= '1';
					en_draw_nop <= '0';
				when OP_NOP=> 
					en_draw_rect <= '0';
					en_draw_circ <= '0';
					en_draw_tria <= '0';
					en_draw_nop <= '1';
			end case;
		end if;
	end if;
end process;

execute_nop: process(clk, rst)
begin
	if rising_edge(clk) then
		busy_nop <= '0';
		if en_draw_nop='1' then
			busy_nop <= '1';
		end if;
	end if;
end process;

execute_rect: process(clk, rst)
	variable paint_rect_pos : pixel_position := (others=>(others=>'0'));
begin
	if rising_edge(clk) then
		if en_draw_rect='1' then
			busy_rect <= '1';
			paint_rect_pos := rect_pos;
		end if;
		avm_write <= busy_rect or avm_waitrequest;
		if busy_rect ='1' and avm_waitrequest='0' then
			avm_address <= std_Logic_vector(position_to_address(paint_rect_pos, display_resolution));
			avm_writedata <= std_logic_vector(resize((rect_color.RED & rect_color.GREEN & rect_color.BLUE), MEM_DATA_BUS_WIDTH));
			if paint_rect_pos.x = rect_pos.x + rect_size.width then
				paint_rect_pos.x := (others=>'0');
				if paint_rect_pos.y = rect_pos.y + rect_size.height then
					busy_rect <= '0';
					paint_rect_pos.y := (others=>'0');
				else
					paint_rect_pos.y := paint_rect_pos.y + 1;
				end if;
			else
				paint_rect_pos.x := paint_rect_pos.x + 1;
			end if;
		end if;
	end if;		
end process;

execute_circ: process(clk, rst)
begin
	if rising_edge(clk) then
		if en_draw_circ='1' then
			busy_circ <= '1';	
		end if;
		if busy_circ='1' then
			busy_circ <= '0';
		end if;
	end if;
end process;

execute_tria: process(clk, rst)
begin
	if rising_edge(clk) then
		if en_draw_tria='1' then
			busy_tria <= '1';
		end if;
		if busy_tria='1' then
			busy_tria <= '0';
		end if;
	end if;
end process;

end behave;