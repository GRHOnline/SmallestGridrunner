; This is the reverse-engineered source code for the game 'Gridrunner' written by Jeff Minter in 1983.
;
; The code in this file was created by disassembling a binary of the game released into
; the public domain by Jeff Minter in 2019.
;
; The original code from which this source is derived is the copyright of Jeff Minter.
;
; The original home of this file is at: https://github.com/mwenge/gridrunner
;
;
; ===========================================================================
	comment HEAD=0001;<VASM> TOSFLAG = PF_TTRAMLOAD
    SECTION TEXT ;<VASM>
	include "equates.asm"
; ---------------------------------------------------------------------------
				move.w	#3,-(sp)	;Logbase / screen address
				trap	#14		;XBIOS
				addq.l	#2,sp

				move.l	d0,(lPointerScreenBufferA).l		;Use the default Atari screen as Screen A. We know it is free and correctly aligned

                ; Enter supervisor mode
                move.l  #0,-(sp)        ; Move Data from Source to Destination
                move.w  #$20,-(sp) ; GEMDOS SUPER
                trap    #1              ; Trap (#vector Exception)
                adda.l  #6,sp           ; Add Address

                move.b  #0,(VID_SHIFTMD).l  ; Set screen mode to 320x200 with 16 colours

                move.l  #func_JustReturn,lPointerRunFunctionVBL ; Move Data from Source to Destination
                clr.w   wVBlankLogicActive      
                clr.w   wGameLogicActive      ; Clear an Operand

                movea.l #(wPaletteArray),a0 ; Move Address
                jsr     func_LoadColourPalette       ; Jump to Subroutine
				
				move.l	#Array_ScreenBufferB,(lPointerScreenBufferB).l ; merge the above two lines into 1
				clr.l	d2
				move.b	#VALUE_ALIGNMENT,d2
				move.l	lPointerScreenBufferB,d3
				sub.b	d3,d2
				;only add if d2 hasn't changed after the minus
				cmpi.b	#VALUE_ALIGNMENT,d2
				beq.b	SKIP_ADDITION
				add.l	d2,lPointerScreenBufferB
				add.l	#1,lPointerScreenBufferB ; we need to add 1 to go from FF to 100
				
SKIP_ADDITION:
				move.l	#Array_ScreenBufferC,(lPointerScreenBufferC).l ; merge the above two lines into 1

                move.l  #MouseVector,-(sp) ; vector for mouse
                move.l  #lMouseParameters,-(sp) ; parameter block address
                move.w  #1,-(sp)        ; Move Data from Source to Destination
                clr.w   -(sp)           ; XBIOS 0 Initmouse
                trap    #$E             ; Trap (#vector Exception)
                adda.l  #$C,sp          ; Tidy the stack

                move.l  #vbl_routine,(VBLANK_SYNC70).l ; Point to the routine to fire on VBLANK
                move    #STATUS_REGISTER_SETTINGS,sr ;Set Interrupt Priority Mask, Bit #12  and Supervisor State to 1 			
				;----------------------------------------------------------------------
				move.l #Array_SpriteBuffer0,lPointerSpriteBuffer0 ; need to update the pointers to match the data
				move.l #Array_SpriteBuffer1,lPointerSpriteBuffer1 ; POINTER_PROJECTILE_DATA
				move.l	#func_FirstInAddressList,lAddressListX3
				move.l	#func_SecondInAddressList,lAddressListX3+$4
				move.l	#func_ThirdInAddressList,lAddressListX3+$8
				;---------------------------------------------------------------------------------
				move.l	#VALUE_SPRITE_BUFFER_TERMINATE,Array_SpriteBuffer0 ; replace the two lines of code
				move.l	#VALUE_SPRITE_BUFFER_TERMINATE,Array_SpriteBuffer1 ; replace the above two lines
                clr.l   lScoreHigh      ; Removing to shrink the code 6 bytes each
                clr.l   lScoreLow      ; Clear an Operand
                move.b  #VAL_STARTING_LIVES,wPlayerLives   ; Move Data from Source to Destination
                bsr.w   SETUP_ALL_SCREEN_BUFFERS       ; Branch to Subroutine
                move.b  #1,wLivesUpdateHUD   ; Move Data from Source to Destination
                bsr.w   BUFFERC_DRAWHUD       ; Branch to Subroutine
				
                move.l  (lPointerScreenBufferA).l,d0   ; Move Data from Source to Destination
                ; Just getting the High Value of the buffer for the VIDHI?
				lsr.l   #8,d0           ; Logical Shift Right
				;graphics already drawn and only the screen pointer is shifted!
                lea     (VID_DBASEHI).l,a0  ; Get Screen address? Debug 1268a
				;old address of the video is 0f 00 80 00 0f 00 fa fe
                movep.w d0,0(a0)        ; Change the screen to a backup value HEX 16c
				;new address of the video is 01 00 6c 00 0f 00 b7 00
                movep.w d0,0(a0)        ; Why is this done twice?
				
				
                bra.w   AWAIT_MOUSE_PRESS00       ; Branch Always
; ---------------------------------------------------------------------------
;was loc_12696:
RESTART_GAME_SCREENS:                              
                move.w  #DEFAULT_LASER_COUNTDOWN,bEnemyLaserCountdown ; Move Data from Source to Destination
                move.w  (wRestoreCountdownLevelUp).l,(wCountdownLevelUp).l ; Move Data from Source to Destination
                move.w  #RESTORE_SCREENDOWN,(wScreendrawCountdown).l ; Move Data from Source to Destination
                clr.b   bGameLogicCountdown      ; Clear an Operand
                clr.b   bSideCountdownY      ; Clear an Operand
                clr.b   bProjectileCountdown      ; Clear an Operand
                clr.b   wCurrentLevel      ; Clear an Operand
                bsr.w   CHANGE_LEVELS       ; Branch to Subroutine
                clr.l   lScoreHigh      ; Clear an Operand
                clr.l   lScoreLow      ; Clear an Operand
                move.b  #VAL_STARTING_LIVES,wPlayerLives   ; Move Data from Source to Destination
                bsr.w   SETUP_ALL_SCREEN_BUFFERS       ; Branch to Subroutine
                move.b  #1,wLivesUpdateHUD   ; Move Data from Source to Destination
				move.l	#Array_ScreenBufferB,a0   ;  copy the value and not the pointers address!
                move.w  #LOOP_CLEAN_HUD,d0         ; Move Data from Source to Destination

loc_126F6:                              ; CODE XREF: ROM:000126F8↓j
                clr.l   (a0)+           ; Clear an Operand
                dbf     d0,loc_126F6    ; If False Decrement and Branch
                move.w  #VALUE_STARTING_PLAYER_YPOS,(wPlayerY).l ; Move Data from Source to Destination
                move.w  #VALUE_STARTING_PLAYER_XPOS,(wPlayerX).l ; Move Data from Source to Destination
                bsr.w   CYCLE_THROUGH_VALUES_d0       ; Branch to Subroutine
                andi.w  #3,d0           ; AND Immediate
                addi.w  #1,d0           ; Add Immediate
                move.w  d0,wXzapperSpeed   ; Move Data from Source to Destination
                bsr.w   CYCLE_THROUGH_VALUES_d0       ; Branch to Subroutine
                andi.w  #1,d0           ; AND Immediate
                addi.w  #1,d0           ; Add Immediate
                move.w  d0,wYzapperSpeed   ; Move Data from Source to Destination
				lea     Array_CollisionsOnGrid,a0
                move.w  #SIZE_PROJECTILE_DATA,d0        ; Move Data from Source to Destination

loc_1273A:                              ; CODE XREF: ROM:0001273C↓j
                clr.l   (a0)+           ; Clear an Operand
                dbf     d0,loc_1273A    ; If False Decrement and Branch
                move.w  #VALUE_HIDE_BULLET,wPlayerBulletX ; Move Data from Source to Destination
                move.l  #UPDATE_GAME_LOGIC,lPointerRunFunctionVBL ; Game Logic will updated from VBL!

loc_12752:                              ; CODE XREF: ROM:00012764↓j
                jsr     NO_LIVES_RESTART       ; Jump to Subroutine
                cmpi.b  #0,wPlayerLives   ; Compare Immediate
                beq.w   NO_LIVES_DETECTED       ; Branch if Equal
                jmp     loc_12752       ; Jump

;-------------------------------------------------------------------------
; was sub_1276A:
;-------------------------------------------------------------------------
CHANGE_LEVELS: ; is fired when the game starts or the player loses all lives as well!
                                   ; CODE XREF: ROM:000126C8↑p
                                        ; UPDATE_GAME_LOGIC+34↓p
                move.b  wCurrentLevel,d0   ; Starts at 0 , turns D0 into 100
                andi.w  #3,d0           ; AND Immediate ; flatten to 0
                ext.w   d0              ; Sign Extend
                lea     (GRID_PALETTE_UPDATES).l,a0 ; Load Effective Address
                asl.w   #1,d0           ; Arithmetic Shift Left
                move.w  (a0,d0.w),(VID_COLOR2).l ; Move Data from Source to Destination
                asl.w   #1,d0           ; Arithmetic Shift Left
                lea     (UPDATE_GAME_LEVEL).l,a0 ; Load Effective Address
                lea     (a0,d0.w),a0    ; Load Effective Address
                move.b  (a0)+,d0        ; Move Data from Source to Destination
                move.b  wCurrentLevel,d1   ; Calculate new enemy strength from the current level
                asr.b   #3,d1           ; Arithmetic Shift Right
                add.b   d1,d0           ; Add
                move.b  d0,wEnemyLevel   ; Move Data from Source to Destination
				;move.b  #3,wEnemyLevel   ; Changing this can disable the Centipede and Bomb Spawners
                clr.b   bSideCountdownY      ; Clear an Operand
                move.b  (a0)+,bScaledRestoreCountdownY ; A value pulled from updategames data ( 4 x 4 bytes ) dependant on what level the game is.
                move.b  (a0)+,bMaxCountdownPlusLevel ; Move Data from Source to Destination
                move.b  (a0)+,bRestoreProjectileCountdown ; Move Data from Source to Destination
                rts                     ; Return from Subroutine

; ---------------------------------------------------------------------------
	SECTION DATA;<VASM>
GRID_PALETTE_UPDATES:
		INCBIN "updatepal.bin" ;was "byte_127BE.bin" the two colours of the grid ( red and then blue )
UPDATE_GAME_LEVEL:
		INCBIN "updategame.bin" ; was "byte_127C6" changing values causes crashes!
; ---------------------------------------------------------------------------
	SECTION TEXT;<VASM>
NO_LIVES_DETECTED:                              ; CODE XREF: ROM:00012760↑j
                bsr.w   NO_LIVES_RESTART       ; Branch to Subroutine

AWAIT_MOUSE_PRESS00:                              ; CODE XREF: ROM:00012692↑j
				btst    #LEFT_MOUSE_BUTTON,(wMouseButton).l ; Test a Bit
                bne.s   AWAIT_MOUSE_PRESS00       ; Branch if Not Equal

AWAIT_MOUSE_PRESS01:                              ; CODE XREF: ROM:000127F0↓j
				btst    #LEFT_MOUSE_BUTTON,(wMouseButton).l ; Test a Bit
                bne.w   RESTART_GAME_SCREENS       ; Branch if Not Equal
                bra.s   AWAIT_MOUSE_PRESS01       ; Branch Always
; ---------------------------------------------------------------------------
                rte                     ; Return from Exception

; =============== S U B R O U T I N E =======================================


;-------------------------------------------------------------------------
; was sub_127F4:
;-------------------------------------------------------------------------
SETUP_ALL_SCREEN_BUFFERS:
                                   ; CODE XREF: ROM:0001266C↑p
                                        ; ROM:000126E0↑p
                movea.l (lPointerScreenBufferC).l,a0   ; Move Address
                bsr.w   CLEAR_SCREEN_BUFFER_A0       ; Branch to Subroutine
                lea     (Pattern_Gridparts).l,a0 ;Hex Values of byte_1324E = 03 00 03 00 03 00 FF FF                           ........
				;draw the grid starts here!
                movea.l (lPointerScreenBufferC).l,a1   ; Move Address
                move.w  #DEFAULT_X_SCREEN_BUFFER,d0         ; Move Data from Source to Destination

loc_1280E:                              ; CODE XREF: SETUP_ALL_SCREEN_BUFFERS+3E↓j
                move.w  #DEFAULT_Y_SCREEN_BUFFER,d1          ; Move Data from Source to Destination

loc_12812:                              ; CODE XREF: SETUP_ALL_SCREEN_BUFFERS+34↓j
                move.w  #DRAW_SETTING_GRID,d2           ; Move Data from Source to Destination
                movea.l (lPointerScreenBufferA).l,a2   ; Move Address
                bsr.w   DRAW_FUNCTION       ; Branch to Subroutine
                addi.w  #8,d1           ; Add Immediate
                cmp.w   #MAX_VERTICAL_GRID,d1         ; Compare
                blt.s   loc_12812       ; Branch if Less Than
                addi.w  #$10,d0         ; Add Immediate
                cmp.w   #$138,d0        ; Compare
                blt.s   loc_1280E       ; Branch if Less Than
                bsr.w   COPY_BUFFER_C_TO_ALL       ; Branch to Subroutine
                rts                     ; Return from Subroutine
; End of function SETUP_ALL_SCREEN_BUFFERS


; =============== S U B R O U T I N E =======================================


;-------------------------------------------------------------------------
; func_LoadColourPalette:
;-------------------------------------------------------------------------
func_LoadColourPalette:
                                   ; CODE XREF: ROM:000125E2↑p
                lea     (VID_COLOR0).l,a1  ; Load the palette starting at entry 0
                move.w  #$F,d1          ; 16 colours in the palette

loc_12844:                              ; CODE XREF: func_LoadColourPalette+C↓j
                move.w  (a0)+,(a1)+     ; Move Data from Source to Destination
                dbf     d1,loc_12844    ; Loop through all the colours
                rts                     ; Return from Subroutine


; =============== S U B R O U T I N E =======================================


;-------------------------------------------------------------------------
; sub_1284C:
;-------------------------------------------------------------------------
PROJECTILES_FUNCTION:
                                   ; CODE XREF: ROM:00012E5C↓p

; FUNCTION CHUNK AT 0001295C SIZE 0000001C BYTES
				;After screen creation, this hits when score and lives are cleared out.
                bsr.w   LOOP_THROUGH_PROJECTILE_DATA       ; Branch to Subroutine
                tst.w   wPlayerBulletX      ; Test an Operand - don't draw bullet if we don't have to
                bmi.s   loc_12872       ; Branch if Minus
                move.w  wPlayerBulletX,d0   ; Move Data from Source to Destination
                move.w  wPlayerBulletY,d1   ; Move Data from Source to Destination
                move.w  #DRAW_SETTING_07,d2           ; Move Data from Source to Destination
                lea     (Pattern_BulletPlayer).l,a0 ; Load Effective Address
                bsr.w   DRAW_FUNCTION       ; Branch to Subroutine

loc_12872:                              ; CODE XREF: PROJECTILES_FUNCTION+A↑j
                clr.w   d0              ; Clear an Operand
                move.w  (wYzapperCoordinate).l,d1 ; Move Data from Source to Destination
                lea     (Pattern_yZapper).l,a0 ; Load Effective Address
                move.w  #DRAW_SETTING_07,d2           ; Move Data from Source to Destination 
                bsr.w   DRAW_FUNCTION       ; Branch to Subroutine
                move.w  #Y_COORD_LOW_ENEMY,d1         ; Move Data from Source to Destination
                move.w  (wXzapperCoordinate).l,d0 ; Move Data from Source to Destination
                lea     (Pattern_xZapper).l,a0 ; Load Effective Address
                bsr.w   DRAW_FUNCTION       ; Branch to Subroutine
                btst    #0,(wGameLogicActive).l   ; is Logic Zero?
                beq.s   func_IsLogicOne       ; Branch if Equal
                move.w  #DRAW_SETTING_08,d2           ; Move Data from Source to Destination
                move.w  #8,d1           ; Move Data from Source to Destination
                move.w  wBottomLaserSetting,d0   ; Move Data from Source to Destination
				lea     (Pattern_VerticalLaser).l,a0   ; change made here, think it works! not sure

loc_128BA:                              ; CODE XREF: PROJECTILES_FUNCTION+7A↓j
                bsr.w   DRAW_FUNCTION       ; Branch to Subroutine
                addi.w  #8,d1           ; Add Immediate
                cmp.w   #Y_COORD_LOW_ENEMY,d1         ; Compare
                blt.s   loc_128BA       ; Branch if Less Than
                move.w  wSideLaserX,d0   ; Move Data from Source to Destination
                move.w  wSideLaserY,d1   ; Move Data from Source to Destination
                lea     (Pattern_HorizontalLaser).l,a0 ; Load Effective Address
                bsr.w   DRAW_FUNCTION       ; Branch to Subroutine

;was loc_128DE
func_IsLogicOne:                              ; CODE XREF: PROJECTILES_FUNCTION+58↑j
                btst    #1,(wGameLogicActive).l   ; Test a Bit
                beq.s   PLAYER_DRAW       ; Branch if Equal
                move.w  bColourFlasher,d3   ; Move Data from Source to Destination
                asl.w   #2,d3           ; Arithmetic Shift Left
                move.w  #DRAW_SETTING_07,d2           ; Move Data from Source to Destination

loc_128F4:                              ; CODE XREF: PROJECTILES_FUNCTION+E6↓j
                move.w  (wPlayerX).l,d0 ; Move Data from Source to Destination
                move.w  (wPlayerY).l,d1 ; Move Data from Source to Destination
                lea     (Pattern_Explosion).l,a0 ; Load Effective Address
                sub.w   d3,d0           ; Subtract
                bsr.s   PlayerExplosion       ; Branch to Subroutine
                sub.w   d3,d1           ; Subtract
                bsr.s   PlayerExplosion       ; Branch to Subroutine
                add.w   d3,d0           ; Add
                bsr.s   PlayerExplosion       ; Branch to Subroutine
                add.w   d3,d0           ; Add
                bsr.s   PlayerExplosion       ; Branch to Subroutine
                add.w   d3,d1           ; Add
                bsr.s   PlayerExplosion       ; Branch to Subroutine
                add.w   d3,d1           ; Add
                bsr.s   PlayerExplosion       ; Branch to Subroutine
                sub.w   d3,d0           ; Subtract
                bsr.s   PlayerExplosion       ; Branch to Subroutine
                sub.w   d3,d0           ; Subtract
                bsr.s   PlayerExplosion       ; Branch to Subroutine
                subi.w  #8,d3           ; Subtract Immediate
                bmi.w   RTS_COMMAND    ; Branch if Minus
                subi.w  #1,d2           ; Subtract Immediate
                bne.s   loc_128F4       ; Branch if Not Equal
                rts                     ; Return from Subroutine
; End of function PROJECTILES_FUNCTION


; =============== S U B R O U T I N E =======================================


;-------------------------------------------------------------------------
; PlayerExplosion:
;-------------------------------------------------------------------------
PlayerExplosion:
                                   ; CODE XREF: PROJECTILES_FUNCTION+BC↑p
                                        ; PROJECTILES_FUNCTION+C0↑p ...
                tst.w   d0              ; Test an Operand
                bmi.w   RTS_COMMAND    ; Branch if Minus
                cmp.w   #MAX_HORIZONTAL_DRAW,d0        ; Compare
                bge.w   RTS_COMMAND    ; Branch if Greater or Equal
                tst.w   d1              ; Test an Operand
                bmi.w   RTS_COMMAND    ; Branch if Minus
				cmp.w   #MAX_VERTICAL_DRAW,d1         ; Compare
                bge.w   RTS_COMMAND    ; Branch if Greater or Equal
                move.w  d3,-(sp)        ; Move Data from Source to Destination
                bsr.w   DRAW_FUNCTION       ; Branch to Subroutine
                move.w  (sp)+,d3        ; Move Data from Source to Destination
                rts                     ; Return from Subroutine
; End of function PlayerExplosion

; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR PROJECTILES_FUNCTION

PLAYER_DRAW:                              ; CODE XREF: PROJECTILES_FUNCTION+9A↑j
                move.w  (wPlayerX).l,d0 ; Move Data from Source to Destination
                move.w  (wPlayerY).l,d1 ; Move Data from Source to Destination
                lea     (Pattern_Player).l,a0 ; Load Effective Address
                move.w  #DRAW_SETTING_PLAYER,d2           ; Move Data from Source to Destination
                jmp     DRAW_FUNCTION       ; Jump
; END OF FUNCTION CHUNK FOR PROJECTILES_FUNCTION

; =============== S U B R O U T I N E =======================================


;-------------------------------------------------------------------------
; was sub_12978:
;-------------------------------------------------------------------------
vbl_routine:
                                   ; DATA XREF: ROM:00012632↑o
                movem.l d0-a6,-(sp)     ; Move Multiple Registers
                tst.w   wVBlankLogicActive      ; Test an Operand
                beq.s   RUN_VBL_FUNCTION       ; Branch if Equal
                clr.w   wVBlankLogicActive      ; Clear an Operand

RUN_VBL_FUNCTION:                              ; was loc_1298A CODE XREF: vbl_routine+A↑j
                movea.l lPointerRunFunctionVBL,a0   ; 129AC ends up jumping to 0129ba, UPDATE_GAME_LOGIC
                jsr     (a0)            ; Jump to Subroutine
                movem.l (sp)+,d0-a6     ; Move Multiple Registers
                rte                     ; Return from Exception
; End of function vbl_routine


; =============== S U B R O U T I N E =======================================


;-------------------------------------------------------------------------
; was sub_12998:
;-------------------------------------------------------------------------
UPDATE_GAME_LOGIC:
                                   ; DATA XREF: ROM:00012748↑o
                subi.w  #1,(wCountdownLevelUp).l ; Subtract Immediate
                bpl.s   CHECK_LIFE_LOST       ; Branch if Plus
INCREASE_LIVES:
                addi.b  #1,wCurrentLevel   ; Add Immediate
                addi.b  #1,wPlayerLives   ; If we change levels then we get an extra life
                cmpi.b  #MAX_PLAYER_LIVES,wPlayerLives   ; Cannot go higher than 9 or we get screen warp
                blt.s   loc_129C4       ; Branch if Less Than
                move.b  #MAX_PLAYER_LIVES-1,wPlayerLives   ; Check for 9 and set 9 minus 1

loc_129C4:                              ; CODE XREF: UPDATE_GAME_LOGIC+22↑j
                move.b  #1,wLivesUpdateHUD   ; Move Data from Source to Destination
                bsr.w   CHANGE_LEVELS       ; Branch to Subroutine
                move.w  (wRestoreCountdownLevelUp).l,(wCountdownLevelUp).l ; Move Data from Source to Destination

CHECK_LIFE_LOST:                              ; was loc_129DA	CODE XREF: UPDATE_GAME_LOGIC+8↑j
                addi.w  #1,bColourFlasher   ; This is where our flash value is updated!
                btst    #1,(wGameLogicActive).l   ; Test a Bit
                beq.s   NOT_LOST_UPDATE       ; Branch if Equal
                btst    #6,bPlayerDisable   ; Test a Bit
                beq.s   NOT_LOST_UPDATE       ; Branch if Equal
LIFE_LOST_UPDATE:
                clr.w   bColourFlasher      ; Clear an Operand
                bclr    #1,(wGameLogicActive).l   ; Test a Bit and Clear
				clr.b   (wMouseButton).l ; Only use this when we are not trying to match the original!
                subi.b  #1,wPlayerLives   ; Subtract Immediate
                move.b  #1,wLivesUpdateHUD   ; Move Data from Source to Destination

NOT_LOST_UPDATE:  ; was loc_12A1A
                                        ; UPDATE_GAME_LOGIC+5C↑j
                move.w  bColourFlasher,(VID_COLOR8).l ; Move Data from Source to Destination
                move.w  wOldPlayerX,d0   ; Move Data from Source to Destination
                move.w  wOldPlayerY,d1   ; Move Data from Source to Destination
                bsr.w   func_CalculateNewLocation0       ; Branch to Subroutine
                clr.b   (a1)            ; Clear an Operand
                move.w  (wPlayerX).l,d0 ; Move Data from Source to Destination
                move.w  d0,wOldPlayerX   ; Move Data from Source to Destination
                move.w  (wPlayerY).l,d1 ; Move Data from Source to Destination
                move.w  d1,wOldPlayerY   ; Move Data from Source to Destination
                bsr.w   func_CalculateNewLocation0       ; Branch to Subroutine
                move.b  #DEFAULT_VALUE_254,(a1)       ; <GRH> this is causing a random blue chunk on screen!
				btst    #LEFT_MOUSE_BUTTON,(wMouseButton).l ; Test a Bit
                beq.s   loc_12A86       ; Branch if Equal
                btst    #1,(wGameLogicActive).l   ; Test a Bit
                bne.s   loc_12A86       ; Branch if Not Equal
                tst.w   wPlayerBulletX      ; Test an Operand
                bpl.s   loc_12A86       ; Branch if Plus
                move.w  (wPlayerY).l,wPlayerBulletY ; Move Data from Source to Destination
                move.w  (wPlayerX).l,wPlayerBulletX ; Move Data from Source to Destination

loc_12A86:                              ; CODE XREF: UPDATE_GAME_LOGIC+C6↑j
                                        ; UPDATE_GAME_LOGIC+D0↑j ...
                tst.w   wPlayerBulletX      ; Test an Operand
                bmi.s   loc_12ADA       ; Branch if Minus
                move.w  wPlayerBulletX,d0   ; Move Data from Source to Destination
                move.w  wPlayerBulletY,d1   ; Move Data from Source to Destination
                bsr.w   func_CalculateNewLocation0       ; Branch to Subroutine
                clr.b   (a1)            ; Clear an Operand
                clr.b   -1(a1)          ; Clear an Operand
                subi.w  #VALUE_BULLET_HEIGHT,wPlayerBulletY   ; Subtract Immediate
                cmpi.w  #VALUE_BULLET_HEIGHT,wPlayerBulletY   ; Compare Immediate
                bge.s   loc_12AC0       ; Branch if Greater or Equal
                move.w  #VALUE_HIDE_BULLET,wPlayerBulletX ; Move Data from Source to Destination
                bra.s   loc_12ADA       ; Branch Always
; ---------------------------------------------------------------------------

loc_12AC0:                              ; CODE XREF: UPDATE_GAME_LOGIC+11C↑j
                move.w  wPlayerBulletX,d0   ; Move Data from Source to Destination
                move.w  wPlayerBulletY,d1   ; Move Data from Source to Destination
                bsr.w   func_CalculateNewLocation0       ; Branch to Subroutine
                move.b  #$FF,(a1)       ; Move Data from Source to Destination
                move.b  #$FF,-1(a1)     ; Move Data from Source to Destination

loc_12ADA:                              ; CODE XREF: UPDATE_GAME_LOGIC+F4↑j
                                        ; UPDATE_GAME_LOGIC+126↑j
                bsr.w   func_jump2projectilecode       ; Branch to Subroutine
                btst    #0,(wGameLogicActive).l   ; Test a Bit
                beq.s   loc_12B54       ; Branch if Equal
                addi.w  #7,wSideLaserX   ; Add Immediate
                move.w  wBottomLaserSetting,d0   ; Move Data from Source to Destination
                asr.w   #4,d0           ; Arithmetic Shift Right
                move.w  (wPlayerX).l,d1 ; Move Data from Source to Destination
                asr.w   #4,d1           ; Arithmetic Shift Right
                cmp.w   d0,d1           ; Compare
                beq.w   loc_12B24       ; Branch if Equal
                move.w  wSideLaserX,d0   ; Move Data from Source to Destination
                cmp.w   d0,d1           ; Compare
                bne.s   loc_12B2E       ; Branch if Not Equal
                move.w  (wPlayerY).l,d1 ; Move Data from Source to Destination
                asr.w   #4,d1           ; Arithmetic Shift Right
                move.w  wSideLaserY,d2   ; Move Data from Source to Destination
                asr.w   #4,d2           ; Arithmetic Shift Right
                cmp.w   d1,d2           ; Compare
                bne.s   loc_12B2E       ; Branch if Not Equal

loc_12B24:                              ; CODE XREF: UPDATE_GAME_LOGIC+16A↑j
                bsr.w   sub_13082       ; Branch to Subroutine
                move.w  wSideLaserX,d0   ; Move Data from Source to Destination

loc_12B2E:                              ; CODE XREF: UPDATE_GAME_LOGIC+176↑j
                                        ; UPDATE_GAME_LOGIC+18A↑j
                cmp.w   wBottomLaserSetting,d0   ; Compare
                ble.s   loc_12B8C       ; Branch if Less or Equal
                bclr    #0,(wGameLogicActive).l   ; Test a Bit and Clear
                bsr.w   sub_12CC6       ; Branch to Subroutine
                beq.s   loc_12B8C       ; Branch if Equal
                move.w  wSideLaserX,d0   ; Move Data from Source to Destination
                move.w  wSideLaserY,d1   ; Move Data from Source to Destination
                bsr.w   func_SetupEnemyPOD       ; Branch to Subroutine

loc_12B54:                              ; CODE XREF: UPDATE_GAME_LOGIC+14E↑j
                subi.b  #1,bEnemyLaserCountdown   ; Subtract Immediate
                bpl.s   loc_12B8C       ; Branch if Plus
                move.b  bEnemyLaserRestore,bEnemyLaserCountdown ; Move Data from Source to Destination
                move.w  #DEFAULT_ENEMY_RESET,wSideLaserX   ; Move Data from Source to Destination
                move.w  (wXzapperCoordinate).l,wBottomLaserSetting ; Move Data from Source to Destination
                move.w  (wYzapperCoordinate).l,wSideLaserY ; Move Data from Source to Destination
                bset    #0,(wGameLogicActive).l   ; Test a Bit and Set

loc_12B8C:                              ; CODE XREF: UPDATE_GAME_LOGIC+19C↑j
                                        ; UPDATE_GAME_LOGIC+1AA↑j ...
                move.w  (wXzapperCoordinate).l,d0 ; Move Data from Source to Destination
                add.w   wXzapperSpeed,d0   ; Add
                cmp.w   #MAX_BOTTOM_COORDINATE,d0        ; Compare
                blt.s   loc_12BA2       ; Branch if Less Than
                move.w  #DEFAULT_ENEMY_RESET,d0           ; Move Data from Source to Destination

loc_12BA2:                              ; CODE XREF: UPDATE_GAME_LOGIC+204↑j
                move.w  d0,(wXzapperCoordinate).l ; Move Data from Source to Destination
                move.w  (wYzapperCoordinate).l,d0 ; Move Data from Source to Destination
                add.w   wYzapperSpeed,d0   ; Add
                cmp.w   #MAX_SIDE_COORDINATE,d0         ; Compare
                blt.s   loc_12BBE       ; Branch if Less Than
                move.w  #DEFAULT_ENEMY_RESET,d0           ; Move Data from Source to Destination

loc_12BBE:                              ; CODE XREF: UPDATE_GAME_LOGIC+220↑j
                move.w  d0,(wYzapperCoordinate).l ; Move Data from Source to Destination
                tst.b   bSideCountdownY      ; Test an Operand
                beq.s   loc_12BEC       ; Branch if Equal
                subi.b  #1,bProjectileCountdown   ; Subtract Immediate
                bpl.w   RTS_COMMAND    ; Branch if Plus
                move.b  bRestoreProjectileCountdown,bProjectileCountdown ; Move Data from Source to Destination
                subi.b  #1,bSideCountdownY   ; Subtract Immediate
                bra.s   func_FirstProjectileWrite       ; Branch Always
; ---------------------------------------------------------------------------

loc_12BEC:                              ; CODE XREF: UPDATE_GAME_LOGIC+232↑j
                subi.b  #1,bGameLogicCountdown   ; Subtract Immediate
                bpl.w   RTS_COMMAND    ; Branch if Plus
                move.b  bMaxCountdownPlusLevel,bGameLogicCountdown ; Move Data from Source to Destination
                move.b  bScaledRestoreCountdownY,d0   ; Move Data from Source to Destination
                addi.b  #3,d0           ; Add Immediate
                ext.w   d0              ; Sign Extend
                cmp.w   (wScreendrawCountdown).l,d0 ; Compare
                bge.w   RTS_COMMAND    ; Branch if Greater or Equal
                bclr    #3,(wGameLogicActive).l   ; Test a Bit and Clear
                bsr.w   CYCLE_THROUGH_VALUES_d0       ; Branch to Subroutine
                btst    #0,d0           ; Test a Bit
                beq.s   loc_12C32       ; Branch if Equal
                bset    #3,(wGameLogicActive).l   ; Test a Bit and Set

loc_12C32:                              ; CODE XREF: UPDATE_GAME_LOGIC+290↑j
                move.b  bScaledRestoreCountdownY,bSideCountdownY ; Move Data from Source to Destination
;was loc_12C3C
func_FirstProjectileWrite:                              ; CODE XREF: UPDATE_GAME_LOGIC+252↑j
                bsr.w   sub_12CC6       ; Branch to Subroutine
                move.w  #$10,2(a0)      ; the address in a0 is for sprite buffers?
                move.w  #8,4(a0)        ; Move Data from Source to Destination
                move.l  #(Pattern_GridSearchSquad),6(a0) ; Move Data from Source to Destination
                move.w  #5,$E(a0)       ; Move Data from Source to Destination
                clr.w   $12(a0)         ; Clear an Operand
                move.b  wEnemyLevel,$13(a0) ; Move Data from Source to Destination
                clr.w   $14(a0)         ; Clear an Operand
                move.w  #3,(a0)         ; Move Data from Source to Destination
                btst    #2,wCurrentLevel   ; Test a Bit
                beq.s   loc_12C7E       ; Branch if Equal
                move.w  $12(a0),$14(a0) ; Move Data from Source to Destination

loc_12C7E:                              ; CODE XREF: UPDATE_GAME_LOGIC+2DE↑j
                btst    #3,(wGameLogicActive).l   ; Test a Bit
                beq.w   RTS_COMMAND    ; Branch if Equal
                move.w  #VALUE_XGRID_MAX,2(a0)     ; Move Data from Source to Destination
                neg.w   $12(a0)         ; Negate
                rts                     ; Return from Subroutine
; End of function UPDATE_GAME_LOGIC


; =============== S U B R O U T I N E =======================================


;-------------------------------------------------------------------------
; was sub_12C96:
;-------------------------------------------------------------------------
func_SetupEnemyPOD:
                                   ; CODE XREF: UPDATE_GAME_LOGIC+1B8↑p
                                        ; ROM:000131C6↓j
                move.w  d0,2(a0)        ; Move Data from Source to Destination
                move.w  d1,4(a0)        ; Move Data from Source to Destination
                move.l  #(Pattern_Pods),6(a0) ; Move Data from Source to Destination
                move.w  #DEFAULT_VALUE_8224,$A(a0)   ; Move Data from Source to Destination
                move.w  #3,$C(a0)       ; Move Data from Source to Destination
                move.w  #6,$E(a0)       ; Move Data from Source to Destination
                move.w  #1,(a0)         ; Move Data from Source to Destination
                bsr.w   func_CalculateNewLocation1       ; Branch to Subroutine
                move.b  #1,(a1)         ; Move Data from Source to Destination
                rts                     ; Return from Subroutine
; End of function func_SetupEnemyPOD


; =============== S U B R O U T I N E =======================================


;-------------------------------------------------------------------------
; sub_12CC6:
;-------------------------------------------------------------------------
sub_12CC6:
                                   ; CODE XREF: UPDATE_GAME_LOGIC+1A6↑p
                                        ; UPDATE_GAME_LOGIC:func_FirstProjectileWrite↑p
                tst.w   (wScreendrawCountdown).l  ; Test an Operand
                bne.s   loc_12CD2       ; Branch if Not Equal
                clr.w   d2              ; Clear an Operand
                rts                     ; Return from Subroutine
; ---------------------------------------------------------------------------

loc_12CD2:                              ; CODE XREF: sub_12CC6+6↑j
				lea     Array_CollisionsOnGrid,a0   ; Load Effective Address

loc_12CD8:                              ; CODE XREF: sub_12CC6+1A↓j
                tst.w   (a0)            ; Test an Operand
                beq.s   loc_12CE2       ; Branch if Equal
                lea     DATA_CHUNK_PROJECTILE(a0),a0      ; Load Effective Address
                bra.s   loc_12CD8       ; Branch Always
; ---------------------------------------------------------------------------

loc_12CE2:                              ; CODE XREF: sub_12CC6+14↑j
                subi.w  #1,(wScreendrawCountdown).l ; Subtract Immediate
                move.w  #DRAW_SETTING_01,d2           ; Move Data from Source to Destination
                rts                     ; Return from Subroutine


;-------------------------------------------------------------------------
; was sub_12CF0:
;-------------------------------------------------------------------------
MouseVector:
                                   ; DATA XREF: ROM:00012618↑o
                btst    #1,(wGameLogicActive).l   ; Test a Bit
                bne.w   RTS_COMMAND    ; Branch if Not Equal
				move.b  (a0),(wMouseButton).l ; Move Data from Source to Destination
                move.b  1(a0),(wMouseX).l ; Move Data from Source to Destination
                move.b  2(a0),(wMouseY).l ; Move Data from Source to Destination
                movem.w d0-d1,-(sp)     ; Move Multiple Registers
                move.b  (wMouseY).l,d1 ; Move Data from Source to Destination
                neg.b   d1              ; Negate
                ext.w   d1              ; Sign Extend
                move.w  (wPlayerY).l,d0 ; Move Data from Source to Destination
                add.w   d1,d0           ; Add
                cmp.w   #CLAMP_PLAYER_Y_LOW,d0 ; 'P'   ; Compare
                bge.s   loc_12D32       ; Branch if Greater or Equal
                move.w  #CLAMP_PLAYER_Y_LOW,d0 ; 'P'   ; Move Data from Source to Destination

loc_12D32:                              ; CODE XREF: MouseVector+3C↑j
                cmp.w   #CLAMP_PLAYER_Y_HIGH,d0         ; Compare
                ble.s   loc_12D3C       ; Branch if Less or Equal
                move.w  #CLAMP_PLAYER_Y_HIGH,d0         ; Move Data from Source to Destination

loc_12D3C:                              ; CODE XREF: MouseVector+46↑j
                move.w  d0,(wPlayerY).l ; Move Data from Source to Destination
                move.b  (wMouseX).l,d1 ; Move Data from Source to Destination
                ext.w   d1              ; Sign Extend
                move.w  (wPlayerX).l,d0 ; Move Data from Source to Destination
                add.w   d1,d0           ; Add
                cmp.w   #CLAMP_PLAYER_X_LOW,d0           ; Compare
                bge.s   loc_12D5C       ; Branch if Greater or Equal
                move.w  #CLAMP_PLAYER_X_LOW,d0           ; Move Data from Source to Destination

loc_12D5C:                              ; CODE XREF: MouseVector+66↑j
                cmp.w   #CLAMP_PLAYER_X_HIGH,d0        ; Compare
                ble.s   loc_12D66       ; Branch if Less or Equal
                move.w  #CLAMP_PLAYER_X_HIGH,d0        ; Move Data from Source to Destination

loc_12D66:                              ; CODE XREF: MouseVector+70↑j
                move.w  d0,(wPlayerX).l ; Move Data from Source to Destination
                movem.w (sp)+,d0-d1     ; Move Multiple Registers
                rts                     ; Return from Subroutine
; End of function MouseVector


; =============== S U B R O U T I N E =======================================


;-------------------------------------------------------------------------
; was sub_12D72:
;-------------------------------------------------------------------------
DRAW_FUNCTION:
;copying data to buffer loop. Source = a0, Destination = a2, X = d0, Y = d1, Type (maybe Size?) = d2
                                   ; CODE XREF: SETUP_ALL_SCREEN_BUFFERS+28↑p
                                        ; PROJECTILES_FUNCTION+22↑p ...
                movem.l d0-d1/a0,-(sp)  ; Backup relevant registers!
                asl.w   #2,d1           ; Arithmetic Shift Left
                lea     (Array_StaticLocationsForGrid).l,a4 ; Load Effective Address
                move.l  (a4,d1.w),d1    ; Move Data from Source to Destination
                lea     (a1,d1.w),a4    ; Load Effective Address
                move.w  (wDrawLoop).l,d1 ; Move Data from Source to Destination
                move.w  d0,d4           ; Move Data from Source to Destination
                andi.w  #$F,d4          ; AND Immediate
                asr.w   #1,d0           ; Arithmetic Shift Right
                andi.w  #$1F8,d0        ; AND Immediate
                lea     (a4,d0.w),a4    ; Load Effective Address
                move.l  a4,d0           ; Move Data from Source to Destination
                sub.l   a1,d0           ; Subtract
                move.l  d0,(a2)+        ; Move Data from Source to Destination

loc_12DA2:                              ; CODE XREF: DRAW_FUNCTION+A8↓j
                clr.l   d0              ; Clear an Operand
                move.w  (a0)+,d0        ; Move Data from Source to Destination
                ror.l   d4,d0           ; Rotate Right (Without Extend)
                move.l  d0,d3           ; Move Data from Source to Destination
                eori.l  #$FFFFFFFF,d3   ; Exclusive OR Immediate
                and.w   d3,(a4)         ; AND Logical
                and.w   d3,2(a4)        ; AND Logical
                and.w   d3,4(a4)        ; AND Logical
                and.w   d3,6(a4)        ; AND Logical
                swap    d3              ; Swap Register Halves
                and.w   d3,8(a4)        ; AND Logical
                and.w   d3,$A(a4)       ; AND Logical
                and.w   d3,$C(a4)       ; AND Logical
                and.w   d3,$E(a4)       ; AND Logical
                btst    #DRAW_SETTING_00,d2           ; Test a Bit
                beq.s   loc_12DE0       ; Branch if Equal
                or.w    d0,(a4)         ; Inclusive-OR Logical
                swap    d0              ; Swap Register Halves
                or.w    d0,8(a4)        ; Inclusive-OR Logical
                swap    d0              ; Swap Register Halves

loc_12DE0:                              ; CODE XREF: DRAW_FUNCTION+62↑j
                btst    #DRAW_SETTING_01,d2           ; Test a Bit
                beq.s   loc_12DF2       ; Branch if Equal
                or.w    d0,2(a4)        ; Inclusive-OR Logical
                swap    d0              ; Swap Register Halves
                or.w    d0,$A(a4)       ; Inclusive-OR Logical
                swap    d0              ; Swap Register Halves

loc_12DF2:                              ; CODE XREF: DRAW_FUNCTION+72↑j
                btst    #DRAW_SETTING_GRID,d2           ; Test a Bit
                beq.s   loc_12E04       ; Branch if Equal
                or.w    d0,4(a4)        ; Inclusive-OR Logical
                swap    d0              ; Swap Register Halves
                or.w    d0,$C(a4)       ; Inclusive-OR Logical
                swap    d0              ; Swap Register Halves

loc_12E04:                              ; CODE XREF: DRAW_FUNCTION+84↑j
                btst    #DRAW_SETTING_03,d2           ; Test a Bit
                beq.s   loc_12E16       ; Branch if Equal
                or.w    d0,6(a4)        ; Inclusive-OR Logical
                swap    d0              ; Swap Register Halves
                or.w    d0,$E(a4)       ; Inclusive-OR Logical
                swap    d0              ; Swap Register Halves

loc_12E16:                              ; This should be for all options greater than 3!	CODE XREF: DRAW_FUNCTION+96↑j
                lea     $A0(a4),a4      ; Load Effective Address
                dbf     d1,loc_12DA2    ; If False Decrement and Branch
                movem.l (sp)+,d0-d1/a0  ; Restore the stored registers!
                rts                     ; Return from Subroutine
; End of function DRAW_FUNCTION


; =============== S U B R O U T I N E =======================================


;-------------------------------------------------------------------------
; COPY_BUFFER_C_TO_ALL:
;-------------------------------------------------------------------------
COPY_BUFFER_C_TO_ALL:
                                   ; CODE XREF: SETUP_ALL_SCREEN_BUFFERS+40↑p
                movea.l (lPointerScreenBufferA).l,a0   ; Move Address
                move.w  #SCREEN_SIZE_LONGS,d0       ; Move Data from Source to Destination
                movea.l (lPointerScreenBufferC).l,a1   ; Move Address
                movea.l (lPointerScreenBufferB).l,a2   ; Move Address

loc_12E3A:                              ; CODE XREF: COPY_BUFFER_C_TO_ALL+1A↓j
                move.l  (a1),(a0)+      ; Move Data from Source to Destination
                move.l  (a1)+,(a2)+     ; Move Data from Source to Destination
                dbf     d0,loc_12E3A    ; If False Decrement and Branch
                rts                     ; Return from Subroutine
; End of function COPY_BUFFER_C_TO_ALL


;-------------------------------------------------------------------------
; CLEAR_SCREEN_BUFFER_A0:
;-------------------------------------------------------------------------
CLEAR_SCREEN_BUFFER_A0: ; clearing the screen or screen buffer ( address 002681c )
                                   
        ; CODE XREF: SETUP_ALL_SCREEN_BUFFERS+6↑p
                move.w  #SCREEN_SIZE_LONGS,d0       ; Move Data from Source to Destination

loc_12E48:                              ; CODE XREF: CLEAR_SCREEN_BUFFER_A0+6↓j
                clr.l   (a0)+           ; Clear an Operand
                dbf     d0,loc_12E48    ; If False Decrement and Branch
                rts                     ; Return from Subroutine

;---------------------------------------------------------------------------------
; loc_12E50:                              
;---------------------------------------------------------------------------------
NO_LIVES_RESTART:                              
        ; CODE XREF: ROM:loc_12752↑p
                                        ; ROM:NO_LIVES_DETECTED↑p
                movea.l (lPointerScreenBufferA).l,a1   ; Move Address
                movea.l (lPointerSpriteBuffer0).l,a2 ; Move Address
                bsr.w   PROJECTILES_FUNCTION       ; Branch to Subroutine
                move.l  #VALUE_SPRITE_BUFFER_TERMINATE,(a2) ; Move Data from Source to Destination
                tst.b   wLivesUpdateHUD      ; Test an Operand
                beq.w   func_HUD_hasbeendrawn       ; Branch if Equal
                bsr.w   BUFFERC_DRAWHUD       ; Branch to Subroutine

;was loc_12E74
func_HUD_hasbeendrawn:                              ; CODE XREF: ROM:00012E6C↑j
                                        ; ROM:00012E7A↓j
                tst.w   wVBlankLogicActive      ; Test an Operand
                bne.s   func_HUD_hasbeendrawn       ; Branch if Not Equal
				;nop ; i think the loop above is a delay after death, VBL changes the test value so it's not stuck in a forever loop!
                move.l  (lPointerScreenBufferA).l,d0   ; Move Data from Source to Destination
                lsr.l   #8,d0           ; Logical Shift Right
                lea     (VID_DBASEHI).l,a0  ; Load Effective Address
                movep.w d0,0(a0)        ; Move Peripheral Data
                movep.w d0,0(a0)        ; Move Peripheral Data
                move.w  #1,wVBlankLogicActive   ; location $1576E stuck at 1?
                move.w  #1,d0           ; Move Data from Source to Destination

loc_12E9E:                              ; CODE XREF: ROM:00012EA4↓j
                cmp.w   wVBlankLogicActive,d0   ; Compare
                beq.s   loc_12E9E       ; Branch if Equal
                movea.l (lPointerSpriteBuffer1).l,a0 ; Move Address

;---------------------------------------------------------------------------------
; MainGameLoop - was loc_12eac
;---------------------------------------------------------------------------------
MainGameLoop:                              ; CODE XREF: ROM:00012EDA↓j
                move.l  (a0)+,d0        ; Move Data from Source to Destination
                bmi.s   SWAP_BUFFERS_A_B       ; Branch if Minus
                movea.l (lPointerScreenBufferB).l,a1   ; Move Address
                adda.l  d0,a1           ; Add Address
                movea.l (lPointerScreenBufferC).l,a2   ; Move Address
                adda.l  d0,a2           ; Add Address
                move.w  #7,d0           ; Move Data from Source to Destination

loc_12EC4:                              ; CODE XREF: ROM:00012ED6↓j
                move.w  #3,d1           ; Move Data from Source to Destination

loc_12EC8:                              ; CODE XREF: ROM:00012ECA↓j
                move.l  (a2)+,(a1)+     ; Move Data from Source to Destination
                dbf     d1,loc_12EC8    ; If False Decrement and Branch
                lea     $90(a1),a1      ; Load Effective Address
                lea     $90(a2),a2      ; Load Effective Address
                dbf     d0,loc_12EC4    ; If False Decrement and Branch
                bra.s   MainGameLoop       ; Branch Always
; ---------------------------------------------------------------------------

SWAP_BUFFERS_A_B:                       ;  Tested and these work fine. Starts 12edc
                move.l  (lPointerScreenBufferA).l,d4   ; Move Data from Source to Destination
                move.l  (lPointerScreenBufferB).l,(lPointerScreenBufferA).l ; Move Data from Source to Destination
                move.l  d4,(lPointerScreenBufferB).l   ; Move Data from Source to Destination
                move.l  (lPointerSpriteBuffer0).l,d4 ; Move Data from Source to Destination
                move.l  (lPointerSpriteBuffer1).l,(lPointerSpriteBuffer0).l ; Move Data from Source to Destination
                move.l  d4,(lPointerSpriteBuffer1).l ; Move Data from Source to Destination
; ---------------------------------------------------------------------------
func_JustReturn:     dc.b $4E, $75 ; was byte_12F08
; ---------------------------------------------------------------------------
;was loc_12F0A - Grid has been drawn in the buffer at this point
BUFFERC_DRAWHUD:                              ; CODE XREF: ROM:00012678↑p
                                        ; ROM:00012E70↑p
                movea.l (lPointerScreenBufferC).l,a0   ; Move Address
                movea.l a0,a1           ; Move Address
                move.w  #VALUE_SCREEN_WIDTH,d0        ; Move Data from Source to Destination

loc_12F16:                              ; CODE XREF: ROM:00012F18↓j
                clr.l   (a0)+           ; Clear an Operand
                dbf     d0,loc_12F16    ; If False Decrement and Branch
                lea     lScoreHigh,a3   ; Load Effective Address
                move.w  #7,d3           ; Move Data from Source to Destination
                move.w  #$14,d0         ; Move Data from Source to Destination
                move.w  #0,d1           ; Move Data from Source to Destination
                move.w  #8,d2           ; Move Data from Source to Destination

loc_12F32:                              ; CODE XREF: ROM:00012F58↓j
				lea     (Pattern_Numbers).l,a0   
                move.b  (a3)+,d4        ; Move Data from Source to Destination
                ext.w   d4              ; Sign Extend
                asl.w   #4,d4           ; Arithmetic Shift Left
                lea     (a0,d4.w),a0    ; Load Effective Address
                movem.l d3/a3,-(sp)     ; Move Multiple Registers
                movea.l (lPointerScreenBufferB).l,a2   ; Move Address
                bsr.w   DRAW_FUNCTION       ; Branch to Subroutine
                movem.l (sp)+,d3/a3     ; Move Multiple Registers
                addi.w  #$10,d0         ; Add Immediate
                dbf     d3,loc_12F32    ; If False Decrement and Branch
                move.w  #$AA,d0         ; Move Data from Source to Destination
;LIVES_DRAW:
                clr.w   d1              ; Clear an Operand
                move.w  #DRAW_SETTING_PLAYER,d2           ; Move Data from Source to Destination
                lea     (Pattern_Player).l,a0 ; Load Effective Address
                move.b  wPlayerLives,d3   ; Move Data from Source to Destination
                ext.w   d3              ; Sign Extend
                subi.w  #1,d3           ; Subtract Immediate
                bmi.s   loc_12F8A       ; Branch if Minus

loc_12F7A:                              ; CODE XREF: ROM:00012F86↓j
                move.w  d3,-(sp)        ; Move Data from Source to Destination
                bsr.w   DRAW_FUNCTION       ; Branch to Subroutine
                addi.w  #$10,d0         ; Add Immediate
                move.w  (sp)+,d3        ; Move Data from Source to Destination
                dbf     d3,loc_12F7A    ; If False Decrement and Branch

loc_12F8A:                              ; CODE XREF: ROM:00012F78↑j
                movea.l (lPointerScreenBufferA).l,a0   ; Move Address
                movea.l (lPointerScreenBufferB).l,a2   ; Move Address
                move.w  #VALUE_SCREEN_WIDTH,d0        ; Move Data from Source to Destination

loc_12F9A:                              ; CODE XREF: ROM:00012F9E↓j
                move.l  (a1),(a2)+      ; Move Data from Source to Destination
                move.l  (a1)+,(a0)+     ; Move Data from Source to Destination
                dbf     d0,loc_12F9A    ; If False Decrement and Branch
                clr.b   wLivesUpdateHUD      ; Clear an Operand
                rts                     ; Return from Subroutine

; =============== S U B R O U T I N E =======================================


;-------------------------------------------------------------------------
; sub_12FAA:
;-------------------------------------------------------------------------
SCORE_CONVERT_HEX2DEC: ; gets called a lot
                                   ; CODE XREF: ROM:00013100↓p
                                        ; ROM:000131BA↓p
                lea     lScoreHigh,a4   ; Load Effective Address
                add.b   d1,(a4,d0.w)    ; Add

loc_12FB4:                              ; CODE XREF: SCORE_CONVERT_HEX2DEC+24↓j
                cmpi.b  #$A,(a4,d0.w)   ; Compare Immediate
                blt.s   loc_12FD0       ; Branch if Less Than
                subi.b  #$A,(a4,d0.w)   ; Subtract Immediate
                subi.w  #1,d0           ; Subtract Immediate
                bmi.s   loc_12FD0       ; Branch if Minus
                addi.b  #1,(a4,d0.w)    ; Add Immediate
                bra.s   loc_12FB4       ; Branch Always
; ---------------------------------------------------------------------------

loc_12FD0:                              ; CODE XREF: SCORE_CONVERT_HEX2DEC+10↑j
                                        ; SCORE_CONVERT_HEX2DEC+1C↑j
                move.b  #1,wLivesUpdateHUD   ; Move Data from Source to Destination
                rts                     ; Return from Subroutine
; End of function SCORE_CONVERT_HEX2DEC


; =============== S U B R O U T I N E =======================================


;-------------------------------------------------------------------------
; was sub_12FDA:
;-------------------------------------------------------------------------
CYCLE_THROUGH_VALUES_d0:
                                   ; CODE XREF: ROM:0001270C↑p
                                        ; ROM:0001271E↑p ...
                move.w  (wCycleBackup_d0).l,d0 ; Move Data from Source to Destination
                mulu.w  #$5E5,d0        ; Unsigned Multiply
                addi.w  #$29,d0 ; ')'   ; Add Immediate
                move.w  d0,(wCycleBackup_d0).l ; Move Data from Source to Destination

RTS_COMMAND:                           ; CODE XREF: PROJECTILES_FUNCTION+DE↑j ;locret_12FEE
                                        ; PlayerExplosion+2↑j ...
                rts                     ; Return from Subroutine
; End of function CYCLE_THROUGH_VALUES_d0


; =============== S U B R O U T I N E =======================================


;-------------------------------------------------------------------------
; was sub_12FF0: 
;-------------------------------------------------------------------------
func_jump2projectilecode:
                                   ; CODE XREF: UPDATE_GAME_LOGIC:loc_12ADA↑p
				lea     Array_CollisionsOnGrid,a0   ; Load Effective Address
                move.w  #VALUE_PROJECTILE_LOOP,d7         ; Move Data from Source to Destination

loc_12FFA:                              ; CODE XREF: func_jump2projectilecode+12↓j
                tst.w   (a0)            ; Test an Operand
                bne.s   JUMP_T0_ADDRESS_IN_LIST       ; Branch if Not Equal

loc_12FFE:                              ; CODE XREF: func_jump2projectilecode+2C↓j
                lea     DATA_CHUNK_PROJECTILE(a0),a0      ; <GRH> Breaking out of the Array_CollisionsOnGrid when we shouldn't!
                dbf     d7,loc_12FFA    ; If False Decrement and Branch
                rts                     ; Return from Subroutine
; ---------------------------------------------------------------------------
;was loc_13008 - 
JUMP_T0_ADDRESS_IN_LIST:                              
                lea     (lAddressListX3).l,a1 ; Load Effective Address ; Address = $013242
                move.w  (a0),d0         ; Move Data from Source to Destination
                subi.w  #1,d0           ; Subtract Immediate
                asl.w   #2,d0           ; Arithmetic Shift Left
                movea.l (a1,d0.w),a1    ; Move Address
                jsr     (a1)            ; incorrect value in a0 will screw up a1, causes an incorrect jump
                bra.s   loc_12FFE       ; Branch Always
; End of function func_jump2projectilecode


; =============== S U B R O U T I N E =======================================


;-------------------------------------------------------------------------
; was sub_1301E:
;-------------------------------------------------------------------------
LOOP_THROUGH_PROJECTILE_DATA:
				;Lives have been draw along with the grid.
				lea     Array_CollisionsOnGrid,a3   ; Load Effective Address
                move.w  #VALUE_PROJECTILE_LOOP,d7         ; Move Data from Source to Destination
;was loc_13028
LOOP_DATA_CHUNK_NOT_ZERO:                              ; CODE XREF: LOOP_THROUGH_PROJECTILE_DATA+12↓j
                tst.w   (a3)            ; Test an Operand
                bne.s   PULL_CENTIPEDE_DRAW_FROM_DATA       ; Branch if Not Equal
;was loc_1302C
DATA_CHUNK_IS_ZERO:                              ; CODE XREF: LOOP_THROUGH_PROJECTILE_DATA+34↓j
                lea     DATA_CHUNK_PROJECTILE(a3),a3      ; Load Effective Address
                dbf     d7,LOOP_DATA_CHUNK_NOT_ZERO    ; If False Decrement and Branch
                rts                     ; Return from Subroutine
; ---------------------------------------------------------------------------
;was loc_13036:
PULL_CENTIPEDE_DRAW_FROM_DATA: ; PROJECTILE DATA ALSO INCLUDES CENTIPEDE, anythin multi-directional rather than projectile?
                movea.l 6(a3),a0        ; Move Address
                move.w  2(a3),d0        ; Move Data from Source to Destination
                move.w  4(a3),d1        ; Move Data from Source to Destination
                move.w  $E(a3),d2       ; Move Data from Source to Destination
                movem.l d7/a3,-(sp)     ; Move Multiple Registers
                bsr.w   DRAW_FUNCTION       ; Branch to Subroutine
                movem.l (sp)+,d7/a3     ; Move Multiple Registers
                bra.s   DATA_CHUNK_IS_ZERO       ; Branch Always
; End of function LOOP_THROUGH_PROJECTILE_DATA

; ---------------------------------------------------------------------------
func_SecondInAddressList: ; address $013054 
                bsr.w   func_ValidateNewLocation       ; Branch to Subroutine
                bpl.s   loc_1306A       ; Branch if Plus
                cmpi.b  #$FF,(a1)       ; Compare Immediate
                bne.w   loc_13142       ; Branch if Not Equal
                move.w  #VALUE_HIDE_BULLET,wPlayerBulletX ; Move Data from Source to Destination

loc_1306A:                              ; CODE XREF: ROM:00013058↑j
                move.w  4(a0),d0        ; Move Data from Source to Destination
                addi.w  #4,d0           ; Add Immediate
				;Drop missles from the bomb spawners will stop being drawn from here!
				cmp.w   #MAX_VERTICAL_DRAW,d0         ; Compare
                bge.w   loc_13142       ; Branch if Greater or Equal
                move.w  d0,4(a0)        ; Move Data from Source to Destination
                bra.w   loc_1314E       ; Branch Always

; =============== S U B R O U T I N E =======================================


;-------------------------------------------------------------------------
; sub_13082:
;-------------------------------------------------------------------------
sub_13082:
                                   ; CODE XREF: UPDATE_GAME_LOGIC:loc_12B24↑p
                                        ; func_ValidateNewLocation:+14↓p
                btst    #1,(wGameLogicActive).l   ; Test a Bit
                bne.w   RTS_COMMAND    ; Branch if Not Equal
                clr.w   bColourFlasher      ; Clear an Operand
                bset    #1,(wGameLogicActive).l   ; Test a Bit and Set
                rts                     ; Return from Subroutine
; End of function sub_13082


; =============== S U B R O U T I N E =======================================


;-------------------------------------------------------------------------
; sub_1309E:
;-------------------------------------------------------------------------
func_ValidateNewLocation: 

                                   ; CODE XREF: ROM:00013054↑p
                                        ; ROM:000130C0↓p ...
                bsr.w   func_CalculateNewLocation1       ; Branch to Subroutine
                tst.b   (a1)            ; Test an Operand
                bpl.w   RTS_COMMAND    ; Branch if Plus
                cmpi.b  #VALUE_VALIDATION,(a1)       ; Compare Immediate
                bne.w   loc_130BC       ; Branch if Not Equal
                move.l  a1,-(sp)        ; Move Data from Source to Destination
                bsr.w   sub_13082       ; Branch to Subroutine
                movea.l (sp)+,a1        ; Move Address
                move.b  #VALUE_VALIDATION,(a1)       ; Move Data from Source to Destination

loc_130BC:                              ; CODE XREF: func_ValidateNewLocation:+E↑j
                tst.b   (a1)            ; Test an Operand
                rts                     ; Return from Subroutine
; End of function func_ValidateNewLocation:

; ---------------------------------------------------------------------------
func_FirstInAddressList: ; this label is for my own purpose, address $0130C0 becomes 0130e2
BULLET_HITS_OR_OFF_SCREEN: ; custom pointer to here should have a value $13264
; ---------------------------------------------------------------------------

                bsr.w   func_ValidateNewLocation      ; Branch to Subroutine
                bpl.w   loc_1310E       ; Branch if Plus
                cmpi.b  #$FF,(a1)       ; Compare Immediate
                bne.w   loc_13142       ; Branch if Not Equal
                move.w  wPlayerBulletX,d0   ; Move Data from Source to Destination
                move.w  wPlayerBulletY,d1   ; Move Data from Source to Destination
                bsr.w   func_CalculateNewLocation0       ; Takes d0 & d1, shifts and adds them, new address in a1, d2 changed as well
                clr.b   (a1)            ; Not using the new address! Clear an Operand
                move.w  #VALUE_HIDE_BULLET,wPlayerBulletX ; Move Data from Source to Destination
                subi.l  #$10,6(a0)      ; Subtract Immediate
                addi.w  #1,$C(a0)       ; Add Immediate
                move.w  #7,d0           ; Move Data from Source to Destination
                move.w  #1,d1           ; Move Data from Source to Destination
                bsr.w   SCORE_CONVERT_HEX2DEC       ; lScoreHigh in a4, adds d1
                cmpi.w  #4,$C(a0)       ; Compare Immediate
                bge.s   loc_13142       ; Branch if Greater or Equal
                rts                     ; Return from Subroutine
; ---------------------------------------------------------------------------

loc_1310E:                              ; CODE XREF: ROM:000130C4↑j
                clr.b   (a1)            ; Clear an Operand
                subi.b  #1,$A(a0)       ; Subtract Immediate
                bpl.s   loc_1314E       ; Branch if Plus
                move.b  $B(a0),$A(a0)   ; Move Data from Source to Destination
                addi.l  #$10,6(a0)      ; Add Immediate
                subi.w  #1,$C(a0)       ; Subtract Immediate
                bpl.s   loc_1314E       ; Branch if Plus
                move.w  #2,(a0)         ; Move Data from Source to Destination
                move.w  #7,$E(a0)       ; Move Data from Source to Destination
                move.l  #Pattern_DropBomb,6(a0) ; Move Data from Source to Destination
                rts                     ; Return from Subroutine
; ---------------------------------------------------------------------------

loc_13142:                              ; CODE XREF: ROM:0001305E↑j
                                        ; ROM:00013076↑j ...
                clr.w   (a0)            ; Clear an Operand
                addi.w  #1,(wScreendrawCountdown).l ; Add Immediate
                rts                     ; Return from Subroutine
; ---------------------------------------------------------------------------

loc_1314E:                              ; CODE XREF: ROM:0001307E↑j
                                        ; ROM:00013116↑j ...
                bsr.s   func_CalculateNewLocation1       ; Branch to Subroutine
                move.b  1(a0),(a1)      ; Move Data from Source to Destination
                rts                     ; Return from Subroutine

; =============== S U B R O U T I N E =======================================


;-------------------------------------------------------------------------
; was sub_13156:
;-------------------------------------------------------------------------
func_CalculateNewLocation1:
                                   ; CODE XREF: func_SetupEnemyPOD+26↑p
                                        ; func_ValidateNewLocation:↑p ...
                move.w  4(a0),d2        ; Move Data from Source to Destination
                andi.w  #FILTER_248,d2         ; AND Immediate
                move.w  d2,d3           ; Move Data from Source to Destination
                asl.w   #2,d3           ; Arithmetic Shift Left
                add.w   d2,d3           ; Add
                move.w  2(a0),d2        ; Move Data from Source to Destination
                asr.w   #4,d2           ; Arithmetic Shift Right
                add.w   d2,d3           ; Add
                lea     (Array_UpdatedLocationsOnGrid).l,a1   ; Load Effective Address
                lea     (a1,d3.w),a1    ; Load Effective Address
                rts                     ; Return from Subroutine
; End of function func_CalculateNewLocation1


; =============== S U B R O U T I N E =======================================


;-------------------------------------------------------------------------
; was sub_13178
;-------------------------------------------------------------------------
func_CalculateNewLocation0:
                                   ; CODE XREF: UPDATE_GAME_LOGIC+98↑p
                                        ; UPDATE_GAME_LOGIC+B6↑p ...
                andi.w  #FILTER_248,d1         ; AND Immediate
                move.w  d1,d2           ; Move Data from Source to Destination
                asl.w   #2,d2           ; Arithmetic Shift Left
                add.w   d1,d2           ; Add
                asr.w   #4,d0           ; Arithmetic Shift Right
                add.w   d0,d2           ; Add
                lea     (Array_UpdatedLocationsOnGrid).l,a1   ; Load Effective Address
                lea     (a1,d2.w),a1    ; Load Effective Address
                rts                     ; Return from Subroutine
; End of function func_CalculateNewLocation0

; ---------------------------------------------------------------------------
func_ThirdInAddressList: ;address 13192
                move.w  bColourFlasher,d0   ; Used as a timer for centipede?
                asl.w   #2,d0           ; Arithmetic Shift Left
                andi.w  #VALUE_CENTIPEDE_SPRITE_END,d0 ; '0'   ; AND Immediate
                lea     (Pattern_GridSearchSquad).l,a1 ; Load Effective Address 
                lea     (a1,d0.w),a1    ; Load Effective Address
                move.l  a1,6(a0)        ; Move Data from Source to Destination
                bsr.w   func_ValidateNewLocation       ; Branch to Subroutine
                bpl.s   loc_131DA       ; Branch if Plus
                move.w  #6,d0           ; Move Data from Source to Destination
                move.w  #5,d1           ; Move Data from Source to Destination
                bsr.w   SCORE_CONVERT_HEX2DEC       ; Branch to Subroutine
                move.w  2(a0),d0        ; Move Data from Source to Destination
                move.w  4(a0),d1        ; Move Data from Source to Destination
                bra.w   func_SetupEnemyPOD       ; Branch Always
; ---------------------------------------------------------------------------

loc_131CA:                              ; CODE XREF: ROM:000131E8↓j
                                        ; ROM:000131F4↓j ...
                neg.w   $12(a0)         ; Negate
                tst.w   $14(a0)         ; Test an Operand
                bne.s   loc_131DA       ; Branch if Not Equal
                addi.w  #8,4(a0)        ; Add Immediate

loc_131DA:                              ; CODE XREF: ROM:000131B0↑j
                                        ; ROM:000131D2↑j
                move.w  $12(a0),d0      ; Move Data from Source to Destination
                bmi.s   loc_131EC       ; Branch if Minus
                add.w   2(a0),d0        ; Add
                cmp.w   #MAX_HORIZONTAL_CENTIPEDE,d0        ; (Compare) d0 - How far the centipede enemy can go horizontally
                bge.s   loc_131CA       ; Branch if Greater or Equal
                bra.s   loc_131F6       ; Branch Always
; ---------------------------------------------------------------------------
loc_131EC:                              ; CODE XREF: ROM:000131DE↑j
                add.w   2(a0),d0        ; Add
                cmp.w   #8,d0           ; Compare
                blt.s   loc_131CA       ; Branch if Less Than

loc_131F6:                              ; CODE XREF: ROM:000131EA↑j
                move.w  d0,2(a0)        ; Move Data from Source to Destination
                move.w  $14(a0),d0      ; Move Data from Source to Destination
                bpl.s   loc_13214       ; Branch if Plus
                add.w   4(a0),d0        ; Add
                cmp.w   #8,d0           ; Compare
                bge.s   loc_13230       ; Branch if Greater or Equal

loc_1320A:                              ; CODE XREF: ROM:00013222↓j
                neg.w   $14(a0)         ; Negate
                add.w   $14(a0),d0      ; Add
                bra.s   loc_13230       ; Branch Always
; ---------------------------------------------------------------------------

loc_13214:                              ; CODE XREF: ROM:000131FE↑j
                add.w   4(a0),d0        ; Add
                cmp.w   #$B8,d0         ; Compare
                ble.s   loc_13230       ; Branch if Less or Equal
                tst.w   $14(a0)         ; Test an Operand
                bne.s   loc_1320A       ; Branch if Not Equal
                move.w  $12(a0),d1      ; Move Data from Source to Destination
                bmi.s   loc_1322C       ; Branch if Minus
                neg.w   d1              ; Negate

loc_1322C:                              ; CODE XREF: ROM:00013228↑j
                move.w  d1,$14(a0)      ; Move Data from Source to Destination

loc_13230:                              ; CODE XREF: ROM:00013208↑j
                                        ; ROM:00013212↑j ...
                move.w  d0,4(a0)        ; Move Data from Source to Destination
                bsr.w   func_CalculateNewLocation1       ; Branch to Subroutine
                cmpi.b  #1,(a1)         ; Compare Immediate
                beq.s   loc_131CA       ; Branch if Equal
                bra.w   loc_1314E       ; Branch Always
; ---------------------------------------------------------------------------
	SECTION DATA;<VASM>
lAddressListX3: ; 3 addresses one after another
		ds.b $C
Pattern_Gridparts:
		INCBIN "Grid.spr" ; I think these are single colour only so called them Patterns rather than sprites until I have done further research.
Pattern_Player:
		INCBIN "PlayerShip.spr"
Pattern_BulletPlayer:
		INCBIN "PlayerBullet.spr"
Pattern_GridSearchSquad:
		INCBIN "GridSearcher.spr" ;the main enemy sprite on the grid, aka Centipede
Pattern_Numbers:
		INCBIN "Numbers.spr" ; need to make sure this is below centipede data as it is referenced afterwards.
wDrawLoop:
		dc.b $00,$07
Pattern_yZapper:
		INCBIN "yZapper.spr"
Pattern_xZapper:
		INCBIN "xZapper.spr"
Pattern_HorizontalLaser:
		INCBIN "HorizontalLaser.spr"
Pattern_VerticalLaser:
		INCBIN "VerticalLaser.spr"
Pattern_Pods:
		INCBIN "Pods.spr" ; I originall called them bomb spawners
Pattern_DropBomb: 
		INCBIN "DownMissile.spr"
Pattern_Explosion:     
		INCBIN "PlayerExplosion.spr" 	
lMouseParameters:
		dc.b $01,$00,$01,$01  
wCountdownLevelUp:
		dc.b $04,$16 ; counts down from the restore value every cycle by steps of 1, CONFIRM this changes the LEVEL UP
wRestoreCountdownLevelUp:	
		dc.b $0B,$B8   ; restores/ countdown from this! This remains static, could de a PREDEFINED
lPointerSpriteBuffer0:
		ds.l $1
lPointerSpriteBuffer1:
		ds.l $1
wXzapperCoordinate:
		dc.b $00,$0E ; bottom enemy
wYzapperCoordinate:
		dc.b $00,$85  ;side enemy  
wCycleBackup_d0:
		dc.b $B0,$87			
wScreendrawCountdown:
		dc.b $00,$06           
wPlayerX: 
		dc.b $00,$57
wPaletteArray:	
		INCBIN "gridrunner.pal" 
wPlayerY:
		dc.b $00,$66
wMouseButton:
		ds.w $1
wMouseX:
		ds.w $1           
wMouseY:
		ds.w $1    
; Used to build the grid image but also navigation points for the enemy AI, I think		
Array_StaticLocationsForGrid: 
		INCBIN "FullScreen.bin" ; Hex 320 Dec 800 bytes in size
	SECTION BSS;<VASM>
Array_SpriteBuffer0:
	ds.b $1000 ; dec 4096
Array_SpriteBuffer1:
	ds.b $1000 ; dec 4096
lPointerScreenBufferC:
	ds.l $1
lPointerScreenBufferA:
	ds.l $1
lPointerScreenBufferB:
	ds.l $1
wVBlankLogicActive: ; the score doesn't reset correctly sometimes. Is this a bullet being fired on restart getting an instant kill or something else?
	ds.w $1
wXzapperSpeed: ; word, starts at 1 and increases per level ( seemingly ) so ends up 2 after dying post level up
	ds.w $1
wYzapperSpeed: ; word, Speed but more like pixels per movement
	ds.w $1
lPointerRunFunctionVBL: ; need to make sure these go in the same order as the equates incase there is spill over, like with the hud
	ds.l $1
bColourFlasher: ; used to flash the score and the enemy lasers. Referred to as a word but it's a byte!
	ds.b $1
bPlayerDisable: ; paired with FLASHER, low bit? Stops drawing player after explosion.
	ds.b $1
wGameLogicActive: ;  byte but with a word clear, Seems to be Zero when the game isn't active ( setup / out of lives ) and One when it is.
	ds.w $1 
bEnemyLaserCountdown: ;  Both lasers are fired when it hits zero.
	ds.b $1
bEnemyLaserRestore: ; equ 			$15781 ; cleared from the variable above I think!
	ds.b $1
wSideLaserX: 
	ds.w $1
Array_CollisionsOnGrid:  ; Everything but the Xzapper and Yzapper as you can't hit them. I sometimes call these projectiles
	ds.b $1000 ; dec 1023 - should match equate SIZE_PROJECTILE_DATA multiplied by 4 ( long ) plus one	
	
Array_UpdatedLocationsOnGrid: ; This might be all be the information for the PODS, not entirely sure.
	ds.b $3E0
wBottomLaserSetting: 
	ds.w $1
wSideLaserY:
	ds.w $1
wPlayerBulletX:
	ds.w $1
wPlayerBulletY: 
	ds.w $1
wOldPlayerX: 
	ds.w $1
wOldPlayerY: 
	ds.w $1
bGameLogicCountdown: 
	ds.b $1
bMaxCountdownPlusLevel: 
	ds.b $1
bSideCountdownY: 
	ds.b $1
bScaledRestoreCountdownY: ;  another countdown affected by the level
	ds.b $1
bProjectileCountdown: 
	ds.b $1
bRestoreProjectileCountdown: ; byte ; see 23 for more info. This value is taken from the GAME UPDATE data
	ds.b $1
lScoreHigh: 
	ds.l $1
lScoreLow:
	ds.l $1
wLivesUpdateHUD: 
	ds.w $1
wPlayerLives: 
	ds.w $1
wCurrentLevel: ; i think is more like XP to detect level. Maybe time spent alive?
	ds.w $1
wEnemyLevel: ; Starts/resets at 2, increased by 1 after level up. Also changes the bomb spawner behaviour!
	ds.w $1
Array_ScreenBufferB:
	ds.b $7d00 ; dec 32000
Array_AlignmentBuffer:
	ds.b $100 ; dec 256, overall both buffers are $7e00 dec 3225
Array_ScreenBufferC:
	ds.b $7d00 ; dec 32000
;GAP_BUFFER_02:
;	ds.b $100 ; is this one needed? The data is just copied so it doesn't need to be aligned
	; end of 'ROM'


                END
