library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
 
entity true_dual_port_ram is
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
end true_dual_port_ram;
 
architecture behave of true_dual_port_ram is
	-- Build a 2-D array type for the RAM
	type mem_type is array ( (2**ADDR_WIDTH)-1 downto 0 ) of std_logic_vector(DATA_WIDTH-1 downto 0);
    -- Declare the shared RAM
    shared variable mem : mem_type  := (others=>(others=>'0'));
	--signal mem : memory_t;
begin
 
-- Port A
process(a_clk)
begin
    if rising_edge(a_clk) then
        if(a_wr='1') then
            mem(to_integer(unsigned(a_addr))) := a_din;
        	-- Read-during-write on the same port returns NEW data
        	a_dout <= a_din; 
        else
        	a_dout <= mem(to_integer(unsigned(a_addr))); -- Read-during-write on the mixed port returns OLD data
    	end if;
    end if;
end process;
 
-- Port B
process(b_clk)
begin
    if rising_edge(b_clk) then
        if b_wr='1' then
            mem(to_integer(unsigned(b_addr))) := b_din;
            -- Read-during-write on the same port returns NEW data
        	b_dout <= b_din; 
        else
        	b_dout <= mem(to_integer(unsigned(b_addr))); -- Read-during-write on the mixed port returns OLD data
    	end if;
    end if;
end process;
 
end behave;
