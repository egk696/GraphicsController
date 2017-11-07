library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;

entity spi_master is
    generic(
        DATA_WIDTH      : integer := 8
    ); 
    port(
        --Out port
       o_sclk       : out std_logic := '1';
       o_mosi       : out std_logic := '0';
       o_ss         : out std_logic := '1'; 
       o_tx_end     : out std_logic := '0'; 
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

    signal sclk      : std_logic := '0';
    signal Tx_Data   : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal Bit_Index : integer range 0 to DATA_WIDTH-1 := 0;
    signal Tx_Done   : std_logic := '0';

    type spi_controller_state is 
    (
        ST_IDLE,
        ST_RESET,
        ST_TX_RX,
        ST_END
    );

    signal st_current   : spi_controller_state;
    signal st_next      : spi_controller_state := ST_IDLE;



begin

    p_state : process(i_clk, i_reset)
    begin
        if(i_reset='0') then
            st_current <= ST_RESET;
        elsif(rising_edge(i_clk)) then
            st_current <= st_next;
        end if;
    end process p_state;
    
    p_sclk : process(i_clk)
        begin
            if rising_edge(i_clk) then
                sclk <= '0';
            else
                sclk <= '1';
            end if;
            if(i_tx_start = '1') then
                o_sclk <= sclk;
            else
                o_sclk <= '1';
            end if;                           
    end process p_sclk;

    p_spi : process(sclk)
    begin
        if falling_edge(sclk) then

            case st_current is

                when ST_IDLE =>
                    o_ss <= '1';
                    o_mosi <= '0';
                    Tx_Done <= '0';
                    Bit_Index <= 0;
                    if(i_reset='1' and i_tx_start = '1') then
                        Tx_Data <= i_data_tx;
                        o_ss <= '0';
                        st_next <= ST_TX_RX;
                    else
                        st_next <= ST_IDLE;
                    end if;

                when ST_RESET =>
                    o_ss <= '1';
                    o_mosi <= '0';
                    Tx_Done <= '0';
                    Bit_Index <= 0;
                    Tx_Data <= (others => '0');
                    st_next <= ST_IDLE;

                when ST_TX_RX =>
                    o_mosi <= Tx_Data(Bit_Index);
                    

                    if Bit_Index < DATA_WIDTH-1 then
                        Bit_Index <= Bit_Index + 1;
                        st_next <= ST_TX_RX;
                    else
                        Bit_Index <= 0;
                        st_next <= ST_END;
                    end if;
                    
                when ST_END =>
                    o_ss <= '1';
                    o_mosi <= '0';    
                    Tx_Done <= '1';
                    Bit_Index <= 0;
                    st_next <= ST_IDLE;

                when others =>
                    st_next <= ST_IDLE;
            end case;
        else
        end if;
       
    end process p_spi;

    o_tx_end <= Tx_Done;

end behave; 