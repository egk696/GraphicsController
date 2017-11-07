library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FrameBufferManagement is
	Generic( PIXEL_SHARES	: Integer := 2;
				EXT_SHARES		: Integer := 2);
    Port ( clk	: in std_logic := '0';
           rst	: in std_logic := '0';
           en	: in std_logic := '0';
			  --external avalon master interface
			  avs_address : in std_logic_vector(19 downto 0) := (others=>'0');
			  avs_read : in std_logic := '0';
			  avs_readdata : out std_logic_vector(15 downto 0) := (others=>'0');
			  avs_write : in std_logic := '0';
			  avs_writedata : in std_logic_vector(15 downto 0) := (others=>'0');
			  avs_waitrequest : out std_logic := '0';
			  avs_byteenable	: in std_logic_vector(1 downto 0) := (others=>'0');
			  avs_readdatavalid : out std_logic := '0';
			  --memory
			  mem_address		: out std_logic_vector(19 downto 0) := (others=>'0');
			  mem_byteenable	: out std_logic_vector(1 downto 0) := (others=>'0');
			  mem_read			: out std_logic := '0';
			  mem_write			: out std_logic := '0';
			  mem_writedata	: out std_logic_vector(15 downto 0) := (others=>'0');
			  mem_readdata		: in std_logic_vector(15 downto 0) := (others=>'0');
			  mem_datavalid	: in std_logic := '0';
			  --fifo
			  fifo_full			: in std_logic := '0';
			  wr_fifo_en		: out std_logic := '0';
			  fifo_writedata	: out std_logic_vector(55 downto 0) := (others=>'0'));
end FrameBufferManagement;

architecture behave of FrameBufferManagement is

	type scrubbing_state_type is (ST_IDLE, ST_REQ_PIXEL_1, ST_REQ_PIXEL_2);
	constant PIXEL_BIT_WIDTH : integer range 0 to PIXEL_SHARES := integer(ceil(log2(real(PIXEL_SHARES))));
	constant EXT_BIT_WIDTH : integer range 0 to EXT_SHARES := integer(ceil(log2(real(EXT_SHARES))));
	
	signal pixel_rd_grant, ext_rd_grant				: std_logic	:= '0';	--read arbitration grant
	signal pixel_wr_grant, ext_wr_grant				: std_logic	:= '0';	--write arbitration grant
	
	signal current_scrubbing_state : scrubbing_state_type := ST_IDLE;
	signal next_scrubbing_state : scrubbing_state_type;
	signal current_pixel_data, next_pixel_data 	: std_logic_vector(31 downto 0) := (others=>'0');
	signal current_pixel_addr, next_pixel_addr 	: unsigned(19 downto 0) := (others=>'0');
	signal current_pixel_valid, next_pixel_valid : std_logic := '0';
	signal current_pixel_rd_req, next_pixel_rd_req : std_logic := '0';
	
	signal current_ext_shares, next_ext_shares		: unsigned(PIXEL_BIT_WIDTH-1 downto 0) := (others=>'0');
	signal current_pixel_shares, next_pixel_shares	: unsigned(EXT_BIT_WIDTH-1 downto 0) := (others=>'0');
	
begin

reg_scrubbing_state: process(clk, rst)
begin
	if rst = '1' then
		current_scrubbing_state <= ST_IDLE;
		current_pixel_data <= (others=>'0');
		current_pixel_addr <= (others=>'0');
		current_pixel_valid <= '0';
	elsif rising_edge(clk) then
		current_scrubbing_state <= next_scrubbing_state;
		current_pixel_data <= next_pixel_data;
		current_pixel_addr <= next_pixel_addr;
		current_pixel_valid <= next_pixel_valid;
		current_pixel_rd_req <= next_pixel_rd_req;
	end if;
end process;

logic_scrubbing_state: process(mem_address, mem_byteenable, mem_read, mem_write, mem_writedata, mem_readdata, mem_datavalid)
begin
	--avoid latch
	next_scrubbing_state <= current_scrubbing_state;
	next_pixel_data <= current_pixel_data;
	next_pixel_addr <= current_pixel_addr;
	next_pixel_valid <= current_pixel_valid;
	next_pixel_rd_req <= current_pixel_rd_req;
	--FSM
	case current_scrubbing_state is
		when ST_IDLE=>
			next_pixel_valid <= '0';
			if ext_wr_grant='0' and ext_rd_grant='0' and fifo_full='0' then
				next_pixel_rd_req <= '1';
				next_scrubbing_state <= ST_REQ_PIXEL_1;
			end if;
		when ST_REQ_PIXEL_1=>
			if pixel_rd_grant <= '1' and mem_datavalid='1' then
				next_pixel_data(15 downto 0) <= mem_readdata;
				next_pixel_rd_req <= '1';
				next_scrubbing_state <= ST_REQ_PIXEL_2;
			end if;
		when ST_REQ_PIXEL_2=>
			if pixel_rd_grant <= '1' and mem_datavalid='1' then
				next_pixel_data(31 downto 16) <= mem_readdata;
				next_pixel_rd_req <= '0';
				next_pixel_valid <= '1';
				next_pixel_addr <= current_pixel_addr + 1;
				next_scrubbing_state <= ST_IDLE;
			end if;
		when others=>
			next_scrubbing_state <= ST_IDLE;
	end case;
end process;

reg_shares: process(clk, rst)
begin
	if rst = '1' then
		current_ext_shares <= to_unsigned(PIXEL_SHARES, PIXEL_BIT_WIDTH);
		current_pixel_shares <= to_unsigned(EXT_SHARES, EXT_BIT_WIDTH);
	elsif rising_edge(clk) then
		current_pixel_shares <= next_pixel_shares;
		current_ext_shares <= next_ext_shares;
	end if;
end process;

abitration_logic: process(current_ext_shares, current_pixel_shares)
begin
	if current_pixel_rd_req='1' and current_pixel_shares > 0 then
		next_pixel_shares <= current_pixel_shares - 1;
		next_ext_shares <= current_ext_shares;
		pixel_rd_grant <= '1';
		ext_rd_grant <= '0';
		ext_wr_grant <= '0';
	elsif avs_read='1' and current_ext_shares > 0 then
		next_pixel_shares <= current_pixel_shares;
		next_ext_shares <= current_ext_shares - 1;
		pixel_rd_grant <= '0';
		ext_rd_grant <= '1';
		ext_wr_grant <= '0';
	elsif avs_read='0' and current_ext_shares > 0 then
		next_pixel_shares <= current_pixel_shares;
		next_ext_shares <= current_ext_shares;
		pixel_rd_grant <= '0';
		ext_rd_grant <= '0';
		ext_wr_grant <= '1';
	else
		next_pixel_shares <= to_unsigned(PIXEL_SHARES, PIXEL_BIT_WIDTH);
		next_ext_shares <= to_unsigned(EXT_SHARES, EXT_BIT_WIDTH);
		pixel_rd_grant <= '0';
		ext_rd_grant <= '0';
		ext_wr_grant <= '0';
	end if;
end process;

--external
avs_waitrequest <= (avs_read and not(ext_rd_grant)) or (avs_write and not(ext_wr_grant));
avs_readdatavalid <= mem_datavalid when ext_rd_grant='1' else '0';
avs_readdata <= mem_readdata when ext_rd_grant='1' else (others=>'0');
--memory out
mem_address	<= std_logic_vector(current_pixel_addr) when pixel_rd_grant='1' and current_pixel_rd_req='1' else avs_address;
mem_byteenable	<= (others=>'1') when pixel_rd_grant='1' and current_pixel_rd_req='1' else avs_byteenable;
mem_read	<= current_pixel_rd_req when pixel_rd_grant='1' else avs_read;
mem_write <= '0' when pixel_rd_grant='1' else avs_write;
mem_writedata <= (others=>'0') when pixel_rd_grant='1' else avs_writedata;
--fifo out
wr_fifo_en <= current_pixel_valid;
fifo_writedata <= std_logic_vector(resize(current_pixel_addr, 32)) & current_pixel_data(23 downto 0);

end behave;

