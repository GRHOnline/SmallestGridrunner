<b>Smallest Gridrunner</b>

Very early Atari ST's had a much smaller amount of RAM than the later models and as such are quite rare so I decided to base my next project on a low memory ST game.
In my testing I was able to run Gridrunner on the Hatari emulator with the following settings :- 
* Only 256kiB of RAM.
* 512kib of Ram but boots TOS from a floppy ( Emulated 260ST )
  
If you have one of those rare machines please test this and let me know how it goes.
The game should be run in Low resolution and has no sound, just use the mouse to move your ship and button 1 to fire / restart after death.
Instead of restarting after running out of lives press mouse button 2 to quit.

The original decompilation can be found here. https://github.com/mwenge/gridrunner.
This is an update of the mwenge's decompilation where I have tried to remove any hard coded addresses and set it up for use with a modern assembler.
VASM was used with the following settings "vasmm68k_mot gridrunner.asm -m68000 -Ftos -o smalgrid.prg"

According to VASM this program should take up 82116 bytes of memory ( not including the ST's default screen buffer ) so there should be plenty of room for adding more stuff.

I have added a small program for creating the monochrome sprites from a bitmap located in the "sprite_editor" folder.
The title screen is just the raw/uncompressed palette and screen data from a standard .NEO file



