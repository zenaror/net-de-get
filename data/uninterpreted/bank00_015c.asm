; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $015C-$0170.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:015C-0170", ROM0[$015C]
ResidualROM00_015C::
	db $C3, $A6, $06, $C3, $DF, $06, $C3, $22, $07, $C3, $47, $07, $C3, $56, $07, $C3
	db $77, $07, $C3, $82, $07
ASSERT @ == $0171
