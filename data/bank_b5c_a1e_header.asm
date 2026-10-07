; PROBABLE native B $5C header, consumed by resident main states.
; Index1 record has four original big-endian relative stream displacements.
; SYNTHETIC forced resident load/setup; no natural launch or audio claim.
SECTION "B5C A1E pointer header", ROMX[$4000], BANK[$2E]
ResidualROM2E_4000::
BankB5CA1EPointerHeader::
	dw $617B, $660E, $600C, $603F, $6061, $614B
ASSERT @ == $400C
SECTION "B5C lower stream record1", ROMX[$462E], BANK[$2E]
BankB5CLowerStreamRecord1::
	db $04, $00, $00, $0A, $02, $2A, $09, $FF, $11, $86
ASSERT @ == $4638
