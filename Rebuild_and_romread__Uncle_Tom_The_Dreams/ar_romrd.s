;               Liest die 4 ROM-BÑnke der Action-Cardridge 
;		aus uns speichert sie im RAM ab
;
;(w) Uncle Tom/The Dreams
		
		.ba $0a00
		
cls:		.eq $e544
strout:		.eq $ab1e
get:		.eq $ffe4
writemem:	.eq $02a7		;routine der AR
bankport:	.eq $de00
zei:		.eq $8e			;wird auch von writemem benutzt

;**********************************************************************

		
		cli
		jsr cls			;screen lîschen
		lda #<text
		ldy #>text
		jsr strout		;meldung ausgeben
getloop:	jsr get			;taste holen
		cmp #$31
		bcc getloop
		cmp #$35
		bcs getloop		;nur auf tasten 1-4 reagieren
		sec
		sbc #$31
		tax 			;in pointer auf tabelle wandeln
		lda #0
		sta zei
		lda #$80
		sta zei+1		;zeiger auf $8000 setzen
		lda tab,x		;wert aus tabelle lesen
		sta copy+1		;in code patchen
		ldx #32			;32*256 bytes kopieren ($8000-$a000)
		ldy #0
copy:		lda #0			;hier wird gepatcht
		sta bankport		;auf richtige bank schalten
		lda (zei),y		;wert aus ROM lesen
		jsr writemem		;und im RAM ablegen (selber zeiger !)
		iny
		bne copy
		inc zei+1
		dex
		bne copy		;bis alle blocks durch
		rts 			;zurÅck ins freezer-menÅ
		
		
text:		.by "Welche Bank auslesen ? (1-4)",0
tab:		.by $00,$08,$10,$18
