; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $0A, address $4886-$488D.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 0A:4886-488D", ROMX[$4886], BANK[$0A]
ResidualROM0A_4886::
	db $FF, $7F, $FF, $7F, $FF, $7F, $FF, $7F
ASSERT @ == $488E
