LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use work.math_pack.all;

ENTITY sincos_lut_rom IS
PORT (
	clock: IN std_logic;
	address: IN unsigned(9 downto 0);
	data_out: OUT integer
);
END sincos_lut_rom;

ARCHITECTURE sincos_lut OF sincos_lut_rom IS

BEGIN

PROCESS (clock)
BEGIN
	IF rising_edge (clock) THEN
		case address(9) is
			when '1'=> data_out <= cos_lut(to_integer(address));
			when '0'=> data_out <= sin_lut(to_integer(address));
		end case;
	END IF;
	END PROCESS;
END sincos_lut;