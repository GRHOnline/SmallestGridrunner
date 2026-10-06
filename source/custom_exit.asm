				;Reverse all our changes. Maybe add code to restore the old resolution and palette?
				
				move.l  #old_vbl,a0 ; Restore the old VBLANK pointer/vector
				move.l  (a0),VBLANK_SYNC70 ; Restore the old VBLANK
				
				;set the first byte to zero in the mouse parameters to stop an inverted mouse.
				clr.b	lMouseParameters
				
				move.l  lOldMouseVector,-(sp) ; 
                move.l  #lMouseParameters,-(sp) ; 
                move.w  #1,-(sp)        ; Turn mouse reporting ON we are just changing the vector
                clr.w   -(sp)           ; XBIOS 0 Initmouse
                trap    #XBIOS             ; Trap (#vector Exception)
                adda.l  #$C,sp          ; Tidy the stack
				
				 ; Quit supervisor mode
                move.l  lOldStack,-(sp)       ; Need the old stack here!
                move.w  #SUPERVISOR_G,-(sp) ; GEMDOS SUPER
                trap    #GEMDOS              ; Trap (#vector Exception)
                adda.l  #6,sp           ; Add Address		
				
				move.l	#0,-(sp)	; PTERM setting <GRH> causing a crash!!
				move.l	#PTERM,-(sp)	; GEMDOS routine number
				trap	#GEMDOS
				
				;clr.w -(sp) ; PTERM0
				;trap #GEMDOS				;Return to OS
				rts