library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;
 
entity async_fifo is
	generic (
	    DATA_WIDTH    : integer := 64;
	    FIFO_DEPTH    : integer := 64
	);
	port(
		--Write port
		wr_clk : in std_logic := '0';
		wr_en : in std_logic := '0';
		wr_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
		--Read port
		rd_clk : in std_logic := '0';
		rd_en : in std_logic := '0';
		rd_data : out std_logic_vector(DATA_WIDTH-1 downto 0);
		--Status port
		full_flag : out std_logic := '0';
		empty_flag : out std_logic := '1';
		--Control
		clear : in std_logic := '0'
	);
end async_fifo;

architecture behave of async_fifo is

--declare components
component true_dual_port_ram is
	generic (
	    DATA_WIDTH    : integer := 32;
	    ADDR_WIDTH    : integer := 10
	);
	port (
	    -- Port A
	    a_clk   : in  std_logic;
	    a_wr    : in  std_logic;
	    --a_rd    : in  std_logic;
	    a_addr  : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
	    a_din   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
	    a_dout  : out std_logic_vector(DATA_WIDTH-1 downto 0);
	     
	    -- Port B
	    b_clk   : in  std_logic;
	    b_wr    : in  std_logic;
	    --b_rd    : in  std_logic;
	    b_addr  : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
	    b_din   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
	    b_dout  : out std_logic_vector(DATA_WIDTH-1 downto 0)
	);
end component;

component gray_counter is
	generic(
		COUNTER_WIDTH : integer := 8
	);
    port (
        grey_count   :out std_logic_vector (COUNTER_WIDTH-1 downto 0);  -- Output of the counter
        en :in  std_logic;                      -- Enable counting
        clk    :in  std_logic;                      -- Input clock
        rst  :in  std_logic                       -- Input reset
    );
end component;

--constants
constant RAM_ADDR_WIDTH : integer := integer(ceil(log2(real(FIFO_DEPTH))));

--declare signals
signal wr_ptr : std_logic_vector(RAM_ADDR_WIDTH-1 downto 0) := (others=>'0');
signal rd_ptr : std_logic_vector(RAM_ADDR_WIDTH-1 downto 0) := (others=>'0');
signal ram_read_en : std_logic := '0';
signal ram_write_en : std_logic := '0';

signal preset_fifo_full : std_logic := '0';
signal fifo_empty : std_logic := '1';
signal check_equal_addr : std_logic := '0';
signal going_full, going_empty : std_logic := '0';
signal quadrant_status : std_logic := '0'; --1 indicates going full, 0 indicates going empty

begin

wr_ptr_counter_inst: gray_counter
generic map(
	COUNTER_WIDTH=>RAM_ADDR_WIDTH
)
port map(
	clk=>wr_clk,
	en=>ram_write_en,
	rst=>clear,
	grey_count=>wr_ptr
);

rd_ptr_counter_inst: gray_counter
generic map(
	COUNTER_WIDTH=>RAM_ADDR_WIDTH
)
port map(
	clk=>rd_clk,
	en=>ram_read_en,
	rst=>clear,
	grey_count=>rd_ptr
);

check_equal_addr <= '1' when wr_ptr=rd_ptr else '0';

--'Quadrant selectors' logic:
process (wr_ptr, rd_ptr)
    variable set_status_bit0 :std_logic;
    variable set_status_bit1 :std_logic;
    variable rst_status_bit0 :std_logic;
    variable rst_status_bit1 :std_logic;
begin
    set_status_bit0 := wr_ptr(RAM_ADDR_WIDTH-2) xnor rd_ptr(RAM_ADDR_WIDTH-1);
    set_status_bit1 := wr_ptr(RAM_ADDR_WIDTH-1) xor  rd_ptr(RAM_ADDR_WIDTH-2);
    going_full <= set_status_bit0 and set_status_bit1;
    
    rst_status_bit0 := wr_ptr(RAM_ADDR_WIDTH-2) xor  rd_ptr(RAM_ADDR_WIDTH-1);
    rst_status_bit1 := wr_ptr(RAM_ADDR_WIDTH-1) xnor rd_ptr(RAM_ADDR_WIDTH-2);
    going_empty      <= rst_status_bit0 and rst_status_bit1;
end process;

--'quadrant_status' latch logic:
process (going_full, going_empty, clear) begin
    if (going_empty = '1' or Clear = '1') then
        quadrant_status <= '0';  --Going 'Empty'
    elsif (going_full = '1') then
        quadrant_status <= '1';  --Going 'Full'
    end if;
end process;

preset_fifo_full <= quadrant_status and check_equal_addr;
fifo_empty <= not(quadrant_status) and check_equal_addr;

full_flag <= preset_fifo_full;
empty_flag <= fifo_empty;

ram_write_en <= not(preset_fifo_full) and wr_en;
ram_read_en <= not(fifo_empty) and rd_en;

tdp_ram_inst: true_dual_port_ram
generic map(
	DATA_WIDTH=>DATA_WIDTH,
	ADDR_WIDTH=>RAM_ADDR_WIDTH
)
port map(
	-- Port A
    a_clk=>wr_clk,
    a_wr=>wr_en,
    a_addr=>wr_ptr,
    a_din=>wr_data,
    a_dout=>open,
     
    -- Port B
    b_clk=>rd_clk,
    b_wr=>'0',
    b_addr=>rd_ptr,
    b_din=>(others=>'0'),
    b_dout=>rd_data
);

end behave;



