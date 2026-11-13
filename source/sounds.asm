sound_intro:
	dc.b	0,$fe ; channel A
	dc.b	1,0 ; 440 hz Hi note
	dc.b	2,0 ; channel
	dc.b	3,0 ; B
	dc.b	4,0; channel
	dc.b	5,0 ; C
	dc.b	6,0 ; noise
	dc.b	7,$fe ; enable A only
	dc.b	8,11 ; A amplitude
	dc.b	9,0 ; B off
	dc.b	10,0 ; C off
	dc.b	11,0 ; no
	dc.b	12,0 ; envelope
	dc.b	13,0 ; shape
	dc.b	130,20 ; delay	
	dc.b 	0,$56	;chan A Lo note
	dc.b	1,1		;187 hz
	dc.b	130,20	
	dc.b	0,$fe,1,0,130,40 ; Hinote
	dc.b	0,$56,1,1,130,40 ; Lonote
	;silence sound
	dc.b	8,0,9,0 ; A & B off
	dc.b	130,20
	;exit list
	dc.b	7,255,8,0 ; off
	dc.b	255,0 ; return

sound_die: 
	dc.b	0,0,1,0,2,0,3,0,4,0,5,0
	dc.b	6,$1f ;DIFF_Sound02 in Ghidra - BOOM - speed?
	dc.b	8,$10
	dc.b 	9,$10
	dc.b	$0a,$10
	dc.b	$0b,0
	dc.b	$0c,$32 ; DIFF_Sound03 - BOOM - reverb / echo?
	dc.b	$0d,9
	dc.b	7,$c0
	dc.b	130,60 ; i have added for a delay,this is Duration i think
	;exit list
	dc.b	7,255,8,0 ; off
	dc.b	255,0 ; return
	
sound_shoot: 
	dc.b 	8,$10
	dc.b	9,16
	dc.b	$0a,16
	dc.b	$0b,0
	dc.b	$0c,1
	dc.b	$0d,3
	dc.b	$0,$50
	dc.b	1,0
	dc.b	2,0
	dc.b 	3,0
	dc.b	4,0
	dc.b 	5,0
	dc.b	6,0
	dc.b	7,$fe
	dc.b	130,25 ; i have added for a delay, i think
	;silence sound
	dc.b	8,0,9,0 ; A & B off
	;exit list
	;dc.b	7,255,8,0 ; off
	dc.b	255,0 ; return
		
sound_warning: 
	dc.b 	8,$10
	dc.b	9,16
	dc.b	$0a,16
	dc.b	$0b,0
	dc.b	$0c,$32 ;$0c,1
	dc.b	$0d,3
	dc.b	$0,$50
	dc.b	1,0
	dc.b	2,0
	dc.b 	3,0
	dc.b	4,0
	dc.b 	5,0
	dc.b	6,0
	dc.b	7,$fe
	dc.b	130,50 ; i have added for a delay, i think
	;silence sound
	dc.b	8,0,9,0 ; A & B off
	;exit list
	;dc.b	7,255,8,0 ; off
	dc.b	255,0 ; return
	
sound_silent: 
	;dc.b 	8,$10
	;dc.b	9,16
	;dc.b	$0a,16
	dc.b	$0b,0
	;dc.b	$0c,1
	;dc.b	$0d,3
	;dc.b	$0,$50
	dc.b	1,0
	dc.b	2,0
	dc.b 	3,0
	dc.b	4,0
	dc.b 	5,0
	dc.b	6,0
	;dc.b	7,$fe
	;dc.b	130,50 ; i have added for a delay, i think
	;exit list
	dc.b	7,255,8,0 ; off
	dc.b	255,0 ; return