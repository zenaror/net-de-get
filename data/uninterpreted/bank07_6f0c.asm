; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $07, address $6F0C-$6F5B.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 07:6F0C-6F5B", ROMX[$6F0C], BANK[$07]
ResidualROM07_6F0C::
	db $8B, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C
	db $8C, $8C, $8C, $8D, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07
	db $07, $07, $07, $07, $07, $07, $07, $07, $E1, $E2, $E2, $E2, $E2, $E2, $E2, $E2
	db $E2, $E2, $E2, $E2, $E2, $E2, $E2, $E2, $E2, $E2, $E2, $E3, $06, $06, $06, $06
	db $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06
ASSERT @ == $6F5C
