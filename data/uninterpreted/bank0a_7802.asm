; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $0A, address $7802-$7FFF.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 0A:7802-7FFF", ROMX[$7802], BANK[$0A]
ResidualROM0A_7802::
	ds $7FE, $00
ASSERT @ == $8000
