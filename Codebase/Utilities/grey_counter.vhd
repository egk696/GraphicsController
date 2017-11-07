library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity gray_counter is
	generic(
		COUNTER_WIDTH : integer := 8
	);
    port (
        grey_count   :out std_logic_vector (COUNTER_WIDTH-1 downto 0);  -- Output of the counter
        en :in  std_logic;                      -- Enable counting
        clk    :in  std_logic;                      -- Input clock
        rst  :in  std_logic                       -- Input reset
    );
end gray_counter;

architecture behave of gray_counter is

    signal count : unsigned(COUNTER_WIDTH-1 downto 0) := (others=>'0');
begin

    process (clk, rst, en) begin
        if (rst = '1') then
            count <= (others=>'0');
        elsif (rising_edge(clk)) then
            if (en = '1') then
                count <= count + 1;
            end if;
        end if;
        grey_count <= std_logic_vector(count(COUNTER_WIDTH-1) & (count(COUNTER_WIDTH-2 downto 0) xor count(COUNTER_WIDTH-1 downto 1)));
    end process;

end behave;