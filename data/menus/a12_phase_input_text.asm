; PROBABLE six zero-terminated Japanese selection strings per action list.
; Original glyph bytes remain literal, with no translation or semantic title.
SECTION "A12 phase input text0 5334-535D", ROMX[$5334], BANK[$09]
ResidualROM09_5334::
A12PhaseInputTextList0::
; Original item 0.
	db $E5, $DB, $FE, $CD, $3C, $E6, $00
; Original item 1.
	db $FF, $E3, $C3, $F7, $D9, $00
; Original item 2.
	db $C9, $FF, $E1, $D0, $ED, $F7, $00
; Original item 3.
	db $CF, $3C, $FE, $DF, $3C, $00
; Original item 4.
	db $FF, $DF, $F7, $FE, $D4, $95, $A9, $B7, $00
; Original item 5.
	db $C1, $E0, $F1, $95, $A9, $B7, $00
ASSERT @ == $535E

SECTION "A12 phase input text1 535E-5386", ROMX[$535E], BANK[$09]
A12PhaseInputTextList1::
; Original item 0.
	db $E5, $DB, $FE, $CD, $3C, $E6, $00
; Original item 1.
	db $FF, $E3, $C3, $F7, $D9, $00
; Original item 2.
	db $C9, $FF, $E1, $D0, $ED, $F7, $00
; Original item 3.
	db $CF, $3C, $FE, $DF, $3C, $00
; Original item 4.
	db $C5, $CF, $FE, $CB, $95, $A9, $B7, $00
; Original item 5.
	db $C1, $E0, $F1, $95, $A9, $B7, $00
ASSERT @ == $5387

SECTION "A12 phase input text2 5387-53B1", ROMX[$5387], BANK[$09]
A12PhaseInputTextList2::
; Original item 0.
	db $E5, $DB, $FE, $CD, $3C, $E6, $00
; Original item 1.
	db $FF, $E3, $C3, $F7, $D9, $00
; Original item 2.
	db $C9, $FF, $E1, $D0, $ED, $F7, $00
; Original item 3.
	db $CF, $3C, $FE, $DF, $3C, $00
; Original item 4.
	db $C5, $CF, $FE, $CB, $95, $A9, $B7, $00
; Original item 5.
	db $FF, $DF, $F7, $FE, $D4, $95, $A9, $B7, $00
ASSERT @ == $53B2
