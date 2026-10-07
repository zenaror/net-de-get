; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $0A, address $422D-$426C.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 0A:422D-426C", ROMX[$422D], BANK[$0A]
ResidualROM0A_422D::
	db $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
	db $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
	db $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
	db $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $EA, $00, $EB, $00
ASSERT @ == $426D
