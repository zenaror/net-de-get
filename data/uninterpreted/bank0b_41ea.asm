; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $0B, address $41EA-$4226.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 0B:41EA-4226", ROMX[$41EA], BANK[$0B]
ResidualROM0B_41EA::
	db $A7, $20, $31, $01, $A3, $02, $11, $D8, $3E, $CD, $B6, $01, $7D, $B4, $28, $20
	db $11, $12, $01, $19, $11, $55, $C6, $01, $10, $00, $CD, $76, $02, $3E, $10, $21
	db $55, $C6, $85, $6F, $3E, $00, $8C, $67, $AF, $77, $21, $55, $C6, $CD, $E9, $01
	db $CD, $B9, $01, $C9, $3E, $0D, $11, $5A, $4F, $CD, $E3, $01, $C9
ASSERT @ == $4227
