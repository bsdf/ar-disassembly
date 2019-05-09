

         *= $8000


;---------------------------------------
; BANK 2
;---------------------------------------

;---------------------------------------
         .BYTE $09,$80
         .BYTE $0C,$80
         .BYTE $C3,$C2,$CD,$38,$30
;---------------------------------------
RESET    JMP $FCEF
;---------------------------------------
RESET1   JSR $F6BC
         JSR $F6ED
         BEQ RS1
         JMP $FE72
RS1      BIT $FD15
         JSR $FDA3
         JSR $E518
         LDA #$E3
         PHA
         LDA #$7A
         PHA
         LDA $DFEF
         PHA
         JMP $DFE3
;---------------------------------------
VEKNMI   BIT $DC01
         BMI BACK1
         LDA $1D
         AND #$03
         STA $DD00
         LDX #$80
VNMI1    DEY
         BNE VNMI1
         DEX
         BNE VNMI1
         LDA #$80
         JMP LP003 ;ENDE
BACK1    RTI
;---------------------------------------
LPRET    RTS
HEX3     RTS
;---------------------------------------
; HEX ADRESSE AUSGEBEN
;---------------------------------------
PADRES   LDY #$AF
         BIT $9D
         BPL HEX3
         LDA #$20
         JSR $E716
         LDA #$24
         JSR $E716
         JSR HEX
         DEY
HEX      LDA $00,Y
         PHA
         LSR A
         LSR A
         LSR A
         LSR A
         JSR HEX1
         PLA
         AND #$0F
HEX1     CLC
         ADC #$30
         CMP #$3A
         BCC HEX2
         ADC #$06
HEX2     JMP $E716
;---------------------------------------
;  BANKUMSCHALTROUTINE
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
         LDA #$10
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
; LISTEN SENDEN, 3 VERSUCHE
;---------------------------------------
LISVER   LDA #$6F
LISVER1  STA $9E
         STX $9F
         LDX #$03
LISVER2  LDA #$00
         STA $90
         LDA $BA
         JSR $FFB1
         LDA $9E
         JSR $FF93
         LDA $90
         ASL A
         BCC FAIL1
         JSR $FFAE
         DEX
         BNE LISVER2
         SEC
FAIL1    LDX $9F
         RTS
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
;---------------------------------------
; EINSPRUNG VON ANDEREN BAENKEN
;---------------------------------------
JUMPA    JMP LOADMAIN
         JMP SAVEMAIN
         JMP GFILMAIN
         JMP SVM1   ;SAVE OH.ADR.SETZEN
         JMP SDNP   ;DEVICE NOT PRESENT
         JMP PSEL1A ; DISKKOMMAND
JUMPAD   JMP PADRES ; HEX ZAHL
         JMP SVWL   ; SAVE WARPLOADER
JUMPB    JSR DIR    ;DIR
JUMPC    JMP CGET1  ;STATUS
         JMP $C000
         JMP PREP8  ; ZEIGER FUER LOAD
;---------------------------------------
;---------------------------------------
; LANGSAMER FASTLOAD
;---------------------------------------
SLLD     LDY #$94
SLLD1    LDA STR1-1,Y  ;FASTLOADROUTINE
         STA $FF,Y     ;WIRD IN STACK
         DEY           ;KOPIERT
         BNE SLLD1
         STY $90
         LDA $93
         BEQ SLLD2
         LDA #$D0
         STA $017E
         LDA #$08
         STA $017F
SLLD2    JMP $0100
;---------------------------------------
STR1     JSR $013D
         TAY
         JSR $013D
         JSR $013D
         DEY
         DEY
         TYA
STR1A    CMP #$FF
         BEQ STR1C
         STA $24
         LDY #$00
         JSR $0140
         TYA
         CLC
         ADC $AE
         STA $AE
         BCC STR1B
         INC $AF
STR1B    JSR $013D
         BNE STR1A
STR1C    ASL A
         PHP
         LDA $B8
         STA $B9
         JSR $F642
         PLP
         LDA #$00
         ROR A
         ORA $90
         STA $90
         LDX $AE
         LDY $AF
         RTS
;---------------------------------------
         LDA #$60
         .BYTE $2C
         LDA #$E6
         STA $017C
         NOP
GETB     LDX $A9
STR1D    BIT $DD00
         BVC STR1D
         SEC
STR1E    LDA $D012
         SBC $AA
         BCC STR1F
         AND #$07
         BEQ STR1E
STR1F    LDA $A8
         STA $DD00
         BIT $1F
         BMI STR1G
         BIT $80
         NOP
STR1G    LDA $DD00
         LSR A
         LSR A
         EOR $DD00
         LSR A
         LSR A
         EOR $DD00
         LSR A
         LSR A
         EOR $DD00
         STX $DD00
         EOR $A8
         RTS
;---------------------------------------
         .BYTE $01,$91,$AE
STR1H    DEC $01
         INY
         DEC $24
         BNE STR1D
         RTS
         EOR ($AE),Y   ;VERIFY
         BEQ STR1H
         LDA #$30
         STA $90
         BNE STR1H
         NOP
;---------------------------------------
;---------------------------------------
; IO UND BILD SETZEN FUER FASTLOAD
;---------------------------------------
SSZG     SEI
         LDA $DD00
         AND #$03
         STA $A8
         ORA #$20
         STA $A9
         STA $DD00
         LDA $D011
         AND #$07
         CLC
         ADC #$2F
         STA $AA
SSZG1    BIT $DD00
         BVS SSZG1
         RTS
;---------------------------------------
;---------------------------------------
         LDA #$2C
         STA $8389
         STA $8398
         LDX #$34
         LDY #$03
         STX $83C0
         STY $83C1
         LDY #$C3
LP028    LDA ZPRT1-1,Y   ;KOPIERT WARP
         STA $0333,Y    ;EMPFANGSROUTINE
         DEY
         BNE LP028
         LDA #<MELD1  ;FILE MIT CURSOR
         LDY #>MELD1  ;AUSWAEHLEN
         JMP $AB1E
;---------------------------------------
;PROGRAMMSTARTADRESSE NACH OPEN HOLEN
;---------------------------------------
DXGET1   LDX $B9
         JSR $DFB1
         LDA $B8
         JSR PSEL1D
         LDA $B8
         JSR FOPEN1
         STA $AE
         LDA $90
         LSR A
         LSR A
         BCS DXGET1A
         JSR $FFA5
         STA $AF
         STX $B9
         LDX $AE
DXGET1A  RTS
;---------------------------------------
; BYTE AN FLOPPY SENDEN(BILD AN)
;---------------------------------------
SENDB    LDY #$FF
SENDB1   BIT $DD00
         BVC SENDB1
         BVS SFR3
;---------------------------------------
; PAGE AN FLOPPY SENDEN(BILD AN)
;---------------------------------------
SFR      LDY #$00
SFR1     BIT $DD00
         BVC SFR1
SFR2     LDA ($22),Y
         NOP
SFR3     PHA
         LSR A
         LSR A
         LSR A
         LSR A
         TAX
         SEC
SFR4     LDA $D012
         SBC $AA
         BCC SFR5
         AND #$07
         BEQ SFR4
SFR5     LDA $A8
         STA $DD00
         LDA SERT1,X
         STA $DD00
         LSR A
         LSR A
         AND #$F7
         STA $DD00
         PLA
         AND #$0F
         TAX
         LDA SERT1,X
         STA $DD00
         LSR A
         LSR A
         AND #$F7
         STA $DD00
         LDA $A9
         NOP
         NOP
         INY
         STA $DD00
         BNE SFR2
         RTS
;---------------------------------------
SERT1    .BYTE $07,$87,$27,$A7
         .BYTE $47,$C7,$67,$E7
         .BYTE $17,$97,$37,$B7
         .BYTE $57,$D7,$77,$F7
;---------------------------------------
OPEN     LDA #$6F
FOPEN1   PHA
         LDA $BA
         JSR $FFB4
         PLA
         JSR $FF96
         JMP $FFA5
;---------------------------------------
; ÆLOPPYMELDUNG AM BILDSCHIRM AUSGEBEN
;---------------------------------------
CGET1    JSR LISVER ;LISTEN
         BCS SDNP    ;DEVICE NOT PR.
         JSR OPEN
         JSR $FFD2
         ASL A
         ASL A
         ASL A
         ASL A
         LDX $AB
         STA $AB
         JSR $FFA5
         PHA
         JSR $FFD2
CGET1A   JSR $FFA5
         JSR $FFD2
         CMP #$0D
         BNE CGET1A
         JSR $FFAB
         PLA
         AND #$0F
         ORA $AB
         STX $AB
         CMP #$02 ;ERROR ?
         RTS
;---------------------------------------
SDNP     LDA #<DNPER ;DEVICE NOT PRESENT
         LDY #>DNPER
         JSR $AB1E
         JMP $F707
;---------------------------------------
DNPER    .TEXT "DEVICE NOT PRESENT"
         .BYTE $0D,$00
         .BYTE $00,$00,$00,$00
         .BYTE $00,$00
;---------------------------------------
;---------------------------------------
; WARP;SCHNELLE UEBERTRAGUNG 192BYTES
;---------------------------------------
ZPRT1    LDA #$07
         STA $DD00
ZPRT1A   BIT $DD00
         BVC ZPRT1A
         BIT $DD00
         BVC ZPRT1B
         BIT $80
         NOP
ZPRT1B   BIT $DD00
         BVS ZPRT1C
         BIT $80
ZPRT1C   BIT $DD00
         BVS ZPRT1D
ZPRT1D   NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         LDY #$50
ZPRT1E   LDA $DD00
         LSR A
         LSR A
         EOR $DD00
         LSR A
         LSR A
         EOR $DD00
         LSR A
         LSR A
         EOR $DD00
         PHA
         LDA $DD00
         LSR A
         LSR A
         EOR $DD00
         LSR A
         LSR A
         EOR $DD00
         LSR A
         LSR A
         EOR $DD00
         PHA
         LDA $DD00
         LSR A
         LSR A
         EOR $DD00
         LSR A
         LSR A
         EOR $DD00
         LSR A
         LSR A
         EOR $DD00
         PHA
         NOP
         BIT $80
         BIT $DD00
         BVC ZPRT1F
ZPRT1F   NOP
         DEY
         BPL ZPRT1E
         BIT $80
         LDY #$F0
         LDA $3C
         BNE ZPRT1G
         DEC $3D
ZPRT1G   DEC $3C
         LDA $3C
         ORA $3D
         BNE ZPRT1I
ZPRT1H   CPY $35
         BEQ ZPRT1I
         PLA
         DEY
         BNE ZPRT1H
         BEQ ZPRT2
ZPRT1I   STY $A6
         JMP $0200
;---------------------------------------
; WARPROUTINEN
;---------------------------------------
VGET1    INC $01
VGET1X   PLA
         EOR #$F9
         DEY
         STA ($AE),Y
         BNE VGET1X
         DEC $01
         JMP ZPRT2
;---------------------------------------
ZPRT2    PLA
         PLA
         PLA
         EOR #$F9
         AND #$3F
         BEQ ZPRT2C
         LDX #$03
ZPRT2A   TXA
         ORA $90
         STA $90
         RTS
ZPRT2C   LDA $AE
         CLC
         ADC $A6
         STA $AE
         BCC ZPRT2D
         INC $AF
ZPRT2D   LDX #$40
         LDA $3C
         ORA $3D
         BEQ ZPRT2A
         JMP ZPRT1
;---------------------------------------
;---------------------------------------
MELD1    .BYTE $93
         .TEXT "  FILE BITTE MIT DEM "
         .TEXT "CURSOR AUSWAEHLEN"
         .BYTE $0D,$0D,$00
;---------------------------------------
;---------------------------------------
VGET2    INC $01
VGET2X   PLA
         EOR #$F9
         DEY
         EOR ($AE),Y  ;VERIFY WARP
         ORA $90
         STA $90
         TYA
         BNE VGET2X
         LDA $90
         BEQ VGET2Y
         LDA #$30
         STA $90
VGET2Y   DEC $01
         JMP ZPRT2
;---------------------------------------
;---------------------------------------
;EMPFANGSROUTINE SCHNELLER FASTLOAD
;---------------------------------------
SER2     LDA #$00
         STA $DD00
SER2A    BIT $DD00
         BVC SER2A
         BIT $DD00
         BVC SER2B
         BIT $80
         NOP
SER2B    BIT $DD00
         BVS SER2C
         BIT $80
SER2C    BIT $DD00
         BVS SER2D
SER2D    LDY #$00
SER2E    BIT $DD00
         BVS SER2F
         BIT $80
SER2F    NOP
         BIT $80
         CMP #$80
         LDA $DD00
         LSR A
         LSR A
         ORA $DD00
         LSR A
         LSR A
         NOP
         NOP
         ORA $DD00
         LSR A
         LSR A
         ORA $DD00
         STA $0200,Y
         CMP #$EA
         LDA $DD00
         LSR A
         LSR A
         ORA $DD00
         LSR A
         LSR A
         NOP
         INY
         ORA $DD00
         LSR A
         LSR A
         ORA $DD00
         STA $0200,Y
         CMP #$EA
         LDA $DD00
         LSR A
         LSR A
         ORA $DD00
         LSR A
         LSR A
         NOP
         INY
         ORA $DD00
         LSR A
         LSR A
         ORA $DD00
         STA $0200,Y
         CMP #$EA
         LDA $DD00
         LSR A
         LSR A
         ORA $DD00
         LSR A
         LSR A
         NOP
         INY
         ORA $DD00
         LSR A
         LSR A
         ORA $DD00
         STA $0200,Y
         INY
         BEQ SER2G
         JMP SER2E
SER2G    LDA $A9
         STA $DD00
         JSR GETB
SER2H    EOR $0200,Y
         EOR $0280,Y
         INY
         BPL SER2H
         CMP #$00   ;CHKSUM
         RTS
;---------------------------------------
; BYTES AN FLOPPY SENDEN
;---------------------------------------
TIPR1    LDA #$E0
TIPR1A   STX $0C
         JSR SENDB
         LDA $21
         JSR SENDB
         LDA $0C
         JMP SENDB
;---------------------------------------
; TRACK LADEN
;---------------------------------------
TIPR2    LDA #$12   ; 18;01 ALS START
         LDX #$01
         STA $21
         STX $22
TIPR2A   BIT $1F
         BMI TIPR2H
         LDX #$00
         JSR TIPR1    ;SENDEN
TIPR2B   JSR LPRET    ;RTS
         LDY #$15
         LDA #$FF
TIPR2C   STA $0114,Y  ;ERRTAB LOESCHEN
         DEY
         BNE TIPR2C
         STY $11
         JSR GETB
         CMP #$16
         BCS TIPR2G
         STA $13
TIPR2D   JSR GETB
         CMP #$15
         BCS TIPR2F
         STA $0C
         JSR SER2    ;PAGE LADEN
         BEQ TIPR2E
         TYA
TIPR2E   JSR MGET1D
         JMP TIPR2D
TIPR2F   LDA #$00
         CLC
TIPR2G   RTS
TIPR2H   RTS
;---------------------------------------
MGET1    LDA #$80
         JSR TIPR1A ;SENDEN
         JSR GETB   ;RUECKMELDUNG
         BPL MGET1A
         DEC $D020
         JMP LP076
MGET1A   PHA
         LDY #$00
MGET1C   JSR GETB       ;PAGE LANGSAM
         STA $0200,Y    ;LADEN
         INY
         BNE MGET1C
         PLA
MGET1D   STA $24
         BNE MGET1E
         INC $11
         LDA $1C
         BNE MGET1E
         LDX $0C
         CPX $22
         BNE MGET1E
         INC $1C
         JSR PREP1      ;STARTADRESSE
         LDA $AE        ;HOLEN
         SEC
         SBC #$04
         STA $AE
         BCS MGET1E
         DEC $AF
MGET1E   LDX $0C
         CPX #$16
         BCS MGET1F
         LDA $0200
         AND #$7F
         ORA $24
         STA $0115,X   ;LINKPOINTER
         LDA $0201     ;SETZEN
         STA $012A,X
MGET1F   LDY #$00
         STY $0F
         LDA $0C
         CLC
         ADC $0E
         STA $10
         JMP $013F
;---------------------------------------
; STARADRESSE SETZEN
;---------------------------------------
PREP1    LDA $0203
         LDX $0202
PREP1A   STA $AF
         STX $AE
PREP1B   LDY $B9
         BNE PREP1C
         LDY $C3
         STY $AE
         LDY $C4
         STY $AF
PREP1C   STX $C3
         STA $C4
         LDA $AF
         CMP #$03
         BCS FORM1
         LDA #$FF
         STA $90
         RTS
;---------------------------------------
; LOADING + ADRESSE AUSGEBEN
;---------------------------------------
FORM1    LDA $0288
         PHA
         LDA $0286
         PHA
         LDA $0A
         STA $0288
         LDA $09
         STA $0286
         JSR $F5D2
         JSR PADRES
         PLA
         STA $0286
         PLA
         STA $0288
         SEC
         RTS
;---------------------------------------
; LINKPOINTER SUCHEN
;---------------------------------------
PREP2    LDY #$FF
PREP2A   INY
         STY $12
PREP2B   LDY $12
         LDX $22
         LDA $0115,X
         BPL PREP2C
         INC $D020
         JSR MGET1
         DEC $D020
         JMP PREP2B
PREP2C   TXA
         STA $0100,Y
         LDA $012A,X
         STA $22
         LDA $0115,X
         CMP $21
         BEQ PREP2A
         STA $21
         TAY
         BEQ PREP2D
         JSR TIPR1
PREP2D   STY $11
PREP2E   LDY $11
         INC $11
         LDA $0100,Y
         TAY
         CLC
         ADC $0E
         STA $10
         LDA $0115,Y
         BNE PREP2F
         LDX $012A,Y
         INX
         STX $0187
PREP2F   JSR PREP2K
         SEC
         SBC $0D
         JSR PREP2I
         LDA #$02
         CMP $0D
         STA $0D
         BCS PREP2G
         JSR PREP2I
PREP2G   DEC $12
         BPL PREP2E
         LDA $21
         BEQ PREP2H
         JSR TIPR2B    ;LINKPOINTER
         BMI PREP2H
         JMP PREP2
PREP2H   LDA #$02
PREP2I   CLC
         ADC $AE
         STA $AE
         BCC PREP2J
         INC $AF
PREP2J   RTS
;---------------------------------------
PREP2K   LDY $0D
         TAX
         BEQ PREP2N
         LDA $93
         BNE PREP2N
         LDA $AF   ;ADRESSE
         CMP #$E0  ;CMP MIT IO+EXT.RAM
         BCS PREP2L
         CMP #$7F
         BCC PREP2L
         CMP #$A0
         BCC PREP2N
         CMP #$CF
         BCS PREP2M
PREP2L   JMP $0165
PREP2M   JMP $014E
PREP2N   JMP $0173
;---------------------------------------
GFILMAIN LDY #$63
         .BYTE $2C
LOADMAIN LDY #$60
         STY $B8
         STA $93
         JSR FLOP2X
         BNE LDM1
         JSR DGET1   ;FLOPPYTEST
         BEQ LDM1
         BMI LDM1
         JSR BANK0
         .BYTE $51,$80 ;RAM SPEICHERN
;---------------------------------------
         JSR LDM1
         PHA
         PHP
         JSR BANK0
         .BYTE $54,$80 ;RAM ZURUECKHOLEN
;---------------------------------------
         PLP
         PLA
         JMP LDM2
;---------------------------------------
LDM1     JSR BANK2
         .WORD LDMAIN  ;LADEROUTINE
;---------------------------------------
; LOAD ENDE
;---------------------------------------
         LDA $90
         CMP #$FF
         BEQ WAIT1
         ASL A
         PHP
         LSR A
         PLP
         BCS LDM2
         JSR JUMPAD   ;ADRESSE AUSGEBEN
LDM2     LDX $AE
         LDY $AF
         RTS
;---------------------------------------
WAIT1    LDX #$80
WAIT1A   DEY
         BNE WAIT1A
         DEX
         BNE WAIT1A
         RTS
;---------------------------------------
; IO UND ZEROPAGE ZWISCHENSPEICHERN
;---------------------------------------
IRQS1    SEI
         LDA #$01
         LDY #$95
         LDX #$02
         JSR BANK0
         .BYTE $15,$80 ;STACK COPY
         JSR RAST2
IRQS1A   LDA $02,Y
         JSR $9FAE
         DEY
         BPL IRQS1A
         LDA $DC0E
         STA $02
         LDA $DC0F
         STA $03
         LDA $D015
         STA $04
         LDA $D01A
         STA $05
         LDA $0318
         STA $06
         LDA $0319
         STA $07
         LDA $DD00
         AND #$07
         STA $1D
         LDA $DD02
         STA $1B
         LDA #$3F
         STA $DD02
         LDA #<VEKNMI
         STA $0318
         LDA #>VEKNMI
         STA $0319
         LDA #$00
         STA $DC0E
         STA $DC0F
         STA $DD0E
         STA $DD0F
         STA $D015
         STA $D01A
         STA $02A1
         STA $A3
         STA $94
         LDA $D019
         STA $D019
         STA $90
         LDA $DC0D
         LDA $D011
         AND #$7F
         STA $08
         LDA $0288
         STA $0A
         LDA $0286
         STA $09
         TSX
         INX
         INX
         STX $0B
         LDX #$FF
         RTS
;---------------------------------------
; ORIGINAL IO UND ZEROPAGE HERSTELLEN
;---------------------------------------
IRQS2    SEI
         LDA $1B
         STA $DD02
         LDA $1D
         AND #$03
         STA $DD00
         LDA $02
         STA $DC0E
         LDA $03
         STA $DC0F
         LDA $04
         STA $D015
         LDA $05
         STA $D01A
         LDA $06
         STA $0318
         LDA $07
         STA $0319
         LDA $08
         STA $D011
         LDX $0B
         TXS
         JSR RAST2
IRQS2A   JSR $9FA2
         STA $02,Y
         DEY
         BPL IRQS2A
         LDY #$01
         LDX #$02
         LDA #$80
         PHA
         LDA #$15
         PHA
         PHP
         LDA #$95
         PHA
         LDA #$00
         JMP $9FDE
;---------------------------------------
RAST2    SEI
         LDA #$FC
RAST2A   CMP $D012
         BNE RAST2A
         LDX #$9E
         LDY #$3B
         RTS
;---------------------------------------
; FASTLOAD START
;---------------------------------------
LDMAIN   JSR IRQS1
         TXS
         LDA $B7
         BEQ LP101
         LDY #$00
         JSR $DF80
         CMP #$24    ;DIR
         BEQ LP101
         JSR DGET1  ;FLOPPYTEST
         BEQ LP101
         BPL PREP3
LP102    JSR DXGET1
         BCS LP103
         JSR PREP1B  ;STARTADRESSE
         BCC LP104
         LDX #$07
         LDY #$FF
         BIT $1F
         BMI LP105
         LDX #$00
         LDY #$1E
LP105    JSR LP106  ;FLOPPYROUT SENDEN
         JSR SLLD    ;LANGSAM F-LOAD
         JMP IRQS2
;---------------------------------------
PREP3    LDX #$9F
         LDY #$08
         JSR $9FA2
         BNE LP102
         LDA #$80
         STA $0E
         JSR PREP4 ;FILENAMETEST
         JSR $DFB1
         JSR LP107 ;FLOPPY SEND
         JSR TIPR2 ;TRACK18 LADEN
         JSR LP108 ;FILENAME SUCHEN
         BCC LP109
         LDA #$62
         JSR SENDB  ;ENDE
LP103    LDA #$84
         BNE LP003
LP109    CMP #$0A
         BEQ LP110      ;WARP-FILE
         LDA #$04
         STA $0D
         JSR PREP4E   ; PREPARE FLOAD
         LDA #$00
         STA $1C
         JSR TIPR2A    ;LINKPOINTER
         BMI LP076
         LDA $90
         BMI LP104
         JSR PREP2    ;LOAD
         LDA #$40
         .BYTE $2C
LP076    LDA #$03
         .BYTE $2C
LP101    LDA #$FF
         ORA $90
LP003    STA $90
LP104    JMP IRQS2
;---------------------------------------
; WARP LADEROUTINE
;---------------------------------------
LP110    LDA $34
         LDX $33
         JSR PREP1A     ;LADEADRESSE
         LDY #$1B       ;SETZEN
         LDA $93
         CMP #$01       ;LOAD/VERIFY
LP112    LDA VGET1,Y
         BCC LP113
         LDA VGET2,Y
LP113    STA $0200,Y
         DEY
         BPL LP112
         LDA #$F0
         LDX $22
         JSR TIPR1A  ;3BYTE SEND
         LDA $3C
         JSR SENDB
         LDA $3D
         JSR SENDB
         LDA #<SLFLR   ;WARP FLOPPYRT.
         LDY #>SLFLR
         LDX #$03
         JSR LP114     ;FLOPPY SEND
         JSR ZPRT1     ;LOAD
         JMP IRQS2     ;IO + ZP SETZEN
;---------------------------------------
LP108    LDX #$7F
LP115    LDA STRT2,X
         STA $013F,X
         DEX
         BPL LP115
         LDA #$01
         JMP $013F
;---------------------------------------
; FILENAME SUCHEN
;---------------------------------------
STRT2    LDX #$20
         STX $DE00
STRT2A   CLC
         ADC $0E
         STA $10
         LDA #$02
         STA $0F
STRT2B   LDY #$03
STRT2C   LDA $FD,Y
         CMP #$A0
         BNE STRT2D
         CMP ($0F),Y
         BEQ STRT2F
STRT2D   CMP ($0F),Y
         BEQ STRT2E
         CMP #$2A
         BEQ STRT2F
         CMP #$3F
         BNE STRT2H
         LDA ($0F),Y
         CMP #$A0
         BEQ STRT2H
STRT2E   INY
         CPY #$13
         BNE STRT2C
STRT2F   LDY #$1D
STRT2G   LDA ($0F),Y
         STA $20,Y
         DEY
         BPL STRT2G
         TAY
         BPL STRT2H
         AND #$0F
         BEQ STRT2H
         CMP #$0A
         BEQ STRT2I
         CMP #$02
         BEQ STRT2I
         EOR $B8
         LSR A
         BCC STRT2I
STRT2H   LDA $0F
         CLC
         ADC #$20
         STA $0F
         BCC STRT2B
         DEC $0F
         LDY #$00
         LDA ($0F),Y
         BPL STRT2A
         SEC
         .BYTE $24
STRT2I   CLC
         LDY #$10
         STY $DE00
STRT2X   RTS
;---------------------------------------
; M-W/M-R/M-E SENDEN
;---------------------------------------
SNDME    LDX #$45
         .BYTE $2C
SNDMR    LDX #$52
         .BYTE $2C
SNDMW    LDX #$57
         JSR LISVER    ;LISTEN
         BCS STRT2X
         LDA #$4D
         JSR $FFA8
         LDA #$2D
LP126    JSR $FFA8
         TXA
         JMP $FFA8
;---------------------------------------
LP127    LDY #$FF
         BNE LP106
;---------------------------------------
LP107    BIT $1F
         BMI LP128
         LDY #$00
         JSR FORM2
         BCS LP129
         LDA #$0B
         STA $D011
         BCC LP129
;---------------------------------------
LP128    LDX #$23
         JSR LP127
LP129    INC $1C
         RTS
;---------------------------------------
; FLOPPYROUT SEND
;---------------------------------------
FORM2    LDX #$00
LP106    STY $23
         TXA
         BNE LP130
         BIT $1F
         BVC LP130
         JSR SNDMW   ;M-W
         LDA #$01
         LDX #$18      ;$1801
         JSR LP126  ;SEND
         LDA #$01
         LDX $1E
         JSR LP126  ;SEND
         JSR $FFAE
         LDX #$00
LP130    LDY #$00
LP131    LDA DATA10,X
         STA $24,Y
         INX
         INY
         CPY #$07
         BNE LP131
LP132    JSR SNDMW   ;M-W
         BCS STRT2X
         LDA $26
         LDX $27
         JSR LP126   ;SEND
         LDA #$22
         JSR $FFA8
         LDY #$00
LP133    LDA ($24),Y
         JSR $FFA8
         INC $26
         BNE LP134
         INC $27
LP134    INY
         CPY #$22
         BNE LP133
         JSR $FFAE
         TYA
         CLC
         ADC $24
         STA $24
         BCC LP135
         INC $25
LP135    DEC $2A
         BNE LP132
         JSR SNDME      ;M-E
         LDA $28
         LDX $29
         JSR LP126     ;SEND
         LDX $23
         BMI LP136
         LDY #$00
LP137    LDA DATA11,X
         STA $26,Y
         INX
         INY
         CPY #$05
         BNE LP137
         LDA $28
         LDX $29
         JSR LP126     ;SEND
         LDA $2A
         JSR $FFA8
         JSR FOUT1
         LDA #<FEL99
         LDY #>FEL99    ;SCHNELLE
         LDX #$01       ;UEBERTRAGUNGS-
         JSR LP114      ;ROUTINE SENDEN
         LDA $26
         LDY $27
         LDX $28
         BEQ LP138
LP114    STA $22
         STY $23
         STX $24
LP139    JSR SFR     ;PAGE SENDEN
         INC $23
         DEC $24
         BNE LP139
LP138    CLC
         RTS
;---------------------------------------
; SENDET FILENAME NACH M-E
;---------------------------------------
FOUT1    BIT $1F
         LDA #$2C
         BVC LP140
         LDA #$8D
LP140    JSR $FFA8
LP136    LDY #$00
LP141    CPY $B7
         BCS LP142
         LDA ($BB),Y
         JSR $FFA8
         INY
         BNE LP141
LP142    LDA #$A0
         JSR $FFA8
         JSR $FFAE
         JMP SSZG    ;IO UND BILD INIT
;---------------------------------------
; TEST DER FLOPPY 1541/71/81
;---------------------------------------
DGET1    LDY #$00
         STY $1F
         LDA $BA
         CMP #$08
         BCC DGET1D
         CMP #$0C
         BCS DGET1D
         LDA #$FE
         LDY #$FF         ;1581 TEST
         JSR DGET2
         BEQ DGET1D
         CMP #$03
         BEQ DGET1C
         LDA #$01         ;$1801 M-R
         LDY #$18         ;1571 TEST
         JSR DGET2
         TAY
         BEQ DGET1A
         AND #$DF
         STA $1E
         INY
         BEQ DGET1A
         TYA
         AND #$78
         CMP #$38
         BEQ DGET1B
DGET1A   SEC
         ROR $1F
DGET1B   ROR $1F
DGET1C   ROR $1F
DGET1D   LDA $1F
         RTS
;---------------------------------------
; M-R 1 BYTE
;---------------------------------------
DGET2    PHA
         JSR SNDMR    ;M-R
         PLA
         BCC DGET2A
         PLA
         PLA
         LDA #$00
         RTS
DGET2A   JSR $FFA8
         TYA
         LDX #$01
         JSR LP126
         JSR $FFAE
         JSR OPEN      ;GETB
         PHA
         JSR $FFAB
         PLA
         RTS
;---------------------------------------
;SCHNELLE UEBERTRAGUNG IN FLOPPY-RAM
;PART1
;---------------------------------------
GETFLR   SEI
         JSR $018D
         LDA #$7A
         STA $1802
         JSR $F5E9
         JSR $0162
         JMP $0300
;---------------------------------------
         LDY #$00
         LDA #$00
         STA $1800
FLUP1    LDA $1800
         BNE FLUP1
         PHP
         LDA $1800
         ASL A
         PLP
         EOR $1800
         ASL A
         ASL A
         ASL A
         NOP
         NOP
         NOP
         EOR $1800
         ASL A
         NOP
         NOP
         NOP
         EOR $1800
         STA $0300,Y
         INY
         BNE FLUP1
         LDA #$08
         STA $1800
         RTS
;---------------------------------------
;FILENAME VERGLEICHEN (,*?)
;---------------------------------------
PREP4    JSR PREP5
         LDX #$00
PREP4A   INY
         CPY $B7
         BCS PREP4D
         JSR $DF80
         CMP #$2C    ; ,
         BEQ PREP4B
         CMP #$3D    ; =
         BNE PREP4C
PREP4B   LDA #$A0
PREP4C   STA $0100,X
         INX
         CPX #$15
         BCC PREP4A
PREP4D   LDA #$A0
         STA $0100,X
         CPX #$03
         BCC PREP4E
         LDA $0101
         CMP #$2A    ; *
         BNE PREP4E
         LDA #$3F    ; ?
         CMP $0100
         BNE PREP4E
         STA $0101
PREP4E   LDX #$7F
PREP4F   LDA FKRT,X   ;SCHNELLE FLOADR.
         STA $013F,X  ;IN RAM KOPIEREN
         DEX
         BPL PREP4F
         LDA $93
         BEQ PREP4G
         LDA #$D0
         STA $0181
         LDA #$09
         STA $0182
PREP4G   RTS
;---------------------------------------
PREP5    LDA #$3A   ; :
PREP5A   STA $24
         LDY #$00
PREP5B   CPY $B7
         BCS PREP5C
         JSR $DF80
         CMP $24
         BEQ PREP5D
         INY
         BNE PREP5B
PREP5C   LDY #$FF
PREP5D   RTS
;---------------------------------------
;KOPIERROUTINEN FUER SCHNELLES FASTLOAD
;---------------------------------------
FKRT     LDA #$23
         STA $DE00
FKR1     LDA $0200,Y
         STA ($0F),Y
         INY
         BNE FKR1
         BEQ FKR3
;---------------------------------------
         LDA #$20
         STA $DE00
FKR2     LDA ($0F),Y
         INC $01
         STA ($AE),Y
         DEC $01
         INY
         BNE FKR2
FKR3     LDA #$10
         STA $DE00
         TYA
         RTS
;---------------------------------------
         LDA #$20
         STA $DE00
FKR4     LDA ($0F),Y
         STA ($AE),Y
         INY
         BNE FKR4
         BEQ FKR3
;---------------------------------------
         LDX #$10
FKR5     LDA #$20
         STA $DE00
         LDA ($0F),Y
         STX $DE00
         INC $01
         STA ($AE),Y
FKR6     DEC $01
         INY
         CPY #$00
         BNE FKR5
         BEQ FKR3
;---------------------------------------
         EOR ($AE),Y  ;VERIFY
         BEQ FKR6
         LDA #$30
         STA $90
         BNE FKR6
;---------------------------------------
;---------------------------------------
SNDWIRK  LDY #$4A
         BIT $9D
         BPL LP166
         LDA #<MELD2     ;WIRKLICH
         LDY #>MELD2
         JSR $AB1E
         LDY #$00
LP167    JSR $FFCF
         CPY #$00
         BNE LP168
         TAY
LP168    CMP #$0D
         BNE LP167
LP166    CPY #$59        ;J
         BNE LP169
         JMP DGET1
LP169    PLA
         PLA
         RTS
;---------------------------------------
MELD2    .BYTE $0D
         .TEXT "WIRKLICH ?"
         .BYTE $00
         .TEXT "   "
         .BYTE $00
;---------------------------------------
; FILENAME SETZEN
;---------------------------------------
         LDA $B7
         CMP #$03
         BCC FFIL1X
         LDY #$00
         JSR $DF80
         CMP #$3F    ; ?
         BNE FFIL1X
         INY
         JSR $DF80
         CMP #$2A    ; *
         BNE FFIL1X
         LDA #$3F
         STA ($BB),Y
FFIL1X   RTS
;---------------------------------------
FFIL1    LDY #$00
FFIL1A   JSR $DF80
         CMP #$3D     ; =
         BEQ FFIL1C
         CMP #$2A     ; *
         BNE FFIL1B
         LDA #$A0
         STA ($BB),Y
FFIL1B   INY
         CPY $B7
         BNE FFIL1A
FFIL1C   RTS
;---------------------------------------
FFIL2    LDA $BB
         CLC
         ADC #$02
         STA $BB
         BCC FFIL2A
         INC $BC
FFIL2A   DEC $B7
         DEC $B7
FFIL2B   RTS
;---------------------------------------
; DEVICE AENDERN
;---------------------------------------
CHDEV    INY
         JSR $DF80
         AND #$0F
         TAY
         CMP #$08
         BCC FFIL2B
         JSR SNDMW      ;M-W
         LDA #$77
         LDX #$00
         JSR LP126    ;SEND
         LDA #$02
         JSR $FFA8
         TYA
         ORA #$40
         TAX
         TYA
         ORA #$20
         JSR LP126    ;SEND
         STY $BA
         JMP CGET1  ;STATUS
;---------------------------------------
; SCRATCH
;---------------------------------------
SCRTCH   JSR SNDWIRK  ;WIRKLICH ?
         AND #$20
         BEQ PSEL1C
         LDX #$15
         JSR LP127   ;FLOPPY SEND
         JMP $FFAE
;---------------------------------------
; DISKKOMMANDO TEIL 2
;---------------------------------------
PSEL2    CMP #$3D     ;DEVICENUMMER
         BEQ CHDEV
         CMP #$52     ;RENAME
         BEQ PSEL1
         CMP #$48     ;HEADER
         BNE PSEL1C
         JSR PREP5    ;CMP :
         BMI PSEL1C
         JSR FFIL2    ;FILESTART+2
         BEQ PSEL2A
         LDA #$2C
         JSR PREP5A   ; CMP ,
         STY $FE
         JSR BANK3
         .BYTE $1E,$80 ; HEADERCHANGE
;---------------------------------------
PSEL2A   RTS
;---------------------------------------
; DISKKOMMANDO ABFRAGEN
;---------------------------------------
PSEL1    JSR FFIL1
         BEQ PSEL1C
PSEL1A   LDA $B7
         BNE PSEL1B
         JMP CGET1
PSEL1B   LDY #$00
         JSR $DF80
         CMP #$53      ;SRATCH
         BEQ SCRTCH
         CMP #$24      ;DIR
         BEQ PSEL1F
         CMP #$4E      ;FORMAT
         BNE PSEL2
         JSR SNDWIRK   ;WIRKLICH ?
         AND #$20
         BNE PSEL1E
PSEL1C   LDA #$6F
PSEL1D   STA $B9
         JMP $DF87
PSEL1E   LDY #$0A
         JSR FORM2     ;FORMATROUT
         JSR $FFAE
PSEL1F   JSR PRET
         JSR JUMPB  ;DIR
         RTS
;---------------------------------------
PRET     LDA #$0D
         JMP $FFD2
;---------------------------------------
; SAVEROUTINE
;---------------------------------------
SAVEMAIN LDA $C1
         STA $C3
         LDA $C2
         STA $C4
SVM1     LDA $C2
         CMP #$03
         BCC SVM4
         LDX #$FE
         LDY $B7
         CPY #$03
         BCC SVM2
         DEY
         JSR $DF80
         CMP #$57
         BNE SVM2
         DEY
         JSR $DF80
         CMP #$2C
         BNE SVM2
         LDX #$F0
SVM2     STX $BF
SVM3     JSR DGET1   ;FLOPPYTEST
         BNE SVM5
SVM4     JSR BANK3A
         .BYTE $ED,$F5
         RTS
;---------------------------------------
SVM5     AND #$20
         BNE SVM6
         LDA #$FE
         STA $BF
SVM6     LDA $B7
         BEQ SVM4
         JSR BANK2
         .WORD MAINSAVE
;---------------------------------------
         JSR $F642
         LDA $90
         CMP #$55
         BEQ DISKFULL
         ASL A
         PHP
         LSR A
         PLP
         BCS DISKFUL3
         BIT $9D
         BPL DISKFUL2
         LDA $90
         BEQ DISKFUL2
         JSR PRET
         JSR JUMPC      ;STATUS
         JMP DISKFUL2
;---------------------------------------
DISKFULL LDA #<FULERR
         LDY #>FULERR
         JSR $AB1E
         LDA #$00
         STA $C6
DISKFUL1 JSR $EA87
         JSR $F142
         CMP #$41
         BEQ SVM3
         CMP #$42
         BNE DISKFUL1
DISKFUL2 CLC
DISKFUL3 RTS
;---------------------------------------
FULERR   .BYTE $0D
         .TEXT "FULL: <A> TRY AGAIN  "
         .TEXT "<B> QUIT"
         .BYTE $0D,$00
;---------------------------------------
; FILENAME VERGLEICHEN (@: UND Ó:) +
; FASTSAVEROUTINE
;---------------------------------------
MAINSAVE LDY #$01
         JSR $DF80
         CMP #$2A    ; *
         BEQ MNS1
         CMP #$3F   ; ?
         BNE MNS2
MNS1     DEY
         JSR $DF80
         CMP #$3F
         BNE MNS2
         JSR FFIL2
MNS2     JSR FFIL1
         JSR PREP5
         BMI MNS3
         BIT $1F
         BMI MNS3
         LDY #$00
         JSR $DF80
         CMP #$40    ; @
         BNE MNS3
         LDA #$53    ; SCRATCH
         STA ($BB),Y
         JSR PSEL1C
         LDY #$00
         LDA #$40
         STA ($BB),Y
         BCS MNS4
         JSR FFIL2
MNS3     LDA #$61
         JSR PSEL1D
         BCC MNS5
MNS4     LDA #$85
MNS4A    STA $90
MNS4B    RTS
;---------------------------------------
MNS5     JSR $DFA5
         LDA #$61
         JSR LISVER1 ;LISTEN MIT SEC.1
         JSR LP126
         JSR $FFAE
         LDA $90
         BEQ MNS6
         LDA #$0A
         BNE MNS4A
MNS6     JSR IRQS1   ; ZP +IO SPEICHERN
         TXS
         JSR FLOP2X
         BNE MNS7
         JSR BANK0
         .BYTE $1B,$80 ;RAMCOPY $0400
;---------------------------------------
         JSR FLOP3X   ;RAMCOPY
MNS7     JSR PREP8V  ;PREPARE SAVE
         LDA $BF
         CMP #$FE
         BEQ MNS8
         JMP SM1   ;FASTSAVE WARP
;---------------------------------------
MNS8     LDY $1F
         BMI MNS10
         TXA
         JSR SENDB
MNS9     INY
         BNE MNS9
         BIT $DD00
         BVC MNS10
         JMP SM2       ;FASTSAVE WARP
MNS10    LDX #$04
MNS11    JSR LPRET
         JSR $0115
         TYA
         CLC
         ADC $AC
         STA $AC
         BCC MNS12
         INC $AD
MNS12    DEC $0200
         PHP
         JSR SFR     ;PAGE SENDEN
         LDX #$02
         PLP
         BNE MNS11
         LDA $AE
         STA $AC
         LDA $AF
         STA $AD
         LDA #$00
         JMP SM6    ;SET STATUS
;---------------------------------------
PREP8    LDX $BF
         JSR $FB8E
         CPX #$FE
         BNE PREP8A
         LDA $AC
         SBC #$02
         STA $AC
         BCS PREP8A
         DEC $AD
PREP8A   LDX #$01
PREP8B   LDA $AE
         SEC
         SBC $AC
         TAY
         LDA $AF
         SBC $AD
         BEQ PREP8E
PREP8C   LDA $AC
         CLC
         ADC $BF
         STA $AC
         BCC PREP8D
         INC $AD
PREP8D   INX
         BNE PREP8B
PREP8E   CPY $BF
         BEQ PREP8F
         BCS PREP8C
PREP8F   LDA $BF
         CMP #$F0
         BEQ PREP8G
         INY
         INY
PREP8G   JMP $FB8E
;---------------------------------------
PREP8V   LDX #$0E
         LDY $1F
         BMI PREP8X
         LDX #$00
         LDY #$05
         LDA $BF
         CMP #$F0
         BNE PREP8X
         LDY #$0F
PREP8X   JSR LP106   ;FLOPPYROUT SEND
         JSR PREP8
         STX $0200
         STY $0201
         LDA $C3
         STA $0202
         LDA $C4
         STA $0203
         LDY #$3F
PREP8Y   LDA FSST-1,Y;FASTSAVEKOPIERROUT
         STA $FF,Y   ;KOPIEREN
         DEY
         BNE PREP8Y
         STY $22
         LDA #$02
         STA $23
         RTS
;---------------------------------------
FSST     INC $01
         LDA ($AC),Y
         STA $29
         INY
         LDA ($AC),Y
         STA $2A
         INY
         LDA ($AC),Y
         STA $2B
         DEC $01
         JMP PREP9
;---------------------------------------
         INC $01
         LDY #$00
FSST2    LDA ($AC),Y
         STA $0200,X
         INY
         INX
         BNE FSST2
         DEC $01
         RTS
;---------------------------------------
;---------------------------------------
;  FLOPPY SAVEROUTINE 1541/71
X41S     = $0400-*
;---------------------------------------
FLOP1    LDA #$0A
         STA $32
         LSR A
         STA $31
         JSR $03A1
         JSR $0600
         JSR $03AC
         LDA ($30),Y
         BNE FLOP2
         LDX $0501
         DEX
         STX $81
         TYA
         STA $80
         BEQ FLOP3
FLOP2    LDA #$02
         JSR $DE41
         JSR $F121
FLOP3    LDY #$01
FLOP4    LDA $80,Y
         STA ($30),Y
         DEY
         BPL FLOP4
         JSR $0300
         INC $B6
         LDA $81
         STA $0B
         LDA $80
         CMP $0A
         BEQ FLOP1
         STA $0A
         LDA #$01
         BIT $03A7
         BPL FLOP5
         JMP $99B5
FLOP5    JMP $F418
;---------------------------------------
FLOP6A   LDX #$01
         STX $82
         STX $83
         JSR $036C
         TAX
         LDY $02FC
         BNE FLOP7
         DEX
         CPX $02FA
         BCC FLOP7
         STY $1800
         JMP $EB4B
FLOP7    JSR $03AC
         LDA #$05
         STA $0189
         LDA $03A7
         ASL A
         LDA #$08
         BCC FLOP8
         LDA #$06
FLOP8    STA $69
         LDX #$74
FLOP9    LDA $F574,X
         BCC FLOP10
         LDA $9774,X
FLOP10   STA $02FF,X
         LDA $0161,X
         STA $05FF,X
         DEX
         BNE FLOP9
         LDA #$60
         BCS FLOP11
         STA $0364
FLOP11   STA $0374
         JSR $DF93
         ASL A
         TAX
         LDA $06,X
         STA $0A
         LDA $07,X
         STA $0B
         BIT $03A7
         BPL FLOP12
         CLI
         JSR $D048
         LDA $0A
         STA $80
         LDA $0B
         STA $81
         JSR $EF90
FLOP12   LDA #$40
         STA $02F9
         LDA #$B0
         LDX #$02
         JSR $0387
         JSR $03AC
         CLI
FLOP13   LDA $0A
         BEQ FLOP14
         STA $08
         LDA #$E0
         STA $01
FLOP15   LDA $01
         BMI FLOP15
         CMP #$02
         BCC FLOP13
         LDX #$02
         JMP $E60A
FLOP14   LDX #$09
FLOP16   LDA FLOP17-1+X41S,X
         STA $0200,X
         DEX
         BNE FLOP16
         JMP $0201
;---------------------------------------
FLOP17   JSR $DBA5
         JSR $EEF4
         JMP $D227
;---------------------------------------
; SCHNELLE SAVE ROUTINE WARP
;---------------------------------------
SM1      LDX #$BA
         TXS
         JSR SFR   ;PAGE SENDEN
         LDA $0200
         STA $12
         JSR GETB
         BPL SM3
SM2      LDA #$55
         BNE SM6
SM3      STA $10
         JSR GETB
         STA $0F
         LDA $AC
         STA $0C
         LDA $AD
         STA $0D
         JSR FPRE1   ;SECTORSTART
         BNE SM5
SM4      JSR FSPD1   ;FREIEN SECTOR
SM5      JSR LPRET   ;RTS
         JSR PREP10  ;SENDZEIGER
         DEC $12
         BNE SM4
         LDA #$00
SM6      STA $90
         JSR FLOP2X
         BNE SM7
         JSR FLOP3X   ;RAMCOPY
         JSR BANK0
         .BYTE $1E,$80 ;RAMCOPY
;---------------------------------------
SM7      JMP IRQS2
;---------------------------------------
FLOP2X   LDX #$9F
         LDY #$00
         JSR $9FA2
         CMP #$41
         RTS
;---------------------------------------
FLOP3X   LDA #$04
         LDY #$84
         LDX #$06
         JSR BANK0
         .BYTE $12,$80 ;RAMCOPY $0400
;---------------------------------------
         RTS
;---------------------------------------
; FREIEN SECTOR SUCHEN
;---------------------------------------
FSPD1    LDY $11
         TYA
         DEY
         CLC
         ADC $0F
         CMP $13
         BCC LP406A
         CPY #$01
         BNE LP407
         AND #$01
         EOR #$01
         BPL LP406A
LP407    LDX $14
         INC $14
         LDA DATA3,X
LP406A   STA $0F
LP406    BNE LP227
LP228    INC $10
         LDA $10
         CMP #$12
         BEQ LP228
         LDA $AC
         LDX $AD
         CPY #$01
         BNE LP229
         JSR LP230
         BEQ LP231
LP229    LDY $13
         JSR LP232
LP231    STA $0C
         STX $0D
         BEQ FPRE1
LP227    LDX $AD
         LDA $AC
         CPY #$01
         BEQ LP230
         LDA $0F
         LSR A
         BCC LP233
         ADC #$08
         LDX $13
         CPX #$13
         ADC #$00
         CPX #$15
         ADC #$00
LP233    TAY
LP232    LDX $0D
         LDA $0C
LP230    CLC
         ADC #$F0
         BCC LP234
         INX
LP234    DEY
         BNE LP230
         STA $AC
         STX $AD
         RTS
;---------------------------------------
; SECTORENANZAHL
;---------------------------------------
LP235    LDX $10
         LDA #$00
         CPX #$12
         ADC #$00
         CPX #$19
         ADC #$00
         CPX #$1F
         ADC #$00
         TAX
         LDA DATA1,X
         STA $13
         RTS
;---------------------------------------
FPRE1    JSR LP235
         LDX $0F
         BNE FPRE2
         CMP $12
         LDA DATA2,X
         LDX #$07
         BCC FPRE3
FPRE2    LDX #$02
FPRE3    STA $14
         STX $11
         RTS
;---------------------------------------
DATA1    .BYTE $15,$13,$12,$11
DATA2    .BYTE $00,$07,$0E,$15
DATA3    .BYTE $01,$02,$03,$04
         .BYTE $05,$06,$00,$02
         .BYTE $04,$06,$01,$03
         .BYTE $05,$00,$03,$06
         .BYTE $02,$05,$01,$04
         .BYTE $00,$04,$01,$05
         .BYTE $02,$06,$03,$00
;---------------------------------------
PREP10   LDY #$00
         STY $22
         STY $15
         STY $2C
         INY
         STY $23
         LDA #$50
         STA $2E
         LDY #$BE
         STY $2D
PREP9C   LDY $2C
         JMP $0100
;---------------------------------------
; BYTE FUER WARP SAVE WANDELN
;---------------------------------------
PREP9    INY
         STY $2C
         LDY $2D
         LDA $29
         JSR PREP9A
         LDA $2A
         ASL $29
         ROL A
         ASL $29
         ROL A
         JSR PREP9A
         LDA $2A
         LSR $2B
         ROR A
         LSR $2B
         ROR A
         LSR A
         LSR A
         JSR PREP9A
         LDA $2B
         JSR PREP9A
         STY $2D
         DEC $2E
         BNE PREP9C
         LDX $15
         LDA FEL07,X
         STA ($22),Y
         INY
         STA ($22),Y
         LDA $0F
         STA $01BB
         LDA $10
         STA $01BC
         LDY #$01
         STY $23
         LDY #$BB
         JSR SFR1   ;REST SENDEN
         INC $23
         JMP SFR  ;PAGE SENDEN
;---------------------------------------
PREP9A   AND #$3F
         TAX
         EOR $15
         STX $15
         TAX
         LDA FEL07,X
         STA ($22),Y
         INY
         BNE PREP9B
         INC $23
PREP9B   RTS
;---------------------------------------
; WARP CODING TABELLE
;---------------------------------------
FEL07    .BYTE $49,$56,$4B,$5A
         .BYTE $99,$AA,$9B,$AD
         .BYTE $4E,$5D,$53,$65
         .BYTE $9E,$B2,$A6,$B5
         .BYTE $69,$76,$6B,$7A
         .BYTE $B9,$CE,$BB,$D3
         .BYTE $6E,$92,$73,$95
         .BYTE $C9,$D6,$CB,$DA
         .BYTE $4A,$59,$4D,$5B
         .BYTE $9A,$AB,$9D,$AE
         .BYTE $52,$5E,$55,$66
         .BYTE $A5,$B3,$A9,$B6
         .BYTE $6A,$79,$6D,$7B
         .BYTE $BA,$D2,$BD,$D5
         .BYTE $72,$93,$75,$96
         .BYTE $CA,$D9,$CD,$DB
;---------------------------------------
;---------------------------------------
; WARP FILE SAVE
XWF      = $0400-*
;---------------------------------------
WFVAL    LDA #$07
         JSR $037A
         LDX #$03
LP241    LDA $0700,X
         STA $C7,X
         DEX
         BPL LP241
         STX $02AF
         CLI
         JSR $D042
         SEI
         JSR LP247A+XWF
         LDX #$64
LP242    LDA $F574,X
         STA $02FF,X
         DEX
         BNE LP242
         LDA #$60
         STA $0364
LP243    LDA #$01
         STA $0189
         LDY #$BB
         JSR $0164
         LDA #$07
         JSR $037A
         LDA $01BB
         STA $0F
         LDA $01BC
         BEQ LP244
         STA $0E
         CMP $22
         BEQ LP245
         LDA #$B0
         STA $04
         CLI
LP246    LDA $04
         BMI LP246
LP245    SEI
         LDA #$55
         STA $01BB
         LDA #$D4
         STA $01BC
         LDA #$AD
         STA $01BD
         LDA $1C0C
         ORA #$0E
         STA $1C0C
         JSR $0314
         DEC $C7
         BNE LP243
LP244    CLI
         JSR $D042
         JMP $C194
;---------------------------------------
LP247A   LDA #$01
         STA $80
         LDA #$00
         STA $81
LP247    LDA $81
         STA $C1
         LDA $80
         STA $C0
         JSR LP59+XWF
LP248    JSR LP58+XWF
         PHP
         JSR LP51A+XWF
         PLP
         BEQ LP247
         DEC $C2
         BNE LP248
         LDA $C1
         STA $81
         LDA $C0
         STA $80
         JSR LP59+XWF
LP249    JSR LP58+XWF
         LDA ($6D),Y
         EOR $EFE9,X
         STA ($6D),Y
         LDY $6F
         LDA ($6D),Y
         SEC
         SBC #$01
         STA ($6D),Y
         JSR LP51A+XWF
         DEC $C2
         BNE LP249
         LDY #$00
         STY $0F
         JSR $0380
         LDA #$CA
         JSR LP50A+XWF
         LDA $C0
         JSR $03B8
         LDA $C1
         JSR $03B8
         LDY #$13
         LDA $C9
         STA ($6D),Y
         INY
         LDA $CA
         STA ($6D),Y
         INY
         LDA $C8
         STA ($6D),Y
         INY
         LDA #$FF
         STA ($6D),Y
         LDY #$1C
         LDA $C7
         STA ($6D),Y
         JMP $0380
;---------------------------------------
LP50A    PHA
         LDY $0261
         STY $0F
         JSR $0383
         LDA #$07
         STA $6E
         LDA $0267
         STA $6D
         LDY #$02
         LDA $C1
         STA ($6D),Y
         DEY
         LDA $C0
         STA ($6D),Y
         DEY
         PLA
         STA ($6D),Y
         TYA
         LDY #$1D
LP250    STA ($6D),Y
         DEY
         CPY #$13
         BNE LP250
         RTS
;---------------------------------------
LP51A    LDA $81
         CLC
         ADC #$02
         CMP $C3
         BCC LP251
         AND #$01
         EOR #$01
         BNE LP251
LP252    INC $80
         LDA $80
         CMP #$12
         BEQ LP252
         JSR LP60+XWF
         LDA #$00
LP251    STA $81
         CMP #$24
         BCC LP253
         JSR $03B6
         LDA #$72
         JMP $C1C8
;---------------------------------------
LP58     LDA $80
         ASL A
         ASL A
         TAY
         JMP $EFD2
;---------------------------------------
LP59     LDX $C7
         STX $C2
LP60     JSR $F24B
         STA $C3
LP253    RTS
;---------------------------------------
LP61     CLI
         JSR $D042
         LDA #$82
         LDX #$12
         LDY #$09
         STX $C0
         STY $C1
         JSR LP50A+XWF
LP254    JSR $0380
         JSR $036C
         STA $0F
         BEQ LP255
         LDA #$07
         JSR $037A
         BNE LP254
LP255    JMP LP244+XWF
;---------------------------------------
; SCRATCH WARP-FILES
;---------------------------------------
WFSCRT   LDA #$08
         STA $1800
         LDA #$0A
         STA $022A
         JSR $C1EE
         JSR $C398
         JSR $C320
         JSR $C3CA
         LDA #$00
         STA $86
         JSR $C49D
         BMI LP256
LP257    LDY #$00
         LDA ($94),Y
         AND #$0F
         CMP #$0A
         BEQ LP258
         JMP $C835
LP258    JSR $C8B6
         LDY #$01
         INC $86
         LDA ($94),Y
         STA $80
         INY
         LDA ($94),Y
         STA $81
         LDY #$1C
         LDA ($94),Y
         STA $C0
LP259    LDA $80
         JSR $F24B
         STA $C1
LP260    LDA $80
         ASL A
         ASL A
         TAY
         JSR $EFD2
         JSR $EF62
         DEC $C0
         BEQ LP261
         LDA $81
         CLC
         ADC #$02
         CMP $C1
         BCC LP262
         AND #$01
         EOR #$01
         BNE LP262
LP263    INC $80
         LDA $80
         CMP #$12
         BEQ LP263
         LDA #$00
LP262    STA $81
         BEQ LP259
         BNE LP260
LP261    LDA #$90
         LDX #$04
         STX $F9
         JSR $D57D
         JSR $D599
         JSR $C48B
         BPL LP257
LP256    JMP $C872
;---------------------------------------
;---------------------------------------
;  WARP LOADER SAVEN
;---------------------------------------
SVWL     JSR LISVER  ;LISTEN
         BCS SVWL1
         LDA #$44
         LDX #$30
         JSR LP126
         JSR $FFAE
         LDA #$06    ; "LOADER"
         LDX #$F8
         LDY #$DF
         JSR $FFBD
         JSR $F68F
         LDA #$61
         JSR PSEL1D
         JSR PRET
         JSR CGET1
         BCS SVWL1
         JSR $F642
         JSR BANK3
         .BYTE $39,$80
;---------------------------------------
         CLC
SVWL1    RTS
         RTS
;---------------------------------------
;LADEROUTINE FUER WARP-FILES
;---------------------------------------
         LDA #$08
         STA $1800
         LDA #$7A
         STA $1802
         LDA #$0A
         STA $022A
         JSR $C1EE
         JSR $C398
         JSR $C320
         JSR $C3CA
         JSR $C49D
         JSR $C194
         JSR $03A1
         LDY #$1F
FLR1     LDA ($94),Y
         JSR $03B8
         DEY
         DEY
         BPL FLR1
         LDY #$02
         LDA ($94),Y
         STA $0F
         DEY
         LDA ($94),Y
         STA $0E
         STY $1C
         DEY
         LDA ($94),Y
         CMP #$82
         PHP
         LDY #$1C
         LDA ($94),Y
         STA $8C
         INY
         LDA ($94),Y
         STA $8D
         LDX #$0C
FLR2     LDA $0364,X
         STA $01,X
         DEX
         BPL FLR2
         CLI
FLR3     LDA $01
         ORA $02
         ORA $03
         BMI FLR3
         JMP $0403
;---------------------------------------
         .BYTE $80,$80,$80,$00
         .BYTE $00,$00,$00,$12
         .BYTE $0E,$12,$11,$12
         .BYTE $03
;---------------------------------------
;---------------------------------------
;SCHNELLE UEBERTRAGUNG IN FLOPPY RAM
;PART2
;---------------------------------------
FEL99    TSX
         STX $033D
         DEY
         STY $02AF
         INY
         STY $11
         INY
         STY $1C
         LDA #$20
         STA $1C07
         JSR $C100
         SEI
         LDX $0205
         LDA #$04
         STA $0189
FLR4     JSR $0162
         INC $0189
         DEX
         BNE FLR4
         LDA $0208
         STA $03A7
         JMP ($0206)
;---------------------------------------
         JSR FLF15+X41L
FLR5     JSR $036C
         BMI FLR6
         STA $026C
         LDX #$45
         TXS
         JSR $03AC
         JMP $C194
FLR6     TAX
         JSR $0371
         STA $0E
         STA $08
         JSR $0371
         STA $09
         STA $0F
         TXA
         CMP #$E0
         BNE FLR7
         LDX #$01
         JSR $0387
         BCC FLR5
FLR7     CMP #$80
         BNE FLR8
         JMP $0600
FLR8     LDA #$B0
         JMP FLF14+X41L
;---------------------------------------
         LDY #$00
         STY $0189
         DEY
         JSR $0164
         LDA $FF
         STY $FF
         RTS
         STA $0189
         JMP $0162
;---------------------------------------
         LDA #$90
         .BYTE $2C
         LDA #$80
         LDX #$04
         STX $F9
         PHA
         LDA $11
         BNE FLR9
         LDA #$B0
         JSR $0396
FLR9     PLA
         STA $11
         SEI
         JSR $D57D
         JSR $03AC
         CLI
         JSR $D599
         SEI
         LDA $1801
         AND #$DF
FLR10    STA $1801
         CLC
         RTS
;---------------------------------------
         LDA #$20
         ORA $1801
         BNE FLR10
;---------------------------------------
         LDA #$00
         .BYTE $2C
         LDA #$FF
         STY $10
         TAY
         AND #$0F
         TAX
         TYA
         LSR A
         LSR A
         LSR A
         LSR A
         TAY
         LDA $03EF,X
         LDX #$00
         STX $1800
FLR11    LDX $1800
         BNE FLR11
         STA $1800
         ASL A
         AND #$0F
         STA $1800
         LDA $03EF,Y
         STA $1800
         ASL A
         AND #$0F
         STA $1800
         LDY $10
         LDA #$08
         INY
         STA $1800
         RTS
;---------------------------------------
         .BYTE $0F,$07,$0D,$05
         .BYTE $0B,$03,$09,$01
         .BYTE $0E,$06,$0C,$04
         .BYTE $0A,$02,$08,$00
;---------------------------------------
; FASTLOADROUTINE FLOPPY
X41L     = $0400-*
;---------------------------------------
FLFLR    JSR $03A1
         LDX $43
         STX $C3
         LDA #$07
         STA $31
         LDA #$FF
FLF1     STA $07DF,X
         DEX
         BNE FLF1
         LDA #$7F
         STA $C2
         LDA $43
         JSR $03B8
FLF2     DEC $C2
         BNE FLF4
FLF3     JMP FLF11+X41L
FLF4     LDX #$FF
         TXS
FLF5     DEX
         BEQ FLF3
         JSR $F556
         BVC *
         CLV
         LDA $1C01
         CMP $24
         BNE FLF5
         INY
FLF6     BVC FLF6
         CLV
         LDA $1C01
         STA ($30),Y
         INY
         CPY #$04
         BNE FLF6
         LDY #$02
         JSR $F82B
         LDX $54
         CPX $43
         BCS FLF2
         LDA $07E0,X
         BPL FLF2
         TXA
         STA $07E0,X
         JSR $F556
         LDY #$40
FLF7     BVC FLF7
         CLV
         LDA $1C01
         LSR A
         STA $0741,Y
         BVC *
         CLV
         LDA $1C01
         ROR A
         STA $0700,Y
         AND #$1F
         STA $063D,Y
         BVC *
         CLV
         LDA $1C01
         TAX
         ROR A
         LSR A
         LSR A
         LSR A
         STA $0782,Y
         BVC *
         CLV
         LDA $1C01
         STA $067E,Y
         ASL A
         TXA
         ROL A
         AND #$1F
         STA $06BF,Y
         BVC *
         CLV
         LDA $1C01
         PHA
         AND #$1F
         STA $05BF,Y
         DEY
         BPL FLF7
         LDX #$FF
         TXS
         LDX #$40
FLF8     LDA $0741,X
         LSR A
         ROR $0700,X
         LSR A
         STA $0741,X
         LDA $0700,X
         ROR A
         LSR A
         LSR A
         LSR A
         STA $0700,X
         LDA $067E,X
         LSR A
         ROR $01BF,X
         LSR A
         AND #$1F
         STA $067E,X
         LDA $01BF,X
         ROR A
         LSR A
         LSR A
         LSR A
         PHA
         DEX
         BPL FLF8
         LDA $54
         JSR $03B8
FLF9     LDA $1800
         LSR A
         BCS FLF9
         LDA #$00
         STA $1800
         NOP
         NOP
         LDA #$08
         STA $1800
         BIT $80
         LDA #$00
         STA $1800
         NOP
         LDA #$08
         STA $1800
         LDX #$3F
FLF9A    LDA #$00
         STA $1800
         LDY $0783,X
         LDA $060B,Y
         STA $1800
         ASL A
         AND #$0F
         STA $1800
         LDY $063E,X
         LDA $060B,Y
         STA $1800
         ASL A
         AND #$0F
         STA $1800
         LDY $067F,X
         LDA $060B,Y
         STA $1800
         ASL A
         AND #$0F
         STA $1800
         LDY $06C0,X
         LDA $060B,Y
         STA $1800
         ASL A
         AND #$0F
         STA $1800
         LDY $05C0,X
         LDA $060B,Y
         STA $1800
         ASL A
         AND #$0F
         STA $1800
         LDY $01C0,X
         LDA $060B,Y
         STA $1800
         ASL A
         AND #$0F
         STA $1800
         LDY $0700,X
         LDA $060B,Y
         STA $1800
         ASL A
         AND #$0F
         STA $1800
         LDY $0741,X
         LDA $060B,Y
         STA $1800
         ASL A
         AND #$0F
         STA $1800
         LDA #$08
         DEX
         BMI FLF10
         STA $1800
         JMP FLF9A+X41L
FLF10    STA $1800
         LDX $0782
         LDA $F8C0,X
         LDX $063D
         ORA $F8A0,X
         JSR $03B8
         DEC $C3
         BEQ FLF11
         JMP FLF4+X41L
FLF11    JSR $03B6
         JMP $F418
;---------------------------------------
FLF14    JSR $0385
         JSR $036C
         STA $8C
         JSR $036C
         STA $8D
         LDX #$03
         INC $0207
         LDA #$00
         STA $0206
         JMP $031A
;---------------------------------------
FLF15    LDX #$3C
FLF12    LDA FLF16+X41L,X
         STA $0600,X
         DEX
         BPL FLF12
         RTS
;---------------------------------------
FLF16    JSR $0383
         JSR $03B3
         LDY #$00
FLF13    LDA $0700,Y
         JSR $03B8
         BNE FLF13
         JMP $0334
;---------------------------------------
         .BYTE $FF,$0E,$0F,$07
         .BYTE $FF,$0A,$0B,$03
         .BYTE $FF,$FF,$0D,$05
         .BYTE $FF,$00,$09,$01
         .BYTE $FF,$06,$0C,$04
         .BYTE $FF,$02,$08,$FF
;---------------------------------------
; LANGSAMERER FASTLOAD FLOPPYROUT+WARP
XLF      = $0400-*
;---------------------------------------
SLFLR    JMP WFR+XLF
         LDA #$B0
         JSR $0385
         PLP
         BNE SLFLR
         LDA $0E
         STA $18
         LDA $0F
         STA $19
SLFLR1   LDA $1C07
         LDY #$01
         STY $1C05
         STA $1C07
         LDA $18
         LDX $19
SLL1     STA $0E
         STX $0F
         JSR $0383
         LDY #$FF
         LDA $0700
         BNE SLL2
         LDY $0701
SLL2     DEY
         STY $C0
         TYA
         JSR $03B8
         LDY #$02
SLL3     LDA $0700,Y
         JSR $03B8
         DEC $C0
         BNE SLL3
         LDX $0701
         LDA $0700
         BNE SLL1
         JSR $03B8
         JSR $03AC
         CLI
         RTS
;---------------------------------------
;     WARP FLOPPY ROUTINE
;---------------------------------------
WFR      JSR WFR15+XLF
WFRA     JSR WFR9A+XLF
         LDA #$00
         STA $1800
         NOP
         NOP
         LDA #$08
         STA $1800
         BIT $80
         LDA #$00
         STA $1800
         NOP
         LDA #$08
         STA $1800
         LDY #$50
WFR1     LDA #$00
         STA $1800
         LDX $0146,Y
         STX $1800
         LDA WFR14A+XLF,X
         STA $1800
         ASL A
         AND #$0F
         STA $1800
         LDX $0700,Y
         STX $1800
         LDA WFR14A+XLF,X
         STA $1800
         ASL A
         AND #$0F
         STA $1800
         LDX $0751,Y
         STX $1800
         LDA WFR14A+XLF,X
         STA $1800
         ASL A
         AND #$0F
         STA $1800
         LDX $07A2,Y
         STX $1800
         LDA WFR14A+XLF,X
         STA $1800
         ASL A
         AND #$0F
         STA $1800
         LDA #$08
         STA $1800
         DEY
         BPL WFR1
         LDA $0196
         BNE WFR4
         LDA $0F
         CLC
         ADC #$02
         CMP $15
         BCC WFR2
         AND #$01
         EOR #$01
         BEQ WFR6
WFR2     STA $0F
         LDA $8C
WFR2A    BNE WFR3
         DEC $8D
WFR3     DEC $8C
         LDA $8C
         ORA $8D
         BNE WFR5
WFR4     JMP $EB4B
WFR5     JMP WFRA+XLF
;---------------------------------------
WFR6     LDX #$02
WFR7     LDA $1C00
         SEC
         ROL A
         AND #$03
         EOR $1C00
         STA $1C00
         LDY #$0A
WFR8     LDA #$C7
         SEC
WFR8A    SBC #$01
         BCS WFR8A
         DEY
         BNE WFR8
         DEX
         BNE WFR7
         INC $0E
         INC $22
         LDA $0E
         CMP #$12
         BEQ WFR6
         JSR WFR15+XLF
         LDA #$00
         BEQ WFR2
;---------------------------------------
WFR8D    .BYTE $15,$13,$12,$11
WFR8E    .BYTE $60,$40,$20,$00
         .BYTE $00
         .BYTE $01,$02,$FF,$03
         .BYTE $04,$FF,$FF,$FF
         .BYTE $05,$06,$FF,$07
         .BYTE $08,$FF,$FF,$09
         .BYTE $0A,$0B,$FF,$0C
         .BYTE $0D,$FF,$FF,$FF
         .BYTE $FF,$FF,$FF,$0E
         .BYTE $0F,$FF,$FF,$20
         .BYTE $21,$22,$FF,$23
         .BYTE $24,$FF,$FF,$FF
         .BYTE $25,$26,$FF,$27
         .BYTE $28,$FF,$FF,$29
         .BYTE $2A,$2B
;---------------------------------------
WFR8C    CPX #$1F
         ADC #$00
         TAY
         LDA $1C00
         AND #$9F
         ORA WFR8E+XLF,Y
         STA $1C00
         LDA WFR8D+XLF,Y
         STA $15
         RTS
;---------------------------------------
         .BYTE $2C,$2D,$FF,$2E
         .BYTE $2F,$FF,$FF,$40
         .BYTE $41,$42,$FF,$43
         .BYTE $44,$FF,$FF,$FF
         .BYTE $FF,$FF,$FF,$45
         .BYTE $46,$FF,$FF,$47
         .BYTE $48,$49,$FF,$4A
         .BYTE $4B,$FF,$FF,$FF
         .BYTE $4C,$4D,$FF,$4E
         .BYTE $4F,$FF,$FF,$60
         .BYTE $61,$62,$FF,$63
         .BYTE $FF,$FF,$FF,$FF
         .BYTE $FF,$FF,$FF,$FF
         .BYTE $FF,$FF,$FF,$64
         .BYTE $65,$66,$FF,$67
         .BYTE $68,$FF,$FF,$FF
         .BYTE $69,$6A,$FF,$6B
         .BYTE $6C,$FF,$FF,$6D
         .BYTE $6E,$6F
;---------------------------------------
WFR9A    LDA $1C0C
         ORA #$0E
         STA $1C0C
         LDA #$03
         STA $8F
WFR9     JSR WFR13A+XLF
         BCS WFR12A
         LDX #$03
WFR10    BVC WFR10
         CLV
         LDA $1C01
         LDA #$00
         DEX
         BNE WFR10
         LDY #$4F
WFR11    BVC WFR11
         CLV
         LDX $1C01
         EOR WFR2A+XLF,X
         STA $0146,Y
         BVC *
         CLV
         LDX $1C01
         EOR WFR2A+XLF,X
         STA $0700,Y
         BVC *
         CLV
         LDX $1C01
         EOR WFR2A+XLF,X
         STA $0751,Y
         BVC *
         CLV
         LDX $1C01
         EOR WFR2A+XLF,X
         STA $07A2,Y
         DEY
         BPL WFR11
         BVC *
         CLV
         LDX $1C01
         EOR WFR2A+XLF,X
         BEQ WFR12
         DEC $8F
         BPL WFR9
WFR12A   LDA #$6F
WFR12    STA $0196
         STA $0750
         STA $07A1
         STA $07F2
         LDA $1C0C
         AND #$FD
         STA $1C0C
         RTS
;---------------------------------------
WFR13A   LDA #$07
         STA $31
WFR13    JSR SYNC+XLF
         BVC *
         CLV
         LDA $1C01
         CMP $24
         BNE WFR13
         INY
WFR14    BVC WFR14
         CLV
         LDA $1C01
         STA ($30),Y
         INY
         CPY #$04
         BNE WFR14
         LDY #$02
         JSR $F82B
         LDX $54
         CPX $0F
         BNE WFR13
         BEQ SYNC
;---------------------------------------
WFR14A   .BYTE $00
         .BYTE $01,$00,$01,$02
         .BYTE $03,$02,$03,$00
         .BYTE $01,$00,$01,$02
         .BYTE $03,$02,$03
;---------------------------------------
SYNC     LDX #$64
SYNC1    LDA $1C00
         BPL SYNC2
         DEY
         BNE SYNC1
         DEX
         BNE SYNC1
         SEC
         RTS
;---------------------------------------
         .BYTE $04,$04,$05,$04
         .BYTE $05,$06,$07,$06
         .BYTE $07,$04,$05,$04
         .BYTE $05,$06,$07,$06
         .BYTE $07
;---------------------------------------
SYNC2    LDA $1C01
         CLV
         LDY #$00
         CLC
         RTS
;---------------------------------------
         .BYTE $09,$08,$09,$0A
         .BYTE $0B,$0A,$0B,$08
         .BYTE $08,$09,$08,$09
         .BYTE $0A,$0B,$0A,$0B
         .BYTE $08,$09,$08,$09
         .BYTE $0A,$0B,$0A,$0B
;---------------------------------------
WFR15    LDX $0E
         LDA #$00
         CPX #$12
         ADC #$00
         CPX #$19
         ADC #$00
         JMP WFR8C+XLF
;---------------------------------------
         .BYTE $FF
         .BYTE $0C,$0D,$0C,$0D
         .BYTE $0E,$0F,$0E,$0F
         .BYTE $0C,$0D,$0C,$0D
         .BYTE $0E,$0F,$0E,$0F
;---------------------------------------
;  FLOPPYROUTINE 1581 LOAD
X81L     = $0500-*
;---------------------------------------
FLOP81   SEI
         LDA #$D8
         STA $4001
         LDA $4C
         LDX $028B
FZ1      STA $0B
         JSR FZ5A+X81L
         LDA $0300
         BNE FZ2
         LDY $0301
FZ2      STY $10
         DEY
         TYA
         JSR FZ11A+X81L
         LDY #$02
FZ3      LDA $0300,Y
         JSR FZ11A+X81L
         BNE FZ3
         LDX $0301
         LDA $0300
         BNE FZ1
         JSR FZ11A+X81L
FZ5      CLI
         RTS
;---------------------------------------
FZ5A     STX $0C
         LDX #$00
         LDA #$80
         JSR $FF54
         LDY #$FF
         LDA $02
         CMP #$02
         RTS
;---------------------------------------
FZ5B     JSR FZ13A+X81L
FZ6      JSR FLOP81A+X81L
         TAX
         BEQ FZ5
         STX $0B
         LDX #$00
FZ7      JSR FZ5A+X81L
         BCS FZ8
         INY
FZ8      TYA
         JSR FZ11A+X81L
         LDY #$00
         STY $10
FZ9      LDA $0300,Y
         JSR FZ11A+X81L
         BNE FZ9
         LDX $0C
         INX
         CPX #$28
         BNE FZ7
         BEQ FZ6
;---------------------------------------
FZ11A    STY $11
         TAY
         AND #$0F
         TAX
         TYA
         LSR A
         LSR A
         LSR A
         LSR A
         TAY
         LDA FZ12X+X81L,X
         TAX
         LDA #$D0
         STA $4001
         LDA #$01
FZ10     BIT $4001
         BNE FZ10
         STX $4001
         TXA
         ASL A
         AND #$0F
         PHA
         PHA
         STA $4001
         PLA
         PLA
         LDA FZ12X+X81L,Y
         STA $4001
         ASL A
         AND #$0F
         PHA
         LDY $11
         INY
         STA $4001
         PLA
         LDA #$D8
         DEC $10
         NOP
         STA $4001
         RTS
;---------------------------------------
FZ12X    .BYTE $0F,$07,$0D,$05
         .BYTE $0B,$03,$09,$01
         .BYTE $0E,$06,$0C,$04
         .BYTE $0A,$02,$08,$00
;---------------------------------------
FLOP81A  LDA #$D0
         STA $4001
         LDA #$01
FZ11     BIT $4001
         BNE FZ11
         PHA
         PLA
         PHA
         PLA
         LDA $4001
         ASL A
         PHA
         PLA
         NOP
         NOP
         BIT $02
         ORA $4001
         ASL A
         ASL A
         ASL A
         ASL A
         STA $BD
         PHA
         PLA
         NOP
         NOP
         NOP
         NOP
         NOP
         LDA $4001
         ASL A
         PHA
         PLA
         BIT $02
         NOP
         NOP
         ORA $4001
         AND #$0F
         ORA $BD
         LDX #$D8
         STX $4001
         RTS
;---------------------------------------
FZ12A    LDY #$00
FZ12     JSR FLOP81A+X81L
         STA $0400,Y
         INY
         BNE FZ12
         RTS
;---------------------------------------
FZ13A    SEI
         LDY #$D8
         STY $4001
FZ13     DEY
         NOP
         BNE FZ13
         RTS
;---------------------------------------
FZ14A    JSR FZ13A+X81L
FZ14     JSR FLOP81A+X81L
         BMI FZ16
         STA $0D
         LDX #$00
FZ15     STX $0E
         JSR FZ12A+X81L
         LDA #$90
         LDX #$01
         JSR $FF54
         LDX $0E
         INX
         CPX #$28
         BNE FZ15
         BEQ FZ14
FZ16     CLI
         RTS
;---------------------------------------
FZ16A    JSR FZ13A+X81L
         LDA $A9
         AND #$0F
         TAX
         STX $50
         LDA $D1,X
         ASL A
         TAY
         LDA #$01
         STA $D1,X
         LDA $0B,Y
         STA $0D
         LDA $0C,Y
         STA $0E
         LDA #$80
         STA $6D
FZ17     JSR FZ12A+X81L
         LDA $0400
         BEQ FZ19
         JSR FZ19A+X81L
         LDA $02A9
         BNE FZ18
         DEC $02AA
FZ18     DEC $02A9
         LDY $4D
         STY $0400
         STX $0401
         LDA #$90
         LDX #$01
         JSR $FF54
         STY $0D
         LDX $0401
         STX $0E
         LDX $50
         INC $0249,X
         BNE FZ17
         INC $0250,X
         BNE FZ17
FZ19     LDA $0401
         STA $BD
         LDA $022B
         STA $19
         STA $1B
         LDA #$90
         STA $09
         STA $0A
         CLI
         RTS
;---------------------------------------
FZ19A    LDA $0D
         STA $4D
         LDA #$03
         STA $40
FZ20     LDX #$0A
         LDA $4D
         CMP #$29
         BCC FZ21
         SBC #$28
         INX
FZ21     ASL A
         STA $31
         ASL A
         ADC $31
         ADC #$0A
         STA $31
         STX $32
         LDY #$00
         LDA ($31),Y
         BNE FZ26
         LDA $4D
         LDX $022B
         CMP $022B
         BEQ FZ23
         BCC FZ24
         INC $4D
         LDA $4D
         CMP $022C
         BCC FZ20
         DEX
         STX $4D
         CPX $90
         BCC FZ25
FZ22     DEC $40
         BNE FZ20
FZ23     LDA #$72
         JSR $FF3F
FZ24     DEC $4D
         LDA $4D
         CMP $90
         BCS FZ20
FZ25     INX
         STX $4D
         BNE FZ22
FZ26     INY
FZ27     LDA ($31),Y
         BNE FZ28
         INY
         CPY #$06
         BCC FZ27
         LDA #$71
         JSR $FF3F
FZ28     PHA
         DEY
         TYA
         ASL A
         ASL A
         ASL A
         TAX
         LDA #$01
         STA $4E
         PLA
FZ29     LSR A
         BCS FZ30
         ASL $4E
         INX
         BNE FZ29
FZ30     INY
         LDA ($31),Y
         EOR $4E
         STA ($31),Y
         STX $4E
         LDY #$00
         LDA ($31),Y
         SEC
         SBC #$01
         STA ($31),Y
         RTS
;---------------------------------------
;---------------------------------------
;FASTFORMAT
XFO      = $0400-*
;---------------------------------------
FFORM    JSR FFO6A+XFO
         INC $08
         LDA $08
         CMP $06
         BCS FFO1
         JMP $F978
FFO1     JMP $F418
;---------------------------------------
FFO1A    STX $08
         LDA #$24
         STA $06
         LDA $0200,Y
         STA $12
         STA $16
         LDA $0201,Y
         STA $13
         STA $17
         SEI
         LDA $22
         BNE FFO2
         LDA #$C0
         STA $02
FFO2     LDA #$E0
         STA $01
         CLI
FFO3     LDA $01
         BMI FFO3
         RTS
;---------------------------------------
FFO3A    LDA #$20
         STA $0208
         JSR $C1E5
         BNE FFO4
         JMP $C1F3
FFO4     STY $027A
         LDA #$A0
         JSR $C268
         JSR $C100
         LDY $027B
         CPY $0274
         BNE FFO5
         JMP $EE46
FFO5     LDX #$00
         STX $07
         INX
         JSR FFO1A+XFO
         JSR $D042
         JMP $EE56
;---------------------------------------
FFO5A    LDX #$64
FFO6     LDA $F574,X
         STA $02FF,X
         DEX
         BNE FFO6
         LDA #$20
         STA FFO17A+XFO
         LDA #$60
         STA $0364
         JSR $036C
         TAX
         JSR FFO20A+XFO
         LDY #$09
         JSR FFO1A+XFO
         JMP $C194
;---------------------------------------
FFO6A    LDA #$07
         STA $31
         LDY #$00
         TYA
FFO7     STA ($30),Y
         INY
         BNE FFO7
         DEY
         STY $0701
         STY $3A
         JSR $F78F
         LDA #$CE
         STA $1C0C
         LDA #$FF
         STA $1C03
         STA $1C01
         LDA #$00
         STA $C2
         STA $C0
         LDA $22
         STA $18
FFO8     LDA $C2
         STA $19
         EOR $16
         EOR $17
         EOR $18
         STA $1A
         JSR $F934
         LDX #$00
         LDY $C0
FFO9     LDA $24,X
         STA $0600,Y
         INY
         INX
         CPX #$08
         BNE FFO9
         STY $C0
         INC $C2
         LDA $C2
         CMP $43
         BNE FFO8
         LDA #$00
         STA $C0
FFO10    LDA #$FF
         STA $1C01
         LDX #$05
FFO11    BVC FFO11
         CLV
         DEX
         BNE FFO11
         LDX #$08
         LDY $C0
FFO12    BVC FFO12
         CLV
         LDA $0600,Y
         STA $1C01
         INY
         DEX
         BNE FFO12
         STY $C0
         LDX #$0B
FFO13    BVC FFO13
         CLV
         LDA #$55
         STA $1C01
         DEX
         BNE FFO13
         LDX #$05
FFO14    BVC FFO14
         CLV
         LDA #$FF
         STA $1C01
         DEX
         BNE FFO14
         LDY #$BB
FFO15    BVC FFO15
         CLV
         LDA $0100,Y
         STA $1C01
         INY
         BNE FFO15
FFO16    BVC FFO16
         CLV
         LDA ($30),Y
         STA $1C01
         INY
         BNE FFO16
         LDX #$08
FFO17    BVC FFO17
         CLV
         LDA #$55
         STA $1C01
         DEX
         BNE FFO17
         BVC *
         DEC $C2
         BNE FFO10
FFO17A   JMP $FE00
;---------------------------------------
         LDA $08
         CMP $07
         BNE FFO23
         LDA $43
         STA $C0
FFO18    JSR $036C
         STA $0A
         LDA #$07
         JSR $037A
         JSR $F5E9
         STA $3A
         JSR $F78F
FFO19    LDA $0A
         ASL A
         ASL A
         ASL A
         TAX
         JSR $F556
         LDY #$08
FFO20    BVC FFO20
         CLV
         LDA $1C01
         CMP $0600,X
         BNE FFO19
         INX
         DEY
         BNE FFO20
         JSR $0317
         DEC $C0
         BNE FFO18
FFO20A   JSR $036C
         BEQ FFO21
         BPL FFO22
         LDA #$24
FFO21    STA $06
FFO22    STA $07
FFO23    RTS
;---------------------------------------
;---------------------------------------
; WARP LADEROUTINE (BASICANFANG)
;---------------------------------------
         .BYTE $01,$08,$3A,$08
         .BYTE $0A,$00,$9C,$3A
         .BYTE $9E,$32,$31,$30
         .BYTE $38,$3A,$9F,$32
         .BYTE $2C,$38,$2C,$32
         .BYTE $2C,$22,$23,$30
         .BYTE $22,$3A,$9F,$31
         .BYTE $2C,$38,$2C,$31
         .BYTE $35,$2C,$22,$42
         .BYTE $2D,$45,$20,$32
         .BYTE $20,$30,$20,$31
         .BYTE $38,$20,$36,$20
         .BYTE $22,$3A,$A0,$32
         .BYTE $3A,$9E,$32,$31
         .BYTE $31,$31,$00,$00
         .BYTE $00
;---------------------------------------
         JMP $087D
;---------------------------------------
         LDA #$16
         LDX #$00
         LDY #$10
         JSR $FFBD
         LDA #$0F
         STA $B9
         JSR $F3D5
         JSR $81D5
         LDY #$00
         STY $1F
         INY
         STY $AE
         LDA #$08
         STA $AF
         PHA
         LDA #$0C
         PHA
         LDY #$1F
WBL1     JSR $8188
         STA $20,Y
         DEY
         BPL WBL1
         AND #$0F
         CMP #$02
         BEQ WBL2
         LDA #$0B
         STA $D011
         JMP $0334
;---------------------------------------
WBL2     JMP SLLD
;---------------------------------------
         LDY #$00
WBL3     LDA $09FB,Y
         STA $8124,Y
         LDA $0AF9,Y
         STA $8300,Y
         LDA $08C6,Y
         STA $1000,Y
         INY
         BNE WBL3
         STY $0205
         JSR $81F4
         JSR $08CC
WBL4     JSR $A560
         LDA $0205
         CMP #$22
         BNE WBL4
         LDY #$00
         STY $93
         STY $1F
WBL5     CPY #$10
         BEQ WBL8
         LDA $0206,Y
         CMP #$22
         BNE WBL6
         TAX
WBL6     CPX #$22
         BNE WBL7
         LDA #$A0
WBL7     STA $1006,Y
         INY
         BNE WBL5
WBL8     RTS
;---------------------------------------
         .BYTE $4D,$2D,$45,$01
         .BYTE $03,$3A
;---------------------------------------
; DIRECTORY
;---------------------------------------
DIR      LDA #$24
         STA $22
         LDA #$01
         LDX #$22
         LDY #$00
         STY $C6
         JSR $FFBD
         LDY #$60
         LDX $BA
         CPX #$08
         BCS DIR1
         LDX #$08
DIR1     JSR $FFBA
         JSR $F3D5
         LDA $BA
         JSR $FFB4
         LDA $B9
         JSR $FF96
         LDX #$03
DIR2     JSR $FFA5
         STA $C3
         JSR $FFA5
         STA $C4
         LDY $90
         BNE DIR6
         DEX
         BNE DIR2
         LDX $C3
         TAY
         JSR $BDCD
         LDA #$20
DIR3     JSR $E716
         LDX $90
         BNE DIR6
         JSR $FFA5
         BNE DIR3
         LDA #$0D
         JSR $E716
         JSR $FFE4
         BEQ DIR5
         CMP #$03
         BEQ DIR6
DIR4     JSR $FFE4
         BEQ DIR4
DIR5     LDX #$02
         CMP #$03
         BNE DIR2
DIR6     JMP $F642
;---------------------------------------
; ZEIGER AUF FLOPPYROUT
;---------------------------------------
DATA10   .WORD GETFLR
         .BYTE $50,$01,$50,$01,$02
         ;
         .WORD FLOP81
         .BYTE $00,$05,$00,$05,$09
         ;
         .WORD FLOP81A
         .WORD FLOP81A+X81L
         .WORD FZ16A+X81L
         .BYTE $0C
         ;
         .WORD WFSCRT
         .BYTE $00,$03,$00,$03,$05
         ;
         .WORD FLOP81A
         .WORD FLOP81A+X81L
         .WORD FZ14A+X81L
         .BYTE $0C
         ;
         .WORD FLOP81
         .BYTE $00,$05
         .WORD FZ5B+X81L
         .BYTE $09
;---------------------------------------
DATA11   .WORD FLFLR
         .BYTE $02,$31,$03
         ;
         .WORD FLOP1
         .BYTE $02
         .WORD FLOP6A+X41S
         ;
         .WORD FFORM
         .BYTE $02
         .WORD FFO3A+XFO
         ;
         .WORD WFVAL
         .BYTE $02,$00,$04
         ;
         .WORD FFORM
         .BYTE $02
         .WORD FFO5A+XFO
         ;
         .WORD WFVAL
         .BYTE $02
         .WORD LP61+XWF
         ;
         .WORD SLFLR
         .BYTE $01
         .WORD SLFLR1+XLF
;---------------------------------------

