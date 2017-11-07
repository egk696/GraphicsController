library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;


entity mastertb is
end entity mastertb;

architecture behave of mastertb is
    constant DATA_WIDTH : integer := 8;
    constant clk_period : time := 10 ns; --10MHz
    constant sclk_period : time := 125 ns; --8MHz
    constant test_data : std_logic_vector(7 downto 0) := "10101001";
    
    signal clk : std_logic := '0';
    signal slaveData : std_logic_vector(7 downto 0) := (others => '0');
    signal reset : std_logic := '0'; --inv
    signal tx_start : std_logic := '0';
    signal done : std_logic := '0';
    signal ss : std_logic := '0';
    signal mosi : std_logic := '0';
    signal sclk : std_logic := '0';

    begin

        spi_master_inst : entity work.SPI_Master
        generic map(
            DATA_WIDTH => DATA_WIDTH
        )
        port map(
              --Out port
            o_sclk => sclk,
            o_mosi => mosi,
            o_ss => ss,
            o_tx_end => done,
            o_data_rx => slaveData,
            i_data_tx => test_data,
            i_miso => '0',
            i_clk => clk,
            i_reset => reset,
            i_tx_start => tx_start      
        );

        clk_process : process
            begin
                clk <= '0';
                wait for clk_period/2;
                clk <= '1';
                wait for clk_period/2; 
            end process;
        

        process is
            begin       
                wait until rising_edge(clk);
                wait until rising_edge(clk);
                --Exit reset state
                reset <= '1';        
                tx_start <= '1';
                wait until rising_edge(done);
                reset <= '0';        
                tx_start <= '0';
                wait until rising_edge(clk);
                wait until rising_edge(clk);
            end process;
    
end behave;