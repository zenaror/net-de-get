; PROBABLE native B $21 header, consumed by resident main states.
; Index1 record has four original big-endian relative stream displacements.
; SYNTHETIC forced resident load/setup; no natural launch or audio claim.
SECTION "B21 A1E pointer header", ROMX[$6000], BANK[$10]
ResidualROM10_6000::
BankB21A1EPointerHeader::
	dw $617B, BankB21LowerPointerPrefix, $600C, $603F, $6061, $614B
ASSERT @ == $600C
SECTION "B21 lower stream record1", ROMX[$662E], BANK[$10]
BankB21LowerStreamRecord1::
	db $04, $00, $00, $0A, $02, $E5, $05, $7A, $07, $01
ASSERT @ == $6638

; Only indices0/1 are represented; total table extent is unknown.
SECTION "B21 lower pointer prefix", ROMX[$660E], BANK[$10]
BankB21LowerPointerPrefix::
	dw $7000, BankB21LowerStreamRecord1
ASSERT @ == $6612

; PROBABLE slot0 prefix through first positive countdown, not full stream.
SECTION "B21 slot0 stream prefix", ROMX[$6638], BANK[$10]
ResidualROM10_6638::
BankB21Slot0StreamPrefix::
	db $00 ; consumed by installation
	db $C0, $0E, $00 ; mapped B $6639
	db $FD, $00, $00 ; mapped B $663C
	db $9C, $45, $0B ; mapped B $663F
ASSERT @ == $6642

; PROBABLE slot1 prefix through first positive countdown, not full stream.
SECTION "B21 slot1 stream prefix", ROMX[$6913], BANK[$10]
BankB21Slot1StreamPrefix::
	db $00 ; consumed by installation
	db $C0, $09, $00 ; mapped B $6914
	db $FD, $00, $00 ; mapped B $6917
	db $9A, $35, $0B ; mapped B $691A
ASSERT @ == $691D

; PROBABLE slot2 prefix through first positive countdown, not full stream.
SECTION "B21 slot2 stream prefix", ROMX[$6BA8], BANK[$10]
BankB21Slot2StreamPrefix::
	db $00 ; consumed by installation
	db $C0, $04, $00 ; mapped B $6BA9
	db $FD, $00, $00 ; mapped B $6BAC
	db $9A, $39, $24 ; mapped B $6BAF
ASSERT @ == $6BB2

; PROBABLE slot3 prefix through first positive countdown, not full stream.
SECTION "B21 slot3 stream prefix", ROMX[$6D2F], BANK[$10]
BankB21Slot3StreamPrefix::
	db $00 ; consumed by installation
	db $C0, $00, $00 ; mapped B $6D30
	db $FD, $00, $00 ; mapped B $6D33
	db $9A, $24, $00 ; mapped B $6D36
	db $80, $18 ; mapped B $6D39
ASSERT @ == $6D3B
