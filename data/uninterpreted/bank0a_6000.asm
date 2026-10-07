; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $0A, address $6000-$6001.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 0A:6000-6001", ROMX[$6000], BANK[$0A]
ResidualROM0A_6000::
	db $1B, $01
ASSERT @ == $6002
