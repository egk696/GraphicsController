library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity embedded_pixie_top is
	port(
		SYS_CLK		: in std_logic;
		SYS_RST		: in std_logic;
		--RAM
		DRAM_DQ		: inout std_logic_vector(31 downto 0);
		DRAM_DQM	: out std_logic_vector(3 downto 0);
		DRAM_CKE	: out std_logic;
		DRAM_CLK	: out std_logic;
		DRAM_CS_N	: out std_logic;
		DRAM_WE_N	: out std_logic;
		DRAM_RAS_N	: out std_logic;
		DRAM_CAS_N	: out std_logic
		--SPI
		--VGA
	);
end embedded_pixie_top;

architecture structure of embedded_pixie_top is

begin

end structure;

