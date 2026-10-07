; PROBABLE native B $5C header, consumed by resident main states.
; Index1 record has four original big-endian relative stream displacements.
; SYNTHETIC forced resident load/setup; no natural launch or audio claim.
SECTION "B5C A1E pointer header", ROMX[$4000], BANK[$2E]
ResidualROM2E_4000::
BankB5CA1EPointerHeader::
	dw $617B, BankB5CLowerPointerPrefix + $2000, $600C, $603F, $6061, $614B
ASSERT @ == $400C
SECTION "B5C lower stream record1", ROMX[$462E], BANK[$2E]
BankB5CLowerStreamRecord1::
	db $04, $00, $00, $0A, $02, $2A, $09, $FF, $11, $86
ASSERT @ == $4638

; Only indices0/1 are represented; total table extent is unknown.
SECTION "B5C lower pointer prefix", ROMX[$460E], BANK[$2E]
BankB5CLowerPointerPrefix::
	dw $7E3E, BankB5CLowerStreamRecord1 + $2000
ASSERT @ == $4612

; PROBABLE slot0 prefix through first positive countdown, not full stream.
SECTION "B5C slot0 stream prefix", ROMX[$4638], BANK[$2E]
ResidualROM2E_4638::
BankB5CSlot0StreamPrefix::
	db $00 ; consumed by installation
	db $C0, $07, $00 ; mapped B $6639
	db $B1, $40, $00 ; mapped B $663C
	db $96, $51, $3B ; mapped B $663F
ASSERT @ == $4642

; PROBABLE slot1 prefix through first positive countdown, not full stream.
SECTION "B5C slot1 stream prefix", ROMX[$4858], BANK[$2E]
BankB5CSlot1StreamPrefix::
	db $00 ; consumed by installation
	db $C0, $00, $00 ; mapped B $6859
	db $B1, $40, $00 ; mapped B $685C
	db $98, $45, $07 ; mapped B $685F
ASSERT @ == $4862

; PROBABLE slot2 prefix through first positive countdown, not full stream.
SECTION "B5C slot2 stream prefix", ROMX[$502D], BANK[$2E]
BankB5CSlot2StreamPrefix::
	db $00 ; consumed by installation
	db $C0, $06, $00 ; mapped B $702E
	db $B1, $40, $00 ; mapped B $7031
	db $9B, $41, $05 ; mapped B $7034
ASSERT @ == $5037

; PROBABLE slot3 prefix through first positive countdown, not full stream.
SECTION "B5C slot3 stream prefix", ROMX[$57B4], BANK[$2E]
BankB5CSlot3StreamPrefix::
	db $00 ; consumed by installation
	db $C0, $00, $00 ; mapped B $77B5
	db $B1, $40, $00 ; mapped B $77B8
	db $9E, $2E, $01 ; mapped B $77BB
ASSERT @ == $57BE
