; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $2D46-$2D52.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:2D46-2D52", ROM0[$2D46]
ResidualROM00_2D46::
	db $EA, $C3, $C1, $F0, $4F, $E6, $01, $F5, $AF, $E0, $4F, $18, $18
ASSERT @ == $2D53
