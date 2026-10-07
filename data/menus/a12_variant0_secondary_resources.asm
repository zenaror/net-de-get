; PROBABLE secondary resource table/layout from 5117 consumer and measured bounds.
; Original Japanese bytes preserved. Count byte is ignored by the secondary reader.
SECTION "A12 variant0 secondary table 6EE0-6EF1", ROMX[$6EE0], BANK[$30]
A12Variant0SecondaryResourceTable::
	dw A12Variant0SecondaryResource0
	dw A12Variant0SecondaryResource1
	dw A12Variant0SecondaryResource2
	dw A12Variant0SecondaryResource3
	dw A12Variant0SecondaryResource4
	dw A12Variant0SecondaryResource5
	dw A12Variant0SecondaryResource6
	dw A12Variant0SecondaryResource7
	dw A12Variant0SecondaryResource8
ASSERT @ == $6EF2

SECTION "A12 variant0 secondary object0 6EF2-6F56", ROMX[$6EF2], BANK[$30]
A12Variant0SecondaryResource0::
	db $18 ; measured object count, not loaded by 5117
	db $00, $81, $46, $10
	db $FF, $00, $00, $68
	db $FE, $83, $00, $00
	db $00, $81, $46, $18
	db $00, $71, $46, $0A
	db $FE, $82, $00, $00
	db $01, $71, $46, $01
	db $01, $5C, $46, $06
	db $02, $50, $46, $06
	db $02, $44, $46, $05
	db $01, $3A, $46, $05
	db $00, $2E, $42, $06
	db $FE, $82, $00, $00
	db $01, $2E, $42, $01
	db $FF, $00, $37, $68
	db $FE, $83, $00, $00
	db $01, $21, $46, $06
	db $02, $19, $46, $06
	db $02, $12, $47, $05
	db $01, $0B, $49, $05
	db $01, $03, $4B, $05
	db $00, $FA, $50, $19
	db $00, $FA, $50, $11
	db $00, $FA, $50, $0A
	db $00, $FA, $50, $32
ASSERT @ == $6F57

SECTION "A12 variant0 secondary object1 6F57-707F", ROMX[$6F57], BANK[$30]
A12Variant0SecondaryResource1::
	db $49 ; measured object count, not loaded by 5117
	db $00, $00, $50, $58
	db $00, $00, $50, $28
	db $00, $00, $50, $1C
	db $00, $00, $50, $28
	db $00, $00, $50, $58
	db $00, $00, $50, $28
	db $00, $00, $50, $58
	db $00, $00, $50, $28
	db $00, $00, $50, $1C
	db $00, $00, $50, $28
	db $00, $00, $50, $28
	db $00, $00, $50, $14
	db $00, $00, $50, $14
	db $00, $00, $50, $14
	db $00, $00, $50, $34
	db $00, $00, $50, $1C
	db $00, $00, $50, $1C
	db $00, $00, $50, $1C
	db $00, $00, $50, $1C
	db $00, $00, $50, $1C
	db $00, $00, $50, $1C
	db $00, $00, $50, $1C
	db $00, $00, $50, $1C
	db $00, $00, $50, $1C
	db $00, $00, $50, $1C
	db $00, $00, $50, $1C
	db $00, $00, $50, $1C
	db $00, $00, $50, $1C
	db $00, $00, $50, $1C
	db $00, $00, $50, $1C
	db $00, $00, $50, $1C
	db $00, $00, $50, $1C
	db $00, $00, $50, $1C
	db $00, $00, $50, $1C
	db $00, $00, $50, $1C
	db $00, $00, $50, $1C
	db $00, $00, $50, $1C
	db $00, $00, $50, $1C
	db $00, $00, $50, $1C
	db $00, $00, $50, $1E
	db $00, $00, $50, $1E
	db $00, $00, $50, $1E
	db $00, $00, $50, $1E
	db $00, $00, $50, $1E
	db $00, $00, $50, $1E
	db $00, $00, $50, $1E
	db $00, $00, $50, $1E
	db $00, $00, $50, $1E
	db $00, $00, $50, $1E
	db $00, $00, $50, $1E
	db $00, $00, $50, $1E
	db $00, $00, $50, $1E
	db $00, $00, $50, $1E
	db $00, $00, $50, $1E
	db $00, $00, $50, $1E
	db $00, $00, $50, $1E
	db $00, $00, $50, $1E
	db $00, $00, $50, $1E
	db $00, $00, $50, $1E
	db $00, $00, $50, $1E
	db $00, $00, $50, $1E
	db $00, $00, $50, $1E
	db $00, $00, $50, $1E
	db $00, $00, $50, $1E
	db $00, $00, $50, $1E
	db $00, $00, $50, $0A
	db $00, $00, $50, $0A
	db $00, $00, $50, $0A
	db $00, $00, $50, $0A
	db $00, $00, $50, $0A
	db $00, $00, $50, $0A
	db $00, $00, $50, $19
	db $00, $00, $50, $32
	db $00, $00, $50, $32
ASSERT @ == $7080

SECTION "A12 variant0 secondary object2 7080-70BC", ROMX[$7080], BANK[$30]
A12Variant0SecondaryResource2::
	db $0E ; measured object count, not loaded by 5117
	db $00, $00, $50, $28
	db $00, $00, $50, $1C
	db $00, $00, $50, $28
	db $00, $00, $50, $58
	db $00, $00, $50, $28
	db $00, $00, $50, $58
	db $00, $00, $50, $28
	db $00, $00, $50, $1C
	db $00, $00, $50, $28
	db $00, $00, $50, $28
	db $00, $00, $50, $14
	db $00, $00, $50, $14
	db $00, $00, $50, $14
	db $00, $00, $50, $14
	db $00, $00, $50, $14
ASSERT @ == $70BD

SECTION "A12 variant0 secondary object3 70BD-70FD", ROMX[$70BD], BANK[$30]
A12Variant0SecondaryResource3::
	db $0F ; measured object count, not loaded by 5117
	db $00, $00, $50, $14
	db $00, $00, $50, $0A
	db $00, $00, $50, $14
	db $FE, $82, $00, $00
	db $01, $00, $50, $01
	db $01, $07, $50, $04
	db $01, $17, $50, $06
	db $01, $27, $51, $06
	db $01, $3F, $52, $03
	db $00, $58, $58, $14
	db $00, $58, $58, $0C
	db $00, $58, $57, $08
	db $00, $58, $57, $18
	db $00, $58, $57, $01
	db $00, $5B, $57, $14
	db $00, $5B, $57, $32
ASSERT @ == $70FE

SECTION "A12 variant0 secondary object4 70FE-713A", ROMX[$70FE], BANK[$30]
A12Variant0SecondaryResource4::
	db $0E ; measured object count, not loaded by 5117
	db $00, $00, $50, $14
	db $00, $00, $50, $08
	db $00, $00, $50, $05
	db $00, $00, $50, $0A
	db $00, $00, $50, $14
	db $FE, $82, $00, $00
	db $01, $FE, $50, $01
	db $01, $FE, $4F, $05
	db $01, $03, $4D, $05
	db $01, $08, $4B, $05
	db $01, $0D, $49, $04
	db $01, $10, $47, $04
	db $01, $13, $45, $04
	db $00, $16, $43, $14
	db $00, $16, $43, $32
ASSERT @ == $713B

SECTION "A12 variant0 secondary object5 713B-716B", ROMX[$713B], BANK[$30]
A12Variant0SecondaryResource5::
	db $0B ; measured object count, not loaded by 5117
	db $00, $00, $50, $14
	db $FF, $00, $0F, $6A
	db $00, $00, $50, $0A
	db $00, $00, $50, $14
	db $FE, $82, $00, $00
	db $01, $00, $50, $01
	db $01, $04, $50, $03
	db $01, $0C, $4D, $05
	db $01, $1B, $4A, $05
	db $01, $24, $48, $05
	db $00, $38, $44, $32
	db $00, $38, $44, $32
ASSERT @ == $716C

SECTION "A12 variant0 secondary object6 716C-71A0", ROMX[$716C], BANK[$30]
A12Variant0SecondaryResource6::
	db $0C ; measured object count, not loaded by 5117
	db $00, $00, $50, $14
	db $00, $00, $50, $0A
	db $00, $00, $50, $14
	db $FE, $82, $00, $00
	db $01, $00, $50, $01
	db $01, $03, $50, $03
	db $01, $0C, $4C, $05
	db $01, $13, $48, $05
	db $01, $1C, $45, $05
	db $01, $28, $43, $05
	db $00, $2E, $40, $12
	db $00, $2E, $40, $1E
	db $00, $2E, $40, $32
ASSERT @ == $71A1

SECTION "A12 variant0 secondary object7 71A1-71D1", ROMX[$71A1], BANK[$30]
A12Variant0SecondaryResource7::
	db $0B ; measured object count, not loaded by 5117
	db $00, $00, $50, $14
	db $00, $00, $50, $0A
	db $00, $00, $50, $08
	db $00, $00, $50, $0C
	db $00, $00, $50, $19
	db $FE, $82, $00, $00
	db $01, $00, $50, $01
	db $01, $FC, $4F, $06
	db $01, $FD, $4D, $06
	db $01, $FD, $44, $06
	db $00, $FD, $3F, $14
	db $00, $FD, $3F, $32
ASSERT @ == $71D2

SECTION "A12 variant0 secondary object8 71D2-7202", ROMX[$71D2], BANK[$30]
A12Variant0SecondaryResource8::
	db $0B ; measured object count, not loaded by 5117
	db $00, $00, $50, $14
	db $00, $00, $50, $0A
	db $00, $00, $50, $08
	db $00, $00, $50, $0C
	db $00, $00, $50, $19
	db $FE, $82, $00, $00
	db $01, $00, $50, $01
	db $01, $FC, $4F, $06
	db $01, $FD, $4D, $06
	db $01, $FD, $44, $06
	db $00, $FD, $3F, $14
	db $00, $FD, $3F, $32
ASSERT @ == $7203
