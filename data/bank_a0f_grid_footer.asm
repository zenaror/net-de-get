; PROBABLE reached 20-column two-plane maps; Japanese bytes preserved.
SECTION "A0F grid footer maps", ROMX[$6F0C], BANK[$07]
ResidualROM07_6F0C::
A0FGridFooterNonzero::
	db $8B, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C
	db $8C, $8C, $8C, $8D, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07
	db $07, $07, $07, $07, $07, $07, $07, $07
A0FGridFooterZero::
	db $E1, $E2, $E2, $E2, $E2, $E2, $E2, $E2, $E2, $E2, $E2, $E2, $E2, $E2, $E2, $E2
	db $E2, $E2, $E2, $E3, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06
	db $06, $06, $06, $06, $06, $06, $06, $06
ASSERT @ == $6F5C
