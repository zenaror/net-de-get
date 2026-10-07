; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $0F, address $5296-$5FFF.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 0F:5296-5FFF", ROMX[$5296], BANK[$0F]
ResidualROM0F_5296::
	ds $D6A, $00
ASSERT @ == $6000
