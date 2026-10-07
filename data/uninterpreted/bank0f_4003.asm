; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $0F, address $4003-$406D.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 0F:4003-406D", ROMX[$4003], BANK[$0F]
ResidualROM0F_4003::
	db $C3, $0E, $41, $C3, $C8, $41, $C3, $1B, $40, $21, $00, $CF, $11, $A0, $CF, $06
	db $40, $2A, $12, $13, $05, $20, $FA, $C9, $21, $00, $50, $2A, $EA, $92, $CF, $2A
	db $EA, $93, $CF, $2A, $EA, $90, $CF, $2A, $EA, $91, $CF, $2A, $EA, $94, $CF, $2A
	db $EA, $95, $CF, $2A, $EA, $96, $CF, $2A, $EA, $97, $CF, $2A, $EA, $98, $CF, $2A
	db $EA, $99, $CF, $2A, $EA, $9A, $CF, $2A, $EA, $9B, $CF, $3E, $FF, $EA, $84, $CF
	db $EA, $88, $CF, $AF, $EA, $89, $CF, $C9, $1A, $6F, $13, $1A, $67, $13, $C9, $21
	db $00, $CF, $06, $80, $3E, $00, $22, $05, $20, $FC, $C9
ASSERT @ == $406E
