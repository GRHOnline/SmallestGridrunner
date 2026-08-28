Smallest Gridrunner

Very early Atari ST's had a much smaller amount of RAM than the later models and as such are quite rare so I decided to base my next project on a low memory ST game.
In my testing I was able to run Gridrunner on the Hatari emulator with only 256kiB of RAM. If you have one of those rare machines please test this and let me know how it goes.
The game has no sound, just use the mouse to move your ship and button 1 to fire / restart after death.

The original decompilation can be found here. https://github.com/mwenge/gridrunner.
This is an update of the mwenge's decompilation where I have tried to remove any hard coded addresses and set it up for use with a modern assembler.
VASM was used with the following settings "vasmm68k_mot gridrunner.asm -m68000 -Ftos -o smallgrid.prg"


