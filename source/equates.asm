;---------> SYSTEM LOCATIONS --------------------------------------------
;
VBLANK_SYNC70 equ $70
VID_DBASEHI equ $FF8201
VID_DBASELO equ $FF8202
VID_COLOR0 equ $FF8240
VID_COLOR2 equ $FF8244 ;  VID_COLOUR2 comes from Debug in Hatari
VID_COLOR8 equ $FF8250
VID_SHIFTMD equ $FF8260; Video Shifter Mode for changing resolution?

;STATIC VALUES, not pointers!
VALUE_HIDE_BULLET equ $FFFF
MAX_PLAYER_LIVES equ $9 ; check against this value but the max is actually one less If >9 = 8
SCREEN_SIZE_LONGS equ $1F3F ;32000/4 -1	Number of longs inside the image data MINUS 1
VALUE_BUFFER_SIZE equ $7E00 ; 32256 used for screen buffer size, 30,000 screen size plus a sprite buffer?
VALUE_SCREEN_SIZE equ $7D00 ; 32256 used for screen buffer size, 30,000 screen size plus a sprite buffer?
VALUE_SCREEN_WIDTH equ $13F ; 320 minus 1
VALUE_SCREEN_HEIGHT equ $C7 ;200 minus 1
VALUE_CENTIPEDE_SPRITE_END equ $30; originally $30 (3rd sprite in the data chunk), if you increase this will start showing numbers!
; the next 3 are all the same value C0 but might want to split them up in order to change the game!
Y_COORD_LOW_ENEMY equ $C0 ; 192, i think that this is Y location of the bottom enemy
MAX_VERTICAL_GRID equ $C0 ; 192, i think that this is Y location of the bottom of the background / grid
MAX_VERTICAL_DRAW equ $C0 ; 192 stop drawing bullets and enemies when they hit this vertical position?
; the next 3 are all the same value 130 but split them up in order to change the game!
MAX_HORIZONTAL_DRAW equ $130 ; 304, the cut off for sprites and drawing
VALUE_XGRID_MAX equ $130 ; 304, can't see what this does look at it in the debugger.
;Bottom enemy speeds up after death! Not a bug it happens in the original! Not caused by XGRID
MAX_HORIZONTAL_CENTIPEDE equ $130 ; 304, the cut off for the enemy
VALUE_SPRITE_BUFFER_TERMINATE equ $FFFFFE0C ; what does this relate to? MC6850 ACIA $FFFC00 is keyb,$FFFC04 is the MIDI. Or even a negative number? would be minus 499 in decimal
STATUS_REGISTER_SETTINGS equ $3200 ; 0011001000000000 - Sets Bit #9, Bit #12 and Bit #13
DRAW_SETTING_00 equ $0
DRAW_SETTING_01 equ $1
DRAW_SETTING_GRID equ $2 ; grid,
DRAW_SETTING_03 equ $3 ; anything greater than this is it's own setting.
DRAW_SETTING_PLAYER equ $4  ;player ship
DRAW_SETTING_07 equ $7 ; bullet,left side NME, bottom NME,
DRAW_SETTING_08 equ $8 ; unknown code below Bottom NME, Enemy lasers ( need to double check )
VAL_STARTING_LIVES equ $5 ; With $A or greater it wraps around the screen! Max should be 9
VALUE_STARTING_PLAYER_YPOS equ $8C ;140
VALUE_STARTING_PLAYER_XPOS equ $98 ;152
DEFAULT_X_SCREEN_BUFFER equ $10 ; 16
DEFAULT_Y_SCREEN_BUFFER equ $A ; 10
CLAMP_PLAYER_Y_LOW equ $50 ; 80
CLAMP_PLAYER_Y_HIGH equ $B7 ; 183
CLAMP_PLAYER_X_LOW equ $8 ; 8
CLAMP_PLAYER_X_HIGH equ $12F ; 303
LEFT_MOUSE_BUTTON equ $1
RIGHT_MOUSE_BUTTON equ $2 ; doesnt work need to get a different bit or maybe d1 I think?
RESTORE_SCREENDOWN equ $1E ; decimal 30. this might be used in multiple places
VALUE_PROJECTILE_LOOP equ $1E ; don't think this is the same as above, maximum projectiles maybe?
SIZE_PROJECTILE_DATA equ $3FF ; 1023, data in bytes maybe? the above is the amount of entries? 34 x 30 = 1020
LOOP_CLEAN_HUD equ $F9 ; 249. From the top of the screen down is the height / depth of the entire HUD.
DEFAULT_LASER_COUNTDOWN equ $3030 ; 30 is the default the 2nd 30 is the restore value when we hit zero.
DEFAULT_ENEMY_RESET equ $8 ; used by both the bottom and side enemy, reset the start location
MAX_BOTTOM_COORDINATE equ $127 ; 295
MAX_SIDE_COORDINATE equ $B8 ; 184
VALUE_BULLET_HEIGHT equ $8 ; only for collision checks I think
BUILD_GRID_INCREMENT equ $A0 ; 160
STARTING_LOCATION_ADDITION equ $100 ; 256
STARTING_LOCATION_FILTER equ $FFFF00; 1111 1111 1111 1111 0000 0000
FILTER_248 equ $F8 ; 1111 1000
DEFAULT_VALUE_254 equ $FE
DEFAULT_VALUE_8224 equ $2020
DATA_CHUNK_PROJECTILE equ $40
VALUE_ALIGNMENT equ $FF ; dec 255
VALUE_VALIDATION equ $FE ; dec 254