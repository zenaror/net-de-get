; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $07, address $728A-$729D.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 07:728A-729D", ROMX[$728A], BANK[$07]
ResidualROM07_728A::
	ds $14, $00
ASSERT @ == $729E
