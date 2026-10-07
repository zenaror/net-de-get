; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $2D, address $65B8-$65D3.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 2D:65B8-65D3", ROMX[$65B8], BANK[$2D]
ResidualROM2D_65B8::
	db $59, $72, $59, $72, $59, $72, $59, $72, $59, $72, $59, $72, $59, $72, $59, $72
	db $59, $72, $59, $72, $59, $72, $59, $72, $59, $72, $59, $72
ASSERT @ == $65D4
