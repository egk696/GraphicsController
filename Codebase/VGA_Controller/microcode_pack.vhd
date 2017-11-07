library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package microcode_pack is
	constant PRIMITIVE_OPCODE_WIDTH : integer := 2;
	--primitive opcodes
	constant OP_RECT : std_logic_vector(PRIMITIVE_OPCODE_WIDTH-1 downto 0) := "00";
	constant OP_CIRC : std_logic_vector(PRIMITIVE_OPCODE_WIDTH-1 downto 0) := "01";
	constant OP_TRIA : std_logic_vector(PRIMITIVE_OPCODE_WIDTH-1 downto 0) := "10";
	constant OP_NOP	: std_logic_vector(PRIMITIVE_OPCODE_WIDTH-1 downto 0) := "11";
	
end package microcode_pack;

