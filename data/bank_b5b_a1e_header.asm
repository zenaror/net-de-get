; PROBABLE native B $5B header, consumed by resident main states.
; Index1 record has four original big-endian relative stream displacements.
; SYNTHETIC forced resident load/setup; no natural launch or audio claim.
SECTION "B5B A1E pointer header", ROMX[$6000], BANK[$2D]
ResidualROM2D_6000::
BankB5BA1EPointerHeader::
	dw $617B, $65B4, $600C, $603F, $6061, $614B
ASSERT @ == $600C
SECTION "B5B lower stream record1", ROMX[$65D4], BANK[$2D]
BankB5BLowerStreamRecord1::
	db $04, $00, $00, $0A, $03, $AB, $06, $F0, $08, $E9
ASSERT @ == $65DE
