; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $0564-$05D9.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:0564-05D9", ROM0[$0564]
ResidualROM00_0564::
	db $3E, $02, $EA, $23, $C6, $C9, $3E, $04, $06, $00, $CD, $64, $02, $3E, $02, $EA
	db $23, $C6, $C9, $3E, $0A, $06, $00, $CD, $64, $02, $C9, $AF, $EA, $23, $C6, $3E
	db $03, $06, $00, $CD, $64, $02, $FA, $23, $C6, $FE, $07, $28, $05, $3E, $02, $EA
	db $23, $C6, $C9, $3E, $02, $06, $00, $CD, $64, $02, $3E, $08, $EA, $23, $C6, $C9
	db $3E, $0D, $06, $00, $CD, $64, $02, $3E, $02, $EA, $23, $C6, $C9, $3E, $16, $EA
	db $FF, $27, $E0, $AB, $3E, $00, $EA, $00, $28, $E0, $AC, $CD, $AA, $44, $3E, $11
	db $E1, $C3, $B8, $02, $0B, $46, $50, $16, $CA, $48, $68, $00, $40, $1D, $00, $40
	db $17, $00, $40, $13, $00, $50
ASSERT @ == $05DA
