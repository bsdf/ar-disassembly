
; Short snippet from the essential part of "PAIN" by Agony

	lda #$d8
	sta $d016

	lda #$23
	sta $de00	; enable ultimax (and Replay RAM)

	lda #$3b
	sta $d011	; display gfx from $1000
	lda #$04
	sta $d021	; color me

	ldy #$00	; ...
	
	lda #$ea
-:	cmp $d012
	bne -
	ldx #$09
	dex
	bne $0936	; wait for rasterline and a little more

	lda #$0a
	sta $de00	; disable ultimax (and switch back to the commonly used bank 1)

; Ultimax mode on original Action Replay and Nordic Power hardware allows to display
; changed charset and graphics at $1000 as the VIC now "sees" that area "properly" and not
; as a mirror of the ROM charset (which doesn't exist on a real "max" machine).
; Without replay cart the VIC sees a memory hole from $1000 on.
;
; _Retro_ Replay "fixes" some garbage which can be seen whenever we are too quick and switch to
; this mode with the screen not blanked. The "fix" leads to the demopart not working properly.
