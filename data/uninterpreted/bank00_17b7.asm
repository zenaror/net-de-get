; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $17B7-$1FFF.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:17B7-1FFF", ROM0[$17B7]
ResidualROM00_17B7::
	db $CD, $80, $FF, $CD, $8C, $01, $CD, $E8, $39, $C9, $00, $00, $00, $00, $00, $00
	ds $839, $00
ASSERT @ == $2000
