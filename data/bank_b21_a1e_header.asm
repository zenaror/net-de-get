; PROBABLE native B $21 header, consumed by resident main states.
; Index1 record has four original big-endian relative stream displacements.
; SYNTHETIC forced resident load/setup; no natural launch or audio claim.
SECTION "B21 A1E pointer header", ROMX[$6000], BANK[$10]
ResidualROM10_6000::
BankB21A1EPointerHeader::
	dw $617B, $660E, $600C, $603F, $6061, $614B
ASSERT @ == $600C
SECTION "B21 lower stream record1", ROMX[$662E], BANK[$10]
BankB21LowerStreamRecord1::
	db $04, $00, $00, $0A, $02, $E5, $05, $7A, $07, $01
ASSERT @ == $6638
