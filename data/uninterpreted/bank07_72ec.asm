; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $07, address $72EC-$7333.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 07:72EC-7333", ROMX[$72EC], BANK[$07]
ResidualROM07_72EC::
	db $00, $00, $AD, $35, $B5, $56, $FF, $7F, $1F, $00, $0D, $21, $B5, $56, $FF, $7F
	db $00, $7C, $8C, $3D, $B5, $56, $FF, $7F, $00, $00, $4A, $29, $B5, $56, $FF, $7F
	db $00, $00, $4A, $29, $B5, $56, $FF, $7F, $00, $00, $4A, $29, $B5, $56, $FF, $7F
	db $0D, $00, $92, $10, $1F, $21, $FF, $7F, $43, $01, $89, $1A, $F4, $47, $FF, $7F
	db $1F, $7C, $00, $00, $FF, $03, $1F, $00
ASSERT @ == $7334
