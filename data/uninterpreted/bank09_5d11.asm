; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $09, address $5D11-$5D5B.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 09:5D11-5D5B", ROMX[$5D11], BANK[$09]
ResidualROM09_5D11::
	db $7D, $93, $6F, $7C, $9A, $67, $C9, $C5, $06, $00, $B7, $4F, $D6, $64, $38, $03
	db $04, $18, $F7, $78, $22, $79, $06, $00, $B7, $4F, $D6, $0A, $38, $03, $04, $18
	db $F7, $78, $22, $79, $06, $00, $B7, $4F, $D6, $01, $38, $03, $04, $18, $F7, $78
	db $22, $C1, $C9, $F5, $F3, $F0, $41, $E6, $02, $20, $FA, $F1, $77, $FB, $C9, $F5
	db $F3, $F0, $41, $E6, $02, $20, $FA, $F1, $12, $FB, $C9
ASSERT @ == $5D5C
