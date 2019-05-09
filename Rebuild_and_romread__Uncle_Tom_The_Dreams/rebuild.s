; Dieses Programm ist ursprÅnglich entwickelt worden, um Screens,
; die durch Rasterinterrupts z.B. in Charset- und Bitmap-Bereiche
; unterteilt wurden, in einer einzigen Bitmap wiederherzustellen.
; Es arbeitet zwar, ist jedoch nie komplett fertiggestellt worden.
; Hier kann jeder Interessierte Programmierer munter weiterentwickeln !
; Die Tastaturbefehle sind dem Quelltext zu entnehmen.
;
;(w) Uncle Tom/The Dreams


		.BA $0A00
                                   
                                   
ZEI:             .EQ $FA
ZEI1:            .EQ $FC           
ZEI2:            .EQ $FE           
ZEI3:            .EQ $A8           
SPEI:            .EQ $AA           
SZEI:            .EQ $BB           
EZEI:            .EQ $AE           
GETIN:           .EQ $FFE4         
CLS:             .EQ $E544         
STROUT:          .EQ $AB1E         
FRESTAU:         .EQ $8843         ;ROM-ROUTINEN DER ACTION-CARTRIDGE
HOLD8:           .EQ $884B         
                                   
                                   
                                   
                                   
                 JSR CLS           
                 LDA #<TX          
                 LDY #>TX          
                 JSR STROUT        
                 CLI               
TAST:            JSR GETIN         
                 BEQ TAST          
                 CMP #'1           
                 BEQ ANFANG        
                 CMP #'2           
                 BNE TAST          
                                   
                 LDX IOBUF+4       
                 INX               
                 BEQ RET           ;ES WURDE NICHTS VERAENDERT
                 STX $08A1         ;(WENN BEIM 1. START 'OLD' GEWAEHLT WURDE
                 LDA IOBUF+2       
                 STA $08A8         ;IO WIEDERHERSTELLEN
                 LDA IOBUF+3       
                 STA $08D0         
                 LDA IOBUF+5       
                 STA $08A6         
                 LDA IOBUF+6       
                 STA $08A5         
                 LDA IOBUF+7       
                 STA $08B0         
                 LDA IOBUF+8       
                 STA $08B1         
                 JSR FHOL          
                 JSR HOLD8         
RET:             CLI               
                 RTS               
                                   
                                   
ANFANG:          JSR FRESTAU       
                 JSR FRETT         ;FARB-RAM MERKEN
                 CLI               
                 JSR MAPCL         ;BITMAP LOESCHEN ($A000-$BFFF)
BEGIN:           LDA #1            ;ZEICHENFARBE
                 STA 646           
                 LDX #0            
                 STX $D020         
                 STX $D021         
                 LDA #$8B          ;FUER SPRITEZEIGER
                 STA SZ1+2         
                 STA SZ2+2         
                                   
                 JSR BANKON        ;BANK VON $8000-$C000 EIN
                 JSR CLS           ;SCREEN AB $8800 LOESCHEN
                 JSR CLSPRITE      ;BEREICH FUER SPRITES LOESCHEN
                                   
                 LDA #$FF          
                 STA GOBEN         
                 STA GUNTEN        ;BEREICHSGRENZEN LOESCHEN (SIEHE IRQ)
                 LDA #0            
                 STA FO+1          ;KEINE RASTERZEILE
                                   
                 SEI               
                 LDA #$34          ;ROMS AUS
                 STA 1             
                 LDA $0872         
                 STA IOBUF         ;STARTADRESSE VIDEO-RAM
                 LDA $0874         
                 STA IOBUF+1       ;STARTADRESSE ZEICHENSATZ
                 LDA $08A8         ;$D018
                 STA IOBUF+2       
                 LDA $08D0         
                 STA IOBUF+3       
                 LDA $08A1         
                 STA IOBUF+4       
                 LDA $08A6         
                 STA IOBUF+5       
                 LDA $08A5         
                 STA IOBUF+6       
                 LDA $08B0         
                 STA IOBUF+7       
                 LDA $08B1         
                 STA IOBUF+8       
                 LDA #$37          
                 STA 1             
                 CLI               ;ALLES NORMAL
                                   
                 JSR IRQON         ;IRQ ANWERFEN
                                   
                 LDX #$00          
WCODES:          TXA               
                 STA $8800,X       ;ZEICHENCODES IN VIDEORAM SCHREIBEN
                 INX               
                 BNE WCODES        
                                   
                 LDA IOBUF+1       
                 STA ZEI+1         
HOLC:            LDA #0            ;ZEICHENSATZ AUSLESEN
                 STA ZEI           
                 STA ZEI1          
                 LDA #$80          
                 STA ZEI1+1        
                                   
                 JSR ZEIOUT        ;ZEIGER HEXADEZIMAL AUSGEBEN
                                   
                 LDX #8            
                 LDY #0            
                 LDA #ZEI          
                 STA 2             
                 LDA #ZEI1         
                 STA 3             ;REGISTER FUER READ UND WRITE
                                   
LESCHAR:         JSR READ          
                 JSR WRITE         ;NACH $8000 KOPIEREN
                 INY               
                 BNE LESCHAR       
                 INC ZEI+1         
                 INC ZEI1+1        
                 DEX               
                 BNE LESCHAR       
                 CLI               
                                   
LOOP:            JSR GETIN         
                 BEQ LOOP          
                 CMP #'+           
                 BEQ NEXTCHAR      
                 CMP #'-           
                 BEQ LASTCHAR      
                 CMP #'_           
                 BEQ EXIT          ;FERTIG
                 CMP #$20          ;SPACE†?
                 BEQ BITMAP        ;DANN BITMAP GEFUNDEN
                 CMP #13           ;RETURN ?
                 BNE LOOP          ;NEIN
                                   
                 JMP VIDEO         ;JETZT VIDEO-RAM AUSWAEHLEN
                                   
                                   
EXIT:            JSR CLSPRITE      ;SPRITES LOESCHEN
                 JSR SHOWBIT       ;ERSTELLTE BITMAP ZEIGEN
                 CLI               
WTAST:           JSR GETIN         
                 BEQ WTAST         
                 CMP #'_           
                 BEQ OKMAP         
                 JMP BEGIN-3       ;ANDERE TASTE ALS '_',DANN RESTART
                                   
OKMAP:           LDA #$91          
                 STA $08D0         ;$DD00
                 LDA #$38          
                 STA $08A8         ;$D018
                 LDA #$3B          
                 STA $08A1         ;$D011
                 LDA #$18          
                 STA $08A6         ;$D016
                 LDA #0            
                 STA $08A5         ;$D015
                 STA $08B0         ;$D020
                 STA $08B1         ;$D021
                 LDA #3            
                 STA $0875         ;BITMAP KANN GESAVED WERDEN
                 LDA #$A0          
                 STA $0873         ;STARTADRESSE DER BITMAP
                 LDA #$8C          
                 STA $0872         ;STARTADRESSE VIDEO-RAM
                 JSR HOLD8         ;FARBRAM FUER CARTRIDGE MERKEN
                 CLI               
                 RTS               
                                   
                                   
LASTCHAR:        LDA ZEI+1         
                 SEC               
                 SBC #$10          
                 STA ZEI+1         
NEXTCHAR:        CLI               
                 JMP HOLC          
                                   
                                   
BITMAP:          LDA IOBUF+2       
                 AND #$F0          ;POSITION VIDEO-RAM
                 STA SPEI          
                 LDA ZEI+1         
                 SEC               
                 SBC #$08          ;STARTADRESSE DER BITMAP
                 AND #$E0          
                 TAX               
                 AND #$20          ;BITMAP IN OBERER ODER UNTERER HAELFTE
                 LSR               
                 LSR               ;BIT RICHTIG SCHIEBEN
                 ORA SPEI          
                 STA $D018         ;BITMAP EINSCHALTEN
                 TXA               
                 STA SPEI          ;MERKEN
                 ASL               
                 ROL               
                 ROL               ;BITS 6+7 SIND JETZT BIT 0+1
                 AND #3            ;BIT 0+1 ISOLIEREN
                 EOR #3            
                 ORA #$90          
                 STA $DD00         ;RICHTIGE BANK WAEHLEN
                 LDA #$3B          
                 STA $D011         
                 LDA #$18          
                 STA $D016         ;MULTI
                                   
                 JSR CLSPRITE      ;SPRITES LOESCHEN
                 JSR HOLGRENZ      ;GRENZEN DES BEREICHES HOLEN
                                   
                 LDA #0            
                 STA ZEI           
                 STA ZEI1          
                 LDA GOBEN         
                 LDX #ZEI          ;ERGEBNIS IN ZEI
                 JSR MAL320        
                 LDA GUNTEN        
                 LDX #ZEI1         
                 JSR MAL320        
                                   
                 LDA ZEI+1         
                 TAX               
                 CLC               
                 ADC SPEI          ;PLUS STARTADRESSE DER BITMAP
                 STA ZEI+1         
                                   
                 TXA               
                 ADC #$A0          ;ZEIGER AUF ANZEIGEBITMAP AB $A000
                 STA ZEI2+1        
                 LDA ZEI           
                 STA ZEI2          
                                   
                 LDA ZEI1+1        
                 CLC               
                 ADC SPEI          
                 STA ZEI1+1        ;ENDADRESSE DES BEREICHES
                                   
                                   
                 LDA #ZEI          
                 STA 2             
                 LDA #ZEI2         
                 STA 3             
                                   
                 LDY #0            
COPMAP:          JSR READ          
                 JSR WRITE         
                 INC ZEI           
                 BNE NOHIA         
                 INC ZEI+1         
NOHIA:           INC ZEI2          
                 BNE NOHIB         
                 INC ZEI2+1        
NOHIB:           LDA ZEI+1         
                 CMP ZEI1+1        
                 BCC COPMAP        
                 LDA ZEI           
                 CMP ZEI1          
                 BCC COPMAP        ;BEREICH IN BITMAP KOPIEREN
                 CLI               
                                   
                 JSR SHOWBIT       ;BITMAP ZEIGEN
                 LDA #$28          ;SCREEN AB $8800
                 STA $D018         
                 JSR SUCHVID       ;RICHTIGES VIDEO-RAM AUSSUCHEN
                 JSR VIDIN         ;BEREICH IN ANZEIGE-VIDEO-RAM KOPIEREN
                 JMP BEGIN         
                                   
                                   
                                   
VIDEO:           LDA ZEI+1         
                 SBC #8            
                 STA CHARANF       ;ANFANGSADRESSE DES ZEICHENSATZES MERKEN
                                   
                 JSR SUCHVID       ;RICHTIGES VIDEO-RAM AUSSUCHEN
                 JSR HOLGRENZ      ;GRENZEN DES BEREICHES HOLEN
                                   
                 JSR VIDIN         ;VIDEO-RAM UMKOPIEREN
                 JSR CHARIN        ;ZEICHENSATZ IN BITMAP KOPIEREN
                 JSR SHOWBIT       ;ERSTELLTE BITMAP ZEIGEN
                 JSR COLSET        ;RICHTIGEN FARBEN HOLEN
                 JMP BEGIN         
                                   
                                   
                                   ;         *** IRQ-ROUTINEN ***
                                   
                                   
IRQ:             LDA $D011         
                 AND #$67          
                 STA $D011         ;SCREEN AUS (SPRITES IM RAHMEN)
SPON:            LDA #3            
                 STA $D015         ;SPRITES AN
                 LDA #$20          
                 STA $D001         
                 STA $D003         
                 LDA #$30          
                 STA $D000         
                 LDA #$48          
                 STA $D002         
                 LDX #$FE          
SZ1:             STX $8BF8         
                 INX               
SZ2:             STX $8BF9         
                 LDA #1            
                 STA $D027         
FO:              LDA #0            
                 JSR LINE+2        ;RASTERZEILE ZEIGEN
                 LDA #1            
                 STA $D028         
                                   
                 LDA #<IRQ1        
                 LDX #>IRQ1        
                 STA $0314         
                 STX $0315         
                 LDA #$28          
                 STA $D012         
                 CLI               
                 JMP $EA31         
                                   
                                   
IRQ1:            DEC $D019         
                 LDA $D011         
                 ORA #$18          ;SCREEN WIEDER AN
                 STA $D011         
                                   
                 LDA GOBEN         ;GRENZEN ANZEIGEN ?†(UEBER RASTERZEILE)
                 BMI BIGLI+5       ;NEIN
                                   
                 ASL               
                 ASL               
                 ASL               ;MAL 8
                 CLC               
                 ADC #49           
                 STA LIUP          ;OBERE RASTERZEILE
                 LDA GUNTEN        
                 ASL               
                 ASL               
                 ASL               
                 CLC               
                 ADC #49           
                 STA LIDO          ;UNTERE RASTERZEILE
                                   
                 LDA #<IRQO        
                 LDX #>IRQO        
                 STA $0314         
                 STX $0315         
                 LDA LIUP          
                 STA $D012         
                 JMP $EA81         
                                   
                                   
IRQO:            JSR LINE          ;RASTERZEILE FAERBEN
                 LDA #<IRQU        
                 LDX #>IRQU        
                 STA $0314         
                 STX $0315         
                                   
                 LDA GUNTEN        
                 CMP #25           
                 BCS BIGLI         ;WENN GANZ UNTEN
                 LDA #0            
                 STA FO+1          
                 LDA LIDO          
                 STA $D012         
                 JMP $EA81         
                                   
                                   
BIGLI:           LDA #7            
                 STA FO+1          
                 LDA #<IRQ         
                 LDX #>IRQ         
                 STA $0314         
                 STX $0315         
                 LDA #$F8          
                 STA $D012         
                 JMP $EA81         
                                   
                                   
IRQU:            JSR LINE          
                 JMP BIGLI+5       
                                   
                                   
                                   
LINE:            LDA #7            
                 LDX #2            
WW:              DEX               
                 BNE WW            
                 STA $D020         
                 STA $D021         
                 LDA #0            
                 LDX #$0A          
WW1:             DEX               
                 BNE WW1           
                 STA $D020         
                 STA $D021         
                 LSR $D019         
                 RTS               
                                   
                                   
                                   ;         *** UNTERPROGRAMME ***
                                   
                                   
IRQON:           SEI               
                 LDA #<IRQ         
                 LDX #>IRQ         
                 STA $0314         
                 STX $0315         
                 LDA #$7F          
                 STA $DC0D         
                 LDA #1            
                 STA $D01A         
                 STA $D019         
                 LDA #$F8          
                 STA $D012         
                 LDA $D011         
                 AND #$7F          
                 STA $D011         
                 CLI               
                 RTS               
                                   
                                   
                                   
ZEIOUT:          LDA #3            ;4 ZEICHEN
                 STA SPEI+1        
                 STA SPON+1        ;SPRITES AN
                 LDA #$BF          
                 STA SZEI+1        
                 LDY #1            
                 LDX #0            
NIBBLE:          LDA ZEI,Y         
                 LSR               
                 LSR               
                 LSR               
                 LSR               
                 JSR INBUF         ;ZEIGER IN NIBBLE AUFSPALTEN UND IN BUFFER
                 LDA ZEI,Y         
                 JSR INBUF         
                 DEY               
                 BPL NIBBLE        
                                   
                 LDA #SZEI         
                 STA 3             
                                   
SHOW:            LDX SPEI+1        
                 LDA STAB,X        
                 STA SZEI          ;ZEIGER IN SPRITE
                 LDA BUF,X         ;NIBBLE HOLEN
                 JSR INSPRITE      ;ZEICHENMATRIX IN SPRITE SCHREIBEN
                 DEC SPEI+1        ;ALLE ZEICHEN DURCH ?
                 BPL SHOW          ;NEIN
                 CLI               
                 RTS               
                                   
INBUF:           AND #$0F          
                 CMP #10           ;ZEICHEN ODER ZIFFER ?
                 BCC ZIFF          ;ZIFFER
                 CLC               
                 ADC #7            
ZIFF:            ADC #48           ;BS-CODE ERMITTELN
                 STA BUF,X         
                 INX               
                 RTS               
                                   
INSPRITE:        LDY #0            
                 STY LS+2          ;ZEIGER VORBEREITEN
                 ASL               
                 ROL LS+2          
                 ASL               ;MAL 8
                 ROL LS+2          
                 ASL               
                 ROL LS+2          
                 STA LS+1          
                 CLC               
                 LDA LS+2          
                 ADC #$D8          ;MATRIX AUS ROM-ZEICHENSATZ
                 STA LS+2          
                 SEI               
                 LDX #0            
CS:              LDA #$33          
                 STA 1             
LS:              LDA $D800,X       ;DUMMY
                 JSR WRITE         ;IN SPRITE SCHREIBEN
                 INY               
                 INY               
                 INY               
                 INX               
                 CPX #8            
                 BNE CS            ;NICHT LS !
                 LDA #$37          
                 STA 1             
                 CLI               
                 RTS               
                                   
                                   
                                   
COLSET:          LDA #$00          
                 STA COL           ;ANFANGS ALLES SCHWARZ (VIDEO-RAM)
                 STA COL+1         
                 STA FARB11+1      ;OR - WERT
                 LDA #7            
                 STA FARB11-1      ;AND - WERT
                 LDA ZEI2+1        
                 AND #3            
                 ORA #$8C          
                 STA ZEI2+1        ;ZEIGER AUF ENDE ANZEIGE-VIDEO-RAM
                 LDA #$8F          
                 STA SZ1+2         
                 STA SZ2+2         ;SPRITEZEIGER LIEGEN IM ANDEREN VIDEO-RAM
                                   
                 JSR BITAUS        ;FARBRAM AN CHARSET-MODE ANPASSEN
                 JSR CLSPRITE      
                 JSR COLIN         ;FARBE SETZEN
CLOOP:           JSR GETIN         
                 BEQ CLOOP         
                 CMP #17           ;DOWN ?
                 BEQ CHD           
                 CMP #29           ;RIGHT ?
                 BEQ CLU           
                 CMP #145          ;UP ?
                 BEQ CHU           
                 CMP #157          ;LEFT ?
                 BEQ CCL           
                 CMP #'C           
                 BEQ CHANGE        ;BITMUSTER 11 UND 00 VERTAUSCHEN
                 CMP #'+           
                 BEQ PL            
                 CMP #'-           
                 BEQ MI            
                 CMP #13           
                 BNE CLOOP         
                 CLI               
                 JSR HOLD8         ;FARBRAM RETTEN
                 CLI               
                 RTS               
                                   
CHD:             DEC COL+1         
COLS:            CLI               
                 JMP CLOOP-3       ;FARBEN ZEIGEN
                                   
CLU:             INC COL           
                 JMP COLS          
CHU:             INC COL+1         
                 JMP COLS          
CCL:             DEC COL           
                 JMP COLS          
                                   
PL:              INC FARB11+1      
                 LDA #0            
                 STA FARB11-1      
                 JSR BITAUS        ;FARBRAM FAERBEN
                 JMP COLS          
MI:              DEC FARB11+1      
                 JMP PL+3          
                                   
                                   
CHANGE:          LDA BSPEI+1       ;BEREICHSSTARTADRESSE DER BITMAP
                 STA ZEI+1         
                 LDA BSPEI         
                 STA ZEI           
                 LDA #ZEI          
                 STA 2             
                 STA 3             
                                   
CH:              LDX #3            ;4 BITPAARE
                 LDY #0            
                 JSR READ          
                 STA SPEI+1        
CHB:             LDA SPEI+1        
                 AND TABELLE11,X   
                 CMP TABELLE11,X   
                 BEQ FOUND         
                 CMP TABELLE00,X   
                 BEQ FOUND1        
WEITER:          DEX               
                 BPL CHB           
                                   
                 LDA SPEI+1        
                 JSR WRITE         ;GEAENDERTES BYTE ZURUECKSCHREIBEN
                                   
                 INC ZEI           
                 BNE NOHID         
                 INC ZEI+1         
NOHID:           LDA ZEI+1         
                 CMP ZEI1+1        
                 BCC CH            
                 LDA ZEI           
                 CMP ZEI1          
                 BCC CH            
                 JMP COLS          
                                   
                                   
FOUND:           LDA TABELLE11,X   
                 EOR #$FF          
                 AND SPEI+1        ;WANDELN 11 NACH 00
                 STA SPEI+1        
                 JMP WEITER        
                                   
FOUND1:          LDA SPEI+1        
                 ORA TABELLE11,X   
                 STA SPEI+1        
                 JMP WEITER        ;WANDELN 00 NACH 11
                                   
                                   
COLIN:           LDA SSPEI         ;BEREICHSSTARTADRESSE VIDEORAM
                 STA ZEI           
                 LDA SSPEI+1       
                 STA ZEI+1         
                 LDA #ZEI          
                 STA 3             
                 LDA COL           
                 AND #$0F          
                 STA COL           
                 LDA COL+1         
                 ASL               
                 ASL               
                 ASL               
                 ASL               
                 ORA COL           
                 LDY #0            
SETCOL:          JSR WRITE         
                 INC ZEI           
                 BNE CNOHI         
                 INC ZEI+1         
CNOHI:           LDX ZEI+1         
                 CPX ZEI2+1        
                 BCC SETCOL        
                 LDX ZEI           
                 CPX ZEI2          
                 BCC SETCOL        
                 STA ZEI+1         ;FARBWERTE FUER AUSGABE IN ZEI
                 LDA FARB11+1      
                 AND #$0F          
                 STA ZEI           
                 CLI               
                 JMP ZEIOUT        ;FARBEN AUSGEBEN
                                   
                                   
BITAUS:          LDA SSPEI+1       
                 AND #3            
                 ORA #$D8          
                 STA ZEI3+1        
                 LDA SSPEI         ;ZEIGER AUF FARB-RAM AB $D800
                 STA ZEI3          
                 LDA ZEI2+1        
                 AND #3            
                 ORA #$D8          
                 STA EZEI+1        
                 LDA ZEI2          
                 STA EZEI          
                                   
                 LDY #0            
AUS:             LDA (ZEI3),Y      
                 AND #7            ;IM CHARSET-MODE SIND NUR BIT 0-2 SIGNIFIKANT
FARB11:          ORA #$00          
                 STA (ZEI3),Y      ;ANSONSTEN WUERDEN FALSCHE FARBEN GEZEIGT
                 INC ZEI3          
                 BNE NOHIC         
                 INC ZEI3+1        
NOHIC:           LDA ZEI3+1        
                 CMP EZEI+1        
                 BCC AUS           
                 LDA ZEI3          
                 CMP EZEI          
                 BCC AUS           
                 CLI               
                 RTS               
                                   
                                   
                                   
CLSPRITE:        LDA #$BF          
                 STA SZEI+1        
                 LDA #$80          ;SPRITES AB $BF80
                 STA SZEI          
                                   
                 LDA #SZEI         
                 STA 3             
                                   
                 LDY #$7F          
                 LDA #0            
CLSS:            JSR WRITE         
                 DEY               
                 BPL CLSS          
                 LDA #$00          
                 STA SPON+1        
                 CLI               
                 RTS               
                                   
                                   
                                   
CHARIN:          LDA ASPEI         
                 STA ZEI           
                 LDA ASPEI+1       
                 STA ZEI+1         ;STARTADRESSE DES BEREICHES (VIDEO-RAM)
                                   
                 LDA #0            
                 STA ZEI1          ;ZEIGER VORBEREITEN
                 LDA GOBEN         
                 LDX #ZEI1         
                 JSR MAL320        
                 LDA ZEI1+1        
                 CLC               
                 ADC #$A0          ;PLUS STARTADRESSE DER BITMAP
                 STA ZEI1+1        ;=ZEIGER AUF BEREICHSANFANG DER BITMAP
                 STA BSPEI+1       ;MERKEN
                 LDA ZEI1          
                 STA BSPEI         
                                   
CHAMAP:          LDY #0            
                 LDA #ZEI          
                 STA 2             
                 JSR READ          ;ZEICHENCODE LESEN
                 JSR INMAP         ;ZEICHENMATRIX IN BITMAP SCHREIBEN
                 INC ZEI           
                 BNE NOHI4         
                 INC ZEI+1         
NOHI4:           LDA ZEI+1         
                 CMP ZEI2+1        
                 BCC CHAMAP        
                 LDA ZEI           
                 CMP ZEI2          
                 BCC CHAMAP        
                 CLI               
                 RTS               
                                   
INMAP:           STY ZEI3+1        
                 ASL               
                 ROL ZEI3+1        
                 ASL               
                 ROL ZEI3+1        ;MAL 8
                 ASL               
                 ROL ZEI3+1        
                 STA ZEI3          
                 LDA ZEI3+1        
                 CLC               
                 ADC CHARANF       ;PLUS STARTADRESSE DES ZEICHENSATZES
                 STA ZEI3+1        ;=ZEIGER AUF ZEICHENMATRIX
                                   
                 LDA #ZEI3         
                 STA 2             
                 LDA #ZEI1         
                 STA 3             
                                   
CHAMA:           JSR READ          
                 JSR WRITE         
                 INY               
                 CPY #8            
                 BNE CHAMA         ;ZEICHENMATRIX IN BITMAP KOPIEREN
                 TYA               
                 CLC               
                 ADC ZEI1          
                 STA ZEI1          
                 LDA ZEI1+1        
                 ADC #0            ;ZEIGER AUF BITMAP AKTUALISIEREN
                 STA ZEI1+1        
                 RTS               
                                   
                                   
                                   
VIDIN:           LDA #0            
                 STA ZEI2          ;ZEIGER VORBEREITEN
                 STA ZEI2+1        
                 STA ZEI1          
                 STA ZEI1+1        
                                   
                 LDA GOBEN         ;OBERE GRENZE DES BEREICHS
                 LDX #ZEI1         ;ERGEBNIS IN ZEI1
                 JSR MAL40         ;STARTADRESSE DER BILDSCHIRMZEILE BERECHNEN
                 LDA GUNTEN        ;UNTERE GRENZE
                 LDX #ZEI2         
                 JSR MAL40         
                                   
                 LDA ZEI1+1        
                 CLC               
                 ADC #$8C          
                 STA ZEI3+1        ;STARTADRESSE AUF ANZEIGE-VIDEO-RAM BERECHNEN
                 STA SSPEI+1       
                 LDA ZEI1          
                 STA ZEI3          
                 STA SSPEI         ;MERKEN
                                   
                 LDA ZEI1          
                 STA ASPEI         ;ANFANGSADRESSE MERKEN
                 LDA ZEI1+1        
                 CLC               
                 ADC ZEI+1         
                 STA ZEI1+1        
                 STA ASPEI+1       
                                   
                 LDA ZEI2+1        ;ENDADRESSE DES BEREICHS BERECHNEN
                 CLC               
                 ADC ZEI+1         
                 STA ZEI2+1        
                                   
                 LDY #0            
                 LDA #ZEI1         
                 STA 2             
                 LDA #ZEI3         
                 STA 3             
                                   
COPVI:           JSR READ          
                 JSR WRITE         
                 INC ZEI1          
                 BNE NOHI1         
                 INC ZEI1+1        
NOHI1:           INC ZEI3          
                 BNE NOHI2         
                 INC ZEI3+1        
NOHI2:           LDA ZEI1+1        
                 CMP ZEI2+1        
                 BCC COPVI         ;BEREICH EINKOPIEREN
                 LDA ZEI1          
                 CMP ZEI2          
                 BCC COPVI         
                 CLI               
                 RTS               
                                   
                                   
                                   
SUCHVID:         LDA IOBUF         
                 STA ZEI+1         
                                   
CV:              LDA #0            
                 STA ZEI           
                 STA ZEI1          
                 LDA #$88          
                 STA ZEI1+1        
                                   
                 JSR ZEIOUT        ;ZEIGER AUSGEBEN
                                   
                 LDX #4            
                 LDY #0            
                 LDA #ZEI          
                 STA 2             
                 LDA #ZEI1         
                 STA 3             
                                   
COPVID:          JSR READ          
                 JSR WRITE         
                 INY               
                 BNE COPVID        ;VIDEO-RAM NACH $8800 KOPIEREN
                 INC ZEI+1         
                 INC ZEI1+1        
                 DEX               
                 BNE COPVID        
                 CLI               
                                   
VLOOP:           JSR GETIN         
                 BEQ VLOOP         
                 CMP #'+           
                 BEQ NEXTVID       
                 CMP #'-           
                 BEQ LASTVID       
                 CMP #13           
                 BNE VLOOP         
                                   
                 LDA ZEI+1         ;RICHTIGES VIDEO-RAM GEFUNDEN
                 SEC               
                 SBC #4            
                 STA ZEI+1         
                 RTS               ;ZEIGER AUF ANFANG DES VIDEO-RAMS
                                   
                                   
LASTVID:         LDA ZEI+1         
                 SEC               
                 SBC #8            
                 STA ZEI+1         
                 BNE CV            
                 LDA #$FC          ;BEI $0000 KANN NICHTS LIEGEN
                 STA ZEI+1         
                 BNE CV            
                                   
NEXTVID:         LDA ZEI+1         
                 BNE CV            
                 LDA #$04          
                 STA ZEI+1         
                 BNE CV            
                                   
                                   
                                   
HOLGRENZ:        LDA #0            
                 STA GOBEN         
                 LDA #25           
                 STA GUNTEN        
                 CLI               
GLOOP:           JSR GETIN         
                 BEQ GLOOP         
                 CMP #17           ;DOWN ?
                 BEQ GOT           
                 CMP #145          ;UP ?
                 BEQ GOH           
                 CMP #29           ;RIGHT ?
                 BEQ GUH           
                 CMP #157          ;LEFT ?
                 BEQ GUT           
                 CMP #13           ;RETURN ?
                 BNE GLOOP         
                 CLI               
                 RTS               
                                   
GUT:             LDA GUNTEN        
                 CMP #25           
                 BEQ GLOOP         
                 INC GUNTEN        
                 BNE GLOOP         
GOT:             LDX GUNTEN        
                 DEX               
                 CPX GOBEN         
                 BEQ GLOOP         ;GOBEN KANN NICHT GROESSER SEIN ALS GUNTEN !
                 INC GOBEN         
                 BNE GLOOP         
GOH:             LDA GOBEN         
                 BEQ GLOOP         
                 DEC GOBEN         
                 JMP GLOOP         
GUH:             LDX GOBEN         
                 INX               
                 CPX GUNTEN        
                 BEQ GLOOP         ;GUNTEN KANN NICHT KLEINER SEIN ALS GOBEN !
                 DEC GUNTEN        
                 BNE GLOOP         
                                   
                                   
                                   
BANKON:          LDA #$91          
                 STA $DD00         
                 LDA #$3F          
                 STA $DD02         
                 LDA #$20          
                 STA $D018         
                 LDA #$88          ;STARTADRESSE VIDEO-RAM
                 STA 648           
                 LDA #$1B          
                 STA $D011         
                 LDA #8            
                 STA $D016         
                 RTS               
                                   
                                   
                                   
MAPCL:           LDA #0            
                 STA ZEI           
                 LDA #$A0          
                 STA ZEI+1         
                                   
                 LDA #ZEI          
                 STA 3             
                                   
                 LDY #$00          
                 LDX #$20          
                 TYA               
CLMAP:           JSR WRITE         
                 INY               
                 BNE CLMAP         
                 INC ZEI+1         
                 DEX               
                 BNE CLMAP         
                 CLI               
                 RTS               
                                   
                                   
                                   
READ:            LDA 2             ;ANDEREN ZEIGER ALS 8E/8F BENUTZEN
                 STA $02B7         
                 JMP $02B3         
WRITE:           PHA               ;DIESE ROUTINEN ERMOEGLICHEN DAS LESEN UND
                 LDA 3             ;BESCHREIBEN DES EINGEFRORENEN SPEICHERS
                 STA $02AE         
                 PLA               
                 JMP $02A7         
                                   
                                   
                                   
SHOWBIT:         LDA #$91          
                 STA $DD00         
                 LDA #$3F          
                 STA $DD02         
                 LDA #$38          
                 STA $D018         
                 LDA #$3B          
                 STA $D011         
                 LDA #$18          
                 STA $D016         
                 LDA #$00          
                 STA $D020         
                 STA $D021         
                 JSR FRESTAU       ;FARBRAM ($D800-$DBFF) RESTAURIEREN
                 CLI               
                 RTS               
                                   
                                   
                                   
MAL320:          STA $01,X         ;MAL 256
                 LSR               
                 ROR $00,X         
                 LSR               ;MAL 64
                 ROR $00,X         
                 ADC $01,X         
                 STA $01,X         
                 RTS               
                                   
                                   
MAL40:           PHA               ;WERT MERKEN
                 LSR               
                 ROR $00,X         
                 LSR               
                 ROR $00,X         
                 LSR               ;MAL 32
                 ROR $00,X         
                 STA $01,X         
                 PLA               ;WERT WIEDERHOLEN
                 ASL               
                 ASL               ;MAL 8
                 ASL               
                 ADC $00,X         ;CARRY WAR 0 (WERT < 32 !)
                 STA $00,X         
                 BCC NOHI          
                 INC $01,X         
NOHI:            RTS               
                                   
                                   
                                   
SETZEI:          LDX #$04          
                 LDY #$00          
                 STY EZEI          
                 LDA #$D8          
                 STA EZEI+1        
                 STY SZEI          ;FARBRAM WIRD NACH $0400 GERETTET
                 LDA #$13          
                 STA SZEI+1        
                 RTS               
                                   
FRETT:           JSR SETZEI        
                 LDA (EZEI),Y      
                 ASL               
                 ASL               
                 ASL               
                 ASL               
                 STA (SZEI),Y      
                 JSR ERAUF         
                 LDA (EZEI),Y      
                 AND #$0F          
                 ORA (SZEI),Y      
                 STA (SZEI),Y      
                 JSR SRAUF         
                 JSR ERAUF         
                 JMP FRETT+3       
                                   
FHOL:            JSR SETZEI        
                 LDA (SZEI),Y      
                 PHA               
                 LSR               
                 LSR               
                 LSR               
                 LSR               
                 STA (EZEI),Y      
                 JSR ERAUF         
                 PLA               
                 AND #$0F          
                 STA (EZEI),Y      
                 JSR SRAUF         
                 JSR ERAUF         
                 JMP FHOL+3        
                                   
SRAUF:           INC SZEI          
                 BNE NOS           
                 INC SZEI+1        
NOS:             RTS               
                                   
ERAUF:           INC EZEI          
                 BNE NOS           
                 INC EZEI+1        
                 DEX               
                 BNE NOS           
                 PLA               
                 PLA               
                 RTS               
                                   
                                   
                                   
TX:              .BY "1 - REBUILD SCREEN ",13,13
                 .BY "2 - OLD",0   
CHARANF:         .BY 0             
GOBEN:           .BY 0             
GUNTEN:          .BY 0             
BUF:             .DB 4             
STAB:            .BY $80,$81,$82,$C0
LIDO:            .BY 0             
LIUP:            .BY 0             
SSPEI:           .BY 0,0           
COL:             .BY 0,0           
ASPEI:           .BY 0,0           
BSPEI:           .BY 0,0           
IOBUF:           .DB 9             
TABELLE00:       .BY 0,0,0,0       
TABELLE11:       .BY $C0,$30,$0C,3 
                                   
                                   
                                   
                                   
