; PROBABLE native B $5B header, consumed by resident main states.
; Index1 record has four original big-endian relative stream displacements.
; SYNTHETIC forced resident load/setup; no natural launch or audio claim.
SECTION "B5B A1E pointer header", ROMX[$6000], BANK[$2D]
ResidualROM2D_6000::
BankB5BA1EPointerHeader::
	dw $617B, BankB5BLowerPointerPrefix, $600C, $603F, $6061, $614B
ASSERT @ == $600C
SECTION "B5B lower stream record1", ROMX[$65D4], BANK[$2D]
BankB5BLowerStreamRecord1::
	db $04, $00, $00, $0A, $03, $AB, $06, $F0, $08, $E9
ASSERT @ == $65DE

; Only indices0/1 are represented; total table extent is unknown.
SECTION "B5B lower pointer prefix", ROMX[$65B4], BANK[$2D]
BankB5BLowerPointerPrefix::
	dw $7259, BankB5BLowerStreamRecord1
ASSERT @ == $65B8

; PROBABLE slot0 prefix through first positive countdown, not full stream.
SECTION "B5B slot0 stream prefix", ROMX[$65DE], BANK[$2D]
ResidualROM2D_65DE::
BankB5BSlot0StreamPrefix::
	db $00 ; consumed by installation
	db $C0, $07, $00 ; mapped B $65DF
	db $B1, $40, $00 ; mapped B $65E2
	db $FD, $00, $00 ; mapped B $65E5
	db $9B, $39, $1B ; mapped B $65E8
ASSERT @ == $65EB

; PROBABLE slot1 prefix through first positive countdown, not full stream.
SECTION "B5B slot1 stream prefix", ROMX[$697F], BANK[$2D]
BankB5BSlot1StreamPrefix::
	db $00 ; consumed by installation
	db $C0, $01, $00 ; mapped B $6980
	db $B1, $40, $00 ; mapped B $6983
	db $FD, $00, $00 ; mapped B $6986
	db $9A, $4B, $0E ; mapped B $6989
ASSERT @ == $698C

; PROBABLE slot2 prefix through first positive countdown, not full stream.
SECTION "B5B slot2 stream prefix", ROMX[$6CC4], BANK[$2D]
BankB5BSlot2StreamPrefix::
	db $00 ; consumed by installation
	db $C0, $02, $00 ; mapped B $6CC5
	db $B1, $40, $00 ; mapped B $6CC8
	db $FD, $00, $00 ; mapped B $6CCB
	db $9F, $45, $1D ; mapped B $6CCE
ASSERT @ == $6CD1

; PROBABLE slot3 prefix through first positive countdown, not full stream.
SECTION "B5B slot3 stream prefix", ROMX[$6EBD], BANK[$2D]
BankB5BSlot3StreamPrefix::
	db $00 ; consumed by installation
	db $C0, $01, $00 ; mapped B $6EBE
	db $B1, $40, $00 ; mapped B $6EC1
	db $FD, $00, $00 ; mapped B $6EC4
	db $9E, $29, $02 ; mapped B $6EC7
ASSERT @ == $6ECA
