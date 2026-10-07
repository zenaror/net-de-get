; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $0A, address $455F-$45FE.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 0A:455F-45FE", ROMX[$455F], BANK[$0A]
ResidualROM0A_455F::
	db $CD, $88, $02, $FA, $03, $C7, $A7, $CA, $7D, $45, $FA, $01, $D0, $EA, $33, $C7
	db $FA, $02, $D0, $47, $FA, $07, $D0, $80, $EA, $34, $C7, $CD, $8B, $02, $C9, $E6
	db $F0, $CB, $37, $EA, $C3, $C5, $21, $04, $C0, $01, $B0, $45, $16, $7B, $1E, $A0
	db $FA, $C3, $C5, $3C, $EA, $CF, $C5, $18, $0E, $3E, $20, $22, $7B, $22, $D6, $04
	db $5F, $7A, $22, $0A, $03, $22, $15, $FA, $CF, $C5, $3D, $EA, $CF, $C5, $20, $E9
	db $C9, $06, $05, $05, $04, $04, $03, $03, $E5, $EA, $C3, $C5, $0E, $64, $CD, $34
	db $02, $7D, $EA, $F7, $DC, $7C, $0E, $0A, $CD, $34, $02, $7D, $EA, $F8, $DC, $7C
	db $EA, $F9, $DC, $E1, $7A, $22, $7B, $22, $FA, $F7, $DC, $C6, $10, $22, $3E, $06
	db $22, $7A, $22, $7B, $C6, $04, $22, $FA, $F8, $DC, $C6, $10, $22, $3E, $06, $22
	db $7A, $22, $7B, $C6, $08, $22, $FA, $F9, $DC, $C6, $10, $22, $3E, $06, $22, $C9
ASSERT @ == $45FF
