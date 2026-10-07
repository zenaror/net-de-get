; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $12B9-$12BE.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:12B9-12BE", ROM0[$12B9]
ResidualROM00_12B9::
	db $F3, $CD, $BF, $12, $FB, $C9
ASSERT @ == $12BF
