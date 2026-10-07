; PROBABLE primary resource layout from 4D82 consumer and measured bounds.
; Original bytes preserved; leading count is written to C5CD by the reader.
SECTION "A12 variant0 primary table 6BBD-6BCE", ROMX[$6BBD], BANK[$30]
A12Variant0PrimaryResourceTable::
	dw A12Variant0PrimaryResource0
	dw A12Variant0PrimaryResource1
	dw A12Variant0PrimaryResource2
	dw A12Variant0PrimaryResource3
	dw A12Variant0PrimaryResource4
	dw A12Variant0PrimaryResource5
	dw A12Variant0PrimaryResource6
	dw A12Variant0PrimaryResource7
	dw A12Variant0PrimaryResource8
ASSERT @ == $6BCF

SECTION "A12 variant0 primary object0 6BCF-6C33", ROMX[$6BCF], BANK[$30]
A12Variant0PrimaryResource0::
	db $18 ; count loaded by 4D82
	db $00, $91, $26, $10
	db $FF, $00
	dw A12Variant0EffectTiles0
	db $FE, $83, $00, $00
	db $00, $91, $26, $18
	db $00, $71, $46, $0A
	db $FE, $82, $00, $00
	db $01, $71, $46, $01
	db $01, $66, $30, $06
	db $01, $5A, $23, $06
	db $01, $4E, $27, $05
	db $01, $43, $34, $05
	db $00, $33, $42, $06
	db $FE, $82, $00, $00
	db $00, $33, $42, $01
	db $FF, $00
	dw A12Variant0EffectTiles1
	db $FE, $83, $00, $00
	db $01, $28, $2C, $06
	db $01, $20, $22, $06
	db $01, $19, $25, $05
	db $01, $14, $2D, $05
	db $01, $0D, $39, $05
	db $00, $00, $50, $19
	db $02, $00, $50, $11
	db $03, $00, $50, $0A
	db $01, $00, $50, $F0
ASSERT @ == $6C34

SECTION "A12 variant0 primary object1 6C34-6D5C", ROMX[$6C34], BANK[$30]
A12Variant0PrimaryResource1::
	db $49 ; count loaded by 4D82
	db $03, $00, $50, $58
	db $04, $00, $50, $28
	db $03, $00, $50, $1C
	db $04, $00, $50, $28
	db $03, $00, $50, $58
	db $04, $00, $50, $28
	db $03, $00, $50, $58
	db $04, $00, $50, $28
	db $03, $00, $50, $1C
	db $04, $00, $50, $28
	db $03, $00, $50, $28
	db $04, $00, $50, $14
	db $03, $00, $50, $14
	db $04, $00, $50, $14
	db $03, $00, $50, $34
	db $03, $00, $50, $1C
	db $05, $00, $50, $1C
	db $03, $00, $50, $1C
	db $06, $00, $50, $1C
	db $03, $00, $50, $1C
	db $05, $00, $50, $1C
	db $03, $00, $50, $1C
	db $06, $00, $50, $1C
	db $03, $00, $50, $1C
	db $05, $00, $50, $1C
	db $03, $00, $50, $1C
	db $06, $00, $50, $1C
	db $03, $00, $50, $1C
	db $05, $00, $50, $1C
	db $03, $00, $50, $1C
	db $06, $00, $50, $1C
	db $03, $00, $50, $1C
	db $05, $00, $50, $1C
	db $03, $00, $50, $1C
	db $06, $00, $50, $1C
	db $03, $00, $50, $1C
	db $05, $00, $50, $1C
	db $03, $00, $50, $1C
	db $06, $00, $50, $1C
	db $03, $00, $50, $1E
	db $07, $00, $50, $1E
	db $08, $00, $50, $1E
	db $09, $00, $50, $1E
	db $08, $00, $50, $1E
	db $07, $00, $50, $1E
	db $08, $00, $50, $1E
	db $09, $00, $50, $1E
	db $08, $00, $50, $1E
	db $07, $00, $50, $1E
	db $08, $00, $50, $1E
	db $09, $00, $50, $1E
	db $08, $00, $50, $1E
	db $07, $00, $50, $1E
	db $08, $00, $50, $1E
	db $09, $00, $50, $1E
	db $08, $00, $50, $1E
	db $07, $00, $50, $1E
	db $08, $00, $50, $1E
	db $09, $00, $50, $1E
	db $08, $00, $50, $1E
	db $07, $00, $50, $1E
	db $08, $00, $50, $1E
	db $09, $00, $50, $1E
	db $0A, $00, $50, $1E
	db $0B, $00, $50, $1E
	db $0C, $00, $50, $0A
	db $0D, $00, $50, $0A
	db $0C, $00, $50, $0A
	db $0D, $00, $50, $0A
	db $0C, $00, $50, $0A
	db $0D, $00, $50, $0A
	db $0C, $00, $50, $19
	db $0D, $00, $50, $32
	db $01, $00, $50, $32
ASSERT @ == $6D5D

SECTION "A12 variant0 primary object2 6D5D-6D99", ROMX[$6D5D], BANK[$30]
A12Variant0PrimaryResource2::
	db $0E ; count loaded by 4D82
	db $04, $00, $50, $28
	db $03, $00, $50, $1C
	db $04, $00, $50, $28
	db $03, $00, $50, $58
	db $04, $00, $50, $28
	db $03, $00, $50, $58
	db $04, $00, $50, $28
	db $03, $00, $50, $1C
	db $04, $00, $50, $28
	db $03, $00, $50, $28
	db $04, $00, $50, $14
	db $03, $00, $50, $14
	db $04, $00, $50, $14
	db $03, $00, $50, $14
	db $02, $00, $50, $14
ASSERT @ == $6D9A

SECTION "A12 variant0 primary object3 6D9A-6DDA", ROMX[$6D9A], BANK[$30]
A12Variant0PrimaryResource3::
	db $0F ; count loaded by 4D82
	db $03, $00, $50, $14
	db $0E, $00, $50, $0A
	db $0F, $00, $50, $14
	db $FE, $82, $00, $00
	db $10, $00, $50, $01
	db $10, $08, $38, $04
	db $10, $18, $26, $06
	db $10, $28, $28, $06
	db $10, $40, $40, $03
	db $0F, $58, $58, $14
	db $0E, $58, $58, $0C
	db $03, $58, $57, $08
	db $02, $58, $57, $18
	db $02, $58, $57, $01
	db $11, $5B, $57, $14
	db $01, $5B, $57, $F3
ASSERT @ == $6DDB

SECTION "A12 variant0 primary object4 6DDB-6E17", ROMX[$6DDB], BANK[$30]
A12Variant0PrimaryResource4::
	db $0E ; count loaded by 4D82
	db $03, $00, $50, $14
	db $0E, $00, $50, $08
	db $12, $00, $50, $05
	db $13, $00, $50, $0A
	db $14, $00, $50, $14
	db $FE, $82, $00, $00
	db $15, $00, $50, $01
	db $15, $04, $36, $05
	db $15, $09, $2A, $05
	db $15, $0D, $23, $05
	db $15, $12, $25, $04
	db $15, $15, $2C, $04
	db $15, $19, $34, $04
	db $13, $1F, $43, $14
	db $01, $1F, $43, $F4
ASSERT @ == $6E18

SECTION "A12 variant0 primary object5 6E18-6E48", ROMX[$6E18], BANK[$30]
A12Variant0PrimaryResource5::
	db $0B ; count loaded by 4D82
	db $03, $00, $50, $14
	db $FF, $00
	dw A12Variant0EffectTiles2
	db $0E, $00, $50, $0A
	db $0F, $00, $50, $14
	db $FE, $82, $00, $00
	db $16, $00, $50, $01
	db $16, $0A, $38, $03
	db $16, $12, $1C, $05
	db $16, $20, $12, $05
	db $16, $2A, $18, $05
	db $16, $38, $28, $32
	db $01, $38, $28, $F2
ASSERT @ == $6E49

SECTION "A12 variant0 primary object6 6E49-6E7D", ROMX[$6E49], BANK[$30]
A12Variant0PrimaryResource6::
	db $0C ; count loaded by 4D82
	db $03, $00, $50, $14
	db $0E, $00, $50, $0A
	db $0F, $00, $50, $14
	db $FE, $82, $00, $00
	db $16, $00, $50, $01
	db $16, $0A, $38, $03
	db $16, $12, $1C, $05
	db $16, $18, $12, $05
	db $16, $22, $18, $05
	db $16, $2E, $2A, $05
	db $12, $32, $40, $12
	db $13, $32, $40, $1E
	db $01, $32, $40, $F5
ASSERT @ == $6E7E

SECTION "A12 variant0 primary object7 6E7E-6EAE", ROMX[$6E7E], BANK[$30]
A12Variant0PrimaryResource7::
	db $0B ; count loaded by 4D82
	db $03, $00, $50, $14
	db $02, $00, $50, $0A
	db $17, $00, $50, $08
	db $13, $00, $50, $0C
	db $14, $00, $50, $19
	db $FE, $82, $00, $00
	db $15, $00, $50, $01
	db $15, $01, $36, $06
	db $15, $02, $2A, $06
	db $15, $02, $32, $06
	db $18, $02, $3F, $14
	db $01, $02, $3F, $F1
ASSERT @ == $6EAF

SECTION "A12 variant0 primary object8 6EAF-6EDF", ROMX[$6EAF], BANK[$30]
A12Variant0PrimaryResource8::
	db $0B ; count loaded by 4D82
	db $03, $00, $50, $14
	db $02, $00, $50, $0A
	db $17, $00, $50, $08
	db $13, $00, $50, $0C
	db $14, $00, $50, $19
	db $FE, $82, $00, $00
	db $15, $00, $50, $01
	db $15, $01, $36, $06
	db $15, $02, $2A, $06
	db $15, $02, $32, $06
	db $18, $02, $3F, $14
	db $01, $02, $3F, $F7
ASSERT @ == $6EE0
