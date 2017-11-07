library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;


entity tb is
end entity tb;

architecture behave of tb is

    constant DATA_WIDTH : integer := 8;
    constant clk_period : time := 10 ns; --10MHz
    constant sclk_period : time := 125 ns; --8MHz
    constant test_data : std_logic_vector(7 downto 0) := "00000001";
    signal index : integer := 0;
    

    signal clk : std_logic := '0';
    signal sclk : std_logic := '0';
    signal reset : std_logic := '0';
    signal mosi : std_logic := '0';
    signal ss : std_logic := '1';
    signal tx_start : std_logic := '0';
    signal indat : std_logic_vector(DATA_WIDTH-1 downto 0) := "11111111";
    signal miso : std_logic := '0';
    signal miso_buf : std_logic_vector(DATA_WIDTH-1 downto 0):= (others=>'0');
    signal done :std_logic := '0';
    signal outdat : std_logic_vector(DATA_WIDTH-1 downto 0) := (others=>'0');

        -- Low-level byte-write
    procedure WRITE_BYTE (
        i_data_in       : in  std_logic_vector(7 downto 0);
        signal o_serial : out std_logic) is
    begin   
        -- Send Data Byte
        for ii in 0 to 7 loop
            o_serial <= i_data_in(ii);
            wait for sclk_period;
        end loop;  -- ii
    end WRITE_BYTE;
 


    begin
        spi_slave_inst : entity work.SPI_Slave
            generic map(
                DATA_WIDTH => DATA_WIDTH
            )
            port map(
                i_clk => clk,       
                i_sclk => sclk,   
                i_rst => reset, 
                i_mosi => mosi, 
                i_ss => ss,
                i_tx_send => tx_start,
                i_in_data => indat,     
                o_miso => miso,
                o_done => done,  
                o_out_data => outdat
            );

        sclk_process : process
            begin
                sclk <= '0';
                wait for sclk_period/2;
                sclk <= '1';
                wait for sclk_period/2;
            end process;

        clk_process : process
            begin
                clk <= '0';
                wait for clk_period/2;
                clk <= '1';
                wait for clk_period/2; 
            end process;
    
        process is
            begin       
                wait until rising_edge(sclk);
                wait until rising_edge(sclk);
                --Exit reset state
                reset <= '1';        

                wait until rising_edge(sclk);
                --Pull SS
                ss <= '0';

                for ii in 0 to 7 loop
                    wait until rising_edge(sclk);
                    mosi <= test_data(ii);     
                end loop;
                --Pull SS Low send complete
                wait until rising_edge(sclk);
                ss <= '1';
                mosi <= '0';
                wait until rising_edge(sclk);          
                reset <= '0';
                wait until rising_edge(sclk); 
            end process;

            rx_miso : process(sclk)
            begin
                if rising_edge(sclk) then
                     if ss = '0' then
                        tx_start <= '1';
                        miso_buf <= miso_buf(DATA_WIDTH-2 downto 0) & miso;
                    end if;
                end if;
            end process;
end behave;