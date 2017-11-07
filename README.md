# GraphicsController
Development of an FPGA-based graphics controller

# Goals
The goal is create an FPGA-based graphics accelerator

## Setup
Currently an VGA evaluation demo is built for the DE2-115 board which can display 3 hardware animated primitive shapes (2x rectangles, 1x circle)
at different resolutions, selectable from the two first switches (1 downto 0) found on the development board.

Selectable display resolutions:
* "00" => 800x600
* "01" => 1024x768
* "10" => 1152x864
* "11" => 1280x1024

## Known issues
Setting the display at 1152x864 resolution might not work at all displays.

## In progress...
* Implement user selectable hardware primitive shapes.
* Create an SDRAM video buffer supporting double-buffering.
