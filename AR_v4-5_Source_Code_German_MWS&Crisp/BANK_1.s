

         *= $8000
;
;---------------------------------------
; BANK1
;---------------------------------------
;
;---------------------------------------
         .BYTE $09,$80,$0C,$80
         .BYTE $C3,$C2,$CD,$38,$30
;---------------------------------------
         JMP RES1   ;RESET
         JMP RES7   ;RESET WARMSTART
         JMP SCOM14 ;NEUE BASICBEFEHLE
         JMP $FCE2   ;RESET
SUBC0    JMP DIREX   ;DIRECTORY
SUBC1    JMP CALLER  ;NEUE TASTATURROUT
SUBC2    JMP SVECL  ;VECTOREN SETZEN
         JMP MONEX   ;MONITOR
SUBC3    JMP WRITC  ;DATASETTE WRITE
         JMP SPR1   ;EXTERNRAM ZEIGER
         JMP INMONA
         JMP INMONB
;---------------------------------------
; NEUE BASICBEFEHLE
;---------------------------------------
BASCM    .BYTE $AF
         .BYTE $A4,$A5,$DE,$DC
         .BYTE $C0,$A6
;---------------------------------------
         .TEXT "OLÄ"
         .TEXT "DELETÅ"
         .TEXT "LINESAVÅ"
         .TEXT "MERGÅ"
         .TEXT "AUTÏ"
         .TEXT "MONITOÒ"
         .TEXT "APPENÄ"
         .TEXT "COPÙ"
         .TEXT "BOOÔ"
         .TEXT "ZAÐ"
         .TEXT "BACKUÐ"
         .TEXT "PLIST"
         .BYTE $A2
         .TEXT "SLIST"
         .BYTE $A2
         .TEXT "OÎ"
         .TEXT "OFÆ"
         .TEXT "RENUÍ"
;---------------------------------------
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         JMP CALL1  ;FSAVE
;---------------------------------------
; RENUMBER START
;---------------------------------------
RENUR    LDA #$29
         STA $DE00
         NOP
         NOP
         JMP RENUR1+$2000
;---------------------------------------
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
         BRK
;---------------------------------------
         JMP CALL2
;---------------------------------------
         JMP CALL3
;---------------------------------------
         JMP CALL4  ;SAVE
;---------------------------------------
CALL1    JSR BANK2
         .BYTE $03,$81  ;FSAVE
         RTS
;---------------------------------------
CALL2    JSR BANK3
         .BYTE $15,$80  ;SLOWSAVE
         RTS
;---------------------------------------
CALL3    JSR BANK3
         .BYTE $18,$80  ;SLOWSAVE OHNE
         RTS            ;ADRESSEN SETZEN
;---------------------------------------
; SAVE
;---------------------------------------
CALL4    JSR BANK2
         .BYTE $09,$81  ;FSAVE O. ADRES.
         RTS
;---------------------------------------
; RESETROUTINE
;---------------------------------------
RES1     SEI
         LDX #$FB
         CLD
         TXS
         LDA #$27
         STA $01
         LDA #$2F
         STA $00
         JSR $FDA3
         JSR RES5
         JSR $FF5B
         JSR $E453
         JSR SVECL
         JSR $E3BF
         JSR $E422
         JSR PRINT
;
         .BYTE $0D,$05,$A0
         .BYTE $A0,$A0,$A0,$A0
         .BYTE $A0,$A0,$A0,$A0
         .TEXT "TOOLKIT (C) "
         .TEXT "DATEL 1988"
         .BYTE $0D,$0D
         .BYTE $00
;---------------------------------------
         NOP
         NOP
         LDA #$E3
         PHA
         LDA #$85
         STA $0313
         NOP
         NOP
         NOP
         PHA
RES3     LDA $C5
         CMP #$40
         BNE RES3
         LDA #$00
         STA $C6
         JMP $DF12
;---------------------------------------
RES5     JSR RES6
         TYA
RES5A    STA $02,Y
         INY
         BNE RES5A
         LDY #$55
RES5B    STA $0200,Y
         INY
         CPY #$A7
         BNE RES5B
         LDA #$64
         STA $0255
         LDA #$0A
         STA $0257
         LDA #$3C
         STA $B2
         LDA #$03
         STA $B3
         LDY #$A0
         STY $0284
         LDA #$08
         STA $0282
         STA $BA
         LSR A
         STA $0288
         RTS
;---------------------------------------
RES7     JSR SUB1   ;VECTOR TESTEN
         JSR $F6BC
         JSR $F6ED
         BEQ RES7A
         JMP $FE72
RES7A    LDX #$00
RES7B    DEX
         NOP
         BNE RES7B
         LDX $0329
         JSR RES6    ;VECTOREN SETZEN
         CPX #$DF
         BNE RES7C
         LDA #$36
         STA $0328
         STX $0329
RES7C    JSR SVECL  ;VEC SETZEN
         JSR $FDA3
         JSR $E518
         LDA #$01
         STA $0286
         JMP ($A002)
;---------------------------------------
SUB1     LDA $0303
         CMP #$DF
         BNE SUBE
         LDX $0302
         CPX #$2E
         BEQ SUBE
         LDA #$80
         PHA
         LDA #$0E
         PHA
         TXA
         SEC
         SBC #$2D
         TAX
         LDA $DFEE,X
         JMP $DFE7
SUBE     RTS
;---------------------------------------
RES6     LDY #$20
RES6A    LDA $FD2F,Y
         STA $0313,Y
         DEY
         BNE RES6A
         RTS
;---------------------------------------
; LINESAVE
;---------------------------------------
LINESV   JSR VALGET  ;DEVICE
         JSR VALU2   ;KOMMA
         JSR VALU1   ;ZEILE HOLEN
         STX $5F
         STY $60
         LDA #$61
         STA $B9
         LDA $BA
         CMP #$08
         BCS LINS1
         JMP $F713
LINS1    LDA $B7
         BNE LINS2
         JMP $F710
LINS2    JSR FLO8   ;FLOPPY INITIALIZE
         BCC LINS3
         JMP $E1D1
LINS3    JSR BANK3A
         .BYTE $D5,$F3 ;OPEN
         LDA $BA
         JSR $FFB1
         LDA $B9
         JSR $FF93
         LDX $C1
         LDY $C2
         JSR $FFBD
         LDX $2B
         LDY $2C
         JSR DEVOUT  ;SEND2BYTES
         LDY #$00
LINS4    JSR $DF6A   ;GET
         JSR $FFA8   ;SEND
         INC $BB
         BNE LINS5
         INC $BC
LINS5    LDA $BB
         CMP $5F
         LDA $BC
         SBC $60
         BCC LINS4
         LDX #$00
         JSR DEVOUT ;2BYTES
         JMP $F642
;---------------------------------------
; DEVICE SETZEN
;---------------------------------------
VALGET   JSR M6    ;FILENAME
         BEQ VALG1
         JSR VALU2
         JSR $B79E
         STX $BA
         RTS
;---------------------------------------
VALG1    LDX $BA
         CPX #$08
         BCS VALG2
         LDX #$08
VALG2    STX $BA
         JMP $79
;---------------------------------------
VALU1    BCS VALU1C
         JSR $A96B     ;GET LINE
         JSR $A613     ;LINESTART
         LDX $5F
         LDY $60
         STX $C1
         STY $C2
         JSR $79
         CMP #$2D
         BNE VALU1C
         JSR $73
         BNE VALU1A
         LDA $2D
         SEC
         SBC #$02
         TAX
         STA $5F
         LDA $2E
         SBC #$00
         TAY
         STA $60
         BNE VALU1B
VALU1A   JSR $A96B
         BNE VALU1C
         JSR $A613
         LDX $5F
         LDY $60
         BCC VALU1B
         LDY #$00
         LDA ($5F),Y
         TAX
         INY
         LDA ($5F),Y
         TAY
VALU1B   LDA $C1
         CMP $5F
         LDA $C2
         SBC $60
         BCS VALU1C
         RTS
VALU1C   JMP $AF08
;---------------------------------------
VALU2    LDA #$2C
         LDY #$00
         CMP ($7A),Y
         BNE VALU1C
         JMP $73
;---------------------------------------
; DELETE
;---------------------------------------
DELETE   JSR VALU1  ;LINE
         TYA
         LDY #$01
         STA ($C1),Y
         TXA
         DEY
         STA ($C1),Y
         STY $0200
         LDA $C1
         STA $5F
         LDA $C2
         STA $60
         LDA $0302
         STA $C1
         LDA $0303
         STA $C2
         LDA #<DELETE1
         STA $0302
         LDA #>DELETE1
         STA $0303
         SEC
         JMP $A4A9  ;LOESCHEN
;---------------------------------------
DELETE1  LDA $C2
         STA $0303
         LDA $C1
         STA $0302
;---------------------------------------
; OLD
;---------------------------------------
OLD      LDA #$08
         LDY #$01
         STA ($2B),Y
         JSR $A533
         LDA $22
         LDY $23
         CLC
         ADC #$02
         BCC OLD1
         INY
OLD1     STA $2D
         STY $2E
         JSR $A66F
         JMP $E37B
;---------------------------------------
DEVOUT   TXA
         JSR $FFA8
         TYA
         JMP $FFA8
;---------------------------------------
FNCOP    JSR M6    ;FILENAME GET
         LDY #$1F
FNCOP1   LDA ($BB),Y
         STA $0230,Y
         DEY
         BPL FNCOP1
         LDA #$30
         STA $BB
         RTS
;---------------------------------------
; APPEND
;---------------------------------------
APPEND   JSR VALGET  ;DEVICE
         LDA $2D
         SEC
         SBC #$02
         TAX
         LDA $2E
         SBC #$00
         TAY
         LDA #$00
         STA $B9
         STA $0A
         JMP $E175    ;LOAD
;---------------------------------------
AUTOLD   JSR RUNCOP
         JSR FNCOP   ;FILENAME
         JSR LOAD
         BNE SCOM8
         BEQ SCOM7
;---------------------------------------
RUNCOP   LDX #$05
         STX $C6
RUNCOP1  LDA AUTST-1,X
         STA $0276,X
         DEX
         BNE RUNCOP1
         RTS
;---------------------------------------
FAUTOLD  JSR RUNCOP
         STX $0A
         STX $B9
         JSR FNCOP ;FILENAME
         JMP $E16F
;---------------------------------------
SCOM6    LDA #$00
         .BYTE $2C
SCOM5    LDA #$01
         LDX #$01
         PHA
         JSR FNCOP ;FILENAME
         PLA
         JSR LOAD1
         BNE SCOM8
SCOM7    JMP $E17A
SCOM8    LDA #$00
         STA $C6
         JMP $E18D
;---------------------------------------
BSAVE    JSR FNCOP
         JMP $E159
;---------------------------------------
AUTST    .TEXT "RUN:"
         .BYTE $0D
;---------------------------------------
SCOM     BCS SCOM2
         AND #$0F
         STA $BA
         CMP #$01
         BNE SCOM1
         JMP TPMES   ;TT AN
SCOM1    JSR $73
SCOM2    BEQ SCOM3
         CMP #$43   ;C=COPY
         BEQ COPY
         CMP #$42   ;B=BACKUP
         BNE SCOM3
BACKU    JSR BANK3
         .BYTE $36,$80  ;BACKUP
         JMP COPY1
;---------------------------------------
SCOM10   BCS SCOM9
         AND #$0F
         STA $BA
         LDA #$24
         STA ($7A),Y
         INC $7A
SCOM9    DEC $7A
SCOM3    JSR M6  ;GET COMMAND
         LDX #$08
         CPX $BA
         BCC SCOM11
         STX $BA
SCOM11   JSR BANK2
         .BYTE $0F,$81   ;DISKCOMMAMD
SCOM12   RTS
;---------------------------------------
COPY     JSR BANK3
         .BYTE $12,$80   ;FILECOPY
COPY1    BCC SCOM12
         JMP $E1D1
;---------------------------------------
OFF      LDX #$03
         .BYTE $2C
ON       LDX #$07
         LDY #$03
ON1      LDA LSVEC,X
         STA $0330,Y
         DEX
         DEY
         BPL ON1
         JMP $E18D
;---------------------------------------
; LOAD SAVE VECTOREN
;---------------------------------------
LSVEC    .BYTE $7C,$DF,$7F
         .BYTE $DF,$82,$DF,$89
         .BYTE $DF
;---------------------------------------
; DATASETTENROUTINE SETZEN
;---------------------------------------
SDEV     STX $9E
         JSR SDEV1
         LDX $9E
SDEVA    RTS
;---------------------------------------
SDEV1    CMP #$06
         BCC SDEVA
         BEQ SDEV1B
SDEV1A   LDA #$36
         LDX #$DF
         BNE SDEV1C
SDEV1B   LDA #$ED
         LDX #$F6
SDEV1C   SEI
         STA $0328
         STX $0329
         LDA #$01
         STA $BA
         RTS
;---------------------------------------
TPMES    JSR PRINT
         .TEXT "TAPE TURBO AN"
         .BYTE $00
;---------------------------------------
         LDA $0329
         CMP #$DF
         BNE SDEV1A
         JSR SDEV1B
         JSR PRINT
         .BYTE $9D,$55,$53,$00 ;=AUS
         RTS
;---------------------------------------
; VECTOREN INITIALISIEREN
;---------------------------------------
SVECL    SEI
         LDX #$82
         LDY #$DF
         LDA $0331
         CMP #$F4
         BNE SVECL1
         STX $0330
         STY $0331
SVECL1   LDX #$89
         LDA $0333
         CMP #$F5
         BNE SVECL2
         STX $0332
         STY $0333
SVECL2   JSR $E453
         LDX #$2E
         STX $0302
         STY $0303
         LDA $0317
         CMP #$FE
         BNE SVECL3
         LDX #$1F
         STX $0316
         STY $0317
SVECL3   RTS
;---------------------------------------
; NEUE ROUTINE FUER BASIC BEFEHLE
;---------------------------------------
SCOM14   JSR SUB1 ;VECTOR TEST
         JSR SVECL;VECT SETZEN
         LDA #$01
         STA $0286
         LDA $0313
         BNE SCOM15
         JMP M3
SCOM15   CLI
         LDA #$01
         STA $DC0E
         JSR SUBC1  ;TASTATUR GET
         STX $7A
         STY $7B
         JSR $73
         TAX
         BNE SCOM16
         STX $0258
         BEQ SCOM14
SCOM16   LDX #$FF
         STX $3A
         BCS SCOM22
         LDX $0258
         BNE SCOM17
         TAX
         LDA #$A4
         PHA
         LDA #$9B
         PHA
         JMP SCOM21B ;ENDE
;---------------------------------------
SCOM17   JSR $A96B  ;ZEILE HOLEN
         BEQ SCOM19
         LDA $14
         TAY
         CMP $0255
         LDA $15
         TAX
         SBC $0256
         BCC SCOM20
         TYA
         CLC
         ADC $0257
         STA $0255
         BCC SCOM18
         INX
SCOM18   CPX #$FA
         BCC SCOM20
SCOM19   LDA #$00
         STA $0258
         BEQ SCOM21A
SCOM20   STX $0256
         JSR AUTO3
SCOM21A  LDA #$A4
         PHA
         LDA #$9E
         PHA
SCOM21B  TXA
         JMP $DF12 ;ENDE
;---------------------------------------
; NEUE BEFEHLE ABFRAGEN
;---------------------------------------
SCOM22   STX $96
SCOM23   INC $96
         LDY #$FF
SCOM24   INY
         INX
         LDA BASCM,X
         BNE SCOM25
         LDA #$A4
         PHA
         LDA #$95
         PHA
         BNE SCOM21B
SCOM25   PHP
         AND #$7F
         CMP ($7A),Y
         BEQ SCOM27
         PLP
         BMI SCOM23
SCOM26   INX
         LDA BASCM,X
         BPL SCOM26
         BMI SCOM23
SCOM27   PLP
         BMI SCOM29
         CPY #$02
         BNE SCOM24
SCOM28   INY
         LDA ($7A),Y
         CMP #$41
         BCS SCOM28
         DEY
SCOM29   TYA
         CLC
         ADC $7A
         STA $7A
         LDX $BA
         LDY #$00
         JSR $FFBA
         STX $97
         LDA $96
         ASL A
         TAX
         LDA #$E3
         PHA
         LDA #$7A
         PHA
         LDA BASSP+1,X
         PHA
         LDA BASSP,X
         PHA
         LDY #$00
         JMP $73
;---------------------------------------
; BOOT
;---------------------------------------
BOOT     JSR $E1D4
         JSR LOAD
         BNE BOOT1
         JMP $E17A ;LOAD ERROR
;---------------------------------------
BOOT1    LDA $C4
         PHA
         LDA $C3
         PHA
         PHP
         PHA
         LDA $DFF3
         JMP $DFDE  ;START
;---------------------------------------
; ZAP = RESET
;---------------------------------------
ZAP      LDX #$FF
         SEI
         TXS
         CLD
         LDX #$00
         STX $D016
         JSR $FDA3
         JSR RES5
         LDA #$FC
         PHA
         LDA #$FA
         PHA
         JMP $DF12
;---------------------------------------
LOAD     LDX #$01
         LDA #$00
LOAD1    STX $B9
         STA $0A
         LDX $2B
         LDY $2C
         JSR BANK1
         .BYTE $D5,$FF
         BCC LOAD2
         JMP $E1D1
LOAD2    LDA $90
         AND #$BF
         BEQ LOAD3
         JMP $E17A
LOAD3    LDA $0330
         CMP #$7C
         BEQ LOAD5
         LDA $C3
         CMP $2B
         BNE LOAD4
         LDA $C4
         CMP $2C
         BEQ LOAD5
LOAD4    LDA #$00
         STA $C6
         LDA #$01
LOAD5    RTS
;---------------------------------------
; NEUE BASICBEFEHLE
;---------------------------------------
BASSP    .WORD SCOM6-1
         .WORD SCOM10-1
         .WORD AUTOLD-1
         .WORD FAUTOLD-1
         .WORD BSAVE-1
         .WORD SCOM-1
         .WORD SCOM5-1
         .WORD OLD-1
         .WORD DELETE-1
         .WORD LINESV-1
         .WORD MERGE-1
         .WORD AUTO-1
         .WORD MONIT-1
         .WORD APPEND-1
         .WORD COPY-1
         .WORD BOOT-1
         .WORD ZAP-1
         .WORD BACKU-1
         .WORD PLIST-1
         .WORD SLIST-1
         .WORD ON-1
         .WORD OFF-1
         .WORD RENUM-2
;---------------------------------------
         PLA
         PLA
;---------------------------------------
; RENUMBER
;---------------------------------------
RENUM    SEI
         LDX #$09
RENUM1   LDA RENUR,X
         STA $0100,X
         DEX
         BPL RENUM1
         JMP $0100
;---------------------------------------
RENUR1   LDX #$00
MSCOPY   LDA $C000,X
         STA $8000,X
         LDA RENUR3+$2000,X
         STA $C000,X
         LDA $C100,X
         STA $8100,X
         LDA RENUR3+$2100,X
         STA $C100,X
         INX
         BNE MSCOPY
         JMP $C000
;---------------------------------------
RENUR2   LDX #$00
MSCOPY2  LDA $8000,X
         STA $C000,X
         LDA $8100,X
         STA $C100,X
         INX
         BNE MSCOPY2
         LDA #$0A
         JMP $DFCF
;---------------------------------------
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
MONIT    LDA $DFED
         LDX #$00
         JMP MONEX
;---------------------------------------
GETK     CLI
         JSR $FFE4
         CMP #$00
         BEQ GETK
         RTS
;---------------------------------------
DIREX    LDA #$01
         LDX #$F6
         LDY #$DF
         JSR $FFBD
         LDA #$03
         STA $BD
         BNE PLI1
;---------------------------------------
SLIST    LDA #$03
         .BYTE $2C
;---------------------------------------
PLIST    LDA #$04
         STA $BD
         JSR VALGET;DEV+FILENAME
PLI1     JSR FLO3   ;OPEN+STARTADRESSE
         JSR $FFCC
         LDA #$04
         LDX $BD
         LDY #$FF
         JSR $FFBA
         LDA #$00
         JSR $FFBD
         JSR $FFC0
         LDA #<PLI2
         LDY #>PLI2  ;$0300 AUF PLI2
         JSR VEKT1  ;SETZEN
PLI2     LDA $DC01
         BPL PLI3
         AND #$10
         BEQ PLI2
         JSR DEVINIT ;GETLINE
         BCS PLI3
         JSR $FFCC
         LDX #$04
         JSR $FFC9
         LDY #$FF
         STY $14
         STY $15
         INY
         STY $01FD
         INY
         STY $0F
         STY $60
         LDA #$FC
         STA $5F
         JMP $A6D4 ;ZEILE AUSGEBEN
;---------------------------------------
; CLOSE
;---------------------------------------
PLI3     LDX #$04
         JSR $FFC9
         JSR M24
         LDA #$04
         JSR $FFC3
PLI3X    JSR SVECL  ;VECTOR SETZEN
         LDA #$03
         JSR $FFC3
         LDX #$01
         STX $01FC
         STX $01FD
         DEX
         STX $C6
         JMP $FFCC
;---------------------------------------
; BASICZEILE GET
;---------------------------------------
DEVINIT  JSR $FFCC
         LDX #$03
         JSR $FFC6
         LDY #$00
DIN1     JSR $FFCF
         STA $01FC,Y
         LDX $90
         BNE DIN3
         CPY #$04
         BCC DIN2
         CLC
         TAX
         BEQ DIN4
         CMP #$12
         BEQ DIN2
         BNE DIN2
         BCS DIN2
         LDA #$20
         STA $01FC,Y
DIN2     CLC
         CPY #$5C
         BCS DIN1
         INY
         BNE DIN1
DIN3     SEC
DIN4     INY
         STY $0B
         RTS
;---------------------------------------
VEKT1    STA $0300
         STY $0301
         RTS
;---------------------------------------
; MERGE
;---------------------------------------
MERGE    JSR VALGET  ;NAME+DEVICE
         JSR $79
         TAX
         BEQ MERG1
         JSR VALU2   ;KOMMA
         JSR $B7EB
MERG1    STX $96
         JSR FLO3
         LDA $14
         STA $C3
         LDA $15
         STA $C4
         JSR $FFCC
         JSR PRINT
         .TEXT "MERGING"
         .BYTE $00
         LDX #$05
MERG2    LDA MERG7,X
         STA $0150,X
         DEX
         BPL MERG2
         LDA #$50
         LDY #$01
         STA $0302  ;$0300 AUF $0150
         STY $0303  ;SETZEN
         JSR VEKT1
MERG3    BIT $DC01
         BPL MERG6
         INC $98
         JSR DEVINIT ;GET LINE
         BCS MERG6
         LDA $01FD
         BEQ MERG6
         LDA $01FE
         LDX $01FF
         LDY $96
         BEQ MERG5
         LDA $C3
         TAY
         LDX $C4
         CLC
         ADC $96
         STA $C3
         BCC MERG4
         INC $C4
MERG4    TYA
MERG5    STA $14
         STX $15
         STA $01FE
         STX $01FF
         LDA #$A4  ;ZEIE SETZEN
         PHA
         LDA #$A3
         PHA
         JMP $DF12
;---------------------------------------
MERG6    JSR PLI3X  ;CLOSE
         JMP $E37B
;---------------------------------------
MERG7    JSR $DF00
         JMP MERG3
;---------------------------------------
; AUTO
;---------------------------------------
AUTO     BEQ AUTO2
         JSR $B7EB ;GET WERT
         TXA
         BNE AUTO1
         JMP $AF08
AUTO1    LDA $14
         STA $0255
         LDA $15
         STA $0256
         STX $0257
AUTO2    STX $0258
         JSR AUTO3
         PLA
         PLA
         JMP $A480
;---------------------------------------
AUTO3    LDA $0256
         STA $62
         LDA $0255
         STA $63
         LDX #$90
         SEC
         JSR $BC49
         JSR $BDDD
         LDY #$FF
AUTO4    INY
         LDA $0101,Y
         STA $0277,Y
         BNE AUTO4
         INY
         STA $0277,Y
         STY $C6
         RTS
;---------------------------------------
AUTO5    JSR $DF12
         CLI
AUTO6    LDA $C6
         STA $CC
         BEQ AUTO6
         JMP $DF00
;---------------------------------------
; TASTENABFRAGE
;---------------------------------------
FKTR     LDA #$00
         STA $CA
         LDA $D6
         STA $C9
         TYA
         PHA
         TXA
         PHA
         LDA $D0
         BEQ FKTR2
         JMP $E63A
FKTR1    JSR $E716
FKTR2    LDX #$0D
FKTR3    LDA AUTO5,X
         STA $0210,X
         DEX
         BPL FKTR3
         JSR $0210
         STA $0292
         SEI
         LDA $CF
         BEQ FKTR4
         LDA $CE
         LDX $0287
         LDY #$00
         STY $CF
         JSR $EA13
FKTR4    JSR $E5B4
         CMP #$8A
         BNE FKTR5
         INC $D020
         BCS FKTR2
FKTR5    CMP #$8B
         BNE FKTR7
         INC $D021
         BCS FKTR2
FKTR6    CMP #$0D
         BNE FKTR1
         LDA $D3
         STA $8E
         JMP $E602
FKTR7    BIT $22
         BPL KEYG1
FKTR8    LDX #$07
FKTR9    CMP FKTK-1,X   ;FUNKTIONSTASTEN
         BEQ FKTR10
         DEX
         BNE FKTR9
         BEQ FKTR6
FKTR10   CPX #$03
         BNE FKTR13
         LDY #$05
         LDA ($D1),Y
         CMP #$22
         BNE FKTR13
         LDA #$20
FKTR11   DEY
         STA ($D1),Y
         BNE FKTR11
         LDA #$25
         CPX #$01
         BEQ FKTR12
         LDA #$2F
FKTR12   STA ($D1),Y
         STA $CE
         STY $D3
         JSR KEYG14
         JMP KEYG7
FKTR13   LDY #$FF
FKTR14   INY
         LDA FTAB,Y
         BNE FKTR14
         DEX
         BNE FKTR14
FKTR15   INX
         INY
         LDA FTAB,Y
         BEQ FKTR16
         STA $0276,X
         BNE FKTR15
FKTR16   STX $C6
FKTR20   JMP FKTR2
;---------------------------------------
FKTK     .BYTE $85,$89
         .BYTE $87,$88,$86,$8C
         .BYTE $83
;---------------------------------------
; ZUSATZTASTATURFUNKTIONEN
;---------------------------------------
KEYG1    LDX $D6
         BNE KEYG2
         CMP #$91
         BEQ KEYG3
         CMP #$13
         BEQ KEYG3
KEYG2    CPX #$18
         BNE KEYG4
         CMP #$11
         BNE KEYG4
KEYG3    STX $8F
         BEQ KEYG5
KEYG4    CMP #$87  ;F5
         BEQ KEYG8
         CMP #$88  ;F7
         BNE FKTR8
KEYG5    JSR KEYG9
KEYG7    LDX #$01
KEYG6    STX $C6
         BNE FKTR20
KEYG8    JSR KEYG9
         LDA #$87
         STA $0278
         STA $0279
         LDX #$03
         BNE KEYG6
KEYG9    LDY #$01
         LDX #$02
KEYG10   LDA KIFF1,X
         CMP ($D1),Y
         BEQ KEYG11
         DEX
         BPL KEYG10
         LDX $0166
         CPX #$02
         BCC KEYG11
         LDX #$02
KEYG11   LDA $8F
         BMI KEYG12
         LDA KIFF3,X
         STA $A8
         LDA KIFF1,X
         STA $AA
         BNE KEYG14
KEYG12   LDA KIFF2,X
         STA ($D1),Y
KEYG14   LDA #$0D
         STA $0277
         RTS
;---------------------------------------
KIFF1    .BYTE $2C,$3A,$3E
KIFF2    .BYTE $09,$0D,$04
KIFF3    .BYTE $20,$08,$00
;---------------------------------------
; TASTATURROUTINE
;---------------------------------------
CALLER   TSX
         LDA #$8C
         CMP $0102,X
         BCS CLL1
         CLC
CLL1     ROR $22
         LDA $EB1D
         CMP #$04
         BNE CLL2
         LDA #$38
         STA $DC05
CLL2     LDX #$FF
         STX $8F
         INX
CLL3     JSR FKTR
         CMP #$0D
         BEQ CLL4
         STA $0200,X
         INX
         CPX #$54
         BCC CLL3
         JMP $A571
CLL4     LDA #$40
         STA $DC05
         JMP $AACA
;---------------------------------------
; FUNKTIONSTASTENBELEGUNG
;---------------------------------------
FTAB     .BYTE $00
         .TEXT "LIST"
         .BYTE $0D,$00
         .TEXT "MON"
         .BYTE $0D,$00
         .TEXT "/0:*"
         .BYTE $0D,$00
         .TEXT "$:*"
         .BYTE $0D,$00
         .TEXT "RUN:"
         .BYTE $0D,$00
         .TEXT "SYS"
         .BYTE $00
         .TEXT "LOAD"
         .BYTE $0D
         .TEXT "RUN"
         .BYTE $0D,$00,$0D,$00
;---------------------------------------
; TALK SENDEN
;---------------------------------------
         JSR $FFAB
         LDA #$6F
         STA $B9
FLO1     LDA $BA
         JSR $FFB4
         LDA $B9
         JMP $FF96
;---------------------------------------
; LISTEN SENDEN
;---------------------------------------
FLO2     LDA $BA
         JSR $FFB1
         LDA #$6F
         JMP $FF93
;---------------------------------------
; FILE OPEN;STARTADRESSE HOLEN
;---------------------------------------
FLO3     LDA #$08
         LDY $B7
         BEQ FLO5
         LDA #$09
         LDX $BA
         CPX #$08
         BCS FLO4
         LDX #$08
FLO4     LDA #$03
         LDY #$60
         JSR $FFBA
         JSR $FFE7
         JSR FLO8
         BCS FLO5
         JSR BANK3A
         .BYTE $C0,$FF   ;OPEN
         JSR FLO1
         JSR $FFA5
         STA $AE
         LDA $90
         LSR A
         LSR A
         BCC FLO6
         JSR $F704
FLO5     JMP $E1D1
FLO6     JSR $FFA5
         STA $AF
FLO7     RTS
;---------------------------------------
; SEND "I" AN DISK
;---------------------------------------
FLO8     LDA #$00
         STA $90
         JSR FLO2
         LDA #$49
         JSR $FFA8
         JSR $FFAE
         LDA $90
         BPL FLO7
         JMP $F707
;---------------------------------------
; ZEIGER IN EXTERNRAM SETZEN
;---------------------------------------
SPR1     LDY #$50
SPR1A    LDA SPRT1,Y
         STA $0100,Y
         DEY
         BPL SPR1A
         JMP $0100
;---------------------------------------
SPRT1    LDA $DFF3
         PHA
         SEI
         LDA $DFF4
         STA $DE00
         LDA #$DF
         STA $8331
         STA $8333
         TAY
         TXA
         CLC
         ADC #$82
         STA $8330
         TXA
         CLC
         ADC #$89
         STA $8332
         LDA #$36
         CPX #$02
         BEQ SPRT1A
         LDA #$ED
         LDY #$F6
         DEX
         BNE SPRT1B
SPRT1A   STA $8328
         STY $8329
SPRT1B   LDX #$07
SPRT1C   LDA $FF00,X
         STA $9FF8,X  ;MARKE
         DEX
         BPL SPRT1C
         PLA
         STA $9FF7
         STA $08EB
         STA $DE00
         RTS
;---------------------------------------
; LOAD /SAVE
;---------------------------------------
         PHP
         BCC CASR3
         LDA $0331
         CMP #$DF
         BNE CASR3B
         LDA $0330
         SEC
         SBC #$82
         JMP CASR3A
CASR3    LDA $0332
         SEC
         SBC #$89
CASR3A   CLC
         ADC #$05
         CMP #$0A
         BCS CASR3B
         CMP #$06
         BCC CASR3B
         STA $BA
CASR3B   LDA $BA
         CMP #$08
         BCS CASR3C
         JSR SDEV  ;DATASETTE
         PLP
         JMP $DF71
CASR3C   PLP
         LDA $95
         PHA
         LDA $93
         BCC CASR3E
         JSR BANK2
         .BYTE $00,$81  ;LOAD
         PHP
         LDA $90
         CMP #$FF
         BEQ CASR3D
         PLP
         JMP $DF62
CASR3D   PLP
         JSR $FFAB
         JSR $F642
         PLA
         TAX
         LDA #$F4
         PHA
         LDA #$A6
         PHA
         TXA
         PHA
         JMP $DF62
;---------------------------------------
CASR3E   JSR BANK2
         .BYTE $03,$81  ;SAVE
         JMP $DF62
;---------------------------------------
;  TURBO TAPE
;---------------------------------------
CASS     SEI
         JSR $FB8E
         LDA $0315
         CMP #$FC
         LDA #$7F
         STA $DC0D
         STA $DC00
         LDA #$82
         LDY #$00
         STY $90
         LDX #$19
         BCS CAS1
         LDA #$81
         LDY #$D0
CAS1     STY $DC06
         STA $DC07
         STX $DC0F
         LDA $DC0D
         BCS CAS2
         JMP CASR  ;LOAD
CAS2     LDY $AB
         LDX #$07
CAS3     LDA CASST-1,X
         STA $0100,X
         DEX
         BNE CAS3
         INX
         CPY #$69
         BNE CAS4
         LDX #$08
CAS4     LDY #$A0
CAS5     LDA #$FF
         JSR CASW  ;LUECKE
         DEY
         BNE CAS5
         DEX
         BNE CAS4
         LDA #$7F
         JSR CASW
         LDY #$10
CAS6     TYA
         JSR CASW   ;STARTMARKE
         DEY
         BNE CAS6
         LDY #$00
         LDX #$07
CAS7     LDA #$04
         JSR $0101 ;GET RAM
         STA $BD
         EOR $90
         STA $90
         JSR CASW1 ;WRITE
         BIT $DC01
         BMI CAS8
         JMP CASR1C
CAS8     INC $AC
         BNE CAS9
         INC $AD
CAS9     SEC
         LDA $AC
         SBC $AE
         LDA $AD
         SBC $AF
         BCC CAS7
         LDA $90     ;ENDE
         JSR CASW
         TYA
         JSR CASW
CAS10    DEX
         BNE CAS10  ;LUECKE
         DEY
         BNE CAS10
         STY $90
         CLC
CAS11    JSR $FB8E
         LDA #$01
         JMP $FC93
;---------------------------------------
; SCHREIBEN
;---------------------------------------
CASW     STA $BD
CASW1    SEC
CASW2    ROR $BD
         BEQ CASW7
CASW3    LDA #$80
         BCC CASW4
         ASL A
CASW4    STA $DC06
         BCC CASW5
         ORA #$82
CASW5    STA $DC07
CASW6    BIT $DC07
         BMI CASW6
         INC $D020
         LDA #$19
         STA $DC0F
         LDA $01
         EOR #$08
         STA $01
         DEC $D020
         CLC
         AND #$08
         BNE CASW3
         BCC CASW2
CASW7    RTS
;---------------------------------------
CASST    STA $01
         LDA ($AC),Y
         STX $01
         RTS
;---------------------------------------
; CASS FLOAD
;---------------------------------------
CASR     LDA #$10
         ORA $D011
         STA $D011
         TSX
         STX $BE
         LDX #$19
CASRA    JSR CASR1
         BCC CASRA
         LDY #$10
CASRB    STY $90
         JSR CASR2   ;START SUCHEN
         CMP $90
         BNE CASRA
         DEY
         BNE CASRB
         STY $90
CASRC    JSR CASR2
         LDX $93
         BEQ CASRD
         EOR ($AC),Y  ;VERIFY
         BEQ CASRX
         LDA #$30
         BNE CASRE
CASRD    STA ($AC),Y  ;LOAD
         EOR $90
CASRE    STA $90
CASRX    JSR $FCDB
         JSR $FCD1
         LDX #$19
         BCC CASRC
         JSR CASR2
         LDX $93
         BNE CASRH
         EOR $90
         BEQ CASRG
         LDA #$30
CASRG    STA $90
CASRH    JMP CAS11
;---------------------------------------
; GETBYTE
;---------------------------------------
CASR2    LDA #$80
         STA $BD
CASR2A   JSR CASR1
         ROR $BD
         BCC CASR2A
         LDA $BD
         EOR #$FF
         RTS
;---------------------------------------
; GET  BIT
;---------------------------------------
CASR1    LDA #$10
CASR1A   BIT $DC01
         BPL CASR1B
         BIT $DC0D
         BEQ CASR1A
         LDA $DC07
         INC $D020
         STX $DC0F
         ASL A
         DEC $D020
         RTS
CASR1B   LDX $BE
         TXS
CASR1C   LDA #$00
         STA $C6
         SEC
         RTS
;---------------------------------------
; CASSWRITE
;---------------------------------------
WRITC    LDA $BA
         JSR SDEV1  ;DEVICE
         JSR $F838
         BCS WRITC1
         JSR BANK1
         .WORD WRITC4  ;HEADER WRITE
         JSR BANK1
         .BYTE $7A,$F6 ;WRITE
WRITC1   RTS
;---------------------------------------
WRITC4   LDA $C2
         PHA
         LDA $C1
         PHA
         LDA $AF
         PHA
         LDA $AE
         PHA
         SEC
         SBC $C1
         LDX $C3
         STX $C1
         TAX
         LDA $AF
         SBC $C2
         LDY $C4
         STY $C2
         TAY
         TXA
         CLC
         ADC $C1
         STA $AE
         TYA
         ADC $C2
         STA $AF
         LDX #$03
         LDA $B9
         AND #$01
         BNE WRITC2
         LDX #$01
WRITC2   STX $9E
         JMP $F77D
;---------------------------------------
; BANKUMSCHALTROUTINE
;---------------------------------------
BANK0    NOP
BANK1    NOP
BANK2    NOP
BANK3    NOP
         NOP
BANK3A   NOP
         CLD
         STA $A5
         STX $A6
         STY $A7
         PHP
         PLA
         STA $A8
         PLA
         STA $9E
         CLC
         ADC #$02
         TAX
         PLA
         STA $9F
         ADC #$00
         PHA
         TXA
         PHA
         LDA $9E
         BNE BANK3B
         DEC $9F
BANK3B   DEC $9E
         LDY #$00
         LDA ($9E),Y
         SEC
         SBC #<BANK0
         TAX
         LDA $DFED
         PHA
         LDA #$DF
         PHA
         LDA #$E2
         PHA
         LDY #$03
         LDA ($9E),Y
         PHA
         DEY
         LDA ($9E),Y
         PHA
         LDA $A8
         PHA
         LDA $A5
         PHA
         LDA $DFEE,X
         LDX $A6
         LDY $A7
         JMP $DFDE
;---------------------------------------
;---------------------------------------
;        MONITOR
;---------------------------------------
MONEX    JMP M1
;---------------------------------------
         JMP M2
;---------------------------------------
M3       JMP M4
;---------------------------------------
         JMP M5
;---------------------------------------
         JMP M6
;---------------------------------------
         JMP M7
;---------------------------------------
M2       STA $0164
         STX $0163
         STX $0167
         PLA
         PLA
         PLA
         PLA
         PLA
M8       JMP M9
M1       STA $0164
         STX $0163
         STX $0167
         JSR M10
         TXA
         BNE M11
         PHA
         PHA
         PHA
         PHA
         PHA
         PHA
         BEQ M8
M11      JSR SUBC2
         JSR M7
         CLC
         JSR M12
         JMP M14
;---------------------------------------
M15      SEC
M16      PHP
         LDA #$4C
         STA $54
         STA $0313
         JSR M17
         LDA $0164
         CMP $DFED
         BEQ M18
         SEC
         JSR M12
         SEI
         PLP
         JSR BANK0
         .BYTE $2A,$80 ;FREEZEREINSPRUNG
M18      JMP $E37B
;---------------------------------------
M10      LDA #$34
         STA $0160
         LDA #$2E
         STA $0165
         LDA #$80
         STA $0161
         STA $0162
         STA $9D
         ASL A
         STA $0313
M17      LDA #$25
         LDY #$DF
M19      STA $0316
         STY $0317
         RTS
;---------------------------------------
M12      SEI
         LDX #$07
M20      LDA $08E0,X
         BCC M21
         LDA $0158,X
         STA $08E0,X
M21      STA $0158,X
         DEX
         BPL M20
M22      RTS
;---------------------------------------
M1I      LDA #$08
         JSR M23
         LDA $8E
         CMP #$1F
         BCC M22
         JSR M24
         JSR M25
         JSR M26
         LDY #$1F
         LDX $D6
         JSR M27
         JMP M28
;---------------------------------------
M1Q      LDA #$20
M23      STA $A8
         JSR M29
         LDY #$01
         LDA ($D1),Y
         STA $97
         BPL M30
         JSR M31
         LDY #$26
M32      LDA ($D1),Y
         JSR M33
         DEY
         CPY #$06
         BNE M32
         JSR M34
         JMP M26
;---------------------------------------
M30      LDY #$00
M35      LDA $AA
         CMP #$2C
         BNE M36
         LDA $0207,Y
         JMP M37
M36      LDA $8E
         CMP #$1F
         BCC M38
         LDA $021F,Y
M37      BEQ M26
         CMP #$2E
         BEQ M39
         BNE M40
M38      JSR M41
M40      JSR M33
M39      INY
         CPY $A8
         BCC M35
M26      LDX $D6
         JSR M42
         LDY $AA
         JSR M43
         LDY #$AD
         JSR M44
         LDA $AA
         CMP #$2C
         BNE M45
         LDA $97
         BPL M46
         JMP M47
M45      LDY #$00
M48      JSR M49
         JSR M50
         INY
         CPY $A8
         BNE M48
M46      JSR M51
         LDY #$00
M52      JSR M49
         CMP #$DE
         BEQ M53
         TAX
         AND #$7F
         CMP #$60
         BCS M53
         CMP #$20
         BCS M54
M53      LDX #$2E
M54      TXA
         JSR $FFD2
         INY
         CPY $A8
         BNE M52
         RTS
M50      PHA
         JSR M51
         PLA
;---------------------------------------
; HEX AUSGEBEN
;---------------------------------------
M5       PHA
         LSR A
         LSR A
         LSR A
         LSR A
         JSR M55
         PLA
         AND #$0F
M55      CLC
         ADC #$30
         CMP #$3A
         BCC M56
         ADC #$06
M56      JMP $FFD2
;---------------------------------------
; ADRESSE AUSGEBEN
;---------------------------------------
M90      JSR M51
M44      LDA $00,Y
         JSR M5
         DEY
         LDA $00,Y
         JMP M5
;---------------------------------------
M1O      CMP #$4F
         BNE M57
         JMP M58
M57      LDX #$00
         CMP #$2A
         BNE M59
         DEX
         JSR $73
M59      STX $97
         LDX #$00
         LDY #$2C
         BNE M60
;---------------------------------------
M60A     INX
         LDY #$3A
M60      STX $0166
         STY $AA
         LDX $9A
         LDA #$08
         CPX #$04
         BCC M61
         ASL A
M61      CPY #$3A
         BEQ M62
         ASL A
         ASL A
M62      STA $A8
         JSR M63
         STY $8D
M64      JSR M24
         LDX $D6
         STX $8F
         JSR M26
M65      JSR M66
         BEQ M67
         JSR M68
         BEQ M65
M67      JSR M25
         BCC M64
         RTS
;---------------------------------------
M68      LDA $AC
         SEC
         SBC $A8
         STA $AC
         BCS M69
         DEC $AD
M69      LDY #$01
         LDA ($D1),Y
         STA $97
         JSR M70
         JMP M26
;---------------------------------------
M71      LDA $0165
         LDY #$00
         STA ($D1),Y
         LDX #$19
M72      DEX
         JSR M42
         LDA ($D1),Y
         CMP $0165
         BNE M72
         JMP M4
;---------------------------------------
; BILDSCHIRM SCROLLEN
;---------------------------------------
M70      DEC $8F
         BPL M73
         LDA $0288
M74      CLC
         ADC #$04
         STA $23
         STA $25
         LDA #$28
         STA $24
         LDA #$00
         STA $22
         LDX #$04
         LDY #$BF
M75      DEC $23
         DEC $25
M76      LDA ($22),Y
         STA ($24),Y
         DEY
         CPY #$FF
         BNE M76
         DEX
         BNE M75
         LDA #$D8
         CMP $23
         BNE M74
         INC $8F
M73      LDX $8F
M42      LDY #$00
M27      CLC
         JMP $FFF0
;---------------------------------------
; ZEILE AUSGEBEN
;---------------------------------------
M47      JSR M31
         LDY #$26
M77      JSR M49
         STA ($D1),Y
         JSR $EA24
         LDA $0286
         STA ($F3),Y
         DEY
         CPY #$06
         BNE M77
         JSR M34
         LDY #$01
         LDA #$AC
         STA ($D1),Y
         DEY
         RTS
;---------------------------------------
M31      LDA $AC
         SEC
         SBC #$07
         STA $AC
         BCS M78
         DEC $AD
M78      RTS
;---------------------------------------
M34      LDA $AC
         CLC
         ADC #$07
         STA $AC
         BCC M79
         INC $AD
M79      RTS
;---------------------------------------
M1J      JSR M41
         STA $0158
         JSR M41
         STA $0159
         LDX #$00
M80      JSR M41
         STA $015B,X
         INX
         CPX #$05
         BCC M80
         DEC $7A
         JSR M81
         STX $015A
         RTS
;---------------------------------------
M1P      JSR M24
         LDA #$A4
         PHA
         LDA #$8C
         PHA
         LDA #$4C
         STA $54
         JSR $79
         JMP $DF12
;---------------------------------------
M1C      JSR M29
         JSR M82
         JSR M41
         TAX
M84      TXA
         JSR M33
         JSR M83
         BCC M84
         RTS
;---------------------------------------
M1D      JSR M63
         JSR M85
M86      LDY #$00
         JSR M87
         STA $C3
         LDA #$C1
         JSR M88
         CMP $C3
         BEQ M89
         TAX
         JSR M24
         LDY #$AD
         JSR M90
         LDY #$C2
         JSR M90
         LDY #$00
         LDA $C3
         JSR M50
         TXA
         JSR M50
         JSR M91
M89      JSR M92
         BCC M86
         RTS
;---------------------------------------
M1E      JSR M63
         JSR M93
         LDY $B7
         BEQ M94
         JSR M24
M95      LDY #$00
         BIT $DC01
         BPL M94
M96      JSR M49
         CMP ($BB),Y
         BNE M97
         INY
         CPY $B7
         BNE M96
         LDY #$AD
         JSR M90
M97      JSR M83
         BCC M95
M94      RTS
;---------------------------------------
M1F      JSR M29
         JSR M82
         JSR M98
         JSR M85
         SEC
         LDA $AE
         SBC $AC
         STA $C4
         LDA $AF
         SBC $AD
         TAX
         LDA $AC
         CMP $C1
         LDA $AD
         SBC $C2
         BCC M99
         INX
M101     CPY $C4
         BNE M100
         DEX
         BEQ M102B
M100     JSR M87
         JSR M102
         INY
         BNE M101
         INC $AD
         INC $C2
         JMP M101
;---------------------------------------
M99      LDY $C4
         TXA
         ADC $AD
         STA $AD
         TXA
         CLC
         ADC $C2
         STA $C2
         INX
M103     TYA
         BEQ M104
M105     DEY
         JSR M87
         JSR M102
         JMP M103
M104     DEC $AD
         DEC $C2
         DEX
         BNE M105
M102B    RTS
;---------------------------------------
M1G      JSR M106
         LDA $0164
         CMP $DFED
         BEQ M107
         CLC
         JMP M16
;---------------------------------------
M107     LDX #$28
M109     LDA MFELD1,X
         STA $0120,X
         DEX
         BPL M109
         LDA #$36
         LDY #$01
         JSR M19
         LDX $015E
         TXS
         LDA $0158
         STA $0135
         LDA $0159
         STA $0134
         LDX $DFF3
         LDA $015A
         JMP $DFA5
;---------------------------------------
         STA $015B
         STX $015C
         STY $015D
         PHP
         PLA
         STA $015A
         JMP M110
;---------------------------------------
MFELD1   STX $DE00
         PHA
         LDX $015C
         LDY $015D
         LDA $015F
         STA $01
         LDA $015B
         PLP
         JMP $FCE2
;---------------------------------------
         LDA $01
         STA $015F
         LDA #$37
         STA $01
         JSR $DF00
         JMP M111
;---------------------------------------
; REGISTER AUSGEBEN
;---------------------------------------
M112     LDY #$3B
         JSR M113
         LDA $0158
         JSR M5
         LDA $0159
         JSR M5
         LDX #$00
M114     LDA $015B,X
         JSR M50
         INX
         CPX #$05
         BNE M114
         JSR M51
         LDA $015A
M115     SEC
M116     ROL A
         BEQ M117
         PHA
         LDA #$30
         ADC #$00
         JSR $FFD2
         PLA
         CLC
         BCC M116
M117     RTS
M9       LDA $01
         STA $015F
M111     LDA #$37
         STA $01
         CLD
         LDA $D011
         ORA #$10
         STA $D011
         JSR $FDA3
         LDX #$05
M118     PLA
         STA $0158,X
         DEX
         BPL M118
         LDA $0159
         BNE M119
         DEC $0158
M119     DEC $0159
         JSR M24
         LDA #$42
         JSR $FFD2
         LDA #$2A
         JSR $FFD2
         JSR M24
         JSR M10
M110     TSX
         STX $015E
         JSR M17
M14      JSR M24
         LDA #<STLINE
         LDY #>STLINE
         JSR $AB1E
         JSR M112
M4       LDA $9A
         CMP #$04
         BCC M120
         JSR M24
M120     JSR $FFE7
M121     LDY #$00
         JSR M113
M28      LDX #$D0
         TXS
         CLD
         JSR M122
         TAX
         BEQ M121
M123     STA $AA
         LDX #$FF
M124     INX
         LDA MFELD2,X
         BNE M125
         JMP M126
M125     CMP $AA
         BNE M124
         JSR M127
         JMP M4
M127     TXA
         ASL A
         TAX
         LDA MFELD3+1,X
         PHA
         LDA MFELD3,X
         PHA
         JSR M7
         LDA $BA
         CMP #$08
         BCS M128
         LDA #$08
         STA $BA
M128     JMP $73
M24      LDA #$0D
         .BYTE $2C
M129     LDA #$24
         .BYTE $2C
M51      LDA #$20
         JMP $FFD2
;---------------------------------------
M106     LDX $0159
         LDY $0158
         JSR $79
         BEQ M130
         JSR M29
         LDX $AC
         LDY $AD
M130     STX $0159
         STY $0158
         RTS
;---------------------------------------
M81      LDA #$01
M131     PHA
         JSR $73
         CMP #$31
         PLA
         ROL A
         DEX
         BCC M131
         TAX
         JMP $73
M132     JSR $79
         CMP #$2B
         BNE M133
         STX $02
         STY $03
         JSR $73
         JSR $B79E
         TXA
         PHA
         JSR $79
         BEQ M134
         CMP #$2C
         BNE M134
         JSR $73
M134     LDX $02
         LDY $03
         PLA
         CLC
         RTS
M133     JSR $79
         JSR M135
         ASL A
         ASL A
         ASL A
         ASL A
         STA $9F
         JSR $73
         JSR M135
         PHA
         JSR $73
         PLA
         ORA $9F
         CLC
         RTS
;---------------------------------------
M137     JSR $79
         CMP #$2C
         BNE M138
         JMP $73
M135     BCS M138B
         ADC #$D0
         RTS
M138B    CMP #$41
         BCC M139
         CMP #$47
         BCS M139
         ADC #$C9
         RTS
M139     PLA
         PLA
         SEC
M140     RTS
M41      JSR M132
         BCC M140
M138     JMP M126
         JMP M4
M29      LDY #$AD
         .BYTE $2C
M82      LDY #$AF
         .BYTE $2C
M85      LDY #$C2
         .BYTE $2C
M141     LDY #$C4
         JSR M41
         STA $00,Y
         JSR M41
         DEY
         STA $00,Y
         LDY #$00
         JMP $79
;---------------------------------------
M63      LDA #$FF
         STA $AE
         STA $AF
         JSR $79
         BEQ M142
         JSR M29
         BNE M143
         LDA $AC
         STA $AE
         LDA $AD
         STA $AF
M142     LDY #$00
         RTS
M143     CMP #$2D
         BEQ M142
         LDY #$02
         LDA ($7A),Y
         CMP #$20
         BEQ M142
         JSR M82
M98      JSR M144
         BCC M142
         JMP M138
;---------------------------------------
M92      INC $C1
         BNE M83
         INC $C2
M83      INC $AC
         BNE M145
         INC $AD
M145     JMP M144
;---------------------------------------
M113     JSR M24
M43      LDA $0165
         BPL M146
         STA $C7
         AND #$7F
M146     JSR $FFD2
         LDA #$00
         STA $C7
         TYA
         BEQ M147
         JMP $FFD2
;---------------------------------------
M122     CLI
         LDY #$00
         STY $D4
         INY
         STY $13
         JSR SUBC1
         STX $7A
         STY $7B
         INX
         STX $13
M148     JSR $73
         CMP #$2E
         BEQ M148
         LDX $8F
         BPL M149
M147     RTS
M149     TAY
         JSR M7
         TYA
         BEQ M150
         JSR $73
         JSR M29
         LDX $8F
         BEQ M150
         JSR M24
         LDY $A8
         BNE M151
         JSR M49
         JSR M152
         INC $A8
M151     JSR M25
M150     LDX $8F
         JSR M153
         SEI
         LDX $D6
         LDY $8E
         JSR M27
         LDA ($D1),Y
         STA $CE
         JMP M122
M153     LDA $A8
         CMP #$08
         BCC M154
         TXA
         BNE M155
         JMP M68
;---------------------------------------
M155     JSR M26
         BEQ M156
M154     TXA
         BNE M157
         JMP M158
M157     JSR M159
M156     JMP M25
M93      JSR M160
M161     JSR $79
         BEQ M162
         CMP #$22
         BEQ M6
         JSR M41
         STA ($BB),Y
         INC $B7
         INY
         BNE M161
M162     RTS
M6       LDY #$00
         LDA ($7A),Y
         CMP #$22
         BNE M163
         INC $7A
M163     LDA ($7A),Y
         CLC
         BEQ M164
         CMP #$22
         BEQ M164
         INY
         BNE M163
M164     JSR M160
         TYA
         ADC $7A
         STA $7A
         JMP $79
M160     LDA $7A
         STA $BB
         LDA $7B
         STA $BC
         STY $B7
         RTS
;---------------------------------------
M165     JSR $79
         BEQ M166
         CMP #$22
         BNE M166
         JSR M6
         BEQ M167
         JSR M137
         JSR $B79E
         STX $BA
         BEQ M167
         JSR M137
         JSR M141
         LDA #$01
M167     CMP #$00
         RTS
M91      CLI
         JSR $FFE4
         CMP #$03
         BEQ M166
         CMP #$11
         BNE M167
M166     JSR M25
M169     BIT $C5
         BVC M169
         JMP M71
M66      JSR M91
         BEQ M170
M171     JSR M91
         BEQ M171
         CMP #$87
         BEQ M172
         CMP #$88
         CLC
         BNE M170
         LDA #$00
M172     STA $8D
M170     LDA $8D
         RTS
;---------------------------------------
M1K      CMP #$49
         BNE M173
         LDY #$01
         LDA ($7A),Y
         CMP #$2A
         BEQ M174
M173     LDA #$04
         TAX
         LDY #$FF
         JSR $FFBA
         JSR $FFC0
         LDX #$04
         JSR $FFC9
M174     JSR $79
         JMP M123
;---------------------------------------
; LOAD / VERIFY
;---------------------------------------
M1A      LDA #$00
         .BYTE $2C
M1B      LDA #$01
         STA $0A
         STA $93
         JSR M165
         EOR #$01
         STA $B9
         CPX #$08
         BCS M175
         LDA $B9
         BNE M175
         JSR BANK1
         .BYTE $2C,$F7
;---------------------------------------
         BCS M176
         SEC
         JSR BANK1
         .BYTE $7D,$F5
;---------------------------------------
         JMP M176
;---------------------------------------
M175     LDA $93
         LDX $C3
         LDY $C4
         JSR BANK1
         .BYTE $D5,$FF
;---------------------------------------
M176     BCS M177
         LDA $0A
         BNE M177
         LDA $90
         AND #$BF
         BNE M177
         LDX $AE
         LDY $AF
         RTS
M177     JMP $E178
;---------------------------------------
; SAVE
;---------------------------------------
M1L      JSR M165
         BEQ M178
         LDA $C3
         STA $C1
         LDA $C4
         STA $C2
         JSR $79
         BEQ M178
         JSR M137
         JSR M82
         JSR $79
         BNE M180
         LDX $AE
         LDY $AF
         LDA #$C1
         JSR BANK1
         .BYTE $D8,$FF
;---------------------------------------
         JMP M181
;---------------------------------------
M178     JMP M126
;---------------------------------------
M180     JSR M137
         JSR M141
         LDA $BA
         CMP #$08
         BCC M182
         JSR BANK2
         .BYTE $09,$81 ;SAVE
;---------------------------------------
         JMP M181
;---------------------------------------
M182     JSR SUBC3
M181     BCC M184
         JMP $E1D1
;---------------------------------------
M1M      JSR M201
         JSR M24
         JSR M129
         LDY #$15
         JSR M44
         JSR M51
         LDA #$25
         JSR $FFD2
         LDA $15
         BEQ M200
         JSR M115
M200     LDA $14
         JSR M115
         JSR M51
         LDX $14
         LDA $15
         JSR $BDCD
         LDA $15
         BNE M184
         LDA $14
         TAX
         AND #$7F
         CMP #$20
         BCC M184
         JSR M51
         LDA #$27
         JSR $FFD2
         TXA
         JSR $FFD2
M184     RTS
;---------------------------------------
M201     PHA
         JSR $73
         PLA
         LDX #$00
         STX $15
         CMP #$24
         BNE M202
         JSR M41
         STA $14
         JSR $79
         BEQ M203
         JSR M41
         LDX $14
         STA $14
         STX $15
M203     RTS
M202     CMP #$25
         BEQ M204
         CLC
         DEC $7A
         JSR $AD8A
         JMP $B7F7
M204     DEC $7A
         JSR M81
         STX $14
         BEQ M203
         DEC $7A
         JSR M81
         LDA $14
         STX $14
         STA $15
         RTS
;---------------------------------------
M1H      LDA #$02
         STA $0166
         JSR M63
         STY $8D
M205     JSR M24
         LDX $D6
         STX $8F
         JSR M159
M206     JSR M66
         BEQ M207
         JSR M158
         JMP M206
M207     JSR M25
         BCC M205
         JMP M4
M158     JSR M70
         LDA #$C1
         STA $0107
         LDA #$15
         STA $25
M208     LDA $AC
         SEC
         SBC $25
         STA $C1
         LDA $AD
         SBC #$00
         STA $C2
         LDY #$01
M209     STY $24
         JSR M49
         JSR M152
         LDY $24
         BCC M210
         INY
         CPY $25
         BCC M209
         BCS M211
M210     TYA
         SEC
         ADC $A8
         CMP $25
         BEQ M212
         TAY
         BCC M209
         DEC $25
         BNE M208
         LDY #$01
         BNE M213
M211     LDY $25
M213     DEY
M212     TYA
         CLC
         ADC $C1
         STA $AC
         LDA $C2
         ADC #$00
         STA $AD
         JSR M214
M159     LDY #$00
         STY $D3
         LDY #$3E
         JSR M43
         LDY #$AD
         JSR M90
         LDY #$02
M215     JSR M49
         STA $A9,Y
         DEY
         BPL M215
         LDA $A9
         JSR M152
         PHA
         LDX $A8
         INX
M216     DEX
         BPL M217
         JSR M51
         JSR M51
         JSR M51
         JMP M218
M217     LDA $A9,Y
         JSR M50
M218     INY
         CPY #$03
         BCC M216
         JSR M51
         JSR M51
         PLA
         LDX #$03
         JSR M220
         LDX #$06
M221     CPX #$03
         BNE M222
         LDY $A8
         BEQ M222
M223     LDA $A7
         CMP #$E8
         PHP
         LDA $A9,Y
         PLP
         BCS M224
         JSR M5
         DEY
         BNE M223
M222     ASL $A7
         BCC M226
         LDA MFELD4,X
         JSR $FFD2
         LDA MFELD5,X
         BEQ M226
         JSR $FFD2
M226     DEX
         BNE M221
M228     INC $A8
         LDA #$20
         LDY $D3
M229     STA ($D1),Y
         INY
         CPY #$28
         BCC M229
         RTS
;---------------------------------------
M224     JSR M230
         PHA
         TXA
         JSR M5
         PLA
         JSR M5
         JMP M228
M230     LDX $AD
         TAY
         BPL M231
         DEX
M231     SEC
         ADC $AC
         BCC M233
         INX
M233     CLC
         ADC #$01
         BNE M232
         INX
M232     RTS
;---------------------------------------
M220     TAY
         LDA MFELD7,Y
         STA $22
         LDA MFELD8,Y
         STA $23
M234     LDA #$00
         LDY #$05
M235     ASL $23
         ROL $22
         ROL A
         DEY
         BNE M235
         ADC #$3F
         JSR $FFD2
         DEX
         BNE M234
         JMP M51
M152     TAY
         LSR A
         BCC M236
         LSR A
         BCS M237
         CMP #$22
         BEQ M237
         AND #$07
         ORA #$80
M236     LSR A
         TAX
         LDA MFELD10,X
         BCS M238
         LSR A
         LSR A
         LSR A
         LSR A
M238     AND #$0F
         CLC
         BNE M239
M237     SEC
         LDY #$80
         LDA #$00
M239     TAX
         PHP
         LDA MFELD11,X
         STA $A7
         AND #$03
         STA $A8
         TYA
         AND #$8F
         TAX
         TYA
         LDY #$03
         CPX #$8A
         BEQ M240
M241     LSR A
         BCC M240
         LSR A
M242     LSR A
         ORA #$20
         DEY
         BNE M242
         INY
M240     DEY
         BNE M241
         PLP
         RTS
;---------------------------------------
MFELD7   .BYTE $1C,$8A,$1C,$23
         .BYTE $5D,$8B,$1B,$A1
         .BYTE $9D,$8A,$1D,$23
         .BYTE $9D,$8B,$1D,$A1
         .BYTE $00,$29,$19,$AE
         .BYTE $69,$A8,$19,$23
         .BYTE $24,$53,$1B,$23
         .BYTE $24,$53,$19,$A1
         .BYTE $00,$1A,$5B,$5B
         .BYTE $A5,$69,$24,$24
         .BYTE $AE,$AE,$A8,$AD
         .BYTE $29,$00,$7C,$00
         .BYTE $15,$9C,$6D,$9C
         .BYTE $A5,$69,$29,$53
         .BYTE $84,$13,$34,$11
         .BYTE $A5,$69,$23,$A0
MFELD8   .BYTE $D8,$62,$5A,$48
         .BYTE $26,$62,$94,$88
         .BYTE $54,$44,$C8,$54
         .BYTE $68,$44,$E8,$94
         .BYTE $00,$B4,$08,$84
         .BYTE $74,$B4,$28,$6E
         .BYTE $74,$F4,$CC,$4A
         .BYTE $72,$F2,$A4,$8A
         .BYTE $00,$AA,$A2,$A2
         .BYTE $74,$74,$74,$72
         .BYTE $44,$68,$B2,$32
         .BYTE $B2,$00,$22,$00
         .BYTE $1A,$1A,$26,$26
         .BYTE $72,$72,$88,$C8
         .BYTE $C4,$CA,$26,$48
         .BYTE $44,$44,$A2,$C8
MFELD10  .BYTE $40,$02,$45,$03
         .BYTE $D0,$08,$40,$09
         .BYTE $30,$22,$45,$33
         .BYTE $D0,$08,$40,$09
         .BYTE $40,$02,$45,$33
         .BYTE $D0,$08,$40,$09
         .BYTE $40,$02,$45,$B3
         .BYTE $D0,$08,$40,$09
         .BYTE $00,$22,$44,$33
         .BYTE $D0,$8C,$44,$00
         .BYTE $11,$22,$44,$33
         .BYTE $D0,$8C,$44,$9A
         .BYTE $10,$22,$44,$33
         .BYTE $D0,$08,$40,$09
         .BYTE $10,$22,$44,$33
         .BYTE $D0,$08,$40,$09
         .BYTE $62,$13,$78,$A9
MFELD11  .BYTE $00,$21,$81,$82
         .BYTE $00,$00,$59,$4D
         .BYTE $91,$92,$86,$4A
         .BYTE $85
MFELD4   .BYTE $9D,$2C,$29,$2C
         .BYTE $23,$28
MFELD5   .BYTE $24,$59,$00,$58
         .BYTE $24,$24,$00
;---------------------------------------
M25      CLC
         LDA $A8
         ADC $AC
         STA $AC
         BCC M144
         INC $AD
M144     LDA $AC
         CMP $AE
         LDA $AD
         SBC $AF
         RTS
;---------------------------------------
M1N      LDA #$02
         STA $0166
         JSR M29
         BEQ M250
         LDY #$02
         LDA ($7A),Y
         CMP #$20
         BNE M251
         LDA $8E
         CMP #$12
         BCS M251
         LDY #$FF
M252     INY
         JSR M41
         PHA
         LDA $7A
         CMP #$12
         BCS M253
         CPY #$02
         BCC M252
M253     PLA
         JSR M33
         DEY
         BPL M253
         JMP M254
M251     DEC $7A
M255     INC $7A
         LDY #$00
         STY $51
         LDY #$03
M256     DEY
         BMI M257
         LDA ($7A),Y
         BEQ M126
         CMP #$20
         BEQ M255
         SEC
         SBC #$3F
         LDX #$05
M258     LSR A
         ROR $51
         ROR $50
         DEX
         BNE M258
         BEQ M256
M126     LDA $7A
         STA $D3
         LDA #$3F
         JSR $FFD2
M250     JMP M4
M257     INC $7A
         INC $7A
         STX $A6
         LDX #$02
M259     JSR $73
M260     JSR $79
         BEQ M261
         CMP #$24
         BNE M262
         JSR M263
         JSR $73
M264     JSR M132
         BCS M260
         INC $A6
         LDY $A6
         CPY #$03
         BEQ M126
         STA $A9,Y
         LDA #$30
         JSR M263
         JSR M263
         BNE M264
M262     JSR M263
         BCC M259
M261     STX $A5
         CPY #$02
         BNE M270
         LDA $AB
         LDY $AA
         STY $AB
         STA $AA
M270     LDX #$00
         STX $A9
M271     LDX #$00
         STX $9F
         LDA $A9
         JSR M152
         LDX $A7
         STX $64
         TAX
         LDA MFELD8,X
         JSR M275
         LDA MFELD7,X
         JSR M275
         LDX #$06
M276     CPX #$03
         BNE M277
         LDY $A8
         BEQ M277
M278     LDA $A7
         CMP #$E8
         LDA #$30
         BCS M279
         JSR M280
         DEY
         BNE M278
M277     ASL $A7
         BCC M281
         LDA MFELD4,X
         JSR M275
         LDA MFELD5,X
         BEQ M281
         JSR M275
M281     DEX
         BNE M276
         BEQ M282
M279     JSR M280
         JSR M280
M282     LDA $A5
         CMP $9F
         BEQ M283
         JMP M285
M283     LDY $A8
         BEQ M286
         LDA $64
         CMP #$9D
         BNE M286B
         LDA $AA
         SBC $AC
         TAX
         LDA $AB
         SBC $AD
         BCC M290
         BNE M291
         CPX #$82
         BCS M291
         BCC M300
M290     TAY
         INY
         BNE M291
         CPX #$82
         BCC M291
M300     DEX
         DEX
         TXA
         LDY $A8
         BNE M301
M286B    LDA $A9,Y
M301     JSR M33
         DEY
         BNE M286B
M286     LDA $A9
         CMP #$02
         BEQ M254
         JSR M33
M254     JSR M159
         JSR M25
         LDY #$41
         JSR M113
         LDY #$AD
         JSR M90
         JSR M51
         JMP M28
M280     JSR M275
M275     STX $A4
         LDX $9F
         CMP $50,X
         BEQ M310
         PLA
         PLA
M285     INC $A9
         BEQ M291
         JMP M271
M310     INC $9F
         LDX $A4
         RTS
M291     JMP M126
;---------------------------------------
M1S      BEQ M311
         BCS M312
         SEC
         SBC #$30
         CMP #$08
         BCS M313
         LDA #$08
M313     STA $BA
         JSR $73
         BNE M312
M311     STA $B7
         JSR M24
         JMP M314
M312     CMP #$2A
         BEQ M314B
         JMP M315
M314B    JSR M316
         JSR $73
         BEQ M317
         AND #$0F
         BNE M318
         LDA #$80
M318     TAX
         TAY
         JSR $73
         BEQ M320
         AND #$0F
         BNE M319
         LDA #$80
M319     TAY
M320     STX $0161
         STY $0162
M317     RTS
;---------------------------------------
M316     LDX #$80
         LDY #$80
         BNE M320
M7       LDX #$57
M322     LDA MFELD14,X
         STA $0100,X
         DEX
         BPL M322
         INX
         LDA $DFED
         STA $0122
         STA $013F
         LDA $DFF4
         STA $012F
M214     LDA #$AC
         STA $0107
         RTS
;---------------------------------------
M87      LDA #$AC
M88      STA $0107
M49      BIT $0161
         BPL M323
         LDA #$AD
         JMP $0100
M323     STX $14
         LDX $0107
         LDA $BA
         PHA
         LDA $0161
         STA $BA
         LDA #$52
         JSR M324
         JSR $FFAE
         LDA $BA
         JSR $FFB4
         LDA #$6F
         JSR $FF96
         JSR $FFA5
         STA $15
         JSR $FFAB
M330     LDX $14
         PLA
         STA $BA
         LDA $15
         RTS
;---------------------------------------
M102     PHA
         LDA #$C1
         STA $0107
         PLA
M33      STA $0136
         BIT $0162
         BPL M331
         LDA #$8D
         JMP $0100
M331     LDA $BA
         PHA
         LDA $0162
         STA $BA
         STX $14
         LDX $0107
         LDA #$57
         JSR M324
         LDA $0136
         JSR $FFA8
         LDA #$0D
         JSR $FFA8
         JSR $FFAE
         JMP M330
M324     JSR M332
         TYA
         CLC
         ADC $00,X
         PHP
         JSR $FFA8
         PLP
         LDA $01,X
         ADC #$00
         JSR $FFA8
         LDA #$01
         JMP $FFA8
M333     LDA #$00
         STA $90
         LDA $BA
         JSR $FFB1
         LDA #$6F
         JSR $FF93
         LDA $90
         BPL M334
         JMP $F707
M334     CLC
         RTS
M332     PHA
         JSR M333
         BCC M335
         JMP $E1D1
M335     LDA #$4D
         JSR $FFA8
         LDA #$2D
         JSR $FFA8
         PLA
         JMP $FFA8
M263     STA $50,X
         INX
         CPX #$0A
         BCC M336
         JMP M126
M336     RTS
;---------------------------------------
M315     CMP #$42
         BNE M337
         JSR $73
         CMP #$52
         BEQ M338
         CMP #$57
         BEQ M339
         BNE M340
M337     CMP #$4D
         BNE M340
         JSR $73
         CMP #$45
         BNE M340
         JSR $73
         JSR M29
         LDA #$45
         JSR M332
         LDA $AC
         JSR $FFA8
         LDA $AD
         JSR $FFA8
         JMP $FFAE
M340     JSR M6
M314     JSR BANK2
         .BYTE $0F,$81
;---------------------------------------
         RTS
;---------------------------------------
M338     JMP M341
;---------------------------------------
M339     JMP M342
;---------------------------------------
M343     LDA #$00
         PHA
         JSR M344
         JSR PRINT
         .TEXT "B-P 3 "
         .BYTE $00
;---------------------------------------
         PLA
         JSR M345
         JMP $FFCC
;---------------------------------------
M341     JSR M346
         BCS M348
M347     LDA #$31
         JSR M349
M350     JSR M351
         BCS M350
         LDY #$00
M352     JSR $FFCF
         JSR M33
         INY
         BNE M352
M348     JSR $FFCC
         JMP M362
;---------------------------------------
M342     JSR M346
         BCS M348
M370     JSR M343
M360     JSR M361
         BCS M360
         LDY #$00
M371     JSR M49
         JSR $FFD2
         INY
         BNE M371
         JSR M372
         JMP M348
;---------------------------------------
M372     LDA #$32
M349     PHA
         JSR M344
         LDA #$55
         JSR $FFD2
         PLA
         JSR $FFD2
         JSR PRINT
         .TEXT ": 3 0 "
         .BYTE $00
;---------------------------------------
         LDA $25
         JSR M345
         JSR M51
         LDA $26
         JSR M345
         JMP $FFCC
M345     LDX #$30
         SEC
M380     SBC #$0A
         BCC M381
         INX
         BCS M380
M381     ADC #$3A
         PHA
         TXA
         BEQ M382
         JSR $FFD2
M382     PLA
         JMP $FFD2
M344     LDX #$0F
         .BYTE $2C
M361     LDX #$03
         JMP $FFC9
         LDX #$0F
         .BYTE $2C
M351     LDX #$03
         JMP $FFC6
         LDA #$0F
         .BYTE $2C
M362     LDA #$03
         JSR $FFC3
         JSR $FFCC
         CLC
         RTS
;---------------------------------------
MOPEN    LDX $BA
         LDA #$0F
         TAY
         JSR $FFBA
         LDA #$00
M400     JSR $FFBD
         JMP $FFC0
;---------------------------------------
M401     LDX $BA
         LDA #$03
         TAY
         JSR $FFBA
         LDA #$01
         LDX #<FNNUM
         LDY #>FNNUM
         BNE M400
M346     JSR $73
         JSR M41
         PHA
         JSR M41
         TAY
         LDX #$CF
         JSR $79
         BEQ M402
         JSR M41
         TAX
M402     PLA
M403     STA $25
         STY $26
         STX $AD
         LDA #$00
         STA $AC
         JSR M316
         JSR M333
         BCS M404
         JSR $FFAE
         JSR $FFE7
         JSR MOPEN
         JSR M401
         CLC
M404     RTS
;---------------------------------------
INMONA   SEC
         .BYTE $24
INMONB   CLC
         PHP
         JSR M403
         BCC M405
         PLP
         SEC
         RTS
M405     JSR M7
         STX $0163
         LDA #$34
         STA $0160
         PLP
         BCC M406
         JMP M347
M406     JMP M370
;---------------------------------------
FNNUM    .BYTE $23
;---------------------------------------
PRINT    PLA
         STA $22
         PLA
         STA $23
         STY $24
         LDY #$00
M500     INC $22
         BNE M501
         INC $23
M501     LDA ($22),Y
         BEQ M502
         JSR $FFD2
         BCC M500
M502     LDY $24
         LDA $23
         PHA
         LDA $22
         PHA
         RTS
;---------------------------------------
M1R      LDA #$52
         JSR $FFD2
         LDA $0160
         CMP #$34
         BEQ M503
         CMP #$37
         BEQ M503
         LDA #$37
M503     EOR #$03
         STA $0160
         LDY #$41
         LDX $0167
         AND #$03
         BEQ M504
         LDY #$4F
         LDX #$00
M504     TYA
         JSR $FFD2
         LDA #$4D
         JSR $FFD2
         LDA #$2E
         CPY #$41
         BEQ M505
         ORA #$80
M505     STA $0165
         STX $0163
         RTS
;---------------------------------------
MFELD2   .BYTE $58,$4D,$52,$4C
         .BYTE $46,$43,$48,$54
         .BYTE $47,$44,$3A,$3B
         .BYTE $50,$53,$56,$4E
         .BYTE $41,$3E,$49,$2C
         .BYTE $42,$2A,$24,$40
         .BYTE $2D,$00
;---------------------------------------
MFELD3   .WORD M15-1
         .WORD M60A-1
         .WORD M14-1
         .WORD M1A-1
         .WORD M1C-1
         .WORD M1D-1
         .WORD M1E-1
         .WORD M1F-1
         .WORD M1G-1
         .WORD M1H-1
         .WORD M1I-1
         .WORD M1J-1
         .WORD M1K-1
         .WORD M1L-1
         .WORD M1B-1
         .WORD M1M-1
         .WORD M1N-1
         .WORD M1N-1
         .WORD M1O-1
         .WORD M1Q-1
         .WORD M1P-1
         .WORD M1R-1
         .WORD SUBC0-1
         .WORD M1S-1
         .WORD M1T-1
;---------------------------------------
STLINE   .BYTE $20,$20,$41
         .BYTE $44,$44,$52,$20
         .BYTE $41,$52,$20,$58
         .BYTE $52,$20,$59,$52
         .BYTE $20,$53,$50,$20
         .BYTE $30,$31,$20,$4E
         .BYTE $56,$2D,$42,$44
         .BYTE $49,$5A,$43,$00
;---------------------------------------
MFELD14  STA $0137
         STX $0144
         LDX #$AC
         SEI
         TYA
         CLC
         ADC $00,X
         STA $0138
         LDA $01,X
         ADC #$00
         CMP $0163
         BCS M700
         ADC #$80
M700     STA $0139
         LDX $0160
         LDA #$0B
         BCS M702
M701     LDA $D012
         SBC #$30
         BCS M701
         LDX #$37
         LDA #$03
M702     STA $DE00
         STX $01
         LDA #$FF
         STA $FFFF
         LDX #$37
         STX $01
         LDX #$0A
         STX $DE00
         LDX #$FF
         AND #$FF
         RTS
;---------------------------------------
M58      LDA $0164
         CMP $DFED
         BEQ M705
         JSR $E544
         LDX #$90
         LDY #$D0
M706     LDA #$00
         STA $C1
         STY $C2
         JSR M24
M707     LDY #$2D
         JSR M113
         LDY #$C2
         JSR M44
         LDY #$08
M708     LDA $0800,X
         JSR M50
         INC $C1
         INX
         DEY
         BNE M708
         CPX #$E0
         BEQ M705
         LDY #$DC
         CPX #$C0
         BEQ M706
         INY
         CPX #$D0
         BEQ M706
         BNE M707
M705     JSR M24
         JMP M14
;---------------------------------------
M1T      JSR M85
         LDX #$90
         LDA $C2
         CMP #$D0
         BEQ M710
         LDX #$C0
         CMP #$DC
         BEQ M710
         LDX #$D0
         CMP #$DD
         BNE M711
M710     TXA
         CLC
         ADC $C1
         BCS M711
         CMP #$D9
         BCS M711
         TAY
         LDX #$08
M712     JSR M41
         STA $0800,Y
         INY
         DEX
         BNE M712
         RTS
M711     JMP M126
;---------------------------------------
; RENUMBER
;---------------------------------------
RENUR3   LDA #$0A
         STA $DE00
         LDA $D020
         STA $02
         JMP $C0D0
;---------------------------------------
         .BYTE $9B,$8A,$A7,$89
         .BYTE $8D,$CB,$AB
;---------------------------------------
         LDY $2C
         STA $63
         STY $62
         LDX #$90
         SEC
         JSR $BC49
         JMP $BDDD
;---------------------------------------
         JSR $79
         BEQ M714
         LDY #$00
         JSR $C063
         BEQ M714
         CMP #$2C
         BNE M714
         JSR $73
         JSR $C063
         BNE M714
         RTS
;---------------------------------------
         LDA #$B9
         PHA
         LDA #$7D
         PHA
         JMP $C054
;---------------------------------------
M714     LDA #$AF
         PHA
         LDA #$07
         PHA
         JMP $C054
;---------------------------------------
         LDA #$E3
         PHA
         LDA #$85
         PHA
         LDA $02
         STA $D020
         LDA #$29
         STA $DE00
         NOP
         NOP
         JMP RENUR2+$2000
;---------------------------------------
         BCS M714
         JSR $A96B
         LDA $14
         STA $0334,Y
         INY
         LDA $15
         STA $0334,Y
         INY
         JMP $79
;---------------------------------------
         LDA $0334
         STA $AC
         LDA $0335
         STA $AD
         JMP $A68E
;---------------------------------------
         JSR $C088
         TAY
         INC $7A
         BNE M720
         INC $7B
M720     LDX #$00
         LDA ($7A,X)
         RTS
;---------------------------------------
         CLC
         LDA $AC
         ADC $0336
         STA $AC
         LDA $AD
         ADC $0337
         STA $AD
         BCS M721
         CMP #$FA
M721     RTS
;---------------------------------------
         JSR $C084
M722     JSR $C088
         BNE M722
         RTS
;---------------------------------------
         LDA $7A
         STA $5A
         LDA $7B
         STA $5B
         RTS
;---------------------------------------
         LDA $7A
         STA $2D
         LDA $7B
         STA $2E
         LDX #$FC
         TXS
         JSR $A659
         JSR $A533
         JMP $C04E
;---------------------------------------
M730A    JMP $C03C
;---------------------------------------
         JSR $C023
         JSR $C077
M730     JSR $C084
         BEQ M731
         JSR $C093
         BCS M730A
         JSR $C0A7
         BEQ M730
M731     JSR $C10C
         JSR $C0F1
         JSR $C084
         JMP $C0B9
;---------------------------------------
         JSR $C077
M732     JSR $C084
         BEQ M733
         LDY #$01
         LDA $AC
         STA ($7A),Y
         INY
         LDA $AD
         STA ($7A),Y
         JSR $C093
         JSR $C0A7
         BEQ M732
         JSR $C077
M740     JSR $C084
         BNE M741
M733     RTS
M741     JSR $C084
         LDA #$10
         STA $C1
M742     LDA #$10
         .BYTE $2C
M743     LDA #$20
         EOR $C1
         STA $C1
M744     JSR $73
M745     TAX
         BEQ M740
         CMP #$22
         BEQ M742
         LDY $C1
         BNE M744
         CMP #$80
         BCC M744
         CMP #$8F
         BEQ M743
         LDX #$05
M746     CMP $C00D,X
         BEQ M747
         DEX
         BPL M746
         BMI M744
M747     INC $D020
         JSR $C0B0
         JSR $73
         LDX #$02
M748     CMP $C013,X
         BEQ M747
         DEX
         BPL M748
         JSR $79
         BCS M745
         JSR $A96B
         JSR $C077
M749     JSR $C084
         BEQ M750
         JSR $C084
         CMP $15
         BNE M751
         CPY $14
         BEQ M752
M751     JSR $C093
         JSR $C0AA
         BEQ M749
M750     LDY #$F9
         LDA #$FF
         BNE M753
M752     LDY $AD
         LDA $AC
M753     JSR $C016
         JSR $C1EA
         LDX #$01
         STX $AF
         DEX
         STX $AE
         JSR $73
M754     INC $AE
         LDA ($AE,X)
         BEQ M755
         BCC M756
         LDY #$FF
         JSR $C1C3
M756     LDA ($AE,X)
         STA ($7A,X)
         JSR $C088
         CMP #$3A
         BCS M754
         JSR $E3B3
         BPL M754
M755     JSR $79
         BCC M757
         JMP $C150
M757     LDY #$01
         JSR $C1C3
         BEQ M755
         JSR $C0B0
         LDX #$00
         LDA #$03
         STA $15
         LDA ($7A),Y
         INY
         BNE M758
         INC $15
M758     STA $14
         LDA ($7A),Y
         PHA
         LDA $14
         STA ($7A,X)
         BEQ M759
         LDA #$04
         STA $15
M759     JSR $C088
         PLA
         DEC $15
         BNE M758
         LDA $5A
         STA $7A
         LDA $5B
         STA $7B
         LDX #$00
         RTS
;---------------------------------------

