; ---------------------------------------------------------------------------
	clr.w	-(sp)		;Set to zero ( which is low resolution )
	move.l	#-1,-(sp)	; phys = SCR_NOCHANGE -1 ( this means DO NOT alter the physical addresses of screen memory )
	move.l	#-1,-(sp)	; log = SCR_NOCHANGE -1 ( this means DO NOT alter the logical addresses of screen memory )
	move.w	#5,-(sp)	;Setscreen()
	trap	#14		;XBIOS
	add.l	#12,sp

	DC.W	$a00a		;Line A 10 : Hide the cursor

	move.l	#Array_AlignmentBuffer,-(sp)	;New palette data shoved into a pre-existing buffer, only use it here.
	move.w	#6,-(sp)	;Setpalette
	trap	#14		;XBIOS
	addq.l	#6,sp

	move.w	#3,-(sp)	;Logbase / screen address
	trap	#14		;XBIOS
	addq.l	#2,sp

	move.l	d0,(lPointerScreenBufferA).l ; uae the default ST screen as a buffer as we know it is available and properly aligned
	move.l	d0,a3		;Logbase / screen address copy to a3
	move.l	#Array_ScreenBufferC,a0	;Title image stored in this buffer before the games starts to use it
	move.l	a3,a1		;Destination

	move.w	#SCREEN_SIZE_LONGS,d0	;Number of longs inside the image data MINUS 1

loopcopy:
	move.l	(a0)+,(a1)+
	dbf	d0,loopcopy

	move.w	#8,-(sp)	;Cnecin - wait for key press
	trap	#1		;GEMDOS
	addq.l	#2,sp

;clear our title screen for a smoother transition into the game
	movea.l (lPointerScreenBufferA).l,a0   ; Move Address
    bsr.w   CLEAR_SCREEN_BUFFER_A0       ; Branch to Subroutine

; ---------------------------------------------------------------------------