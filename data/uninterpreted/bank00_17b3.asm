; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $17B3-$1FFF.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:17B3-1FFF", ROM0[$17B3]
ResidualROM00_17B3::
	db $53, $59, $53, $30, $CD, $80, $FF, $CD, $8C, $01, $CD, $E8, $39, $C9, $00, $00
	ds $83D, $00
ASSERT @ == $2000
