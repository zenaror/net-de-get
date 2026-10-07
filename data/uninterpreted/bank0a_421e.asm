; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $0A, address $421E-$4223.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 0A:421E-4223", ROMX[$421E], BANK[$0A]
ResidualROM0A_421E::
	db $50, $51, $00, $00, $3A, $00
ASSERT @ == $4224
