library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;

entity spi_master is
    generic(
        DATA_WIDTH      : integer := 8;
        SLAVE_DEVICES   : integer := 1;
        CLK_DIV         : integer := 100 --o_sclk fc = i_clk/(2*CLK_DIV)
    ); 
    port(
        --Out port
       o_sclk       : out std_logic;
       o_mosi       : out std_logic;
       o_ss         : out std_logic; 
       o_tx_end     : out std_logic; 
       o_data_rx    : out std_logic_vector(DATA_WIDTH-1 downto 0); -- data received
        --In port
       i_data_tx    : in std_logic_vector(DATA_WIDTH-1 downto 0); -- data to send
       i_miso       : in std_logic;
       --Control
       i_clk        : in std_logic;
       i_reset      : in std_logic;
       i_tx_start   : in std_logic -- Start TX
    );
end spi_master;

architecture behave of spi_master is

    type spi_controller_state is 
    (
        ST_RESET,
        ST_TX_RX,
        ST_END
    );

    signal st_current   : spi_controller_state;
    signal st_next      : spi_controller_state;


begin

    p_state : process(i_clk, i_reset)
    begin
        if(i_reset='0') then
            st_current <= ST_RESET;
        elsif(rising_edge(i_clk)) then
            st_current <= st_next;
        end if;
    end process p_state;
    



end behave 