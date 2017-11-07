----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/20/2017 04:12:29 AM
-- Design Name: 
-- Module Name: vga_pack
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

package math_pack is

  type sincos_lut_rom_t is array(0 to 359) of integer;
 
  function init_sin_rom return sincos_lut_rom_t;
  function init_cos_rom return sincos_lut_rom_t;
  
  constant sin_lut : sincos_lut_rom_t := init_sin_rom;
  constant cos_lut : sincos_lut_rom_t := init_cos_rom;
	 
end package math_pack;

package body math_pack is

	-- function computes contents of cosine lookup ROM
  function init_sin_rom return sincos_lut_rom_t is
    variable lut : sincos_lut_rom_t; 
  begin
    for angle in 0 to 359 loop
		lut(angle) := integer(sin(real(angle) * MATH_DEG_TO_RAD));
	 end loop;
    return lut;
  end function init_sin_rom;
  
   function init_cos_rom return sincos_lut_rom_t is
    variable lut : sincos_lut_rom_t; 
	begin
		for angle in 0 to 359 loop
			lut(angle) := integer(cos(real(angle) * MATH_DEG_TO_RAD));
		end loop;
    return lut;
  end function init_cos_rom;


end package body;

