

         *= $8000

;---------------------------------------
; BANK 0
;---------------------------------------

;---------------------------------------
         .BYTE $09,$80
         .BYTE $0C,$80
         .BYTE $C3,$C2,$CD,$38,$30
;---------------------------------------
START    JMP RESET
START1   JMP RESET1   ;FREEZERMENUE
         JMP RESET1   ;FRZMEN
RRTSH    JMP $9F45     ;EXTERNRAMCOPY
RRCOP    JMP $9F47     ;EXTERNRAMCOPY
         JMP CER6    ;FREEZERSTART
         JMP CER3    ; $0800>$9E00
         JMP CER2A   ; $0800>$9E00
         JMP PRINT
         JMP PRINTT   ;+CURSOR POSIT.
         JMP SFARB    ;FARBRAM SETZEN
         JMP MON1      ;MONITOR
         JMP CER4     ;$0200-$0A00
         JMP GETKEY
PMSR     JSR CER3     ;$0800 >$9E00
         JMP CER4     ; $0200-$0A00
         JSR CER4     ; $0200-$0A00
         JMP CER2A   ; $0800>$9E00
         JMP TSTBIT   ; TASTE
         JMP STAR    ;STACKROUT START
         JMP SCRENS   ;BILDWERTE SETZEN
         JMP BILD3    ;INIT SCREEN
         JMP SFARB1   ;FARBRAM SETZEN
PFB1     JMP PFARB    ;FARBRAM HOLEN
         JMP CER1    ; $0800>$8800
         JMP CER2    ; $8800>$0800
         JMP GETFILN  ;FILENUMMER
         JMP GFN1  ;FILENUMMER O. TEXT
         JMP GFN2  ;FILENUMMER O. POS.
;---------------------------------------
; RESET
;---------------------------------------
RESET    LDA #$00
         .BYTE $2C
RESET1   LDA #$01  ;FREEZEREINSPRUNG
         STA $0200
         SEI
         LDX #$FF
         TXS
         CLD
         TAX
         BEQ RES1
         JSR CLRSCR ;BILD+IO LOESCHEN
RES1     JSR $FDA3
         LDX #$00
         LDA $DC01
         AND #$04    ;CTRL
         BEQ RES2
         LDA $DC01
         AND #$20    ;CBM
         BNE RES3
         JMP TOOL     ;TOOLKIT
RES2     JMP FILLRTX  ; FILL
RES3     JSR INITMEM  ;ZP LOESCHEN
         JSR $FF5B
         CLI
         JSR $E453
         JSR $E3BF
         JSR RESMEN   ;EINSCHALTMELDUNG
         LDA #$37
         STA $01
         STA $C0
         LDX $0200
         BNE RES4
         INX
         JSR INITRAM ;EXT.RAM
         JMP RESMENU
;---------------------------------------
RES4     JSR GRRT    ;COPYROUT IN RAM
         JSR FZMEN  ;FREEZERMENU
         JMP RESET1
;---------------------------------------
; SPRUNG IN MONITOR
;---------------------------------------
MONITOR  LDA $DFED
         LDX $0878
         JSR BANK1
         .BYTE $1E,$80 ;MON
;---------------------------------------
MON1     BCS MON2
         SEI
         LDX #$FB
         TXS
         JMP REST
MON2     JMP START1
;---------------------------------------
RESMENU  JSR RESMEN
         JSR PRINT
;
         .BYTE $0D,$0D,$0D,$01,$03
         .TEXT "F1*SPEICHERRESET"
         .BYTE $01,$05
         .TEXT "F3*RESET"
         .BYTE $0D,$0D,$0D,$01,$0E
         .TEXT "F5*UTILITY"
         .BYTE $0D,$0D,$01,$0E
         .TEXT "F7*TOOLKIT"
         .BYTE $00
;---------------------------------------
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
RSM1     CLI
         JSR GETKEY
         LDX #$01
         CMP #$85
         BEQ FILLMEM
         DEX
         CMP #$86
         BEQ FILLMEM
         CMP #$87
         BEQ UTIL
         CMP #$88
         BNE RSM1
TOOL     LDX #$01
         JSR INITRAM   ;EXT.RAM SETZEN
         JSR CLRSCR
         JSR BANK1
         .BYTE $09,$80  ;UTILITY
;---------------------------------------
; SPRUNG IN UTILITY
;---------------------------------------
UTIL     JSR BANK3
         .BYTE $21,$80
;---------------------------------------
INITMEM  LDA #$00
         TAY
INIMEM1  STA $02,Y
         STA $0201,Y
         STA $0300,Y
         INY
         BNE INIMEM1
         LDX #$3C
         LDY #$03
         STX $B2
         STY $B3
         LDA #$A0
         STA $0284
         STA $C2
         LDA #$08
         STA $0282
         LSR A
         STA $0288
         LDY #$1F
INIMEM2  LDA $FD30,Y
         STA $0314,Y
         DEY
         BPL INIMEM2
         RTS
;---------------------------------------
; SPEICHER FUELLEN
;---------------------------------------
FILLMEM  BIT $C5
         BVC FILLMEM
FILLRTX  STX $02
         LDX #$FF
         JSR INITRAM
         LDX $02
         LDY #$7F
FILLMEM2 LDA FILLRT-1,Y
         STA $04FF,Y
         DEY
         BNE FILLMEM2
         JMP $0500
;---------------------------------------
FILLRT   SEI
         INC $01
         TXA
         BEQ FILLRT5
         STY $02
         LDA #$BD
FILLRT1  STX $03
FILLRT2  STA ($02),Y
         INY
         BNE FILLRT2
FILLRT3  INX
         BEQ FILLRT4
         CPX #$05
         BEQ FILLRT3
         BNE FILLRT1
FILLRT4  STY $D07F
FILLRT5  DEC $01
         LDA #$55
         STA $A000
         STX $D016
         JSR $FDA3
         JSR INITMEM
         JSR $FD15
         LDA #$06
         STA $DE00
         JMP $FCFB
;---------------------------------------
;  FREEZROUTINEN
;---------------------------------------
; SUCHT 32 GLEICHE BYTES
;---------------------------------------
FRT1     SEI
         INC $01
         LDA #$01   ;START $01FF($0200)
         STA $FC
         LDY #$FF
         STY $FB
         INY
         STY $FD
         LDA $D000
         PHA
         LDA $CFFF  ;UBERGANG VIC
         EOR #$FF  ;KEINE 32B  MOEGLICH
         STA $D000
         LDA #$3E
FRT1A    STA $FA
FRT1B    SEC         ;ZEIGER ERHOEHEN
         TYA
         ADC $FB
         STA $FB
         BCC FRT1C
         INC $FC
         BEQ FRT1K     ;CMP MIT ENDE
         LDA $FC
         CMP $F8
         BNE FRT1C
         INC $FC
         LDA #$60
         STA $FB
FRT1C    LDY #$1F    ; 32 BYTES
         LDA ($FB),Y
FRT1D    DEY
         BMI FRT1E
         CMP ($FB),Y
         BNE FRT1B
         BEQ FRT1D
FRT1E    LDY $FA
         BEQ FRT1I
FRT1F    CMP ($FB),Y
         BNE FRT1I
         DEY
         CPY #$1F
         BNE FRT1F
         LDY $FA
         CPY #$38
         BEQ FRT1H
         STA $3D
         LDX $FC
         CPX #$D0   ;$D000
         BCC FRT1G
         CPX #$E0   ;$E000
         BCC FRT1I
FRT1G    STX $2C
         LDA $FB
         STA $2B
         LDA #$38
         BNE FRT1A
FRT1H    STA $3E
         LDA $FC
         STA $3C
         LDA $FB
         STA $3B
         LDA #$00
         BEQ FRT1A
FRT1I    LDX $FD
         CPX #$05
         BEQ FRT1J
         STA $0C,X   ;BYTEWERT
         INC $FD
         TXA
         ASL A
         TAX
         LDA $FB
         STA $02,X   ;ZEIGER AUF 32BYTE
         LDA $FC
         STA $03,X
         LDY #$1F
         BNE FRT1B
FRT1J    LDA $FA
         BNE FRT1B
FRT1K    PLA
         STA $D000
         DEC $01
         RTS
;---------------------------------------
;KOPIERT ZEROPAGE IN DIE 32BYTE-LUECKEN
;---------------------------------------
FRT2     STX $DE00
         BIT $80
FRT2A    LDY #$1F    ;32 BYTES
FRT2B    DEC $010B
         LDA $8000
         INC $01
         STA ($0A),Y ;ZP IN LUECKEN COPY
         DEC $01     ;
         DEY
         BPL FRT2B
         DEC $0110
         DEC $0110
         BNE FRT2A
         LDY #$38
FRT2C    LDA $8002,Y   ;ZP COPY
         INC $01
         STA ($3B),Y
         DEC $01
         CPY #$1A
         BCS FRT2D
         LDA $0156,Y   ;RESTARTROUTINE
         STA $11,Y   ; IN ZP
FRT2D    DEY
         BPL FRT2C
         LDA #$00
         STA $DE00
         INC $01
         LDY #$3E
FRT2E    LDA $0170,Y
         CMP #$BB
         BNE FRT2F
         DEC $014A
         LDX $01B6
         LDA $00,X
FRT2F    STA ($2B),Y
         DEY
         BPL FRT2E
         DEC $01
         RTS
;---------------------------------------
; RESTARTROUTINEN
;---------------------------------------
FRT3     LDY #$1F
         STX $18
         STX $20
FRT3A    LDA ($0A),Y
         DEC $1C
         STA $00
         LDA $10
         STA ($0A),Y
         DEY
         BPL FRT3A
         DEC $1E
         DEX
         DEX
         BNE FRT3
         JMP $01E6
;---------------------------------------
FRT4     LDX #$02
FRT4A    LDA $2D,X
         STA $DD0D,X
         LDA $30,X
         STA $DC0D,X
         DEX
         NOP
         NOP
         BPL FRT4A
         LDX #$03
FRT4B    LDA $33,X
         STA $DD04,X
         LDA $37,X
         STA $DC04,X
         DEX
         BPL FRT4B
         DEC $01
         LDX #$38
FRT4C    LDA $BBBB,X
         STA $02,X
         LDA #$BB
         STA $BBBB,X
         DEX
         BPL FRT4C
         INC $01
         LDA #$BB
         LDY #$3E
         LDX #$BB
         JMP $01BB
;---------------------------------------
         .BYTE $3B
         .BYTE $3C,$3E,$3B,$3C
         .BYTE $3D,$E7,$E9
;---------------------------------------
FRT5     SEI
         LDA $2B       ;ZEIGER SETZEN
         STA $0149
         LDA $2C
         STA $014A
         LDA $E4
         STA $0155
         LDA $E5
         STA $0157
         LDA $E8
         AND #$03
         CMP #$03
         BEQ FRT5A
         LDY #$A9
         STY $014E
         STA $014F
         LDA #$85
         STA $0150
         LDA #$00
         STA $0151
FRT5A    LDY #$11
         LDA #$23
         STA $DE00
         LDA #$81
         STA $EA
FRT5B    LDA $0148,Y  ;=FRT5C
         STA ($E9),Y
         DEY
         BPL FRT5B
         LDA #$00
         STA $DE00
         RTS
;---------------------------------------
FRT5C    STA $BBBB,Y  ;RESTART ENDEROUT
         DEY
         BPL FRT5C
         STY $D019
         NOP
         STX $01
         LDX #$BB
         LDY #$BB
         PLA
         RTI         ;SPRUNG IN PRG
;---------------------------------------
; HAUPTFREEZROUTINEN
;---------------------------------------
FREEZR   JSR FRT6
         LDA #$80  ;MARK FUER FREEZ
         SEI
         BNE FZR1
;---------------------------------------
; EINSPRUNG VON RESTARTROUTINE
;---------------------------------------
REST     CLI
REST1    BIT $C5
         BVC REST1
         SEI
         JSR SFARB1
         JSR FRT6
         JSR FRT7
         LDA #$00  ;MARK FUER RESTART
FZR1     STA $08F3
         LDX #$1F
FZR2     LDA $08E0,X
         STA $E0,X
         DEX
         BPL FZR2
         LDA $086C
         STA $ED
         SEC
         SBC #$13
         BCS FZR3
         LDA #$EB
FZR3     STA $E9
         LDY $0872
         CPY #$D0
         BCC FZR4
         CPY #$E0
         BCS FZR4
         LDY #$FD
FZR4     STY $F8
         LDX #$00
         LDA #$40
         STA $2B
         STY $2C
         SEC
         ADC #$3E
         STA $3B
         STY $3C
         SEC
         ADC #$38
FZR5     STA $02,X ;ZEIGER SETZEN FALLS
         STY $03,X ;KEINE 32BYTE GLEICH
         CLC
         ADC #$20
         BCC FZR6
         INY
FZR6     INX
         INX
         CPX #$0E
         BNE FZR5
         LDA #$20
         STA $0C
         STA $0D
         STA $0E
         STA $0F
         STA $10
         STA $3D
         STA $3E
         JSR PMSR  ;EXT.RAM IN ZP
         LDA #<FRT1 ;32BYTE-ROUT
         LDY #>FRT1
         JSR STAR
         LDA #<FRT2 ;32BYTE-RAMCOPY
         LDY #>FRT2
         LDX $DFF2
         JSR STAR
         LDA #<FRT5 ;RESTART IN STACK
         LDY #>FRT5
         JSR STAR
         LDX #$70
FZR7     LDA FZRR1,X
         STA $60,X
         DEX
         BPL FZR7
         LDA $DFF4
         JMP $60
;---------------------------------------
FZRR1    SEI
         STA $DE00
         LDX #$25
FZRR2    LDA $803A,X   ;ZP
         STA $3A,X
         DEX
         BNE FZRR2
FZRR3    LDA $8100,X   ;STACK HERSTELLEN
         STA $0100,X
         DEX
         BNE FZRR3
         LDX $ED
         TXS
         PLA
         PLA
         PLA
         PLA
         LDX #$00
FZRR4    LDA $E0,X   ;RTI EINSPRUNG
         PHA
         INX
         CPX #$04
         BNE FZRR4
         BIT $F3     ;RESTART
         BMI FZRR7
         LDA $DC08    ;ECHTZEITUHR
         ASL $EC
         BMI FZRR5
         STA $DC08
FZRR5    LDA $DD08
         ASL $EC
         BMI FZRR6
         STA $DD08
FZRR6    LDA $E8
         STA $00
         LDA $EB
         STA $DE00
         LDA #$34
         STA $01
         LDX #$0A
         JMP $11   ;START
;---------------------------------------
FZRR7    LDX #$00
FZRR8    LDA $0100,X  ;STACK RETTEN
         STA $8100,X
         INX
         BNE FZRR8
         LDA $FFED
         STA $DE00
         LDX #$FB
         TXS
         JMP FRT     ;PACKROUTINE
;---------------------------------------
; KOPIERROUTINEN FUER GRAPHIC + IO
;---------------------------------------
FRT6     LDX #$00
         LDA $08EB
         AND #$08
         BEQ FRT6A
         INX
FRT6A    JSR INITRAM ;EXT.RAM INIT
         JSR CLRSCR
         JSR FRT8 ;TIMERWERTE SETZEN
         LDX #$0E
FRT6B    LDA $082D,X
         STA $2D,X
         DEX
         BPL FRT6B
         LDA $082E
         STA $0833
         LDA $082F
         STA $0834
         LDX #$31
         LDY #$C4
         JSR FRT6C
         INX
         LDY #$D4
FRT6C    JSR FRT6D
         INX
         INY
         INY
FRT6D    LDA $0800,X
         AND #$41
         LSR A
         BNE FRT6F
         BCC FRT6F
         LDA $0801,Y
         CLC
         ADC #$0A
         BCC FRT6E
         LDA #$FF
FRT6E    STA $0801,Y
FRT6F    RTS
;---------------------------------------
; IO + SID    HERSTELLEN
;---------------------------------------
FRT7     SEI
         LDX #$00
FRT7A    LDA $08C0,X
         STA $DC00,X
         LDA $08D0,X
         STA $DD00,X
         INX
         CPX #$10
         BNE FRT7A
         LDA $08EC
         AND #$80
         ORA #$0F
         STA $D418
         JSR STPI
         LDA $08AA
         STA $D01A
         LDA $08A1
         STA $D011   ;BILD AN
         RTS
;---------------------------------------
; TIMERWERTE SETZEN
;---------------------------------------
FRT8     LDX #$03
FRT8A    LDY $0837,X
         LDA $08C4,X
         STA $0837,X
         TYA
         STA $08C4,X
         LDY $0833,X
         LDA $08D4,X
         STA $0833,X
         TYA
         STA $08D4,X
         CPX #$03
         BCS FRT8C
         LDA $082D,X
         CMP #$FF
         BNE FRT8B
         LDA $08DD,X
         STA $082D,X
FRT8B    LDA $0830,X
         CMP #$FF
         BNE FRT8C
         LDA $08CD,X
         STA $0830,X
FRT8C    DEX
         BPL FRT8A
         LDA #$7F      ;IRQ VERHINDERN
         STA $08CD
         STA $08DD
         LDA #$18      ;TIMER
         STA $08CE
         STA $08CF
         STA $08DE
         STA $08DF
         RTS
;---------------------------------------
CLRSCR   SEI
         LDX #$0E
         LDA #$00
CLSC1    STA $DC01,X
         STA $DD01,X
         STA $D011,X
         DEX
         BPL CLSC1
         RTS
;---------------------------------------
INITRAM  LDY #$3F
INITR1   LDA INITT-1,Y
         STA $03FF,Y
         DEY
         BNE INITR1
         JMP $0400
;---------------------------------------
INITT    LDA #$23    ;EXT RAM EIN
         STA $DE00
INITRR1  LDA $FF00,Y ;RAMCOPYROUT
         STA $9F00,Y
         INY
         CPY #$F7
         BNE INITRR1
         LDY #$07
INITRR2  TXA
         STA $9F00,Y
         BMI INITRR3
         BEQ INITRR4
         LDA $FF00,Y
INITRR3  STA $9FF8,Y    ;RAMZEIGER
INITRR4  DEY
         BPL INITRR2
         JMP $9FB7
;---------------------------------------
         STA $AC
         STY $AD
         LDX #$09
         LDY #$0A
         CLC
         JSR $FFF0
         LDA #$41
         STA $AA
         STY $AE
TSTK1    LDY $AE
         CLC
         JSR $FFF0
         LDY #$00
         LDA ($AC),Y
         BEQ TSTK3
         LDA $AA
         INC $AA
         JSR $FFD2
         JSR PRINT
         .BYTE $2E,$20,$00
;---------------------------------------
TSTK2    LDA ($AC),Y
         PHP
         AND #$7F
         JSR $FFD2
         JSR $FCDB
         PLP
         BPL TSTK2
         INX
         BNE TSTK1
TSTK3    STA $C6
         CLI
TSTK4    JSR $FFE4
         CMP #$41
         BCC TSTK4
         CMP $AA
         BCS TSTK4
         SEC
         SBC #$41
         TAX
         RTS
;---------------------------------------
;   TEXT AUSGEBEN
;---------------------------------------
PRINTT   CLC
         JSR $FFF0   ;CURSOR SETZEN
PRINT    STY $24
         PLA
         STA $22
         PLA
         STA $23
         LDA $D6
         STA $25
         LDY #$00
PRINT1   INY
         LDA ($22),Y
         BEQ PRINT5
         CMP #$01
         BNE PRINT3
         INY
         LDA ($22),Y
         TAX
PRINT2   JSR PRINTSP
         DEX
         BNE PRINT2
         BEQ PRINT1
PRINT3   CMP #$2A
         BNE PRINT4
         JSR PRINTSP
         LDA #$3D
         JSR $FFD2
         LDA #$20
PRINT4   JSR $FFD2
         BCC PRINT1
PRINT5   TYA
         CLC
         ADC $22
         TAY
         LDA $23
         ADC #$00
         PHA
         TYA
         PHA
         LDY $24
         CLC
         RTS
;---------------------------------------
PRINTSP  LDA #$20
         JMP $FFD2
;---------------------------------------
;  RESETMENUE
;---------------------------------------
RESMEN   JSR BILD5
         JSR PRINT
         .BYTE $93,$01,$07
         .TEXT "ACTION CARTRIDGE "
         .TEXT "PLUS V5.0"
         .BYTE $0D,$0D,$01,$07
         .TEXT "(C) DATEL ELECTRONICS"
         .TEXT " 1988"
         .BYTE $0D,$0D
         .BYTE $0D,$00
;---------------------------------------
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         CLC
RESME1   LDX #$25
         LDA #$63
RESME2   STA $04A1,X  ;STRICH ZEICHNEN
         BCC RESME3
         STA $0519,X
         STA $0519,X
RESME3   DEX
         BPL RESME2
         RTS
;---------------------------------------
;  FREEZERMENUE
;---------------------------------------
FZMEN    LDA #<RESET1   ;RESTARTZEIGER
         LDY #>RESET1
         STA $0334
         STY $0335
         JSR PRINT
;---------------------------------------
         .BYTE $01,$05
         .TEXT "F1*BACKUP"
         .BYTE $01,$06
         .TEXT "F7*RESTART"
         .BYTE $0D,$0D,$0D,$01,$09
         .TEXT "D*DIRECTORY"
         .BYTE $01,$1B
         .TEXT "S*BILD SPEICHERN"
         .BYTE $01,$16
         .TEXT "L*TURBO-LINKER"
         .BYTE $01,$40
         .TEXT "M*MONITOR"
         .BYTE $01,$1D
         .TEXT "T*TEXT AENDERN"
         .BYTE $01,$18
         .TEXT "K*KOLLISIONSKILLER"
         .BYTE $01,$14
         .TEXT "V*SPRITE-VIEW"
         .BYTE $01,$19
         .TEXT "P*PARAMETER"
         .BYTE $01,$1B
         .TEXT "E*POKEN"
         .BYTE $01,$47
         .TEXT "B*BILD"
         .BYTE $01,$20
         .TEXT "A*AUSDRUCKEN"
         .BYTE $0D,$0D,$00
;---------------------------------------
         SEC
         JSR RESME1
FZME1    JSR GETKEY
         LDX #$0E
FZME2    CMP CMDFM,X
         BEQ FZME3
         DEX
         BPL FZME2
         BMI FZME1
FZME3    STX $3F
         TXA
         ASL A
         TAX
         LDA JBFM+1,X
         PHA
         LDA JBFM,X
         PHA
         PHP
         JSR CZPR
         RTI
;---------------------------------------
; FREEZECOMMAMDOS
;---------------------------------------
CMDFM    .BYTE $85,$88,$42,$87
         .BYTE $5F,$4D,$45,$44
         .BYTE $54,$50,$41,$56
         .BYTE $53,$4B,$4C
;---------------------------------------
JBFM     .WORD FREEZR
         .WORD REST
         .WORD BILD
         .WORD FREEZR
         .WORD EXIT
         .WORD MONITOR
         .WORD POKE
         .WORD DIRECT
         .WORD TEXT
         .WORD PARAM
         .WORD HRDCOP
         .WORD SPRITE
         .WORD SAVPIC
         .WORD KOLLIS
         .WORD TULINK
;---------------------------------------
EXIT     JMP ($087E)
;---------------------------------------
; DIRECTORY
;---------------------------------------
DIRECT   LDA #$08
         CMP $0877
         BCC DIRECT1
         STA $BA
DIRECT1  JSR BANK2
         .BYTE $18,$81
;---------------------------------------
TSTBIT   JSR PRINT
         .BYTE $0D
         .TEXT "TASTE BITTE"
         .BYTE $00
;---------------------------------------
GETKEY   LDA #$00
         STA $C6
         CLI
GETKEY1  JSR $FFE4
         BEQ GETKEY1
         CMP #$03    ;RUN/STOP
         BNE STPI2
         JMP ($0334)
;---------------------------------------
; BILD ANSCHAUEN
;---------------------------------------
STPI     SEI
         LDX #$2E
STPI1    LDA $0890,X
         STA $D000,X
         DEX
         BPL STPI1
         LDA $DD00
         AND #$FC
         ORA $08D0
         STA $DD00
         LDA $08A1
         ORA #$10
         STA $D011
         LDA #$F0
         STA $D01A
         LDA #$0F
         STA $D019
STPI2    RTS
;---------------------------------------
SCRENS   JSR STPI
         JSR CER3   ;COPY
         JSR CER5   ;COPYRAM
SFARB1   LDX #$D8
SFARB    LDA #<SETFR    ;FARBRAM COPY
         LDY #>SETFR
         BNE STAR
PFARB    LDA #<PUTFR    ;FARBRAMSETZEN
         LDY #>PUTFR
;
;---------------------------------------
; ROUTINE IN STACK AUSFUEHREN
;---------------------------------------
STAR     STA $0100
         LDA $A9
         PHA
         LDA $AA
         PHA
         LDA $0100
         STA $A9
         STY $AA
         SEI
         LDY #$00
STAR1    LDA ($A9),Y
         STA $0100,Y
         INY
         CPY #$D0
         BNE STAR1
         PLA
         STA $AA
         PLA
         STA $A9
         LDY #$00
         JMP $0100
;---------------------------------------
; IO WERTE KOPIEREN
;---------------------------------------
CER1     JSR CER3
         LDA #$88   ;$8800 -> $0800
         LDY #$08
         BNE CER3C
CER2     LDA #$08   ;$0800 -> $8800
         LDY #$88
         JSR CER3C
CER2A    LDA #$9E   ; $9E00
         LDY #$08
         JSR CER3B
         LDX #$0E
CER2B    LDA $08F0,X
         STA $082D,X
         DEX
         BPL CER2B
         RTS
;---------------------------------------
CER3     LDX #$0E
CER3A    LDA $082D,X
         STA $08F0,X
         DEX
         BPL CER3A
         LDA #$08
         LDY #$9E
CER3B    LDX #$01
         .BYTE $2C
CER3C    LDX #$02
         JMP RRCOP
;---------------------------------------
CER4     LDA #$02 ;$0200
         LDY #$82
         LDX #$08
CER4A    JMP RRTSH
;---------------------------------------
CER5     LDA #$04  ;$0400
         LDY #$84
         LDX #$06
         BNE CER4A
;---------------------------------------
BILD     JSR SCRENS
         CLI
BILD1    JSR $FFE4
         BEQ BILD1
         LDX #$00
         CMP #$86
         BEQ BILD2
         INX
         CMP #$87
         BNE BILD3
BILD2    LDA $D020,X   ;BILDFARBEN
         ADC #$00
         STA $D020,X
         JMP BILD1
;---------------------------------------
; MENUBILSCHIRM SETZEN
;---------------------------------------
BILD3    JSR CER5
         JSR CER2A
         LDX #$0E
BILD4    LDA $D020,X
         STA $08B0,X
         DEX
         BPL BILD4
         JSR $FDA3
         JSR $E5A0
BILD5    LDA #$01
         LDX #$06
         LDY #$06
         STA $0286
         STX $D020
         STY $D021
         JMP INIFA
;---------------------------------------
; FREEZMENU
;---------------------------------------
CER6     LDA #$E3
         PHA
         LDA #$7B
         PHA
         PHP
         LDA #$01
         LDX #$02
         LDY #$03
         JMP FREEZX+$6000
;---------------------------------------
SETFR    LDA $DFF2
         STA $DE00
         STX $0118
         INX
         INX
         STX $0120
         LDX #$02
SETFR1   LDA $9700,Y
         PHA
         AND #$0F
         STA $D800,Y
         PLA
         LSR A
         LSR A
         LSR A
         LSR A
         STA $DA00,Y
         INY
         BNE SETFR1
         INC $0118
         INC $0120
         INC $0112
         DEX
         BNE SETFR1
         JMP $9FB7
;---------------------------------------
PUTFR    JSR $9F94
         LDY #$00
         LDX #$02
PUTFR1   LDA $DA00,Y   ;FARBRAM
         ASL A
         ASL A
         ASL A
         ASL A
         STA $0117
         LDA $D800,Y
         AND #$0F
         ORA #$FF
         STA $9700,Y
         INY
         BNE PUTFR1
         INC $0109
         INC $0113
         INC $011A
         DEX
         BNE PUTFR1
         JMP $9FB7
;---------------------------------------
;  PACKROUTINE
;---------------------------------------
FRT      LDX #$00
         STX $91
         DEX
         STX $8F
         DEX
         LDA #<PACKR  ;PACKROUT
         LDY #>PACKR
         JSR STAR
         LDX #$00
         STX $DC    ;$0200 START
         LDA #$02
         STA $DD
PMR1     LDA PRG,X   ;ENTPACKROUT
         STA $0800,X
         LDA $00,X
         STA $0900,X
         DEX
         BNE PMR1
         LDA $DFF5
         STA $08D4
         LDA #$97   ;$9700 ->$0B00
         LDY #$0B
         JSR CER3C
         LDA #$81   ;$8100 ->$0A00
         LDY #$0A
         JSR CER3B
         LDX #$7A
PMR2     LDA EPROUT,X ;ENTPACKR ZP
         STA $0960,X
         DEX
         BPL PMR2
         LDA $90
         STA $0961
         LDA $91
         STA $0962
         LDA #<PCOP
         LDY #>PCOP
         JSR STAR
         LDX #$01
         LDY #$08
         STX $AC
         STY $AD
         LDX $8E
         LDY $8F
         STX $AE
         STY $AF
         JSR BANK3
         .BYTE $24,$80 ;SAVEMENUE
;---------------------------------------
PCOP     INC $01   ;RAMCOPYROUT
         LDA #$50
         STA $8E
         LDA #$0D
         STA $8F
PCP1     LDA ($90),Y
         STA ($8E),Y
         INC $8E
         BNE PCP2
         INC $8F
PCP2     INC $90
         BNE PCP1
         INC $91
         BNE PCP1
         LDA $8E
         SEC
         SBC #$51
         STA $081A
         EOR #$FF
         STA $081F
         LDA $8F
         SBC #$00
         STA $081D
         DEC $01
         JSR $9F94
         LDX #$4F
PCP3     LDA $9E90,X
         STA $0D00,X
         DEX
         BPL PCP3
         LDA $9EEC
         ASL A
         ROR $0881
         LDA $9E6C
         STA $0834
         LDA #$35
         STA $0901
         LDA $9EE8
         ORA #$03
         STA $0900
         LDA $9EEE
         TAX
         LDA $9EEF
         TAY
         ORA $9EEE
         BEQ PCP6
         STX $09C5
         STY $09C6
         INX
         BNE PCP4
         INY
PCP4     STX $09CA
         STY $09CB
         LDX #$08
         LDA #$EA
PCP5     STA $08D5,X
         DEX
         BPL PCP5
PCP6     LDA $9EEC  ;ECHTZEIT VORHANDEN
         LDX #$8D
         ASL A
         BMI PCP7
         STX $09B2
PCP7     ASL A
         BMI PCP8
         STX $09B8
PCP8     JMP $9FB7
;---------------------------------------
; ENTPACKEN
;---------------------------------------
EPROUT   LDA $FFFF
         INC $61
         BNE EPR1
         INC $62
EPR1     RTS
EPR2     JSR $60
         TAX
         JSR $60
EPR3     STA ($DC),Y
         INY
         BEQ EPR9
         DEX
         BNE EPR3
         BEQ EPR5
EPR4     JSR $60
         STA $84
EPR5     JSR $60
         CMP #$FF
         BEQ EPR2
         STA ($DC),Y
         INY
         BNE EPR5
         BEQ EPR9
EPR6     ASL $DF
         BCC EPR7
         ROL $DF
         DEC $97
EPR7     LSR $FF
         BCC EPR4
EPR8     JSR $60
         STA ($DC),Y
         INY
         BNE EPR8
EPR9     INC $DD
         BNE EPR6
         INC $01
EPR10    LDA $D012
         CMP #$80
         BNE EPR10
         LDA $DC08 ;ECHTZEITUHR
         LDA $DC08
         LDA $DD08
         LDA $DD08
         NOP
         NOP
         NOP
         NOP
         NOP
         DEC $01
         LDA #$FF
         .BYTE $8D,$60,$00
         LDA #$FF
         .BYTE $8D,$60,$00
         LDX #$0A
         JMP $11
;---------------------------------------
; SPEICHER PACKEN
;---------------------------------------
PACKR    SEI
         STX $92
         LDA #$7B
         STA $D011
         INC $01
         LDA #$80
         STA $DF
         ASL A
         TAY
         STY $8E
         STY $90
         LDA #$00
PCKR1    CLC
         ADC #$01
         BEQ PCKR9
         DEC $01
         INC $D020
         INC $01
         LDY #$00
PCKR2    CMP ($8E),Y
         BEQ PCKR1
         INY
         BNE PCKR2
         STA $94
         STY $93
         DEY
PCKR3    JSR $0196
PCKR4    INX
         DEY
         CPY #$FF
         BEQ PCKR5
         CMP ($8E),Y
         BEQ PCKR4
PCKR5    CPX #$00
         BEQ PCKR7
         CPX #$04
         BCS PCKR7
         STX $95
PCKR6    DEC $95
         BEQ PCKR8
         JSR $0198
         CLC
         BCC PCKR6
PCKR7    ROR $93
         TXA
         JSR $0198
         LDA $94
         JSR $0198
PCKR8    CPY #$FF
         BNE PCKR3
         LDA $93
         BEQ PCKR11
         LDA $94
         JSR $0198
         CLC
         BCC PCKR12
PCKR9    LDY #$FF
PCKR10   JSR $0196
         DEY
         CPY #$FF
         BNE PCKR10
PCKR11   SEC
PCKR12   ROL $E0
         LSR $DF
         BCC PCKR13
         ROR $DF
         INC $0178
PCKR13   DEC $8F
         DEC $92
         BEQ PCKR14
         JMP $0114
PCKR14   DEC $01
         LDA #$50
         CMP $90
         LDA #$0D
         SBC $91
         RTS
;---------------------------------------
         LDA ($8E),Y
         LDX #$00
         CPX $90
         BNE PCKR15
         DEC $91
PCKR15   DEC $90
         STA ($90,X)
         RTS
;---------------------------------------
; FREEZER NMI EINSPRUNG
;---------------------------------------
FREEZ    SEI
         PHA
         LDA #$7F
         STA $DD0D
         BNE FZ1
FREEZX   SEI
         PHA
FZ1      LDA $DD0E
         PHA
         LDA $DD0F
         PHA
         LDA #$7C
         STA $DD0D
         LDA #$00    ;TIMERSTOP
         STA $DD0E
         STA $DD0F
         LDA $DC0E
         PHA
         LDA $DC0F
         PHA
         LDA #$00    ;TIMERSTOP
         STA $DC0E
         STA $DC0F
         LDA $DD0D
         CLD
         TXA
         PHA
         TYA
         PHA
         LDA $00
         PHA
         LDA #$2F
         STA $00
         LDA $01
         ORA #$00
         PHA
         LDA #$37
         STA $01
         LDA $5F
         PHA
         LDA #$00
         STA $5F
         LDA $DC08    ;ECHTZEITUHR
         PHA
         LDA $DD08
         LDX #$60
         LDY #$00
FZ2      DEY
         BNE FZ2
         DEX
         BNE FZ2
         CMP $DD08
         BEQ FZ3
         CLC
FZ3      ROR $5F
         PLA
         CMP $DC08
         BEQ FZ4
         CLC
FZ4      ROR $5F
         LDA $DC0B
         LDA $DD0B
         LDX $D41B  ;SID
FZ5      INY
         CPX $D41B
         SEC
         BNE FZ6
         TYA
         BNE FZ5
         CLC
FZ6      ROR $5F
         LDX $5F
         PLA
         STA $5F
         TXA
         PHA
         LDX #$00
         STX $D418
FZ7      DEY
         BNE FZ7
         DEX
         BNE FZ7
         LDA #>FZ7A+$6000
         PHA
         LDA #<FZ7A
         PHA
         LDA $FFF6
         JMP SHRT+$6000
;---------------------------------------
FZ7A     NOP
         LDA #>FZ7B+$6000
         PHA
         LDA #<FZ7B
         PHA
         LDA $FFF4
         JMP SHRT+$6000
;---------------------------------------
FZ7B     NOP
         LDX #$07
FZ8      LDA $9F00,X  ;RAM UEBERPRUEFEN
         CMP $FF00,X
         BNE FZ9
         DEX
         BPL FZ8
         LDA #>START1
         PHA
         LDA #<START1-1
         PHA
         LDA $FFED
         JMP SHRT+$6000
;---------------------------------------
FZ9      LDX #$00
FZ10     LDA $00,X
         STA $8000,X    ;ZP COPY
         LDA $0100,X
         STA $8100,X
         CPX #$F7
         BCS FZ11
         LDA $FF00,X
         STA $9F00,X
FZ11     CPX #$02
         BCC FZ12
         LDA #$00
         STA $00,X
FZ12     INX
         BNE FZ10
         PLA
         STA $EC
         PLA
         STA $E7
         PLA
         STA $E8
         PLA
         STA $E5
         PLA
         STA $E4
         PLA
         STA $CF
         PLA
         STA $CE
         PLA
         STA $DF
         PLA
         STA $DE
         TSX
         STX $6C
         PLA
         STA $E3
         PLA
         STA $E2
         PLA
         STA $E1
         PLA
         STA $E0
         TSX
         STX $E6
         LDX #$FB
         TXS
         LDY $FFF5
         LDX #$07
FZ13     LDA $9FF8,X
         CMP $FF00,X
         BNE FZ14
         DEX
         BPL FZ13
         LDY $9FF7
         BNE FZ14
         LDY #$0A
         NOP
FZ14     LDA $0331
         ORA $0333
         CMP #$DF
         BNE FZ15
         BIT $0A
FZ15     STY $EB
         LDA #>FZ16
         PHA
         LDA #<FZ16
         PHA
         LDA #$02  ;$0200 -> $8200
         LDY #$82
         LDX #$08
         JMP $9F47
;---------------------------------------
FZ16     NOP
         LDX #<FZRNMI
         LDY #>FZRNMI
         STX $0318
         STY $0319
         LDX #$2F
FZ17     LDA $CFFF,X  ;VICDATEN
         STA $8F,X
         DEX
         BNE FZ17
         LDA $AA
         STA $8C
         STX $D01A
         STX $A1
         STX $A2
FZ18     LDY #$00
         LDA $D019
         STA $D019
FZ19     LDA $D019
         LSR A
         BCS FZ20
         DEX
         BNE FZ19
         DEY
         BNE FZ19
         LDA $D011
         AND #$7F
         STA $D011
         SEC
         ROR $A1
         BNE FZ18
FZ20     LDX $D012   ;RASTER IRQ TESTEN
         LDA $D011
         ORA $A1
         STA $A1
         STX $A2
         LDX #$0C
FZ21     LDA $DC00,X
         STA $C0,X
         LDA $DD00,X
         STA $D0,X
         DEX
         BPL FZ21
         LDA $DC0B
         LDA $DD0B
         STX $DC03
         LDA $DC01
         STA $C1
         STX $DD03
         LDA $DD01
         STA $D1
         JSR FZR10
;---------------------------------------
; TIMERWERTE HOLEN
;---------------------------------------
         SEI
         LDA #$10
         STA $DC0E
         STA $DC0F
         STA $DD0E
         STA $DD0F
         LDX #$03
FZ22     LDA $C4,X
         STA $37,X
         LDA $DC04,X
         STA $C4,X
         LDA $D4,X
         STA $33,X
         LDA $DD04,X
         STA $D4,X
         DEX
         BPL FZ22
         LDX #$02
         LDY #$01
FZ23     LDA #$80
         STA $DC04,X
         LDA #$00
         STA $DC05,X
         LDA $DC0D
         LDA #$19
         STA $DC0E,Y
FZ24     LDA $DC0D
         BPL FZ25
         AND #$83
         ORA $CD
         STA $CD
FZ25     DEC $FF
         BNE FZ24
         LDA #$08
         STA $DC0E,Y
         DEX
         DEX
         DEY
         BPL FZ23
         LDX #$02
         LDY #$01
FZ26     LDA #$80
         STA $DD04,X
         LDA #$00
         STA $DD05,X
         LDA $DD0D
         LDA #$19
         STA $DD0E,Y
FZ27     DEC $FF
         NOP
         BNE FZ27
         LDA #$08
         STA $DD0E,Y
         DEX
         DEX
         DEY
         BPL FZ26
         LDX #$7F
         STX $DD0D
         STX $DC0D
         LDA $CD
         BMI FZ28
         STX $CD
FZ28     LDA $DD
         BMI FZ29
         STX $DD
FZ29     LDA $8002
         STA $7E
         LDA $8003
         STA $7F
         LDA #$0A
         STA $78
         JSR FZR20
         LDX #$06
FZ30     DEC $2C,X
         DEX
         BNE FZ30
         TXA
         INX
         LDY #$08
         JSR RRCOP ;$0000 > $0800
         JSR PFB1  ;FARBRAM
         JSR CER3  ;$0800 > $9E00
         JMP ($8002)
;---------------------------------------
FZR20    LDY #$08
         LDX #$9F
         JMP $9FAE
;---------------------------------------
; GRAPHICZEIGER SETZEN
;---------------------------------------
FZR10    LDA $D0    ;$DD00
         AND #$03
         STA $70
         TAX
         LDA FZT1,X
         STA $71
         LDA $A8   ;$D018
         TAY
         AND #$0E
         ASL A
         ASL A
         ORA $71
         STA $74
         TYA
         AND #$F0
         LSR A
         LSR A
         ORA $71
         STA $72
         TYA
         AND #$08
         ASL A
         ASL A
         ORA $71
         STA $73
         LDA $A6    ;$D016
         AND #$10
         PHP
         LDX #$00
         LDA $A1    ;$D011
         TAY
         AND #$20
         BEQ FZR1A
         LDX #$02
FZR1A    PLP
         BEQ FZR1B
         INX
FZR1B    STX $75
         TYA
         AND #$40
         STA $76
         RTS
;---------------------------------------
FZRNMI   PHA
         LDA $DD0D
         BPL FZRNMI1
         AND #$83
         ORA $DD
         STA $DD
FZRNMI1  PLA
         RTI
;---------------------------------------
FZT1     .BYTE $C0,$80,$40
;---------------------------------------
         LDA #$FC
         PHA
         LDA #$E1
         PHA
         LDA #$02
         JMP $DFCF
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
;---------------------------------------
;  BANKUMSCHALTROUTINE
;---------------------------------------
BANK0    NOP
BANK1    NOP
BANK2    NOP
BANK3    NOP
         NOP
         NOP
         CLD
         STA $A5
         STX $A6
         STY $A7
         PHP
         JMP BANKR
;---------------------------------------
SHRT     LDX #$00
         STA $DE00
NIX      DEX
         BNE NIX
         TAX
         RTS
;---------------------------------------
BANKR    PLA
         STA $A8
         PLA
         STA $A9
         CLC
         ADC #$02
         TAX
         PLA
         STA $AA
         ADC #$00
         PHA
         TXA
         PHA
         LDA $A9
         BNE BANKRT
         DEC $AA
BANKRT   DEC $A9
         LDY #$00
         LDA ($A9),Y
         SEC
         SBC #<BANK0
         TAX
         LDA $DFED
         PHA
         LDA #$DF  ;RUECKSPRUNG
         PHA
         LDA #$E2
         PHA
         LDY #$03
         LDA ($A9),Y
         PHA
         DEY
         LDA ($A9),Y
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
; RESTARTROUTINE FREEZERPRG(BASICSTART)
;---------------------------------------
PRG      .BYTE $00
         .BYTE $0B,$08,$0A,$00
         .BYTE $9E,$32,$30,$36
         .BYTE $31,$00,$00,$00
         .BYTE $78,$A9,$7F,$8D
         .BYTE $0D,$DD,$A9,$34
         .BYTE $85,$01,$A2,$0C
         .BYTE $A0,$AA,$B9,$50
         .BYTE $AA,$99,$AA,$FF
         .BYTE $88,$C0,$FF,$D0
         .BYTE $F5,$CE,$20,$08
         .BYTE $CE,$1D,$08,$EC
         .BYTE $1D,$08,$D0,$EA
         .BYTE $E6,$01,$A2,$E0
         .BYTE $9A,$C8,$B9,$00
         .BYTE $0A,$99,$00,$01
         .BYTE $B9,$00,$0B,$99
         .BYTE $00,$D8,$4A,$4A
         .BYTE $4A,$4A,$99,$00
         .BYTE $DA,$C8,$D0,$EA
         .BYTE $EE,$3F,$08,$EE
         .BYTE $42,$08,$EE,$49
         .BYTE $08,$CE,$39,$08
         .BYTE $CE,$3C,$08,$10
         .BYTE $D9,$A2,$0E,$A9
         .BYTE $80,$9D,$02,$D4
         .BYTE $9D,$03,$D4,$A9
         .BYTE $21,$9D,$04,$D4
         .BYTE $A9,$08,$9D,$05
         .BYTE $D4,$A9,$80,$9D
         .BYTE $06,$D4,$8A,$38
         .BYTE $E9,$07,$AA,$10
         .BYTE $E2,$A0,$0F,$A9
         .BYTE $00,$0A,$90,$17
         .BYTE $A2,$FF,$8E,$0E
         .BYTE $D4,$8E,$0F,$D4
         .BYTE $8D,$13,$D4,$A2
         .BYTE $F0,$8E,$14,$D4
         .BYTE $A2,$81,$8E,$12
         .BYTE $D4,$A0,$8F,$8C
         .BYTE $18,$D4,$A0,$02
         .BYTE $A9,$FF,$99,$01
         .BYTE $DC,$99,$01,$DD
         .BYTE $88,$D0,$F7,$C0
         .BYTE $10,$B0,$0C,$B9
         .BYTE $30,$0D,$99,$00
         .BYTE $DC,$B9,$40,$0D
         .BYTE $99,$00,$DD,$B9
         .BYTE $00,$0D,$99,$00
         .BYTE $D0,$C8,$C0,$2F
         .BYTE $D0,$E5,$AD,$30
         .BYTE $03,$85,$C3,$AD
         .BYTE $31,$03,$85,$C8
         .BYTE $A9,$20,$A2,$06
         .BYTE $8D,$00,$DE,$8D
         .BYTE $FE,$DF,$8E,$00
         .BYTE $DE,$AD,$0D,$DC
         .BYTE $AD,$0D,$DD,$C6
         .BYTE $01,$A0,$00,$4C
         .BYTE $8E,$00
;---------------------------------------
;---------------------------------------
CPOS     JSR CPOS1 ;CURSOR SETZEN
         JMP PRINT
;---------------------------------------
TULINK   JSR LWU1  ;DEVICE
         JSR BANK1
         .BYTE $24,$80  ;TURBOLINK
;---------------------------------------
         JSR PRINT
         .BYTE $0D,$4F,$4B,$0D;OK
         .BYTE $00
         JMP PARA8
;---------------------------------------
; SPRITE KOLLISION
;---------------------------------------
KOLLIS   JSR PRINT
         .TEXT "KOLLISIONSART: "
         .TEXT "A*SPRITES"
         .BYTE $01,$1D
         .TEXT "B*SPRITE-HINTERGRUND"
         .BYTE $01,$12
         .TEXT "C*BEIDES"
         .BYTE $00
;---------------------------------------
         NOP
         NOP
         LDX #$43
         JSR WTKEY2
         LDY #$1E
         STY $A0
         STY $A1
         LDX #$04
         DEC $FB
         BEQ KOLI1
         INC $A0
         INC $A1
         LDX #$02
         DEC $FB
         BEQ KOLI1
         DEC $A1
         LDX #$06
KOLI1    TXA
         EOR #$FF
         AND $088C
         STA $088C
         STA $088A
         LDX #$06
KOLI2    LDA KOLTB-1,X
         STA $3F,X
         DEX
         BNE KOLI2
         STX $8D
         STX $8E
         LDA #$04
         STA $8F
         JSR SCRENS
         LDA #<KOLSR
         LDY #>KOLSR
         JSR STAR
         JSR BILD3   ;RESET BILD
KOLI3    JSR PANZAL  ;ANZAHL AUSGEBEN
         JMP TSTBIT  ;TASTE
;---------------------------------------
KOLSR    INC $01
KOLSR1   LDY #$01
KOLSR2   INC $8E
         BNE KOLSR3
         INC $8F
         BEQ KOLSR7
KOLSR3   LDA ($8E),Y
         CMP $A0
         BEQ KOLSR4
         CMP $A1
         BNE KOLSR2
KOLSR4   INY
         LDA ($8E),Y
         CMP #$D0
         BNE KOLSR1
         LDY #$00
         LDA ($8E),Y
         LDX #$02
KOLSR5   CMP $40,X
         BEQ KOLSR6
         DEX
         BPL KOLSR5
         BMI KOLSR1
KOLSR6   INC $8D
         LDA $43,X
         STA ($8E),Y
         INY
         LDA #$00
         STA ($8E),Y
         INY
         LDA #$EA
         STA ($8E),Y
         BNE KOLSR1
KOLSR7   DEC $01
         RTS
;---------------------------------------
KOLTB    .BYTE $AD,$AE,$AC
         .BYTE $A9,$A2,$A0
;---------------------------------------
PANZAL   JSR PRINT
         .BYTE $0D
         .TEXT "ANZAHL:"
         .BYTE $00
;---------------------------------------
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         LDX $8D
         LDA #$00
         JMP $BDCD
;---------------------------------------
;  PARAMETER
;---------------------------------------
PARAM    JSR PRINT
         .TEXT "PARAMETER CODE : "
         .BYTE $00
         JSR GFN1    ; GET FILENAME
         BEQ SPRUNG3
         JSR CHKPC
         LDY #$03
PARA1    LDA ($BB),Y  ;FILENAME
         CMP PARFIL,Y
         BNE PARA2
         DEY
         BPL PARA1
         JSR PARA10
         JMP PARA7
;---------------------------------------
PARFIL   .TEXT "NOVA"
;---------------------------------------
PARA2    LDA #$08
         STA $BA
         JSR FOPEN
         BCC PARA4
         CMP #$05
         BEQ PARA3
PARA3    JMP SPI2
;---------------------------------------
PARA4    LDA $AE
         CMP #$BB
         BNE PARA5
         CMP $AF
         BEQ PARA9
PARA5    CLV
PARA6    PHP
         JSR $FFAB
         JSR $F642
         PLP
         BVS PARA7
         JSR PRINT
         .BYTE $0D
         .TEXT "FILETYP FALSCH"
         .BYTE $00
         JMP PARA8
;---------------------------------------
PARA7    CLI
         JSR PRINT
         .BYTE $0D,$4F,$4B,$00 ;OK
PARA8    JSR TSTBIT   ;TASTE
SPRUNG3  JMP ($0334)
;---------------------------------------
PARA9    LDX #$FB
         TXS
         BIT $90
         BVS PARA6
         JSR $FFA5
         TAY
         JSR $FFA5
         STA $BB
         STY $8D
         TYA
         ASL A
         TAY
         LDA PARTB+1,Y
         PHA
         LDA PARTB,Y
         PHA
         LDY #$00
         RTS
;---------------------------------------
PRU1     JSR PRU3
         STA $8E
PRU2     JSR PRU3
         STA $8F
PRU3     LDA $BB
         PHA
         JSR $FFA5
         STA $BB
PRU4     BIT $90
         BVS PARA9
         PLA
         CMP #$BB
         BNE PRU5
         CMP $BB
         BEQ PARA9
PRU5     CLC
         RTS
;---------------------------------------
PRR1     LDA #$40
         STA $90
         BNE PRU4
;---------------------------------------
PARTB    .WORD PRR1-1
         .WORD PRR2-1
         .WORD PRR3-1
         .WORD PRR4-1
         .WORD PRR5-1
         .WORD PRR6-1
         .WORD PRR6-1
         .WORD PRR7-1
;---------------------------------------
PRR2     JSR PRU1
         JSR RCR
         JMP PRR2
;---------------------------------------
PRR3     JSR PRU1
         BCC PRR3B
PRR3A    JSR PRU3
PRR3B    JSR RCR
         INC $8E
         BNE PRR3A
         INC $8F
         BNE PRR3A
PRR4     JSR PRU2
         STA $08E0
         LDA $8F
         STA $08E1
         JMP PRR4
;---------------------------------------
PRR5     JSR PRU2
         STA $08EF
         LDA $8F
         STA $08EE
         JMP PRR5
;---------------------------------------
PRR6     JSR PRU1
         STA ($8E),Y
         LDA $8E
         STA $7A
         LDA $8F
         STA $7B
PRR6A    JSR $FFA5
         INC $8E
         BNE PRR6B
         INC $8F
PRR6B    STA ($8E),Y
         BIT $90
         BVC PRR6A
         JSR $FFAB
         JSR $F642
         LDA $8D
         CMP #$06
         BEQ PRR6C
         JMP ($8E)
PRR6C    JMP ($7A)
;---------------------------------------
PRR7     JSR PRU3
         JSR $FFD2
         JMP PRR7
;---------------------------------------
CHKPC    LDY #$01
         LDA ($BB),Y
         CMP #$2E
         BNE CKPC1
         DEY
         LDA ($BB),Y
         LDX #$08
         CMP #$45     ;E
         BEQ CKPC2
         DEX
         CMP #$54     ;T
         BEQ CKPC2
CKPC1    RTS
CKPC2    STX $BA
         PLA
         PLA
         JSR PRRT
         JSR BANK1
         .BYTE $1B,$80 ;VECTOREN SETZEN
;---------------------------------------
         LDA #$00
         STA $B9
         TAX
         LDY #$0A
         JSR BANK1
         .BYTE $D5,$FF  ;LOAD
;---------------------------------------
         BCS CKPC3
         JSR $0A00
         JMP ($0334)
CKPC3    JMP SPI2
;---------------------------------------
PARA10   LDY #$02
PARA11   LDA $1FD3,Y
         CMP PARFIL1,Y
         BNE PARA13
         DEY
         BPL PARA11
         LDA #$35
         STA $1FD3
         LDA #$39
         STA $1FD4
         STA $1FD5
         LDA #$38
         STA $1E8E
PARA12   CLC
         RTS
;---------------------------------------
PARFIL1  .BYTE $32,$35,$30
;---------------------------------------
PARA13   LDA #$FF
         STA $AB
PARA14   INC $AB
         LDA $AB
         ASL A
         ASL A
         TAX
         LDA PATB1,X
         STA $8E
         LDA PATB1+1,X
         STA $8F
         BEQ PARA12
         LDY #$02
         SEI
PARA15   JSR $02B3
         CMP PARTX,Y
         BNE PARA14
         DEY
         BPL PARA15
         LDA PATB1+2,X
         STA $8E
         LDA PATB1+3,X
         STA $8F
         LDY #$48
PARA16   LDA PARR4,Y
         CMP #$BB
         BNE PARA17
         TYA
         CLC
         ADC $8E
         STA $08EE
         LDA $8F
         ADC #$00
         STA $08EF
         LDA #$A5
PARA17   JSR $02A7
         DEY
         BPL PARA16
         BMI PARA14
;---------------------------------------
PARTX    .BYTE $A9,$F4
         .BYTE $8D
;---------------------------------------
PARR4    JSR $FFAE
PARR5    LDA #$01
         STA $B9
         LDA #$08
         STA $BA
         LDA #$00
         STA $9D
         JSR $F4BB
         BCS PARR6
         LDA #$00
         STA $90
         LDA #$01
         STA $BA
         CLI
         CLC
         RTS
PARR6    LDX $DC02
         LDY $DC03
         LDA #$FF
         STA $DC02
         LDA #$00
         STA $DC03
         LDA #$7F
         STA $DC00
PARR7    LDA $DC01
         CMP #$EF   ;SPACE
         BNE PARR7
         STX $DC02
         STY $DC03
         BEQ PARR5
;---------------------------------------
PATB1    .BYTE $E4,$AF,$00,$AF
         .BYTE $0E,$D0,$09,$D0
         .BYTE $2B,$CF,$D9,$CE
         .BYTE $4A,$03,$45,$03
         .BYTE $E4,$03,$B0,$02
         .BYTE $00,$00
;---------------------------------------
;  BILDSAVE
;---------------------------------------
SAVPIC   LDA $0875
         CMP #$03
         BEQ SAVPIC1
         JSR PRINT
         .TEXT "GRAFIKMODUS FALSCH"
         .BYTE $00
         JMP PARA8
;---------------------------------------
SAVPIC1  JSR PRINT
;
         .BYTE $0D
         .TEXT " FORMAT:"
         .BYTE $01,$49
         .TEXT "A*BLAZING PADDLES"
         .BYTE $01,$15
         .TEXT "B*KOALA"
         .BYTE $01,$1F
         .TEXT "C*ADVANCED ART STUDIO"
         .BYTE $01,$11
         .TEXT "D*ARTIST 64"
         .BYTE $01,$1B
         .TEXT "E*VIDCOM 64"
         .BYTE $01,$1B
         .TEXT "F*IMAGE SYSTEM"
         .BYTE $00
;---------------------------------------
         NOP
         NOP
         NOP
         NOP
         NOP
         LDX #$46
         JSR WTKEY2
         STA $3E
         ASL A
         TAX
         LDA PICP,X
         STA $A9
         LDA PICP+1,X
         STA $AA
         LDY #$1C
SPI1     LDA ($A9),Y   ;GRAPHICTABELLE
         STA $0840,Y
         DEY
         BPL SPI1
         JSR LWCHK
         LDA $BA
         CMP #$08
         ROR $BD
         JSR PIR1
         LDX $084F
         LDY $0850
         JSR FSAVE
         BCS SPI2
         JSR $F68F     ;SAVING
         LDA #$0B
         STA $D011
         JSR SFARB1    ;FARBRAM
         JSR PIR3
         JSR PIR2
SPI2     JSR FSAVE4
         JMP PARA8
;---------------------------------------
PIR2     LDA #$40
         CMP $0871
         BCC PIR2A
         LSR A
PIR2A    STA $C2
         STA $AF
         LDX #$00
         STX $C1
         STX $AE
PIR2B    TXA
         ASL A
         TAY
         LDA #$00
         STA $8E
         LDA $0840,X
         JSR PIU1
         STA $8F
         LDA $0845,Y
         STA $8C
         LDA $0846,Y
         STA $8D
         JSR PIR5
         INX
         CPX #$03
         BNE PIR2B
         JSR INIFA
         BIT $BD
         BPL PIR2C
         JMP $F63F
;---------------------------------------
PIR2C    LDA $3E
         BEQ PIR2D
         LDX $084F
         LDY $0850
         STX $C3
         STY $C4
         JSR BANK1
         .BYTE $21,$80  ;SAVE TAPE
;---------------------------------------
         JMP START
;---------------------------------------
PIR2D    LDA $C2
         CLC
         ADC #$20
         LDX #$00
         JSR PIR4
         LDA $3F
         STA $C2
         CLC
         ADC #$08
         LDX #$FF
         JSR PIR4
         JMP START
;---------------------------------------
PIR4     STA $AF
         STA $3F
         LDA #$00
         STA $AE
         STA $C1
         JSR $FB8E
         TXA
PIR4A    SEI
         JSR BANK3
         .BYTE $2A,$80 ;SAVE TURBOTAPE
;---------------------------------------
         RTS
;---------------------------------------
PIR5     LDY #$00
         JSR $02B3
         JSR PIR6
         INC $8E
         BNE PIR5A
         INC $8F
PIR5A    CPY $8C
         BNE PIR5B
         DEC $8D
         INC $D020
PIR5B    DEC $8C
         LDA $8D
         ORA $8C
         BNE PIR5
         RTS
;---------------------------------------
PIR6     BIT $BD
         BPL PIR6A
         JMP $FFA8
PIR6A    STA ($AE),Y
         INC $AE
         BNE PIR6B
         INC $AF
PIR6B    RTS
;---------------------------------------
PIR3     LDX #$00
         STX $8E
         INX
PIR3A    TXA
         ASL A
         TAY
         LDA $0843,X
         JSR PIU1
         CLC
         ADC $084C,Y
         BCS PIR3B
         STA $8F
         LDA $084B,Y
         TAY
         LDA $08B0,X
         JSR $02A7
PIR3B    DEX
         BPL PIR3A
         RTS
;---------------------------------------
PIU1     CMP #$02
         BNE PIU2
         LDA #$37
         STA $02D3
         LDA #$D8
         RTS
PIU2     STX $02
         TAX
         LDA #$34
         STA $02D3
         LDA $0872,X
         LDX $02
         RTS
;---------------------------------------
; FILENAME FUER BILD SETZEN
;---------------------------------------
PIR1     JSR GETFILN
         BIT $BD
         BMI PIR1A
         LDX $3F
         BEQ PIR1H
PIR1A    LDX $0852
         BEQ PIR1D
PIR1B    LDA $B7
         CMP #$10
         BCS PIR1C
         INC $B7
PIR1C    DEC $BB
         LDY #$00
         LDA $0852,X
         STA ($BB),Y
         DEX
         BNE PIR1B
PIR1D    LDY $B7
PIR1E    CPY $0851
         BCS PIR1F
         LDA #$20
         STA ($BB),Y
         INY
         STY $B7
         BNE PIR1E
PIR1F    LDX $0858
         BEQ PIR1H
PIR1G    DEY
         LDA $0858,X
         STA ($BB),Y
         DEX
         BNE PIR1G
PIR1H    RTS
;---------------------------------------
PICP     .WORD PICT1
         .WORD PICT2
         .WORD PICT3
         .WORD PICT4
         .WORD PICT5
         .WORD PICT6
;---------------------------------------
PICT1    .BYTE $01
         .BYTE $00,$02,$01,$01
         .BYTE $00,$20,$00,$04
         .BYTE $00,$04,$7F,$1F
         .BYTE $80,$1F,$00,$A0
         .BYTE $00,$03,$50,$49
         .BYTE $2E,$20,$20,$00
PICT2    .BYTE $01,$00,$02,$02
         .BYTE $02,$40,$1F,$E8
         .BYTE $03,$E9,$03,$FF
         .BYTE $FF,$E8,$03,$00
         .BYTE $60,$0F,$05,$81
         .BYTE $50,$49,$43,$20
         .BYTE $00
PICT3    .BYTE $01,$00,$02
         .BYTE $00,$00,$40,$1F
         .BYTE $F8,$03,$E8,$03
         .BYTE $E8,$03,$E9,$03
         .BYTE $00,$20,$10,$00
         .BYTE $20,$20,$20,$20
         .BYTE $20,$04,$4D,$50
         .BYTE $49,$43
PICT4    .BYTE $01,$00
         .BYTE $02,$02,$02,$00
         .BYTE $20,$00,$04,$00
         .BYTE $04,$FE,$03,$FF
         .BYTE $03,$00,$40,$00
         .BYTE $02,$50,$2D,$20
         .BYTE $20,$20,$00
PICT5    .BYTE $02
         .BYTE $00,$01,$01,$01
         .BYTE $00,$04,$00,$04
         .BYTE $40,$1F,$FF,$FF
         .BYTE $FF,$FF,$00,$58
         .BYTE $00,$02,$42,$2E
         .BYTE $20,$20,$20,$00
PICT6    .BYTE $02,$01,$00,$00
         .BYTE $00,$00,$04,$00
         .BYTE $20,$E8,$03,$FF
         .BYTE $FF,$FF,$FF,$00
         .BYTE $3C,$00,$03,$4D
         .BYTE $53,$2E,$20,$20
         .BYTE $00
;---------------------------------------
;  HARDCOPY
;---------------------------------------
HRDCOP   LDA #<HRDCOP1
         LDY #>HRDCOP1
         JSR SERVE
         BNE HRDCOP2
HRDCOP1  JSR PERROR
         LDX #$FB
         TXS
HRDCOP2  JSR PRINT
         .BYTE $0D
         .TEXT "DRUCKERTYP: "
         .BYTE $00
         LDA #$30
         STA $0277
         LDA #$9D
         STA $0278
         LDA #$02
         STA $C6
         LDX #$0C
         LDY #$0E
         JSR GFN2  ;GET NUMMER
         JSR $79
         BEQ SPRUNG
         JSR $B79E
         TXA
         PHA
         JSR SCRENS
         PLA
         JSR BANK3
         .BYTE $1B,$80 ;HARDCOPY
;---------------------------------------
         JSR BILD3
SPRUNG   JMP ($0334)
;---------------------------------------
;  POKE
;---------------------------------------
POKE     LDA #<POKE1A
         LDY #>POKE1A
         JSR SERVE     ;VECTOR SETZEN
         BNE POKE2
POKE1A   JSR PERROR
POKE1    LDX #$FB
         TXS
POKE2    JSR PRINT
         .TEXT "POKE "
         .BYTE $00
         LDX #$05
         STX $8D
         LDY #$10
         JSR GFN2  ;GET
         JSR $79
         CMP #$2A
         BNE POKE3
         LDA #$40
         STA $8D
         JSR $73
POKE3    JSR $79      ;GET WERT
         BEQ SPRUNG
         JSR $B7EB
         TXA
         LDY $14
         LDX #$00
         STX $8E
         LDX $15
         STX $8F
         BNE POKE4
         BIT $8D
         BVC POKE4
         JSR $02A7   ;SETZEN
         JMP POKE2
POKE4    JSR RCR
         JMP POKE2
;---------------------------------------
PERROR   JSR PRINT
         .TEXT "ERROR!"
         .BYTE $0D,$00
         RTS
;---------------------------------------
; SPRITEMENU
;---------------------------------------
SPRITE   LDA $087C
SPRIT1   LDX $087D
         BNE SPRIT4
         LDA $0871
         ORA #$20
         TAX
         LDA $08A5   ; $D015
         BEQ SPRIT4
         LDX $0872   ;VIDEORAM
         INX
         INX
         INX
         STX $8F
         LDY #$F8   ;ZEIGER AUF SPRPOINT
         STY $8E
         LDY #$FF
SPRIT2   INY
         LSR A
         BCC SPRIT2
         JSR $02B3   ;GET BYTE
         TAY
         LDX $0871
         LDA #$00
SPRIT3   CPY #$00
         BEQ SPRIT4
         ADC #$3F
         DEY
         BCC SPRIT3
         INX
         BCS SPRIT3
SPRIT4   STA $8E
         STX $8F
         LDA #$C1
         LDX #$FE
         STA $0318
         STX $0319
         LDX #$0D
SPRIT5   LDA VICTSPR2-1,X
         STA $D021,X
         DEX
         BNE SPRIT5
         STX $45
         INX
         STX $46
         LDA $0877
         STA $BA
         JSR CER3   ;COPY $0800>$9E00
         JSR SSPRP  ;FILEDATEN SETZEN
SPRIT6   LDX #$FB
         TXS
         JSR SPRMENU
SPRIT7   JSR SPRBA1 ;GET SPRITEDATEN
SPRIT7A  NOP
         JSR SSPRP
SPRIT8   LDA #<SPRIT6
         LDY #>SPRIT6
         JSR SSPR    ;VECTOR
         CLI
         LDA $C5
         CMP #$28
         BEQ SPRIT9
         CMP #$2B
         BNE SPRIT11
SPRIT9   LSR A
         LDA $8E
         BCS SPRIT10
         ADC #$40
         STA $8E
         BCC SPRIT7
         INC $8F
         BCS SPRIT7
SPRIT10  SBC #$40
         STA $8E
         BCS SPRIT7
         DEC $8F
         BCC SPRIT7
SPRIT11  JSR $FFE4
         LDX #$0D
SPRIT12  CMP CMDSPR,X
         BEQ SPRIT13
         DEX
         BPL SPRIT12
         BMI SPRIT8
SPRIT13  TXA
         ASL A
         TAX
         LDA #>SPRIT7A
         PHA
         LDA #<SPRIT7A
         PHA
         LDA JPSPR+1,X
         PHA
         LDA JPSPR,X
         PHA
         LDY #$3E
         LDX #$00
         STX $02
         RTS
;---------------------------------------
; KOMMAMDOS VOM SPRITEMENU
;---------------------------------------
CMDSPR   .BYTE $42,$4D,$57,$49
         .BYTE $4F,$52,$46,$31
         .BYTE $32,$33,$34,$4C
         .BYTE $53,$58
;---------------------------------------
JPSPR    .WORD SPRBANK-1
         .WORD SPRMULTI-1
         .WORD SPRWIP-1
         .WORD SPRINV-1
         .WORD OOPS-1
         .WORD SPRSPIEG-1
         .WORD FLIP-1
         .WORD SPRFB1-1
         .WORD SPRFB2-1
         .WORD SPRFB3-1
         .WORD SPRFB4-1
         .WORD SPRLOAD-1
         .WORD SPRSAVE-1
         .WORD SPREXIT-1
;---------------------------------------
SPREXIT  JSR CER2A
         LDA $8E
         LDX $8F
         STA $087C
         STX $087D
         JMP START1
;---------------------------------------
SPRSPIEG LDX #$00
SPIEG1   LDY #$03
SPIEG2   LDA #$01
SPIEG3   ROR $0900,X
         BIT $45
         BPL SPIEG4
         PHP
         ROR $0900,X
         ROL A
         PLP
SPIEG4   ROL A
         BCC SPIEG3
         PHA
         INX
         DEY
         BNE SPIEG2
         CPX #$3F
         BCC SPIEG1
         BCS SPIEG6
;---------------------------------------
FLIP     LDA ($C1),Y
         PHA
         DEY
         BPL FLIP
SPIEG6   LDY #$3C
SPIEG7   PLA
         STA ($C1),Y
         PLA
         STA $0901,Y
         PLA
         STA $0902,Y
         DEY
         DEY
         DEY
         BPL SPIEG7
         BMI SPIEG10
;---------------------------------------
OOPS     LDA $0800,Y
         STA ($C1),Y
         DEY
         BPL OOPS
         BMI SPIEG10
;---------------------------------------
SPRINV   DEC $02
SPRWIP   LDA ($C1),Y
         EOR #$FF    ;INVERS
         AND $02
         STA ($C1),Y
         DEY
         BPL SPRWIP
SPIEG10  LDY #$3E
SPIEG11  LDA ($C1),Y
         JSR $02A7
         DEY
         BPL SPIEG11
         RTS
;---------------------------------------
SPRMULTI LDA $45
         EOR #$FE
SPRMU1   STA $45
         STA $D01C
         LDX #$0B
         LDY #$20
         AND #$FF
         BPL SPRMU2
         JSR PRINTT
         .TEXT "MULTCOL"
         .BYTE $00
         RTS
;---------------------------------------
SPRMU2   JSR PRINTT
         .TEXT "STANDRD"
         .BYTE $00
         RTS
;---------------------------------------
SPRBANK  LDA $8F
         CLC
         ADC #$40
         STA $8F
SPRBA1   DEC $8F
         LDY #$40
SPRBA2   JSR $02B3  ;GET SPRITEDATEN
         STA $0800,Y
         INY
         BNE SPRBA2
         INC $8F
SPRBA3   JSR $02B3
         CPY #$40
         BCS SPRBA4
         STA $0800,Y
SPRBA4   STA ($C1),Y
         INY
         BNE SPRBA3
         LDX #$0B
         LDY #$0F
         JSR CPOS3
         LDA $8F
         STA $02
         LDX $8E
         JSR HEXR
         ASL $02
         ROL A
         ASL $02
         ROL A
         AND #$03
         EOR #$03
         CLC
         ADC #$30
         STA $05C3   ;ZEIGER IN BILD
         LDY #$00
         LDA $8F
         CMP #$0A
         BCC SPRBA6
         LDX #$30
SPRBA5   DEY
         BNE SPRBA5
         DEX
         BNE SPRBA5
SPRBA6   STY $C6
         JMP $FF9F
;---------------------------------------
HEXR     PHA
         LDA #$24
         JSR $FFD2
         PLA
         JSR PHEX
         TXA
PHEX     PHA
         LSR A
         LSR A
         LSR A
         LSR A
         JSR PHEX1
         PLA
         AND #$0F
PHEX1    CLC
         ADC #$30
         CMP #$3A
         BCC PHEX2
         ADC #$06
PHEX2    JMP $FFD2
;---------------------------------------
SPRMENU  JSR $E544
         LDY #$22
         SEI
SPRMEN1  LDA VICTSPR-1,Y
         STA $CFFF,Y    ;VIC SETZEN
         DEY
         BNE SPRMEN1
SPRMEN2  LDA #$A0       ;REVERS
         STA $0400,Y
         STA $0440,Y
         INY
         BNE SPRMEN2
         JSR SPRFB1A
         LDX #$07
SPRMEN3  TXA
         CLC
         ADC #$20
         STA $07F8,X    ;POINTER
         DEX
         BPL SPRMEN3
         LDX #$08
         LDY #$11
         JSR PRINTT
         .BYTE $90,$0D
         .BYTE $0D,$0D,$20
         .TEXT "B*BANK: 1"
         .BYTE $01,$09
         .TEXT "M*MODUS:"
         .BYTE $01,$32
         .TEXT "+/-*SCROLL"
         .BYTE $01,$08
         .TEXT "1-4*FARBEN"
         .BYTE $01,$5E
         .TEXT "L*LADEN"
         .BYTE $01,$04
         .TEXT "S*SPEICHERN"
         .BYTE $01,$0E
         .TEXT "X*EXIT"
         .BYTE $01,$05
         .TEXT "W*WIPE"
         .BYTE $01,$13
         .TEXT "I*INVERS"
         .BYTE $01,$03
         .TEXT "F*FLIP"
         .BYTE $01,$13
         .TEXT "O*OOPS"
         .BYTE $01,$05
         .TEXT "R*SPIEGELN"
         .BYTE $00
;---------------------------------------
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         LDA $45
         JMP SPRMU1
;---------------------------------------
SPRFB1   INC $46
SPRFB1A  LDA $46
         LDX #$00
SPRFB1B  STA $D840,X   ;FARBRAM SETZEN
         STA $D800,X
         INX
         BNE SPRFB1B
         RTS
;---------------------------------------
SPRFB3   INC $D025
         RTS
;---------------------------------------
SPRFB4   INC $D026
         RTS
;---------------------------------------
SPRFB2   LDX #$07
SPRFB2A  INC $D027,X
         DEX
         BPL SPRFB2A
         RTS
;---------------------------------------
VICTSPR  .BYTE $80,$80,$20,$48
         .BYTE $48,$48,$70,$48
         .BYTE $A0,$3C,$E8,$48
         .BYTE $10,$48,$38,$48
         .BYTE $C0,$1B,$99,$00
         .BYTE $00,$FE,$C8,$10
         .BYTE $15,$7F,$F0,$00
         .BYTE $FE,$10,$00,$00
         .BYTE $00,$07
;---------------------------------------
VICTSPR2 .BYTE $00,$00,$01,$06
         .BYTE $05,$02,$00,$00
         .BYTE $00,$00,$00,$00
         .BYTE $00,$00
;---------------------------------------
SSPRP    LDA #$00
         STA $C6
         STA $C1
         LDA #$09   ;START-ENDE SETZEN
         STA $C2
         STA $AF
         LDA #$40
         STA $AE
         RTS
;---------------------------------------
FILTST   JSR CPOS1
         LDA $BA
         JSR LWCK1Q
         JSR GETFILN ;GET FILENAME
         LDA #$80
         STA $9D
         ASL A
         STA $B9
         STA $D015
         STA $DC0E
         JSR $FB8E
         LDA $BA
         CMP #$07
FILTST1  RTS
;---------------------------------------
SPRSAVE  JSR FILTST
         JSR FILSAV
SPRSAV1  JSR $FDA3
         JSR SPIEG10
         JSR FSAVE4
         LDA #$FE
         STA $D015
         JSR TSTBIT
         JMP SPRIT6
;---------------------------------------
FILSAV   BEQ FILSAV1
         LDX #$40
         LDY #$09
         LDA #$C1
         JMP $FFD8
FILSAV1  JSR FSAVE
         BCS FILTST1
         LDA #$07
         JMP PIR4A
;---------------------------------------
SPRLOAD  JSR FILTST
         JSR FILLOAD
         JMP SPRSAV1
;---------------------------------------
FILLOAD  PHP
         LDX #$00
         LDY #$09
         PLP
         BEQ FILLOAD1
         LDA #$00
         JMP $FFD5
;---------------------------------------
FILLOAD1 JSR $F817      ;DATASETTE
         BCS FILLOAD2
         LDX #$00
         LDY #$09
         LDA #$07
         JSR BANK3
         .BYTE $27,$80
;---------------------------------------
FILLOAD2 RTS
;---------------------------------------
FSAVE    JSR $FB8E
         LDA $BA
         CMP #$08
         BCS FSAVE1
         JSR TSTKERN ;DATASETTE
         CLI
         JMP $F838
;---------------------------------------
TSTKERN  LDA $F86C
         CMP #$38
         BEQ FOPEN1
         JSR PRINT
         .BYTE $0D
         .TEXT "BAD KERNAL"
         .BYTE $00
         JMP PARA8
;---------------------------------------
FSAVE1   STX $C3
         STY $C4
         LDA #$61
         STA $B9
         JSR FSAVE3
         LDA $BA
         JSR $FFB1
         LDA $B9
         JSR $FF93
         LDA $C3
         JSR $FFA8
         LDA $C4
         JMP $FFA8
;---------------------------------------
FOPEN    LDA #$60
         STA $B9
         JSR $F3D5
         LDA $BA
         JSR $FFB4
         LDA $B9
         JSR $FF96
         JSR $FFA5
         STA $AE
         LDA $90
         LSR A
         LSR A
         BCS FOPEN1
         JSR $FFA5
         STA $AF
         LDA #$00
         STA $90
         CLC
FOPEN1   RTS
;---------------------------------------
FSAVE3   JSR FILNSEND
         BCS FSAVE4
         RTS
;---------------------------------------
FILNSEND JSR $F3D5
         RTS
;---------------------------------------
FSAVE4   JSR LWCK5
         LDA $BA
         CMP #$08
         BCC FSAVE5
         JSR BANK2
         .BYTE $1B,$81  ;SAVE
;---------------------------------------
FSAVE5   RTS
;---------------------------------------
GETFILN  JSR PRINT
         .BYTE $0D
         .TEXT "FILENAME BITTE:"
         .BYTE $00
;---------------------------------------
         NOP
         NOP
GFN1     LDX #$0F
         LDY #$1D
GFN2     STX $22   ;ZEIGER AUF BILD
         STY $23
         JSR $EA24
         LDA $0286
GFN3     STA ($F3),Y
         DEY
         CPY $22
         BCS GFN3
         LDX #$08
         LDY #$02
         JSR $FFBD
         STX $7A
         STY $7B
         LDY #$0F
         LDA #$20
GFN4     STA ($BB),Y   ;LOESCHEN
         DEY
         BPL GFN4
GFN5     CLI
         JSR $FFE4
         STA $CC
         BEQ GFN5
         SEI
         PHA
         LDA $CF
         BEQ GFN6
         LDA $CE
         LDY $D3
         STA ($D1),Y
         LDY #$00
         STY $CF
         INY
         STY $CD
GFN6     PLA
         CMP #$0D
         BEQ GFN15
         LDY $D3
         CMP #$1D
         BNE GFN7
         CPY $23
         BCS GFN5
         INC $D3
         BNE GFN5
GFN7     CMP #$9D
         BNE GFN8
         CPY $22
         BEQ GFN5
         DEC $D3
         BPL GFN5
GFN8     CMP #$94
         BNE GFN11
         LDY $23
         CPY $D3
         BEQ GFN5
GFN9     DEY
         LDA ($D1),Y
         INY
         STA ($D1),Y
         DEY
         CPY $D3
         BNE GFN9
GFN10    LDA #$20
         STA ($D1),Y
         BNE GFN5
GFN11    CMP #$14
         BNE GFN13
         LDY $D3
         CPY $22
         BEQ GFN12
         DEY
         STY $D3
GFN12    INY
         LDA ($D1),Y
         DEY
         STA ($D1),Y
         INY
         CPY $23
         BNE GFN12
         BEQ GFN10
GFN13    CMP #$60
         BCS GFN5
         CMP #$20
         BCC GFN5
         AND #$3F
         LDY $D3
         STA ($D1),Y
         CPY $23
         BCS GFN14
         INY
         STY $D3
GFN14    JMP GFN5
;---------------------------------------
GFN15    LDX #$00
         LDY $22
         DEY
GFN16    INY
         LDA ($D1),Y
         AND #$3F
         BEQ GFN17
         STA $02
         ASL $02
         BIT $02
         BVS GFN17
         ORA #$40
GFN17    STA $0208,X
         INX
         CPY $23
         BNE GFN16
GFN18    DEX
         BMI GFN20
         LDA $0208,X
         CMP #$22
         BEQ GFN19
         CMP #$20
         BEQ GFN18
         INX
GFN19    LDA #$00
         STA $0208,X
         DEX
GFN20    INX
         STX $B7
         JSR LWCK5
         LDA $B7
         RTS
;---------------------------------------
; TEXT
;---------------------------------------
TEXT     LDX #$3C
         LDY #$03
         STX $B5
         STY $B6
         LDY #$28
         LDA #$20
TEXT1    STA ($B5),Y
         DEY
         BPL TEXT1
         JSR PRINT
         .TEXT "ALTER TEXT : "
         .BYTE $00
         JSR FIX  ;GET
TEXT2    LDA ($BB),Y
         STA ($B5),Y
         INY
         CPY $B7
         BNE TEXT2
         STY $B8
         JSR PRINT
         .BYTE $0D
         .TEXT "NEUER TEXT : "
         .BYTE $00
         JSR FIX   ;GET
TEXT3    LDA ($BB),Y
         STA $0350,Y
         INY
         CPY $B7
         BNE TEXT3
         JSR SCRENS
         LDA #$00
         STA $8D
         LDA #<TXTRT
         LDY #>TXTRT
         JSR STAR
         JSR BILD3
         JMP KOLI3
;---------------------------------------
TXTRT    INC $01
         LDA #$40
TXTR1    STA $BE
         LDY #$27
TXTR2    LDA ($B5),Y
         AND #$3F
         CMP #$20
         BEQ TXTR3
         CMP #$3F
         BEQ TXTR3
         ORA $BE
TXTR3    STA ($B5),Y
         DEY
         BPL TXTR2
         STY $8E
         LDY #$03
         STY $8F
TXTR4    INC $8E
         BNE TXTR5
         INC $8F
         BEQ TXTR10
TXTR5    LDY #$00
TXTR6    LDA ($B5),Y
         CMP #$3F
         BEQ TXTR8
         LDA ($8E),Y
         AND #$7F
         BIT $BE
         BVS TXTR7
         AND #$3F
TXTR7    CMP ($B5),Y
         BNE TXTR4
TXTR8    INY
         CPY $B8
         BNE TXTR6
         INC $8D
         LDY #$00
TXTR9    LDA $0350,Y
         STA ($8E),Y
         INY
         CPY $B8
         BNE TXTR9
         BEQ TXTR4
TXTR10   LDA #$00
         CMP $BE
         BNE TXTR1
         DEC $01
         RTS
;---------------------------------------
FIX      LDX #$0D
         LDY #$20
         JSR GFN2
         BEQ SPRUNG1
         LDY #$00
         RTS
;---------------------------------------
SPRUNG1  JMP ($0334)
;---------------------------------------
SSPR     STA $0334
         STY $0335
         RTS
;---------------------------------------
RCR      PHA
         LDA $8F
         BNE RCR1
         LDA #$08
         STA $8F
         PLA
         STA ($8E),Y
         RTS
RCR1     PLA
         JMP $02A7
;---------------------------------------
;  DEVICENUMMER
;---------------------------------------
LWCHK    LDA $0877
LWCK1Q   STA $BA
         BNE LWCK3
         LDA #$00
         STA $90
         LDA #$08
         JSR $FFB1
         LDA #$FF
         JSR $FF93
         LDA $90
         PHP
         JSR $FFAE
         PLP
         BMI LWCK2
         LDA #$08
         .BYTE $2C
LWCK2    LDA #$01
         STA $BA
         STA $0877
LWCK3    JSR LWU2   ;PREPARE
         JSR PRINT
         .BYTE $01,$03
         .TEXT "A*WEITER"
         .BYTE $0D,$01,$11
         .TEXT "B*DEVICE AENDERN"
         .BYTE $00
;---------------------------------------
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         JSR WTKEY
         BEQ LWCK4
         JSR LWU1
         STA $0877
         STA $BA
LWCK4    JSR LWU2  ;PREPARE
LWCK5    LDA #$0D
         JMP $FFD2
;---------------------------------------
LWU1     JSR CPOS
;
         .TEXT " DEVICE:"
         .BYTE $01,$49
         .TEXT "1*TAPE"
         .BYTE $01,$20
         .TEXT "7*TURBO-TAPE"
         .BYTE $01,$1A
         .TEXT "8*DISK"
         .BYTE $01,$20
         .TEXT "9*DISK"
         .BYTE $00
;---------------------------------------
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
LWU1A    JSR GETKEY
         LDX #$04
LWU1B    CMP DEVTB-1,X
         BEQ LWU1C
         DEX
         BNE LWU1B
         BEQ LWU1A
LWU1C    AND #$0F
         RTS
;---------------------------------------
DEVTB    .BYTE $31,$37,$38,$39
;---------------------------------------
SERVE    STA $0300
         STY $0301
         RTS
;---------------------------------------
CPOS1    LDX #$0F
CPOS2    JSR $E9FF
         INX
         CPX #$19
         BNE CPOS2
         LDX #$0F
         LDY #$00
CPOS3    CLC
         JMP $FFF0
;---------------------------------------
LWU2     JSR CPOS
         .TEXT "PREPARE "
         .BYTE $00
         LDA $BA
         CMP #$08
         BCC LWU2A
         JSR PRINT
         .TEXT "DISK "
         .BYTE $00
         JMP PDEV
;---------------------------------------
LWU2A    JSR PRINT
         .TEXT "TAPE "
         .BYTE $00
PDEV     LDA $BA
         ORA #$30
         JMP $FFD2
;---------------------------------------
WTKEY    LDX #$42
WTKEY2   INX
         STX $3F
WTT3     JSR GETKEY
         CMP #$41
         BCC WTT3
         CMP $3F
         BCS WTT3
         SBC #$40
         TAX
         STX $3F
         RTS
;---------------------------------------
INIFA    LDA #$01
         LDY #$00
INIFA1   STA $D800,Y
         STA $D900,Y
         STA $DA00,Y
         STA $DAE8,Y
         INY
         BNE INIFA1
INIFA2   LDA #$1B
         STA $D011
         RTS
;---------------------------------------
; KOPIERROUTINEN FUER RAM
;---------------------------------------
GRRT     LDA #$15
         JSR TSTZPR ;ROUT TESTEN
GRRT1    JSR $02B3  ;GET
         STA ($8E),Y
         INY
         BNE GRRT1
         INC $8F
         DEX
         BNE GRRT1
         LDA #$0A
GRRT2    STA $0878
         STA $02CA
         JMP FZR20
;---------------------------------------
PRRT     LDA #$0A
         JSR TSTZPR
PRRT1    LDA ($8E),Y
         JSR $02A7  ;SET DATA
         INY
         BNE PRRT1
         INC $8F
         DEX
         BNE PRRT1
         RTS
;---------------------------------------
TSTZPR   CMP $0878      ;TESTEN
         BNE TSTZPR1
         JSR CZPR      ;COPY
         LDA #$24
         STA $02DD
         LDA #$15
         JSR GRRT2
         LDA #$0A
         STA $8F
         LDY #$00
         STY $8E
         LDX #$0B
         RTS
TSTZPR1  PLA
         PLA
         RTS
;---------------------------------------
CZPR     LDX #$53
CZPR1    LDA ZPROUT,X ;KOPIERT NACH 02A7
         STA $02A7,X
         DEX
         BPL CZPR1
         LDA $0878
         STA $02CA
         RTS
;---------------------------------------
ZPROUT   STA $02E9  ;$02A7
         STX $02F7
         LDX #$8E
         LDA #$8D  ;STA
         BNE ZPR1
         STX $02F7  ;$02B3
         LDX #$8E
         LDA #$AD  ;LDA
ZPR1     STA $02EA
         SEI
         TYA
         CLC
         ADC $00,X
         STA $02EB
         LDA $01,X
         ADC #$00
         CMP #$0A
         BCS ZPR2
         ADC #$80
ZPR2     STA $02EC
         LDX #$34
         LDA #$00
         BCS ZPR4
ZPR3     LDA $D012
         SBC #$30
         BCS ZPR3
         LDX #$37
         LDA #$23
ZPR4     STA $DE00
         STX $01
         LDA #$FF
         STA $FFFF
         LDX #$37
         STX $01
         LDX #$00
         STX $DE00
         LDX #$FF
         AND #$FF
         RTS
;---------------------------------------

