

         *= $8000

;---------------------------------------
; BANK3
;---------------------------------------

TSTFBR   = $89D1
CMDBR    = $82AB
BROUT    = $9009

;---------------------------------------
         .BYTE $09,$80
         .BYTE $0C,$80
;---------------------------------------
         .BYTE $C3,$C2,$CD,$38,$30
;---------------------------------------
         JMP TOOLKIT
         JMP RES
         JMP MAINROUT
FILCOP   JMP FILCOPR
         JMP SLSAVE
         JMP SLSAVE1
         JMP HARDCOPY
         JMP CHDISKN
UTILITY  JMP UTILR
         JMP FRZROUT
FTAPEL   JMP FLDTAPE
         JMP TSVTAPE
         JMP DISKSAVE
         JMP SOURMES ; INSERT SOURCE
         JMP DESTMES ; INSERT DEST
BACKDISK JMP BACKRM  ; BACKUP
         JMP WARPS   ; WARPSAVE
;---------------------------------------
DISKSAVE JSR BANK2
         .BYTE $09,$81
;---------------------------------------
         RTS
;---------------------------------------
RES      JSR $F6BC
         JSR $F6ED
         BEQ RESA
         JMP $FE72
RESA     LDX #$FB
         TXS
         JSR BANK1
         .BYTE $0C,$80 ;RESET WARMSTART
;---------------------------------------
; SAVE PRG
;---------------------------------------
SAVEPD   JSR BANK2
         .BYTE $03,$81
;---------------------------------------
         RTS
;---------------------------------------
; SAVE PRG OHNE ADRESSEN SETZEN
;---------------------------------------
         JSR BANK2
         .BYTE $09,$81
;---------------------------------------
         RTS
;---------------------------------------
; DEVICE NOT PRESENT
;---------------------------------------
         JSR BANK2
         .BYTE $0C,$81
;---------------------------------------
         RTS
;---------------------------------------
; DISK FORMAT
;---------------------------------------
FORMAT   LDA #$4E   ;N:
         STA $033C
         LDA #$3A
         STA $033D
         JSR PRINTM
;
         .TEXT "DISK-NAME:"
         .BYTE $A0
;---------------------------------------
         LDX #$0B
         LDY #$1A
         JSR BANK0
         .BYTE $5D,$80 ;GET NAME
;---------------------------------------
         BNE FORMAT2
         JMP MAINROUT
FORMAT2  STA $FB
         TAY
         DEY
FORMAT3  LDA ($BB),Y
         STA $033E,Y
         DEY
         BPL FORMAT3
         JSR PRINTM
;
         .TEXT "ID-NUMMER:"
         .BYTE $A0
;---------------------------------------
         LDX #$0B
         LDY #$0C
         JSR BANK0
         .BYTE $5D,$80 ;GET NAME
;---------------------------------------
         LDX $FB
         TAY
         BEQ FORMAT5
         LDA #$2C
         STA $033E,X
         INX
         LDY #$00
FORMAT4  LDA ($BB),Y
         STA $033E,X
         INX
         INY
         CPY #$02
         BNE FORMAT4
FORMAT5  INX
         INX
         TXA
         LDX #$3C
         LDY #$03
         JSR $FFBD
         LDA #$00
         STA $9D
FORMAT6  JSR BANK2
         .BYTE $0F,$81 ;COMMAND EXECUTE
;---------------------------------------
         JSR $FFAE
         JMP TASTMES  ;TASTE
;---------------------------------------
;---------------------------------------
RAMINIT  LDA #$00
         STA $B7
         BEQ FORMAT6
RAMIN1   LDY #$20
RAMIN2   LDA $FD2F,Y
         STA $0313,Y
         DEY
         BNE RAMIN2
         TYA
RAMIN3   STA $02,Y
         INY
         BNE RAMIN3
         LDY #$59
RAMIN4   STA $0200,Y
         INY
         CPY #$A7
         BNE RAMIN4
         LDA #$3C
         STA $B2
         LDA #$03
         STA $B3
         LDA #$A0
         STA $0284
         LDA #$08
         STA $0282
         LSR A
         STA $0288
         RTS
;---------------------------------------
PRINTX3  LDX #$03
PRINTC   JSR SETCUR ;CURSOR
PRINTM   PLA
         STA $8E
         PLA
         STA $8F
         STX $8D
PRINTM1  LDY #$00
         INC $8E
         BNE PRINTM2
         INC $8F
PRINTM2  LDA ($8E),Y
         BEQ PRINTM4
         CMP #$01
         BNE PRINTM3
         LDX $D6
         INX
         LDY #$0A
         JSR SETCUR
         BNE PRINTM1
PRINTM3  PHP
         AND #$7F
         JSR $FFD2
         PLP
         BPL PRINTM1
PRINTM4  LDA $8F
         PHA
         LDA $8E
         PHA
         LDX $8D
         RTS
;---------------------------------------
; ANFANG-,ENDEDRESSE
;---------------------------------------
SSTW     LDA $0336
         STA $AE
         LDA $0337
         STA $AF
         LDX #$01
         STX $C1
         LDY #$08
         STY $C2
         LDA $0338
         STA $BD
         JMP $FB8E
;---------------------------------------
ACTMES   SEI
         JSR $FDA3
         JSR RAMIN1 ;RAM INITIALIZE
         JSR $FF5B
         JSR $E453
         JSR $E3BF
         LDA #$03
         STA $2D
         LDA #$08
         STA $2E
         LDA #$80
         STA $9D
         LDA #$37
         STA $01
         STA $C0
         LDX #$01
         LDY #$0B
         JSR PRINTC
;
         .BYTE $05
         .TEXT "ACTION CARTRIDGE "
         .BYTE $AB
;---------------------------------------
         LDX #$02
         LDY #$0B
         JSR SETCUR ;CURSOR
         LDX #$11
         LDA #$A3
ACTMES1  JSR $FFD2
         DEX
         BPL ACTMES1
         LDX #$30
         LDY #$DF
         STX $0302
         STY $0303
         RTS
;---------------------------------------
; FREEZROUTINE
;---------------------------------------
FRZROUT  LDX #<FRZMEN
         LDY #>FRZMEN
         BNE UTILR1
;---------------------------------------
; UTILITYROUTINE
;---------------------------------------
UTILR    LDX #<UTILMEN
         LDY #>UTILMEN
UTILR1   STX $033A
         STY $033B
         SEI
         LDX #$FB
         TXS
         CLD
         LDX $BA
         CPX #$08
         BEQ UTILR2
         CPX #$09
         BEQ UTILR2
         LDX #$08
UTILR2   STX $0339
         LDA $AE
         STA $0336
         LDA $AF
         STA $0337
         JSR ACTMES ;BILDKOPF AUSGEBEN
MAINROUT SEI
         LDX #$FB
         TXS
         CLD
         STX $CC
         JSR ACTMES
         JSR $A660
         LDA $0339
         STA $BA
         JMP ($033A)
;---------------------------------------
;---------------------------------------
FRZMEN   JSR SSTW
         LDY #$0E
         JSR PRINTX3
;
         .BYTE $12
         .TEXT "FREEZE MENUE"
         .BYTE $8D
;---------------------------------------
         JSR PBLOCK  ;BLOCKS PRINT
         LDX #<FRZMES
         LDY #>FRZMES
         LDA #$08
FRZMEN1  JSR NORMMES ;PRINT
         JMP MAINROUT
;---------------------------------------
;---------------------------------------
UTILMEN  LDY #$0D
         JSR PRINTX3
;
         .BYTE $12
         .TEXT "UTILITY MENUE "
         .BYTE $8D
;---------------------------------------
         LDX #<UTILMES
         LDY #>UTILMES
         LDA #$18
         BNE FRZMEN1
;---------------------------------------
;---------------------------------------
PDIR     JSR BANK2
         .BYTE $18,$81 ;DIR
;---------------------------------------
TASTMES  JSR PRINTM
;
         .BYTE $0D
         .TEXT "TASTE BITTÅ"
;---------------------------------------
TASTMES1 LDA #$00
         STA $C6
TASTMES2 JSR $FF9F
         JSR $FFE4
         BEQ TASTMES2
         RTS
;---------------------------------------
; BAND DIASCHOW
;---------------------------------------
DIASHOW  JSR $E544
         JSR PRINTM
;
         .TEXT "BAND DIA-SHOW"
         .BYTE $1D,$0D,$0D
         .TEXT "SPACE FUER NAECHSTES "
         .TEXT "BILD  "
         .BYTE $0D,$0D
         .TEXT "BAND EINLEGEN UND "
         .TEXT "PLAY DRUECKEN !"
         .BYTE $A0
;---------------------------------------
DIASH1   LDA #$00
         STA $B7
         TAX
         LDY #$40
         JSR FTAPEL ;LOAD
         LDA #$FF
         LDX #$00
         LDY #$60
         JSR FTAPEL ;LOAD
         LDA #$40
         LDY #$20
         LDX #$20
         JSR DIASH3 ;COPY RAM
         LDA #$60
         LDY #$04
         LDX #$04
         JSR DIASH3 ;COPY RAM
         LDA #$64
         LDY #$D8
         LDX #$04
         JSR DIASH3 ;COPY RAM
         LDA $5F7F
         STA $D020
         LDA $5F80
         STA $D021
         LDA #$D8
         STA $D016
         LDA #$1D
         STA $D018
         LDA #$3B
         STA $D011
         CLI
         LDA #$7F
         STA $DC00
DIASH2   LDA $DC00
         AND $DC01
         AND #$10
         BNE DIASH2
         BEQ DIASH1
;---------------------------------------
DIASH3   STA $23
         STY $25
         LDY #$00
         STY $22
         STY $24
DIASH4   LDA ($22),Y
         STA ($24),Y
         INY
         BNE DIASH4
         INC $23
         INC $25
         DEX
         BNE DIASH4
         RTS
;---------------------------------------
;---------------------------------------
; TAPE TRANSFORMER
;---------------------------------------
TATRANS  JSR TATRMES ;MENUE PRINT
TATR1    JSR TATR4   ;LOAD
         BCS TATR5
         LDA #$00
         STA $C1
         LDX #$08
         STX $C2
         CPX $BA
         BCC TATR2
         STX $BA
TATR2    JSR TATR3   ;SAVE
         JMP TATR1
;---------------------------------------
TATR3    JMP ($0332)
;---------------------------------------
TATR4    JSR $F817
         BCC TATR6
TATR5    RTS
TATR6    LDX #$41
         LDY #$03
         JSR $FFBD
         LDA $FB
         BNE NOVA
         LDA #$00
         STA $90
         STA $93
         STA $0A
         JSR $F72C
         BCS TATR5
         LDX #$00
         LDY #$08
         STX $C3
         STY $C4
         STX $90
         SEC
         JSR $F57D ;LOAD
         BCS TATR5
         LDY #$01
         LDA ($B2),Y
         STA $C3
         INY
         LDA ($B2),Y
         STA $C4
         LDY #$10
TATR7    LDA $0340,Y
         CMP #$20
         BNE TATR8
         DEY
         BNE TATR7
TATR8    STY $B7
         CLC
         RTS
;---------------------------------------
; NOVALOAD
;---------------------------------------
NOVA     SEI
         LDA #$0B
         STA $D011
         LDX #$07
         STX $01
         LDA #$00
         STA $C0
         STX $AF
         INX
         STX $AD
         SEI
         LDA #$F4
         STA $DC04
         LDA #$81
         STA $DC05
         LDA #$05
         LDY #$00
         STY $A6
         STY $A5
         STY $AE
         STY $AC
NOVA1    JSR NOVA11
         BPL NOVA1
         JSR NOVA10
         CMP #$AA
         BNE NOVA1
         JSR NOVA10
         STA $B7
         BEQ NOVA3
NOVA2    JSR NOVA9
         STA ($BB),Y
         INY
         CPY $B7
         BNE NOVA2
NOVA3    LDY #$FA
NOVA4    JSR NOVA9
         STA $FFC7,Y
         INY
         BNE NOVA4
NOVA5    JSR NOVA9
         CMP $A5
         BNE NOVA
         LDA $C6
         BEQ NOVA7
         INC $AF
         DEC $C6
         BNE NOVA6
         LDA $C5
         BEQ NOVA7
         STA $A6
NOVA6    JSR NOVA9
         STA ($AE),Y
         INY
         CPY $A6
         BNE NOVA6
         BEQ NOVA5
NOVA7    STY $AE
NOVA8    DEX
         BNE NOVA8
         DEY
         BNE NOVA8
         JSR $FF84
         LDA #$37
         STA $01
         STA $C0
         INC $C2
         CLI
         LDA #$1B
         STA $D011
         LDY #$00
         STY $C6
         LDA $C1
         STA $C3
         LDA $C2
         STA $C4
         CLC
         RTS
;---------------------------------------
NOVA9    CLC
         LDA $A5
         ADC $AA
         STA $A5
NOVA10   LDA #$7F
NOVA11   PHA
         INC $D020
         LDX #$11
         LDA #$10
NOVA12   BIT $DC0D
         BEQ NOVA12
         LDA $DC05
         STX $DC0E
         EOR #$80
         ASL A
         PLA
         ROR A
         BCS NOVA11
         STA $AA
         RTS
;---------------------------------------
; TAPE TRANSFER MENU
;---------------------------------------
TATRMES  LDA #<TRANSM
         LDY #>TRANSM
         JSR $AB1E
         LDA #$80
         STA $9D
TATM1    JSR TASTMES1
         CMP #$85
         BNE TATM3
         LDX #$05
TATM2    LDA $0438,X
         EOR #$80
         STA $0438,X
         DEX
         BPL TATM2
         BMI TATM1
TATM3    CMP #$86
         BNE TATM5
         LDX #$09
TATM4    LDA $0488,X
         EOR #$80
         STA $0488,X
         DEX
         BPL TATM4
         BMI TATM1
TATM5    CMP #$87
         BNE TATM1
         LDA #$80
         STA $0333 ;SAVE VECTOR
         STA $9D
         LDA #$2D
         BIT $0438
         BMI TATM6
         LDA #$18
TATM6    STA $0332 ;VECTOR
         LDA $0488
         AND #$80
         STA $FB
         RTS
;---------------------------------------
TRANSM   .BYTE $93,$11,$1D
         .TEXT "F1: DISK TURBO "
         .BYTE $12
         .TEXT "AN "
         .BYTE $92
         .TEXT "AUS"
         .BYTE $0D,$0D
         .TEXT " F3: FILE-ART   "
         .BYTE $12
         .TEXT "NOVA "
         .BYTE $92
         .TEXT "STD."
         .BYTE $0D,$0D
         .TEXT " F5: TRANSFER-START"
         .BYTE $0D,$0D,$0D,$00
;---------------------------------------
;---------------------------------------
NORMMES  STX $AE
         STY $AF
         STA $AD
         JSR PDEV1  ;DEVICE
         LDX #$05
         LDY #$0A
         JSR PRINTC
;
         .TEXT "F1:"
         .BYTE $1D
         .TEXT "FLOPPY-NR.:"
         .BYTE $01
         .TEXT "F2:"
         .BYTE $1D
         .TEXT "DOSBEFEHL"
         .BYTE $01
         .TEXT "F3:"
         .BYTE $1D
         .TEXT "DIRECTORY"
         .BYTE $01
         .TEXT "F5:"
         .BYTE $1D
         .TEXT "NEW"
         .BYTE $1D
         .TEXT "DISK"
         .BYTE $1D,$01
         .TEXT "F7:"
         .BYTE $1D
         .TEXT "LOADER"
         .BYTE $1D
         .TEXT "SPEICHERN"
         .BYTE $01,$00
;---------------------------------------
         LDA #$41
         STA $AB
         LDY #$00
NRMM1    STY $FB
         LDX $D6
         INX
         CMP #$20
         BNE NRMM2
         INX
NRMM2    LDY #$06
         JSR SETCUR  ;CURSOR
         LDA $AB
         INC $AB
         JSR $FFD2
         JSR PRINTM
;
         .BYTE $20,$2D,$A0
;---------------------------------------
         LDY $FB
NRMM3    LDA ($AE),Y
         BEQ NRMM4
         PHP
         AND #$7F
         JSR $FFD2
         INY
         PLP
         BPL NRMM3
         BNE NRMM1
NRMM4    JSR TASTMES1
         CMP #$85
         BNE NRMM5
         JSR PDEV
         BCC NRMM4
NRMM5    LDX #$00
         CMP #$86
         BEQ NRMM6
         LDX #$02
         CMP #$87
         BEQ NRMM6
         LDX #$04
         CMP #$88
         BEQ NRMM6
         LDX #$06
         CMP #$89
         BEQ NRMM6
         CMP #$41
         BCC NRMM4
         CMP $AB
         BCS NRMM4
         SEC
         SBC #$41
         ASL A
         CLC
         ADC $AD
         TAX
NRMM6    LDA JPTAB+1,X
         PHA
         LDA JPTAB,X
         PHA
         JSR SSTW
         LDX #$16
         LDY #$00
SETCUR   CLC
         JMP $FFF0
;---------------------------------------
FRZMES   .TEXT "DISK SAVE - TURBÏ"
         .TEXT "DISK SAVE - STANDARD"
         .BYTE $A0
         .TEXT "TURBO-TAPE"
         .BYTE $1D
         .TEXT "SAVE "
         .BYTE $A0
         .TEXT "TAPE SAVE - SUPERTURBO"
         .BYTE $A0
         .TEXT "PROGRAMM STARTEÎ"
         .TEXT "EXIT -> UTILITÙ"
         .TEXT "EXIT -> TOOLKIT-SYSTEM "
         .BYTE $00
;---------------------------------------
         .BYTE $1D
         .BYTE $1D,$1D,$1D,$1D
         .BYTE $1D,$1D,$1D,$1D
         .BYTE $1D,$1D,$1D,$00
;---------------------------------------
UTILMES  .TEXT "DISK FILECOPÙ"
         .TEXT "DISK BACKUÐ"
         .TEXT "NOVA-DISK-TRANSFEÒ"
         .TEXT "BAND DIA-SHO×"
         .TEXT "->"
         .BYTE $1D
         .TEXT "TOOLKIT-SYSTEM"
         .BYTE $1D,$1D,$1D,$1D
         .BYTE $20,$20,$20,$00
;---------------------------------------
JPTAB    .WORD PDIR-1   ;DIRECTORY
         .WORD FORMAT-1 ;FORMAT
         .WORD SWLOAD-1  ;LOADER SAVEN
         .WORD DOSCOM-1 ;DOSCOMMAND
;---------------------------------------
         .WORD DSAVT-1   ;TURBODISK
         .WORD DSAVN-1   ;NORMALDISK
         .WORD TSAVT-1   ;TURBOTAPE
         .WORD TSAVST-1  ;SUPERTURBOTAPE
         .BYTE $0C,$08  ;PRG STARTEN
         .WORD UTILITY-1
         .WORD TOOLKIT-1
         .WORD TOOLKIT-1
;---------------------------------------
         .WORD COPYFIL-1
         .WORD BACKDISK-1
         .WORD TATRANS-1
         .WORD DIASHOW-1
         .WORD TOOLKIT-1
;---------------------------------------
; FILECOPY
;---------------------------------------
COPYFIL  JSR FILCOP
         JSR PRET
         JMP RAMINIT
;---------------------------------------
;   SLOWSAVE
;---------------------------------------
SLSAVE   LDA $C1
         STA $C3
         LDA $C2
         STA $C4
SLSAVE1  JSR BANK3
         .BYTE $8F,$F6
;---------------------------------------
         JSR $FB8E
         LDA #$61
         STA $B9
         JSR $DFC3
         BCS TSX1
         LDA $BA
         JSR $FFB1
         LDA $B9
         JSR $FF93
         LDA $C3
         JSR $FFA8
         LDA $C4
         JSR $FFA8
SLSAVE2  JSR $FCD1
         BCS SLSAVE4
         SEI
         LDY #$07
SLSAVE3  LDA RGET1-1,Y
         STA $A4,Y
         DEY
         BNE SLSAVE3
         JSR $A5
         JSR $FFA8
         JSR $FCDB
         BNE SLSAVE2
SLSAVE4  JMP $F63F
;---------------------------------------
;VERSCHIEDENE SAVE ROUT FUER FREEZER PRG
;---------------------------------------
DSAVT    LDA #$80   ;DISKTURBO
         .BYTE $2C
         LDA #$00   ;NORMAL DISK
         .BYTE $2C
TSAVT    LDA #$40   ;TURBO TAPE
         .BYTE $2C
TSAVST   LDA #$C0   ;SUPERTURBO
         STA $0338
         STA $BD
         JSR FILENAM ;GET NAME
         BIT $BD
         BVC TSX2
         JSR TSTKER  ;KERNAL MIT CASS?
         JSR TSTWAIT ;TASTE
         JSR SSTW    ;ADRESSE
         LDA $BD
         STA $BA
         LDX $AC
         LDY $AD
         JSR FSVTAPE ;SAVE
TSX1     RTS
;---------------------------------------
TSX2     LDA $BD
         BNE TSX3
         LDY $B7
         LDA #$2C
         STA ($BB),Y
         INY
         LDA #$57
         STA ($BB),Y
         INY
         STY $B7
TSX3     JSR SAVEPD  ;DISKSAVE
         JSR PRET
         JMP RAMINIT
;---------------------------------------
;
; SAVE WARP LOADER
;---------------------------------------
SWLOAD   JSR BANK2
         .BYTE $15,$81
;---------------------------------------
         JMP TASTMES  ;TASTE
;---------------------------------------
; GET FILENAME
;---------------------------------------
FILENAM  JSR BANK0
         .BYTE $57,$80
;---------------------------------------
         BNE PRET
         JMP MAINROUT
;---------------------------------------
PRET     LDA #$0D
         JMP $FFD2
;---------------------------------------
; DOS BEFEHL
;---------------------------------------
DOSCOM   JSR PRINTM
;
         .TEXT "DOS-BEFEHL   =>"
         .BYTE $A0
;---------------------------------------
         LDX #$10
         LDY #$38
         JSR BANK0
         .BYTE $5D,$80 ;GET COMMAND
;---------------------------------------
         PHP
         JSR BANK2
         .BYTE $0F,$81 ;SEND COMM
;---------------------------------------
         PLP
         BEQ TSTKER1
         JMP RAMINIT
;---------------------------------------
; TEST KERNEL
;---------------------------------------
TSTKER   LDA $F86C
         CMP #$38
         BEQ CHDEV3
         JSR PRINTM
;
         .BYTE $0D
         .TEXT "ROM FALSCÈ"
;---------------------------------------
         PLA
         PLA
TSTKER1  JMP TASTMES
;---------------------------------------
; DEVICE AENDERN
;---------------------------------------
CHDEV    LDX $BA
         CPX #$08
         BCS CHDEV1
         LDX #$07
CHDEV1   INX
         CPX #$0A
         BCC CHDEV2
         LDX #$08
CHDEV2   STX $BA
         STX $0339
CHDEV3   RTS
;---------------------------------------
; PRINT DEVICE
;---------------------------------------
PDEV     JSR CHDEV
PDEV1    LDX #$05
         LDY #$1D
         JSR SETCUR
         LDA $BA
         CLC
         ADC #$30
         JMP $FFD2
;---------------------------------------
; JMP TOOLKIT
;---------------------------------------
TOOLKIT  JSR BANK1
         .BYTE $09,$80
;---------------------------------------
; RAM GET BYTE
;---------------------------------------
RGET1    INC $01
         LDA ($AC),Y
         DEC $01
         RTS
;---------------------------------------
; BLOCK AUSGEBEN
;---------------------------------------
PBLOCK   LDX #$0A
         LDY #$1F
         JSR PRINTC
;
         .TEXT "BLOCK"
         .BYTE $D3
;---------------------------------------
         LDY #$80
PBLO1    DEX
         BNE PBLO1
         DEY
         BNE PBLO1
         LDA #$FE
         LDX #$0B
         JSR PBLO2
         LDA $BF
         PHA
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         LDX #$0C
         LDY #$20
         JSR SETCUR ;CURSOR
         PLA
         TAX
         CPX #$CB
         BCC PBLO3
         INX
         BNE PBLO3
PBLO2    LDY #$20
         STA $BF
         JSR SETCUR
         LDX $BF
         JSR BANK2
         .BYTE $21,$81
;---------------------------------------
         STX $BF
PBLO3    LDA #$00
         JMP $BDCD
;---------------------------------------
; BANK UMSCHALTROUTINE
;---------------------------------------
BANK0    NOP
BANK1    NOP
BANK2    NOP
         NOP
         NOP
BANK3    NOP
         SEI
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
         BNE BANK3A
         DEC $9F
BANK3A   DEC $9E
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
; NORMALSAVE DISK FREEZER
;---------------------------------------
DSAVN    JSR FILENAM  ;GET
         LDY #$B9
DSAN1    LDA DSANR-1,Y
         STA $0346,Y
         DEY
         BNE DSAN1
         JSR $0347
         JSR PRET
         JMP RAMINIT
;---------------------------------------
DSANR    LDA $AF
         SEC
         SBC #$D0
         BCC DSANR1
         TAX
         STX $FD
         INX
         STX $03CA
         JSR $0388
         LDA $AE
         CLC
         ADC #$50
         STA $AE
         LDA $FD
         ADC #$08
         STA $AF
         JSR $0372
         JSR $0388
         JSR $03F1
         LDY #$D0
         BNE DSANR2
;---------------------------------------
DSANR1   LDX $AE
         LDY $AF
DSANR2   LDA #$01
         STA $AC
         LDA #$08
         STA $AD
         LDA #$AC
         DEC $01
         JSR $FFD8
         INC $01
         RTS
;---------------------------------------
         LDY #$3A
DSANR3   LDA $080C,Y
         PHA
         LDA $03C5,Y
         STA $080C,Y
         PLA
         STA $03C5,Y
         DEY
         BNE DSANR3
         LDA #$47
         STA $22
         LDA #$08
         STA $23
         LDA #$D0
         STA $25
         STY $24
         SEI
         LDX $FD
         INX
         INC $01
DSANR4   LDA ($22),Y
         PHA
         LDA ($24),Y
         STA ($22),Y
         PLA
         STA ($24),Y
         INY
         BNE DSANR4
         INC $23
         INC $25
         DEX
         BNE DSANR4
         DEC $01
         RTS
;---------------------------------------
         SEI
         INC $01
         LDX #$20
         LDY #$00
DSANR5   LDA $0847,Y
         STA $D000,Y
         INY
         BNE DSANR5
         INC $0816
         INC $0819
         DEX
         BNE DSANR5
         DEC $01
         JSR $0838
         INY
         STY $B9
         LDA #$08
         PHA
         LDA #$0C
         PHA
         TXA
         JMP $FFD5
;---------------------------------------
; FILENAME BEI 2ÆILES
;---------------------------------------
         LDA $BB
         BNE DSANR6
         DEC $BC
DSANR6   DEC $BB
         INC $B7
         LDA #$31
         STA ($BB),Y
         RTS
;---------------------------------------
; DISKNAME AENDERN
;---------------------------------------
CHDISKN  JSR BANK2
         .WORD TSTFBR ;FLOPPYTEST
;---------------------------------------
         BEQ CHDN7
         PHP
         LDA #$12
         LDX #$90
         PLP
         BPL CHDN1
         LDA #$28
         LDX #$04
CHDN1    STA $FB
         STX $FC
         JSR CHDN6 ;COPY RAM
         LDA $BC
         PHA
         LDA $BB
         PHA
         LDA $B7
         PHA
         LDA $FB
         LDY #$00
         LDX #$0F
         STX $FD
         JSR BANK1
         .BYTE $27,$80 ;LOAD SECTOR
;---------------------------------------
         PLA
         STA $B7
         PLA
         STA $BB
         PLA
         STA $BC
         JSR BANK2
         .WORD CMDBR ;STATUS
         BCS CHDN6
         LDY #$00
CHDN2    LDA ($BB),Y
         CPY $FE
         BCS CHDN3
         CPY $B7
         BCC CHDN4
CHDN3    LDA #$A0
CHDN4    STA ($FC),Y
         INY
         CPY #$14
         BNE CHDN2
         LDY $FE
         BMI CHDN5
         INY
         LDA ($BB),Y
         TAX
         INY
         LDA ($BB),Y
         LDY #$13
         STA ($FC),Y
         DEY
         TXA
         STA ($FC),Y
CHDN5    LDA $FB
         LDY #$00
         LDX #$0F
         JSR BANK1
         .BYTE $2A,$80 ;SAVE SECT
;---------------------------------------
CHDN6    LDA #$9A
         LDY #$0F
         LDX #$01
         JSR BANK0
         .BYTE $12,$80 ;RAM COPY $0F00
;---------------------------------------
CHDN7    RTS
;
;---------------------------------------
; FASTTAPE-ROUTINEN
;---------------------------------------
TSTWAIT  JMP WTAST
;---------------------------------------
TSVTAPE  JMP FTSV2A ;FREEZER TAPESAVE
;---------------------------------------
FSVTAPE  JMP FTSAVE
;---------------------------------------
FLDTAPE  JMP FTLOAD
;---------------------------------------
FTLOAD   STX $B4
         STY $B5
         STA $B0
         TSX
         STX $97
         LDX #$0D
         SEI
FTLD1    LDA RGET3-1,X
         STA $0100,X
         DEX
         BNE FTLD1
         LDA #$7F
         STA $DD0D
         STA $DC0D
         STA $DC00
         LDA #$07
         STA $01
         STA $C0
         LDA #$D0
         STA $DD06
         INX
         STX $DD07
         LDX #$19
         STX $DD0F
FTLD2    JSR GTPB3
         BCS FTLD2
         JSR GTPB
         CMP #$52   ;STARTWERT
         BNE FTLD2
         JSR GTPB
         CMP #$42
         BNE FTLD2
         LDY #$05
FTLD3    JSR GTPB
         STA $AA,Y
         DEY
         BNE FTLD3
         CMP $B0
         BNE FTLD2
         STY $90
         JSR GTPB
         STA $B0
         CMP $B7
         BEQ FTLD4
         CPY $B7
         BNE FTLD2
FTLD4    CPY $B0
         BEQ FTLD6
         JSR GTPB
         CMP ($BB),Y  ;FILENAME
         BEQ FTLD5
         LDA $B7
         BNE FTLD2
FTLD5    INY
         BNE FTLD4
FTLD6    JSR GTPB     ;GET
         JSR $0101    ;PUT
         EOR $90
         STA $90
         INC $B4
         BNE FTLD7
         INC $B5
FTLD7    INC $AE
         BNE FTLD6
         INC $AF
         BNE FTLD6
         JSR GTPB
         EOR $90
         STA $90
         JMP FTSV6
;---------------------------------------
GTPB     LDA #$80
         STA $B6
GTPB2    JSR GTPB3
         ROR $B6
         BCC GTPB2
         LDA $B6
         RTS
;---------------------------------------
GTPB3    LDA #$10
GTPB4    BIT $DC01
         BPL GTPB5
         BIT $DC0D
         BEQ GTPB4
         LDA $DD0D
         STX $DD0F
         LSR A
         LSR A
         INC $D020
         RTS
;---------------------------------------
GTPB5    LDX $97
         TXS
         JMP FTSV6
;---------------------------------------
FTSAVE   JSR TWI
         LDY #$51
FTSV1    LDA TPSTR1-1,Y
         STA $FF,Y
         DEY
         BNE FTSV1
         STY $B7
         LDA $90
         STA $AB
         JSR WRTPST
         LDA #$D0
         BIT $BA
         BPL FTSV2
         LDA #$11
         JSR WRTB1
         JSR WRTB1
         LDA #$05
         JMP $0100
;---------------------------------------
FTSV2    JSR WRTB1
         JSR WRTB1
         BEQ FTSV3
FTSV2A   STA $AB
         JSR TWI
         JSR WRTPST
FTSV3    JSR $4E   ;GET
         JSR WRTB1 ;WRITE
         INC $B4
         BNE FTSV4
         INC $B5
FTSV4    INC $AE
         BNE FTSV3
         INC $AF
         BNE FTSV3
         LDA $90
         JSR WRTB1
FTSV5    JSR WRTB1
FTSV6    LDA #$37
         STA $01
         STA $C0
         CLC
         SEI
         LDA #$10
         ORA $D011
         STA $D011
         RTS
;---------------------------------------
RGET2    LDA #$04
         STA $01
         LDA ($AC),Y
         LDX #$07
         STX $01
         RTS
;---------------------------------------
RGET3    LDY #$04
         STY $01
         LDY #$00
         STA ($B4),Y
         LDY #$07
         STY $01
         RTS
;---------------------------------------
; TAPE STARTBYTES SCHREIBEN
;---------------------------------------
WRTPST   LDA #$0B
         STA $D011
         LDA #$7F
         STA $DC0D
         LDA $DC0D
         LDA #$07
         STA $01
         STA $C0
         LDA #$04
WRTPST1  DEY
         BNE WRTPST1
         DEX
         BNE WRTPST1
         SBC #$01
         BNE WRTPST1
         LDA #$82
         STY $DC06
         STA $DC07
         LDA #$19
         STA $DC0F
WRTPST2  LDA #$FF
         JSR WRTB1
         DEY
         BNE WRTPST2
         LDA #$7F
         JSR WRTB1
         LDA #$52   ;STARTWERTE
         JSR WRTB1
         LDA #$42
         JSR WRTB1
         LDY #$05
WRTPST3  LDA $AA,Y
         JSR WRTB1
         DEY
         BNE WRTPST3
         LDA $B7
         JSR WRTB1
WRTPST4  CPY $B7
         BEQ WRTPST5
         LDA ($BB),Y  ;FILENAME
         JSR WRTB1
         INY
         BNE WRTPST4
WRTPST5  LDY #$00
         RTS
;---------------------------------------
WRTB1    STA $B6
         LDX #$08
WRTB2    LSR $B6
WRTB3    LDA #$80
         BCC WRTB4
         ASL A
WRTB4    STA $DC06
         BCC WRTB5
         ORA #$82
WRTB5    STA $DC07
WRTB6    BIT $DC07
         BMI WRTB6
         LDA #$19
         STA $DC0F
         LDA $01
         EOR #$08
         STA $01
         CLC
         AND #$08
         BNE WRTB3
         DEX
         STX $D020
         BNE WRTB2
         RTS
;---------------------------------------
; STARTWERT SETZEN
;---------------------------------------
TWI      SEI
         TXA
         PHA
         TYA
         PHA
         LDY #$0B
TWI1     LDA RGET2-1,Y
         STA $4D,Y
         DEY
         BNE TWI1
         LDA $AC
         STA $B4
         LDA $AD
         STA $B5
         LDY #$00
         STY $90
TWI2     JSR $4E
         EOR $90
         STA $90
         JSR $FCDB
         JSR $FCD1
         BCC TWI2
         LDA #$B4
         STA $53
         LDA $AE
         SEC
         SBC $B4
         EOR #$FF
         STA $AE
         LDA $AF
         SBC $B5
         EOR #$FF
         STA $AF
         INC $AE
         BNE TWI3
         INC $AF
TWI3     PLA
         STA $AD
         PLA
         STA $AC
         RTS
;---------------------------------------
TPSTR1   STA $01
TPSTR1A  DEC $01
         LDA ($B4),Y
         INC $01
         STA $B6
         LDX #$08
TPSTR1B  LSR $B6
TPSTR1C  LDA #$40
         BCC TPSTR1D
         LDA #$FF
TPSTR1D  STA $DC06
TPSTR1E  BIT $DC07
         BMI TPSTR1E
         LDA #$19
         STA $DC0F
         LDA $01
         EOR #$08
         STA $01
         CLC
         AND #$08
         BNE TPSTR1C
         DEX
         STX $D020
         BNE TPSTR1B
         INC $B4
         BNE TPSTR1F
         INC $B5
TPSTR1F  INC $AE
         BNE TPSTR1A
         INC $AF
         BNE TPSTR1A
         LDA #$37
         STA $01
         JMP FTSV5
;---------------------------------------
; WRITE TAPE AUTOSTART (FREEZER)
;---------------------------------------
WTAST    JSR $F7D7
         LDY #$AE
WTAST1   LDA TPLDR-1,Y
         STA $0350,Y
         DEY
         BNE WTAST1
         LDY #$0F
WTAST2   LDA TPLDA,Y
         STA ($C1),Y
         LDA ($BB),Y
         STA $0341,Y
         DEY
         BPL WTAST2
         LDA #$69
         JSR $F869
         LDX #<TPATST ;START
         LDY #>TPATST
         STX $C1
         STY $C2
         LDX #<TPLDR ;ENDE
         LDY #>TPLDR
         STX $AE
         STY $AF
         LDA #$14
         JSR $F869
         JMP FTSV6
;---------------------------------------
TPLDA    .BYTE $03,$F0,$02,$04,$03
;---------------------------------------
TPATST   SEI
         JSR $FD15
         JSR $E453
         LDA #$7F
         STA $DC0D
         SEI
         JMP $0351
;---------------------------------------
         .BYTE $F0,$02
         .BYTE $F0
         .BYTE $02
;---------------------------------------
TPLDR    LDA #$0B
         STA $D011
         LDA #$05
         STA $01
         STA $C0
TPLDR1   DEY
         BNE TPLDR1
         DEX
         BNE TPLDR1
         LDA #$D0
         INY
         STA $DD06
         STY $DD07
         LDX #$19
         STX $DD0F
         LDA $DC0D
         LDA $DD0D
TPLDR2   JSR $03E8
         BCS TPLDR2
         JSR $03DA
         CMP #$52
         BNE TPLDR2
         JSR $03DA
         CMP #$42
         BNE TPLDR2
         LDY #$05
TPLDR3   JSR $03DA
         STA $AA,Y
         DEY
         BNE TPLDR3
         STY $90
         JSR $03DA
         JSR $03DA
         STA $DD06
         JSR $03DA
TPLDR4   JSR $03DA
         DEC $01
         STA ($AC),Y
         EOR $90
         STA $90
         INC $01
         INC $AC
         BNE TPLDR5
         INC $AD
TPLDR5   INC $AE
         BNE TPLDR4
         INC $AF
         BNE TPLDR4
         LDA #$37
         STA $01
         STA $C0
         LDA #$1B
         STA $D011
         JSR $FF84
         LDA $AB
         EOR $90
         CLI
         BEQ TPLDR6
         LDX #$1D
         JMP $A437
TPLDR6   JMP $E37B
;---------------------------------------
         LDA #$80
         STA $B6
TPLDR7   JSR $03E8
         ROR $B6
         BCC TPLDR7
         LDA $B6
         RTS
;---------------------------------------
TPLDR8   LDA #$10
         BIT $DC0D
         BEQ TPLDR8
         LDA $DD0D
         STX $DD0F
         LSR A
         LSR A
         INC $D020
         RTS
;---------------------------------------
; HARDCOPY
;---------------------------------------
HARDCOPY TAY
         SEI
         LDX #$3F
HDC1     LDA $90,X
         PHA
         DEX
         BPL HDC1
         TYA
         STA $93
         LSR A
         BCS HDC2
         INX
HDC2     LDA #$00
         STA $DD03
         STA $DC0E
         STX $DC0C
         LDA #$7F
         STA $DC00
         LDA #$3F
         STA $DD02
         LDA $DD00
         AND #$03
         STA $92
         CMP #$02
         BCS HDC4
         LDA $DD00
         AND #$FC
         ORA #$02
         STA $DD00
         LDY #$80
         LDA $92
         BNE HDC3
         LDY #$C0
HDC3     JSR COPMEM ; BEREICH > $4000
HDC4     LDA #$70
         STA $00
         JSR UH1
         LDA #$37
         STA $01
         LDA #$2F
         STA $00
         LDA $DD00
         AND #$FC
         ORA $92
         STA $DD00
         LDY #$C0
         LDA $92
         BEQ HDC5
         CMP #$02
         BCS HDC6
         LDY #$80
HDC5     JSR COPMEM ;ORIGINALBEREICH
HDC6     LDX #$00
HDC7     PLA
         STA $90,X
         INX
         CPX #$40
         BNE HDC7
         LDA #$01
         STA $DC0E
         RTS
;---------------------------------------
; RAMCOPYROUTINE FUER HARDCOPY
;---------------------------------------
COPMEM   LDX #$1E
COPMEM1  LDA COPMR,X
         STA $98,X
         DEX
         BPL COPMEM1
         STY $B4
         LDX #$40
         LDY #$00
         SEI
         JMP $98
;---------------------------------------
COPMR    INC $01
COPMR1   LDA ($B1),Y
         PHA
         LDA ($B3),Y
         STA ($B1),Y
         PLA
         STA ($B3),Y
         INY
         BNE COPMR1
         INC $B2
         INC $B4
         DEX
         BNE COPMR1
         DEC $01
         RTS
;---------------------------------------
         .BYTE $00,$40,$00,$80
;---------------------------------------
;
; UNTERROUTINE HARDCOPY
;---------------------------------------
UH1      LDX #$00
         STX $A3
         STX $94
         LDA $93
         BPL UH2
         DEX
UH2      STX $91
         LSR A
         BCS UH3
         JMP XH1 ;MPS
;---------------------------------------
; EPSON + COMPATIBLE
;---------------------------------------
UH3      LDA #$67
         JSR SOPEN
         LDA $90
         BPL UH4
         RTS
UH4      LDA $D011
         AND #$20
         STA $C7
         LDA $D016
         AND #$10
         ASL A
         STA $AC
         LDX #$00
         STX $C1
         STX $C3
         STX $CE
         LDA $DD00
         AND #$03
         EOR #$03
         LSR A
         ROR A
         ROR A
         STA $CC
         LSR A
         LSR A
         STA $C8
         LDA $D018
         TAX
         AND #$F0
         LSR A
         LSR A
         ORA $CC
         JSR HUX1  ;WERTE SETZEN
         AND #$08
         ORA $C8
         LSR A
         LDY $C7
         BNE UH5
         TXA
         AND #$0E
         ORA $C8
         LSR A
         CMP #$02
         BCC UH5
         CMP #$04
         BCS UH5
         ORA #$18
         LDX #$33
         STX $01
UH5      STA $C8
         LDA #$D8
         STA $C4
         LDA $D023
         STA $B4
         LDA $D022
         STA $B5
         LDA #$1B
         JSR SENDB
         LDA #$33
         JSR SENDB
         LDA #$17
         JSR SENDB
         BIT $93
         BVS UH6
         LDA #$41
         JSR SESC
         LDA #$08
         JSR SENDB
UH6      LDA #$19
         STA $CD
         BNE UH8
UH7      LDA #$00
         STA $CE
         LDA $C1
         CLC
         ADC #$28
         STA $C1
         STA $C3
         BCC UH8
         INC $C2
         INC $C4
         LDA $C7
         BEQ UH8
         INC $C8
UH8      LDA $DC01
         CMP #$7F
         BEQ UH16
         JSR SGRAPHM ;MODUS AN DRUCKER
         LDA #$00
         STA $CF
UH9      LDA $C8
         STA $CA
         LDY $CF
         LDA ($C3),Y
         LDX $C7
         BNE UH10
         AND #$07
UH10     AND #$0F
         STA $B6
         JSR G4BC  ;4BYTES IN PUFFER
         LDA #$80
         STA $AE
UH11     LDA $AC
         BNE UH12
         LDA #$04
UH12     STA $AF
UH13     JSR SPRT ;SPRITE
         LDA $9E
         EOR $91
         JSR SENDB
         LSR $AF
         BCC UH13
         LSR $AE
         LDA $AC
         BEQ UH14
         LSR $AE
UH14     BCC UH11
         INC $CF
         LDA $CF
         CMP #$28
         BCC UH9
         LDA $CE
         BNE UH15
         LDA #$04
         STA $CE
         BNE UH8
UH15     DEC $CD
         BNE UH7
UH16     LDA #$34
         STA $01
         LDA #$32
         JSR SESC
         JSR SRET
         JSR CLOSE
         LDA #$E7
         JSR SOPEN
         JMP CLOSE
;---------------------------------------
; 1 GRAPHICBYTE UMRECHNEN;EPSON
;---------------------------------------
W1BC     LDA #$00
         STA $9E
         LDY #$03
W1BC1    LDA $AC
         BNE W1BC2
         LDA $B0,Y
         AND $AE
         BEQ W1BC5
         JSR W1BU2
         BNE W1BC4
W1BC2    JSR W1BU1
         ASL $AE
         AND #$0F
         TAX
         LDA GRTB4,X
         PHA
         LDA GRTB3,X
         AND $AF
         BEQ W1BC3
         JSR W1BU2
W1BC3    PLA
         AND $AF
         BEQ W1BC5
W1BC4    LDA GRTB2,Y
         JSR W1BU3
W1BC5    DEY
         BPL W1BC1
         RTS
;---------------------------------------
; ACTUELLE FARBE HOLEN;EPSON
;---------------------------------------
W1BU1    LDA $B0,Y
         TAX
         AND $AE
         BNE W1BU1B
         LSR $AE
         TXA
         AND $AE
         BEQ W1BU1A
         LDA $B5
         RTS
;---------------------------------------
W1BU1A   LDA $D021
         RTS
;---------------------------------------
W1BU1B   LSR $AE
         TXA
         AND $AE
         BEQ W1BU1C
         LDA $B6
         RTS
W1BU1C   LDA $B4
         RTS
;---------------------------------------
W1BU2    LDA GRTB1,Y
W1BU3    ORA $9E
         STA $9E
         RTS
;---------------------------------------
GRTB1    .BYTE $80,$20,$08,$02
GRTB2    .BYTE $40,$10,$04,$01
;---------------------------------------
; 4 BYTES IN ZWISCHENPUFFER;EPSON
;---------------------------------------
G4BC     LDA #$2F
         STA $00
         LDA ($C1),Y
         LDX $C7
         BEQ G4BC1
         STA $B4
         LSR A
         LSR A
         LSR A
         LSR A
         STA $B5
         TYA
         CLC
         ADC $C1
         BCC G4BC1
         INC $CA
G4BC1    LDX #$03
G4BC2    ASL A
         ROL $CA
         DEX
         BNE G4BC2
         ORA $CE
         STA $C9
         LDY #$03
G4BC3    LDA ($C9),Y
         STA $B0,Y
         DEY
         BPL G4BC3
         LDA #$70
         STA $00
         RTS
;---------------------------------------
SGRAPHM  JSR SRET
         LDA #$4C  ;GRAPHICMODUS
         JSR SESC
         LDA #$C0
         JSR SENDB
         LDA #$03
SGRAPH1  JMP SENDB
;---------------------------------------
SESC     PHA
         LDA #$1B    ;CHR$(27)
         JSR SENDB
         PLA
         BNE SGRAPH1
;---------------------------------------
GRTB3    .BYTE $3F
         .BYTE $00,$55,$11,$15
         .BYTE $09,$55,$01,$25
         .BYTE $2D,$09,$1B,$29
         .BYTE $01,$29,$09
GRTB4    .BYTE $3F,$00,$24,$04
         .BYTE $4A,$24,$AA,$08
         .BYTE $2A,$1F,$24,$26
         .BYTE $12,$08,$12,$04
;---------------------------------------
; MPS HARDCOPY
;---------------------------------------
XH1      LDA #$60
         JSR SOPEN1
         LDA $90
         BPL XH2
         RTS
XH2      LDA $D011
         AND #$20
         LSR A
         LSR A
         ORA #$07
         STA $C6
         LDA $D023
         AND #$0F
         STA $C7
         LDA $D022
         ASL A
         ASL A
         ASL A
         ASL A
         ORA $C7
         LDX #$03
XH3      STA $B4,X
         DEX
         BPL XH3
         LDA $DD00
         AND #$03
         EOR #$03
         PHA
         LSR A
         ROR A
         ROR A
         STA $C7
         LSR A
         LSR A
         STA $C5
         LDA $D018
         TAX
         AND #$08
         ASL A
         ASL A
         ORA $C7
         STA $C7
         TXA
         AND #$F0
         STA $C8
         PLA
         LSR A
         ROR $C8
         LSR A
         ROR $C8
         TXA
         AND #$0E
         ORA $C5
         LSR A
         CMP #$02
         BCC XH4
         CMP #$04
         BCS XH4
         ORA #$18
         LDX #$33
         STX $01
XH4      STA $C5
         LDX #$06
         LDA $D016
         AND #$10
         BEQ XH6
XH5      LDA ZMULT,X
         STA $97,X
         DEX
         BPL XH5
         BMI XH7
XH6      LDA ZNORM,X
         STA $97,X
         DEX
         BPL XH6
XH7      LDA #$1C
         STA $CF
         LDX #$00
         STX $CE
         LDA #$08
         JSR $FFA8
XH8      LDA #$01
         STA $9F
         .BYTE $2C
XH9      DEC $CE
         LDA #$0D
         JSR $FFA8
         LDX #$00
         LDA #$28
         STA $CB
         STX $C9
         STX $CA
XH10     LDA $CE
         STA $CD
         JSR G4BN  ;4BYTES PUFFER
         JSR S4B   ;DRUCKEN
         LDA $DC01
         CMP #$7F
         BEQ XH12
         CLC
         LDA $C9
         ADC #$08
         STA $C9
         BCC XH11
         INC $CA
XH11     DEC $CB
         BNE XH10
         LDA $CD
         STA $CE
         DEC $9F
         BEQ XH9
         DEC $CF
         BPL XH8
XH12     LDA #$0D
         JSR $FFA8
         LDA #$0F
         JSR $FFA8
         JSR $FFAE
         LDX #$F0
         JSR SOPEN
         JMP $FFAE
;---------------------------------------
; 4 BYTES AN DRUCKER SENDEN;MPS801
;---------------------------------------
S4B      LDA #$80
         STA $AF
S4B1     LDA #$04
         STA $AE
S4B2     LDX #$03
         LDA #$00
         STA $9E
S4B3     JSR $97
         ASL $AF
         AND #$0F
         TAY
         LDA ($9A),Y
         AND $AE
         BEQ S4B4
         LDA $9E
         ORA GRTB6,X
         STA $9E
S4B4     LDA ($9C),Y
         AND $AE
         BEQ S4B5
         LDA $9E
         ORA GRTB7,X
         STA $9E
S4B5     DEX
         BPL S4B3
         LDA $9E
         EOR $91
         LDX $9F
         BNE S4B6
         LSR A
         LDX $CF
         BNE S4B6
         AND #$01
S4B6     ORA #$80
         JSR $FFA8
         LSR $AE
         BCC S4B2
         LSR $AF
         LSR $AF
         BCC S4B1
         RTS
;---------------------------------------
;GETBYTE AUS ZWISCHENPUFFER;MULTICOLOR
;---------------------------------------
GBZM     LDA $B0,X
         PHA
         AND $AF
         BNE GBZM2
         LSR $AF
         PLA
         AND $AF
         BEQ GBZM1
         LDA $B4,X
         LSR A
         LSR A
         LSR A
         LSR A
         RTS
GBZM1    LDA $D021
         RTS
;---------------------------------------
GBZM2    LSR $AF
         PLA
         AND $AF
         BEQ GBZM3
         LDA $B8,X
         RTS
GBZM3    LDA $B4,X
         RTS
;---------------------------------------
;GETBYTE AUS ZWISCHENPUFFER NORMAL
;---------------------------------------
GBZ      LDY #$00
         LDA $B0,X
         PHA
         AND $AF
         BEQ GBZ1
         INY
         INY
GBZ1     LSR $AF
         PLA
         AND $AF
         BEQ GBZ2
         INY
GBZ2     TYA
         RTS
;---------------------------------------
; GET 4 BYTES VON GRAPHIC;MPS801
;---------------------------------------
G4BN     LDX #$00
G4BN1    SEI
         LDA $CD
         JSR ZSF
         JSR G1BN
         INC $CD
         INX
         CPX #$04
         BCC G4BN1
         RTS
;---------------------------------------
; ZEIGER FUER FARBRAM,VIDEORAM SETZEN
;---------------------------------------
ZSF      PHA
         LSR A
         LSR A
         LSR A
         TAY
         LDA ZTB1,Y
         STA $AD
         TYA
         AND #$03
         TAY
         PLA
         AND #$07
         ORA GRTB5,Y
         CLC
         ADC $C9
         STA $AC
         STA $C1
         LDA $AD
         ADC $CA
         STA $C2
         ORA $C7
         STA $AD
         LDY #$03
ZSF1     LSR $C2
         ROR $C1
         DEY
         BNE ZSF1
         LDA $C1
         STA $C3
         LDA $C2
         PHA
         ORA $C8
         STA $C2
         PLA
         ORA #$D8
         STA $C4
         LDA $D011
         AND #$20
         BNE ZSF3
         LDA $C5
         STA $AD
         LDA ($C1),Y
         LDY #$03
ZSF2     ASL A
         ROL $AD
         DEY
         BNE ZSF2
         STA $AC
         LDA $CD
         AND #$07
         ORA $AC
         STA $AC
ZSF3     RTS
;---------------------------------------
ZTB1     .BYTE $00,$01,$02,$03
         .BYTE $05,$06,$07,$08
         .BYTE $0A,$0B,$0C,$0D
         .BYTE $0F,$10,$11,$12
         .BYTE $14,$15,$16,$17
         .BYTE $19,$1A,$1B,$1C
         .BYTE $1E
;---------------------------------------
GRTB5    .BYTE $00,$40,$80,$C0
GRTB6    .BYTE $02,$08,$20,$80
GRTB7    .BYTE $01,$04,$10,$40
         .BYTE $07,$00,$05,$02
         .BYTE $06,$01,$05,$00
         .BYTE $05,$07,$02,$03
         .BYTE $03,$00,$04,$02
         .BYTE $07,$00,$03,$00
         .BYTE $05,$04,$07,$06
         .BYTE $02,$05,$04,$06
         .BYTE $04,$02,$06,$01
         .BYTE $00,$03,$04,$07
         .BYTE $00,$01,$06,$07
;---------------------------------------
; GRAPHICBYTES AUS RAM HOLEN;MPS801
;---------------------------------------
G1BN     LDA #$2F
         STA $00
         LDA ($AC),Y
         STA $B0,X
         LDA $D011
         AND #$20
         BEQ G1BN1
         LDA ($C1),Y
         STA $B4,X
G1BN1    LDA ($C3),Y
         AND $C6
         STA $B8,X
         LDA #$70
         STA $00
         RTS
;---------------------------------------
ZMULT    JMP GBZM
;---------------------------------------
         .BYTE $35,$92,$45,$92
;---------------------------------------
ZNORM    JMP GBZ
;---------------------------------------
         .BYTE $55,$92,$59,$92
;---------------------------------------
;
;  SERIAL ROUTINEN
;---------------------------------------
OPEN     ORA #$20
CLOSE1   PHA
         BIT $94
         BPL OPEN1
         SEC
         ROR $A3
         JSR SEND
         LSR $94
         LSR $A3
OPEN1    PLA
         STA $95
         SEI
         CMP #$24
         BNE OPEN2
         JMP TSTCENT
OPEN2    JSR SERINIT
         LDA $DD00
         ORA #$08
         STA $DD00
         SEI
         JSR $EE8E
         JSR $EE97
         JSR $EEB3
;---------------------------------------
SEND     SEI
         BIT $DD0C
         BMI SEND1
         JSR $EE97
         JMP $ED44
SEND1    LDA $95
         JSR SENDC
         BIT $A3
         BPL SEND2
         JSR SERINIT
SEND2    CLI
         CLC
         RTS
;---------------------------------------
SENDB    BIT $94
         BMI SENDB1
         SEC
         ROR $94
         BNE SENDB2
SENDB1   PHA
         JSR SEND
         PLA
SENDB2   STA $95
         CLC
         RTS
;---------------------------------------
CLOSE    LDA #$3F
         JSR CLOSE1
         JMP $EE03
;---------------------------------------
SECA     STA $95
         JSR SECOND1
         JMP $EDBE
;---------------------------------------
SENDC    JSR SENDCB
         LDA #$10
SENDC1   BIT $DD0D
         BEQ SENDC1
         RTS
;---------------------------------------
SENDCB   STA $DD01
         LDA $DD0D
         LDA $DD00
         AND #$FB
         STA $DD00
         ORA #$04
         STA $DD00
         RTS
;---------------------------------------
SERINIT  LDA $DD0C
         AND #$7F
         STA $DD0C
         LDA #$3F
         STA $DD02
         LDA $DD00
         ORA #$04
         STA $DD00
         LDA #$00
         STA $DD03
         RTS
;---------------------------------------
SECOND1  SEI
         BIT $DD0C
         BMI SECOND2
         JSR $EE8E
         JSR $EE9A
         JMP $ED44
SECOND2  AND #$F0
         CMP #$E0
         BNE SECOND3
         LDA #$00
         STA $DD0C
         JSR SENDCB
         JSR SERINIT
SECOND3  CLI
SECOND4  CLC
         RTS
;---------------------------------------
TSTCENT  JSR TSTC
         BCC TSTCENT1
         JMP $ED2E
TSTCENT1 LDA #$C0
         STA $DD0C
         CLI
         RTS
;---------------------------------------
TSTC     JSR SERINIT
         DEC $DD03
         BIT $DD0C
         BVS SECOND4
         JSR SENDCB
         LDA #$FF
         STA $DC07
         LDA #$19
         STA $DC0F
         LDA $DC0D
TSTC1    LDA $DD0D
         AND #$10
         BNE SECOND4
         LDA $DC0D
         AND #$02
         BEQ TSTC1
         SEC
         RTS
;---------------------------------------
SOPEN    PHA
         LDA #$00
         STA $90
         LDA #$04
         JSR OPEN
         PLA
         JMP SECA
;---------------------------------------
SOPEN1   PHA
         LDA #$00
         STA $90
         LDA #$04
         JSR $FFB1
         PLA
         JMP $FF93
;---------------------------------------
SNDA     LDA #$0A
         .BYTE $2C
SNDD     LDA #$0D
         JMP SENDB
;---------------------------------------
SRET     JSR SNDD
         LDA $93
         AND #$20
         BNE SNDA
         RTS
;---------------------------------------
;
; DISK COPYS
;---------------------------------------
FILCOPR  JMP FILECOPY ;FILECOPY
;---------------------------------------
BACKRM   JMP BACKUP
;---------------------------------------
SOURMES  JMP INSMES
;---------------------------------------
DESTMES  JMP PDEST
;---------------------------------------
FILECOPY LDA #$00
         JSR SETDEV  ;DEVICE
FC1      JSR PSOURCE
         LDA #$01
         LDX #<DIRB ;$
         LDY #>DIRB
         JSR $FFBD
         LDY #$00
         LDX $F9
         JSR $FFBA
         LDA #$60
         STA $B9
         JSR $F3D5
         LDA $BA
         JSR $FFB4
         LDA $B9
         JSR $FF96
         JSR $FFA5
         LDA $90
         LSR A
         LSR A
         BCC FC5
         JSR STATUS1
FC2      JSR WDMES ;WEITERE DISK?
         BEQ FC1
FC3      CLC
         .BYTE $24
FC4      SEC
         LDX #$01
         STX $DC0E
         DEX
         STX $0800
         RTS
;---------------------------------------
FC5      JSR $FFA5
         JSR PRINTM
;
         .BYTE $0D,$0D
         .TEXT " FILES MIT J/N "
         .TEXT "AUSWAEHLEN"
         .BYTE $0D,$0D,$00
;---------------------------------------
         LDA #$00
         LDX #$09
FC6      STA $03EF,X
         DEX
         BPL FC6
         STA $FD
         LDX #$03
         LDY #$08
         STX $FB
         STY $FC
         JSR DIRLINE ;GET LINE
         JSR PRET
         JSR $FFD2
         BCC FC8
FC7      JSR PRINTM
;
         .TEXT "N/A"
         .BYTE $0D,$00
;---------------------------------------
FC8      JSR DIRLINE
         LDA $90
         BEQ FC9
         JMP FC22  ;ERROR
FC9      LDY #$05
         LDA ($D1),Y
         CMP #$22
         BEQ FC10
         JMP FC21
FC10     LDA $C3
         CPX $C3
         BCC FC7
         ORA $C4
         BEQ FC7
         LDA $C4
         BNE FC7
         LDA $F8
         CMP #$52
         BEQ FC7
         CMP #$44
         BEQ FC7
FC11     JSR GETK  ;GETKEY
         BCS FC12
         CMP #$4A  ;J
         BEQ FC14
         CMP #$4E  ;N
         BEQ FC13
         BNE FC11
FC12     JSR $F633
         JMP FC4
FC13     LDY #$00
         STY $D3
         BEQ FC8
FC14     LDA #$0D
         JSR $FFD2
         LDX $03EF
         LDA $BD
         CLC
         ADC $03F7
         STA $03F7
         BCS FC16
         BIT $8C
         BVS FC15
         CMP #$F0
         BCC FC17
         BCS FC16
FC15     CMP #$F6
         BCC FC17
FC16     INX
         LDA $BD
         STA $03F7
         STX $03EF
FC17     INC $03F0,X
         LDA $F7
         SEC
         ADC $FB
         STA $FB
         TAX
         BCC FC18
         INC $FC
FC18     LDA $FC
         CMP #$09
         BCC FC19
         TXA
         CMP #$9B
FC19     INC $FD
         BCS FC20
         LDA $FD
         CMP #$26
         BCS FC20
         JMP FC8
FC20     JSR PRINTM
;
         .BYTE $0D,$0D
         .TEXT "... MEHR FILES ..."
         .BYTE $0D,$0D,$00
;---------------------------------------
FC21     JSR $F642
FC22     LDX #$03
         LDY #$08
         JSR $FFBD
         LDA #$00
         STA $03EF
         STA $02
FC23     LDA $BB
         STA $FB
         LDA $BC
         STA $FC
         LDA #$00
         STA $8B
         STA $09B0
         STA $AE
         LDA #$0A
         STA $09B1
         STA $AF
         LDX $03EF
         INC $03EF
         LDA $03F0,X
         BNE FC24
         JMP FC2
FC24     STA $FD
         STA $FE
         LDA $02
         BEQ FC25
         JSR PSOURM  ;SOURCE
FC25     LDA #$01
         STA $02
         JSR IFILZ ;FILENAME SETZEN
FC26     LDX $F9
         LDY #$00
         JSR $FFBA
         LDX $AE
         LDY $AF
         STX $C3
         STY $C4
         LDA #$80
         STA $9D
         ASL A
         STA $93
         JSR $F5D2
         LDA #$20
         JSR $FFD2
         JSR $F5C1
         ASL $9D
         DEC $B7
         DEC $B7
         LDA #$00
         JSR FLOAD  ;LOAD
         INC $B7
         INC $B7
         BCC FC27
         LDA #$20
         JSR STATUS
FC27     LDX $8B
         LDA $C3     ;START
         STA $02A7,X
         LDA $C4
         STA $02A8,X
         LDA $AE     ;END
         STA $09B2,X
         LDA $AF
         STA $09B3,X
         INX
         INX
         STX $8B
         JSR SFILZ   ;FILENAME ERHOEHEN
         DEC $FD
         BNE FC26
         JSR PDESTM  ;DESTINATION
FC28     LDA $FE
         STA $FD
         LDX $FB
         LDY $FC
         STX $BB
         STY $BC
         LDA #$00
         STA $8B
         STA $AE
         LDA #$0A
         STA $AF
         JSR IFILZ  ;FILENAME
FC29     LDA $AE
         STA $C1
         LDA $AF
         STA $C2
         LDX $8B
         LDA $09B2,X   ;START
         STA $AE       ;+END SETZEN
         LDA $02A7,X
         STA $C3
         LDA $09B3,X
         STA $AF
         LDA $02A8,X
         STA $C4
         INX
         INX
         STX $8B
         LDA $FA
         STA $BA
         LDA #$80
         STA $9D
         JSR BANK2
         .BYTE $09,$81   ;SAVE
;---------------------------------------
         LDA $90
         BEQ FC30
         JSR STATUS1
FC30     JSR SFILZ
         DEC $FD
         BNE FC29
         BIT $8C
         BMI FC31
         JSR PRINTM
;
         .BYTE $0D,$0D
         .TEXT "WEITERE AUSGABE (J/N)?"
         .BYTE $00
;---------------------------------------
         JSR GETJN
         BNE FC31
         JSR PDEST  ;DESTINATION
         JMP FC28
FC31     LDA $BB
         BNE FC32
         DEC $BC
FC32     DEC $BB
         JMP FC23
;---------------------------------------
SFILZ    LDA $B7
         CLC
         ADC $BB
         STA $BB
         BCC IFILZ
         INC $BC
IFILZ    LDY #$00
         LDA ($BB),Y
         STA $B7
         INC $BB
         BNE IFILZ2
         INC $BC
IFILZ2   RTS
;---------------------------------------
DIRLINE  LDY #$02
         STY $8B
         LDY #$00
         STY $F8
         STY $90
DLI1     JSR $FFA5
         STA $C3
         JSR $FFA5
         STA $C4
         LDX $90
         BEQ DLI3
DLI2     JMP $F642
DLI3     DEC $8B
         BNE DLI1
         LDX $C3
         LDY $C4
         JSR $BDCD
         LDY #$01
         LDA #$20
DLI4     JSR $FFD2
         JSR $FFA5
         CMP #$22
         BNE DLI5
         LDA $F8
         EOR #$FF
         STA $F8
         LDA #$22
         BNE DLI6
DLI5     LDX $F8
         BEQ DLI6
         STA ($FB),Y
         INY
DLI6     LDX $90
         BNE DLI2
         TAX
         BNE DLI4
         LDA #$2C
         STA ($FB),Y
         INY
         STY $F7
         LDY #$18
         LDA ($D1),Y
         ORA #$40
         LDX #$FE
         CMP #$4C
         BNE DLI7
         LDX #$F0
         LDA #$50
DLI7     BIT $8C
         BVS DLI8
         CMP #$53
         BEQ DLI8
         CMP #$55
         BEQ DLI8
         LDA #$57
DLI8     LDY $F7
         STA ($FB),Y
         TYA
         LDY #$00
         STA ($FB),Y
         STX $BF
         TYA
         LDY $C3
         BEQ DLI11
         LDX #$01
DLI9     CLC
         ADC $BF
         BCC DLI10
         INX
DLI10    DEY
         BNE DLI9
         STX $BD
DLI11    LDX #$F6
         LDA $BF
         CMP #$FE
         BEQ DLI12
         LDX #$FF
DLI12    RTS
;---------------------------------------
STATUS1  LDA #$0D
STATUS   JSR $FFD2
         JSR BANK2
         .BYTE $1B,$81 ;FLOPPYSTATUS
;---------------------------------------
         RTS
;---------------------------------------
FLOAD    BIT $033C
         BMI FLOAD1
         JSR BANK2
         .BYTE $06,$81
;---------------------------------------
         RTS
;---------------------------------------
FLOAD1   JSR BANK2
         .BYTE $00,$81
         RTS
;---------------------------------------
WDMES    JSR PRINTM
;
         .BYTE $0D,$0D
         .TEXT "WEITERE DISK? (J/N) "
         .BYTE $00
;---------------------------------------
GETJN    JSR GETK
         CMP #$4E   ;N
         BEQ GETJN1
         CMP #$4A   ;J
         BNE GETJN
GETJN1   JSR $FFD2
         CMP #$4A
         RTS
;---------------------------------------
; DEVICE SETZEN + MENUE AUSGEBEN
;---------------------------------------
SETDEV   PHA
         LDX #$08
         STX $F9
         INX
         STX $FA
         STX $BA
         JSR BANK2
         .WORD TSTFBR   ;TSTFLOPPY
;---------------------------------------
         BNE STD1
         DEC $FA
STD1     LDY #$01
         STY $FB
         STY $FC
         DEY
         PLA
         TAX
         BEQ STD2
         STY $FC
         STY $FB
STD2     LDA CMES1,Y
         BEQ STD5
         CMP #$FF
         BEQ STD4
         JSR $FFD2
STD3     INY
         BNE STD2
STD4     INX
         LDA CMES2,X
         BEQ STD3
         JSR $FFD2
         BCC STD4
STD5     LDA #$54
         LDY #$05
         LDX #$04
STD6     STA $22
         STY $23
         LDA $F8,X
         AND #$01
         LSR A
         ROR A
         EOR #$80
         STA $24
         LDY #$05
STD7     LDA ($22),Y
         AND #$7F
         EOR $24
         CPY #$03
         BCC STD8
         EOR #$80
STD8     STA ($22),Y
         DEY
         BPL STD7
         LDY $23
         LDA $22
         SEC
         SBC #$50
         BCS STD9
         DEY
STD9     DEX
         BNE STD6
STD10    JSR GETK
         CMP #$20
         BEQ STD11
         SEC
         SBC #$85
         CMP #$04
         BCS STD10
         TAX
         LDA #$01
         EOR $F9,X
         STA $F9,X
         BPL STD5
STD11    LDA #$00
         LSR $FC
         ROR A
         LSR $FB
         ROR A
         STA $8C
         LDX #$00
         STX $BA
         STX $FD
         INX
STD12    STX $24
         LDA $F9,X
         CMP $BA
         STA $BA
         BEQ STD13
         JSR BANK2
         .WORD TSTFBR ;FLOPPYTEST
;---------------------------------------
         BNE STD13
         PLA
         PLA
         LDA #$05
         SEC
         RTS
;---------------------------------------
STD13    LDA $1F
         EOR $FD
         STA $FD
         LDX $24
         DEX
         BPL STD12
         CLC
         LDA $1F
         STA $033C
         LDA $FD
         RTS
;---------------------------------------
CMES1    .BYTE $93,$20,$FF
         .TEXT " COPY"
         .BYTE $0D,$0D
         .TEXT " F1: QUELL-DISK   "
         .TEXT "=  8  9"
         .BYTE $0D,$0D
         .TEXT " F3: ZIEL-DISK "
         .BYTE $1D
         .TEXT "  =  8  9"
         .BYTE $0D,$0D
         .TEXT " F5: "
         .BYTE $FF
         .TEXT "=  J  N "
         .BYTE $0D,$0D
         .TEXT " F7: "
         .BYTE $FF
         .TEXT "    =  J  N "
         .BYTE $0D,$0D
         .TEXT " SPACE FUER COPYSTART"
         .BYTE $0D
CMES2    .BYTE $00
         .TEXT "FILE"
         .BYTE $00
         .TEXT "MEHRFACHCOPY "
         .BYTE $00
         .TEXT "WARP SAVE"
         .BYTE $00
         .TEXT "DISK"
         .BYTE $00
         .TEXT "FEHLER IGNOR."
         .BYTE $00
         .TEXT "BAM-COPY "
         .BYTE $00
;---------------------------------------
PDESTM   SEC
         .BYTE $24
PSOURM   CLC
         LDA $F9
         EOR $FA
         BNE PRRET3
         BCS PDEST
         JSR INSMES
         JMP PRRET
;---------------------------------------
INSMES   LDA $F9
INSMES1  PHA
         JSR PRINTM
;
         .BYTE $0D
         .TEXT "BITTE  QUELL-DISK "
         .TEXT "IN FLOPPY "
         .BYTE $00
;---------------------------------------
         PLA
         TAX
         LDA #$00
         JMP $BDCD
;---------------------------------------
PSOURCE  JSR INSMES
         LDA $FA
         CMP $F9
         BEQ PRRET
PDEST    LDA $FA
         JSR INSMES1
         LDA #$07
         STA $D3
         JSR PRINTM
;
         .TEXT "ZIEL -"
         .BYTE $00
;---------------------------------------
PRRET    JSR PRINTM
;
         .BYTE $0D
         .TEXT "<RETURN>"
         .BYTE $00
;---------------------------------------
PRRET1   JSR GETK
         BCS PRRET2
         CMP #$0D
         BNE PRRET1
PRRET3   RTS
PRRET2   PLA
         PLA
         JMP FC4
;---------------------------------------
GETK     LDX #$01
         STX $DC0E
         CLI
         DEX
         STX $C6
GETK1    JSR $FFE4
         BEQ GETK1
         DEC $DC0E
         CMP #$03
         BEQ GETK2
         CLC
GETK2    RTS
;---------------------------------------
DIRB     .BYTE $24
;---------------------------------------
; BACKUP
;---------------------------------------
BACKUP   LDA #$1D
         JSR SETDEV
         BNE BK1
         LDA $1F
         BEQ BK2
         AND #$20
         BNE BK3
BK1      JSR PRINTM
;
         .BYTE $0D
         .TEXT "BACKUP NUR FUER "
         .TEXT "1541 ! "
         .BYTE $1D,$1D,$0D,$00
;---------------------------------------
         JMP FC3
;---------------------------------------
BK2      JMP STATUS1
;---------------------------------------
BK3      JSR PSOURCE
         LDA $F9
         STA $BA
         LDA #$00
         STA $FD
         LDA #$0E
         STA $FE
         JSR IBK  ;TESTFLOPPY +BAMLOAD
         LDY #$00
         LDX #$01
BK4      STX $10
         BIT $8C
         BVS BK9
         STY $24
         BIT $1F
         BMI BK5
         JSR BANK2
         .WORD BROUT ;ANZAHL SECTOREN
;---------------------------------------
         LDA $10
         ASL A
         ASL A
         TAY
         LDA $0E00,Y
         BCC BK8
BK5      LDA #$0E
         CPX #$29
         ADC #$00
         STA $FE
         LDA #$0A
BK6      CLC
         ADC #$06
         CPX #$29
         BEQ BK7
         DEX
         BNE BK6
BK7      TAY
         LDA ($FD),Y
BK8      LDY $24
         CMP $13
         BEQ BK10
BK9      INY
         LDA $10
         STA $0352,Y
BK10     LDX $10
         INX
         CPX $F8
         BNE BK4
         INY
         LDA #$FF
         STA $0352,Y
         LDA #$00
         STA $51
         STA $0352
         INC $51
         LDX #$00
BK11     LDA BACKR,X
         STA $0800,X
         LDA BACKR+$0100,X
         STA $0900,X
         INX
         BNE BK11
BK12     CLC
         LDA $F9
         JSR READD ;READ
         JSR PDESTM ;DESTINATION
         JSR BANK2
         .BYTE $00,$08  ; WRITE DISK
;---------------------------------------
         LDA $50
         PHA
         BIT $1F
         BMI BK13
         BIT $8C
         BPL BK13
         SEC
         LDA $FA
         JSR READD ;READ
BK13     PLA
         TAX
         LDA $0352,X
         BMI BK14
         STX $51
         JSR PSOURM ;SOURCE
         JMP BK12
BK14     JSR $FFAE
         JSR WDMES ;WEITERE DISK?
         BNE BK15
         JMP BK3
BK15     JMP FC3
;---------------------------------------
; DISK EINLADEN
;---------------------------------------
READD    STA $BA
         JSR BANK2
         .BYTE $C4,$08
;---------------------------------------
         BIT $8C
         BPL READD1
         JSR PRINTM
;
         .BYTE $0D
         .TEXT "FEHLER:"
         .BYTE $00
;---------------------------------------
         LDX $FE
         LDA #$00
         JMP $BDCD
;---------------------------------------
READD1   RTS
;---------------------------------------
; BACKUPROUTINE (IM RAM BEI $0800)
; AUF BANK2 GESCHALTET
;---------------------------------------
BACKR    JSR $8698
         TXS
         LDA $FA
         STA $BA
         LDA $51
         STA $50
         LDA #$0B
         STA $0E
         LDX #$00
         STX $AC
         LDY #$14
         BIT $1F
         BPL BACKR1
         LDX #$1C
         LDY #$FF
BACKR1   JSR $88FF
         LDA #$FF
         BCS BACKR3
         JSR $8E0A
         LDX $50
         BIT $1F
         BMI BACKR2
         LDY $0351,X
         INY
         TYA
         JSR $8239
BACKR2   LDX $50
         LDA $0352,X
         STA $10
         PHA
         JSR $8239
         PLA
         BMI BACKR3
         JSR $0859
         INC $50
         LDA $0E
         CLC
         ADC $13
         STA $0E
         CMP #$EB
         BCC BACKR2
         LDA #$00
BACKR3   JMP $880A
;---------------------------------------
         BIT $1F
         BMI BACKR9
         LDX #$15
         LDA #$FF
BACKR4   STA $033C,X
         DEX
         BPL BACKR4
         JSR $9009
         LDY #$08
         LDA $13
         STA $41
BACKR5   CPY $13
         BCC BACKR7
         TYA
         TAX
         LDY #$FF
BACKR6   INY
         DEX
         CPX $13
         BCS BACKR6
BACKR7   LDA $033C,Y
         BMI BACKR8
         INY
         CPY $13
         BCC BACKR7
         LDY #$00
         BCS BACKR7
BACKR8   TYA
         STA $033C,Y
         PHA
         PHA
         CLC
         ADC $0E
         STA $AD
         LDX #$00
         JSR $0115
         PLA
         JSR $8239
         JSR $8242
         PLA
         CLC
         ADC #$07
         TAY
         DEC $41
         BNE BACKR5
         RTS
;---------------------------------------
BACKR9   LDA #$28
         STA $40
         LDA $0E
         STA $AD
         LDX #$00
BACKR10  JSR $0115
         JSR $8242
         INC $AD
         DEC $40
         BNE BACKR10
         RTS
;---------------------------------------
         LDA #$00
         STA $FE
         ROR A
         STA $93
         JSR $8698
         TXS
         JSR $88E3
         LDA #$FF
         STA $1C
         LDY #$3F
BACKR11  LDA $0920,Y
         STA $013F,Y
         DEY
         BPL BACKR11
         LDA $93
         BEQ BACKR12
         LDA #$24
         STA $0144
BACKR12  LDA $51
         STA $50
         LDA #$0B
BACKR13  STA $0E
         LDX $50
         INC $50
         LDA $0352,X
         BMI BACKR16
         STA $21
         LDA #$03
         STA $F3
BACKR14  LDA $21
         LDX #$00
         STX $FD
         JSR $84C9
         LDA $FD
         BEQ BACKR15
         DEC $F3
         BNE BACKR14
         INC $FE
BACKR15  LDA $0E
         CLC
         ADC $13
         CMP #$EB
         BCC BACKR13
BACKR16  JMP $8800
;---------------------------------------
         INC $01
BACKR17  LDA $0200,Y
         STA ($0F),Y
         EOR ($0F),Y
         BEQ BACKR18
         LDA #$40
         STA $FD
BACKR18  INY
         BNE BACKR17
         DEC $01
         LDX $0C
         LDA $0115,X
         BPL BACKR19
         BIT $1F
         BPL BACKR20
         LDA $90
BACKR20  STA $FD
BACKR19  RTS
;---------------------------------------
; STARTWERTE FUER BACKUP SETZEN
; BAM EINLADEN
;---------------------------------------
IBK      JSR BANK2
         .WORD TSTFBR ;FLOPPYTEST
;---------------------------------------
         BEQ IBK3
         BMI IBK1
         LDA #$24
         STA $F8
         LDX #$0E
         LDA #$12
         LDY #$00
         BEQ IBK2
IBK1     LDA #$51
         STA $F8
         LDA #$28
         STA $13
         LDX #$0E
         LDA #$28
         LDY #$01
         JSR IBK2
         LDY #$00
         LDA ($FD),Y
         PHA
         INY
         LDA ($FD),Y
         TAY
         PLA
         LDX #$0F
IBK2     JSR BANK1
         .BYTE $27,$80  ;LOAD SECTOR
;---------------------------------------
         JSR PRET
         JSR BANK2
         .BYTE $1B,$81 ;STATUS
;---------------------------------------
         BCC IBK4
IBK3     JMP PRRET2
IBK4     RTS
;---------------------------------------
; PRG-REST WIRD NICHT BENUTZT
;---------------------------------------
         STY $24
         BIT $1F
         BMI XX1
         JSR BANK2
         .WORD BROUT
;---------------------------------------
         LDA $10
         ASL A
         ASL A
         TAY
         LDA $0E00,Y
         BCC XX3
XX1      LDA #$0E
         CPX #$29
         ADC #$00
         STA $FE
         LDA #$0A
         CLC
XX2      ADC #$06
         DEX
         BPL XX2
         TAY
         LDA ($FD),Y
XX3      LDY $24
         CMP $13
         RTS
;---------------------------------------
; WARP LOADER SAVEROUTINE
;---------------------------------------
WARPS    LDX #$AE
WARPS1   LDA WARPR-1,X
         STA $0350,X
         DEX
         BNE WARPS1
         JSR BANK2
         .BYTE $51,$03
;---------------------------------------
         RTS
;---------------------------------------
WARPR    JSR $8698
         TXS
         LDY #$19
         JSR $88FD
         JSR $8E0A
         STY $FB
WARPR1   LDY #$12
         LDX $FB
         LDA $03D2,X
         STA $0201
         BPL WARPR2
         LDY #$00
WARPR2   STY $0200
         TXA
         ASL A
         TAX
         LDA $03DF,X
         STA $FD
         LDA $03E0,X
         STA $FE
         LDY #$00
WARPR3   LDA ($FD),Y
         STA $0202,Y
         INY
         CPY #$FE
         BNE WARPR3
         LDX $FB
         INC $FB
         LDA $03D6,X
         JSR $8239
         JSR $8242
         LDY $0200
         BNE WARPR1
WARPR4   LDA $9351,Y
         CPY #$7F
         BCC WARPR5
         LDA $93C2,Y
WARPR5   STA $0200,Y
         INY
         BNE WARPR4
         LDX $FB
         TXA
         ASL A
         TAX
         LDA $03DF,X
         STA $22
         LDA $03E0,X
         STA $23
         LDX $FB
         INC $FB
         LDA $03D6,X
         BEQ WARPR6
         JSR $8239
         JSR $8242
         JMP $03AB
;---------------------------------------
WARPR6   JSR $8239
         JMP $8728
;---------------------------------------
         .BYTE $0C,$0F,$12,$FF
         .BYTE $09,$0C,$0F,$12
         .BYTE $0E,$11,$03,$06
         .BYTE $00
         .BYTE $5D,$9D
         .BYTE $5B,$9E,$24,$81
         .BYTE $00,$83,$B5,$96
         .BYTE $B5,$97,$B5,$98
         .BYTE $00,$02
;---------------------------------------
; HARDCOPYROUTINEN FORTSETZUNG
;---------------------------------------
HUX1     STA $C2
         TAY
         INY
         INY
         INY
         STY $B8
         LDA #$F8
         STA $B7
         TXA
         RTS
;---------------------------------------
; SPRITE DRUCKROUTINE
;---------------------------------------
SPRT     JSR W1BC  ;BYTE UMRECHNEN
         LDA $D015  ;SPRITETEST
         BNE SPR1
         RTS
SPR1     LDA #$07   ;8SPRITES TESTEN
         STA $BF
SPR2     LDX $BF
         LDA SPRTB,X
         BIT $D015   ;SPRITE AN
         BNE SPR3
         JMP SPR29
SPR3     LDY #$00
         STY $BA
         BIT $D010   ;POSITION
         BEQ SPR4
         INY
SPR4     STY $BE
         TXA
         ASL A
         TAX
         LDA $D000,X  ;POSITION
         STA $BD
         LDA $D001,X
         STA $BC
         LDA $CF
         LDX #$03
SPR5     ASL A
         DEX
         BNE SPR5
         ROL $BA
         STA $B9
         LDA $AE
         LDX #$08
SPR6     DEX
         LSR A
         BCC SPR6
         TXA
         CLC
         ADC $B9
         STA $B9
         BCC SPR7
         INC $BA
SPR7     LDA $D016 ;X-POS
         AND #$07
         CLC
         ADC $B9
         STA $B9
         BCC SPR8
         INC $BA
SPR8     LDA $AC
         BEQ SPR9
         LDA $AF
         CMP #$08
         BCS SPR9
         INC $B9
         BNE SPR9
         INC $BA
SPR9     LDA $BD
         SEC
         SBC $B9
         TAX
         LDA $BE
         SBC $BA
         BEQ SPR10
         JMP SPR29  ;ENDE
SPR10    TXA
         BNE SPR11
         JMP SPR29  ;ENDE
SPR11    CMP #$19
         BCC SPR12
         JMP SPR29
SPR12    EOR #$FF
         ADC #$19
         STA $BB
         LDA #$00
         STA $BE
         LDY $BF
         LDA ($B7),Y
         LDX #$06
SPR13    ASL A
         ROL $BE
         DEX
         BNE SPR13
         STA $BD
         CLC
         LDA $BE
         ADC $CC
         STA $BE
         LDA $BB
SPR14    CMP #$08
         BCC SPR15
         SEC
         SBC #$08
         INC $BD
         BNE SPR14
SPR15    STA $BB
         EOR #$07
         TAX
         LDA SPRTB,X
         STA $B9
         LDA #$19
         SEC
         SBC $CD
         ASL A
         ASL A
         ASL A
         CLC
         ADC #$2F
         ADC $CE
         STA $BA
         LDA $D011  ;Y-POS
         AND #$07
         CLC
         ADC $BA
         STA $BA
         LDA #$15
         STA $C0
SPR16    LDA $BC
         SEC
         SBC $BA
         CMP #$04
         BCC SPR17
         JMP SPR28
SPR17    TAY
         LDX $BF
         LDA SPRTB,X
         AND $D01C   ;MULTICOLOR
         BNE SPR19
         STY $C6
         LDY #$00
         LDA ($BD),Y
         AND $B9
         BNE SPR18
         JMP SPR28
SPR18    LDY $C6
         JSR W1BU2
         LDA GRTB2,Y
         JSR W1BU3
         JMP SPR28
;---------------------------------------
SPRU     LDA $B9
         TAY
         LDA $BB
         AND #$01
         BNE SPRU1
         TYA
         LSR A
         BNE SPRU2
SPRU1    TYA
         ASL A
SPRU2    LDY #$00
         AND ($BD),Y
         RTS
;---------------------------------------
SPR19    STY $C6
         LDY #$00
         LDA ($BD),Y
         AND $B9
         BNE SPR22
         JSR SPRU
         BEQ SPR28
         LDA #$00
SPR20    EOR $BB
         AND #$01
         BEQ SPR21
         LDY $BF
         LDA $D027,Y ;SPRITEFARBE
         JMP SPR24
SPR21    LDA $D025   ;FARBE1
         JMP SPR24
SPR22    JSR SPRU
         BNE SPR23
         LDA #$01
         BNE SPR20
SPR23    LDA $D026   ;FARBE2
SPR24    AND #$0F
         TAX
         LDA $AF
         CMP #$08
         BCC SPR25
         LSR A
         LSR A
         LSR A
SPR25    TAY
         LDA $BB
         AND #$01
         BNE SPR26
         TYA
         ASL A
         ASL A
         ASL A
         TAY
SPR26    STY $C5
         LDY $C6
         LDA GRTB1,Y
         ORA GRTB2,Y
         EOR #$FF
         AND $9E
         STA $9E
         LDA GRTB3,X
         AND $C5
         BEQ SPR27
         JSR W1BU2
SPR27    LDA GRTB4,X
         AND $C5
         BEQ SPR28
         LDA GRTB2,Y
         JSR W1BU3
SPR28    CLC
         LDA $BD
         ADC #$03
         STA $BD
         INC $BC
         DEC $C0
         BEQ SPR29
         JMP SPR16
SPR29    DEC $BF
         BMI SPR30
         JMP SPR2
SPR30    RTS
;---------------------------------------
SPRTB    .BYTE $01,$02,$04,$08
         .BYTE $10,$20,$40,$80
;---------------------------------------

