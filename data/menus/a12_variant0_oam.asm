; PROBABLE count-prefixed OAM objects consumed by original 4DFE/5188 emitters.
; Records preserve Y offset, X offset, tile and attributes. No natural visual meaning.
SECTION "A12 variant0 primary OAM table", ROMX[$7203], BANK[$30]
ResidualROM30_7203::
A12Variant0PrimaryOAMTable::
	dw A12Variant0PrimaryOAM0
	dw A12Variant0PrimaryOAM1
	dw A12Variant0PrimaryOAM2
	dw A12Variant0PrimaryOAM3
	dw A12Variant0PrimaryOAM4
	dw A12Variant0PrimaryOAM5
	dw A12Variant0PrimaryOAM6
	dw A12Variant0PrimaryOAM7
	dw A12Variant0PrimaryOAM8
	dw A12Variant0PrimaryOAM9
	dw A12Variant0PrimaryOAM10
	dw A12Variant0PrimaryOAM11
	dw A12Variant0PrimaryOAM12
	dw A12Variant0PrimaryOAM13
	dw A12Variant0PrimaryOAM14
	dw A12Variant0PrimaryOAM15
	dw A12Variant0PrimaryOAM16
	dw A12Variant0PrimaryOAM17
	dw A12Variant0PrimaryOAM18
	dw A12Variant0PrimaryOAM19
	dw A12Variant0PrimaryOAM20
	dw A12Variant0PrimaryOAM21
	dw A12Variant0PrimaryOAM22
	dw A12Variant0PrimaryOAM23
	dw A12Variant0PrimaryOAM24
ASSERT @ == $7235

SECTION "A12 variant0 primary OAM 0", ROMX[$7235], BANK[$30]
A12Variant0PrimaryOAM0::
	db $0C ; Original record count.
	db $F0, $F0, $18, $01
	db $F0, $F8, $19, $01
	db $F0, $00, $1A, $01
	db $F0, $08, $1B, $01
	db $F8, $F0, $28, $01
	db $F8, $F8, $29, $01
	db $F8, $00, $2A, $01
	db $F8, $08, $2B, $01
	db $00, $F0, $38, $01
	db $00, $F8, $39, $01
	db $00, $00, $3A, $01
	db $00, $08, $3B, $01
ASSERT @ == $7266

SECTION "A12 variant0 primary OAM 1", ROMX[$7266], BANK[$30]
A12Variant0PrimaryOAM1::
	db $0E ; Original record count.
	db $E8, $08, $04, $21
	db $E8, $00, $05, $21
	db $E8, $F8, $06, $21
	db $E8, $F0, $07, $21
	db $F0, $08, $14, $21
	db $F0, $00, $15, $21
	db $F0, $F8, $16, $21
	db $F0, $F0, $17, $21
	db $F8, $00, $25, $21
	db $F8, $F8, $26, $21
	db $F8, $F0, $27, $21
	db $00, $00, $35, $21
	db $00, $F8, $36, $21
	db $00, $F0, $37, $21
ASSERT @ == $729F

SECTION "A12 variant0 primary OAM 2", ROMX[$729F], BANK[$30]
A12Variant0PrimaryOAM2::
	db $0F ; Original record count.
	db $E8, $F3, $44, $01
	db $E8, $FB, $45, $01
	db $E8, $03, $46, $01
	db $E8, $0B, $47, $01
	db $F0, $F3, $54, $01
	db $F0, $FB, $55, $01
	db $F0, $03, $56, $01
	db $F0, $0B, $57, $01
	db $F8, $F3, $64, $01
	db $F8, $FB, $65, $01
	db $F8, $03, $66, $01
	db $00, $F3, $74, $01
	db $00, $FB, $75, $01
	db $00, $03, $76, $01
	db $00, $0B, $77, $01
ASSERT @ == $72DC

SECTION "A12 variant0 primary OAM 3", ROMX[$72DC], BANK[$30]
A12Variant0PrimaryOAM3::
	db $10 ; Original record count.
	db $E8, $F0, $02, $01
	db $E8, $F8, $03, $01
	db $F0, $F0, $12, $01
	db $F0, $F8, $13, $01
	db $F8, $F0, $22, $01
	db $F8, $F8, $23, $01
	db $E8, $08, $02, $21
	db $E8, $00, $03, $21
	db $F0, $08, $12, $21
	db $F8, $08, $22, $21
	db $F8, $00, $23, $21
	db $F0, $00, $34, $01
	db $00, $F0, $32, $01
	db $00, $F8, $33, $01
	db $00, $08, $32, $21
	db $00, $00, $33, $21
ASSERT @ == $731D

SECTION "A12 variant0 primary OAM 4", ROMX[$731D], BANK[$30]
A12Variant0PrimaryOAM4::
	db $11 ; Original record count.
	db $E8, $F0, $00, $01
	db $E8, $F8, $01, $01
	db $F0, $F0, $10, $01
	db $F0, $F8, $11, $01
	db $F8, $F0, $20, $01
	db $F8, $F8, $21, $01
	db $00, $F0, $30, $01
	db $00, $F8, $31, $01
	db $E8, $08, $00, $21
	db $E8, $00, $01, $21
	db $F0, $08, $10, $21
	db $F0, $00, $11, $21
	db $F8, $08, $20, $21
	db $F8, $00, $21, $21
	db $00, $08, $30, $21
	db $00, $00, $31, $21
	db $F0, $00, $24, $01
ASSERT @ == $7362

SECTION "A12 variant0 primary OAM 5", ROMX[$7362], BANK[$30]
A12Variant0PrimaryOAM5::
	db $10 ; Original record count.
	db $E8, $E8, $0C, $01
	db $E8, $F0, $0D, $01
	db $E8, $F8, $0E, $01
	db $E8, $00, $0F, $01
	db $F0, $E8, $1C, $01
	db $F0, $F0, $1D, $01
	db $F0, $F8, $1E, $01
	db $F0, $00, $1F, $01
	db $F8, $E8, $2C, $01
	db $F8, $F0, $2D, $01
	db $F8, $F8, $2E, $01
	db $F8, $00, $2F, $01
	db $00, $E8, $3C, $01
	db $00, $F0, $3D, $01
	db $00, $F8, $3E, $01
	db $00, $00, $3F, $01
ASSERT @ == $73A3

SECTION "A12 variant0 primary OAM 6", ROMX[$73A3], BANK[$30]
A12Variant0PrimaryOAM6::
	db $10 ; Original record count.
	db $E8, $10, $0C, $21
	db $E8, $08, $0D, $21
	db $E8, $00, $0E, $21
	db $E8, $F8, $0F, $21
	db $F0, $10, $1C, $21
	db $F0, $08, $1D, $21
	db $F0, $00, $1E, $21
	db $F0, $F8, $1F, $21
	db $F8, $10, $2C, $21
	db $F8, $08, $2D, $21
	db $F8, $00, $2E, $21
	db $F8, $F8, $2F, $21
	db $00, $10, $3C, $21
	db $00, $08, $3D, $21
	db $00, $00, $3E, $21
	db $00, $F8, $3F, $21
ASSERT @ == $73E4

SECTION "A12 variant0 primary OAM 7", ROMX[$73E4], BANK[$30]
A12Variant0PrimaryOAM7::
	db $10 ; Original record count.
	db $E8, $F0, $4E, $01
	db $E8, $F8, $4F, $01
	db $F0, $F0, $5E, $01
	db $F0, $F8, $5F, $01
	db $F8, $F0, $6E, $01
	db $F8, $F8, $6F, $01
	db $00, $F0, $7E, $02
	db $00, $F8, $7F, $01
	db $E8, $00, $4F, $21
	db $F8, $00, $6F, $21
	db $F8, $08, $4D, $01
	db $00, $08, $5D, $01
	db $F0, $00, $08, $01
	db $E8, $08, $4E, $21
	db $F0, $08, $5E, $21
	db $00, $00, $67, $01
ASSERT @ == $7425

SECTION "A12 variant0 primary OAM 8", ROMX[$7425], BANK[$30]
A12Variant0PrimaryOAM8::
	db $12 ; Original record count.
	db $E8, $F0, $05, $09
	db $E8, $F8, $06, $09
	db $F0, $F0, $15, $09
	db $F0, $F8, $16, $09
	db $F0, $00, $17, $09
	db $F8, $E8, $24, $0A
	db $F8, $F0, $25, $0A
	db $F8, $F8, $26, $09
	db $00, $E8, $34, $0A
	db $00, $F0, $35, $0A
	db $00, $F8, $36, $09
	db $E8, $08, $05, $29
	db $E8, $00, $06, $29
	db $F0, $08, $15, $29
	db $F8, $00, $26, $29
	db $00, $00, $36, $29
	db $F8, $08, $04, $09
	db $00, $08, $14, $09
ASSERT @ == $746E

SECTION "A12 variant0 primary OAM 9", ROMX[$746E], BANK[$30]
A12Variant0PrimaryOAM9::
	db $18 ; Original record count.
	db $F0, $F0, $1A, $09
	db $F0, $F8, $1B, $09
	db $F0, $00, $1C, $09
	db $F0, $08, $1D, $09
	db $F8, $D8, $27, $0A
	db $F8, $E0, $28, $0A
	db $F8, $E8, $29, $0A
	db $F8, $F0, $2A, $0A
	db $F8, $F8, $2B, $09
	db $F8, $00, $2C, $09
	db $F8, $08, $2D, $09
	db $00, $D8, $37, $0A
	db $00, $E0, $38, $0A
	db $00, $E8, $39, $0A
	db $00, $F0, $3A, $0A
	db $00, $F8, $3B, $09
	db $00, $00, $3C, $09
	db $00, $08, $3D, $09
	db $E8, $F0, $0B, $09
	db $E8, $F8, $0C, $09
	db $E8, $08, $0B, $29
	db $E8, $00, $0C, $29
	db $08, $E0, $0D, $0A
	db $08, $E8, $0E, $0A
ASSERT @ == $74CF

SECTION "A12 variant0 primary OAM 10", ROMX[$74CF], BANK[$30]
A12Variant0PrimaryOAM10::
	db $17 ; Original record count.
	db $E8, $F0, $05, $09
	db $E8, $F8, $06, $09
	db $F0, $F0, $15, $09
	db $F0, $F8, $16, $09
	db $F8, $F8, $26, $09
	db $00, $F8, $36, $09
	db $F8, $F0, $18, $09
	db $00, $F0, $19, $09
	db $E8, $E8, $0F, $0A
	db $F0, $E0, $1E, $0A
	db $F0, $E8, $1F, $0A
	db $F8, $E0, $2E, $0A
	db $F8, $E8, $2F, $0A
	db $00, $E0, $3E, $0A
	db $00, $E8, $3F, $0A
	db $E8, $00, $06, $29
	db $F8, $00, $26, $29
	db $00, $00, $36, $29
	db $F8, $08, $04, $09
	db $00, $08, $14, $09
	db $E8, $08, $05, $29
	db $F0, $08, $15, $29
	db $F0, $00, $17, $09
ASSERT @ == $752C

SECTION "A12 variant0 primary OAM 11", ROMX[$752C], BANK[$30]
A12Variant0PrimaryOAM11::
	db $12 ; Original record count.
	db $E8, $F0, $02, $01
	db $E8, $F8, $03, $01
	db $F0, $F0, $12, $01
	db $F0, $F8, $13, $01
	db $E8, $08, $02, $21
	db $E8, $00, $03, $21
	db $F0, $08, $12, $21
	db $F0, $00, $34, $01
	db $F8, $F0, $6C, $01
	db $F8, $F8, $6D, $01
	db $00, $F0, $7C, $01
	db $00, $F8, $7D, $01
	db $F8, $08, $6C, $21
	db $F8, $00, $6D, $21
	db $00, $08, $7C, $21
	db $00, $00, $7D, $21
	db $F1, $12, $09, $01
	db $F9, $12, $0A, $01
ASSERT @ == $7575

SECTION "A12 variant0 primary OAM 12", ROMX[$7575], BANK[$30]
A12Variant0PrimaryOAM12::
	db $10 ; Original record count.
	db $E8, $F0, $05, $09
	db $E8, $F8, $06, $09
	db $F0, $F0, $15, $09
	db $F0, $F8, $16, $09
	db $E8, $00, $06, $29
	db $F8, $00, $26, $29
	db $00, $00, $36, $29
	db $F8, $08, $04, $09
	db $00, $08, $14, $09
	db $E8, $08, $05, $29
	db $F0, $08, $15, $29
	db $F0, $00, $17, $09
	db $F8, $F8, $26, $09
	db $00, $F8, $36, $09
	db $F8, $F0, $04, $29
	db $00, $F0, $14, $29
ASSERT @ == $75B6

SECTION "A12 variant0 primary OAM 13", ROMX[$75B6], BANK[$30]
A12Variant0PrimaryOAM13::
	db $10 ; Original record count.
	db $E8, $F0, $02, $01
	db $E8, $F8, $03, $01
	db $F0, $F0, $12, $01
	db $F0, $F8, $13, $01
	db $E8, $08, $02, $21
	db $E8, $00, $03, $21
	db $F0, $08, $12, $21
	db $F0, $00, $34, $01
	db $F8, $F0, $6C, $01
	db $F8, $F8, $6D, $01
	db $00, $F0, $7C, $01
	db $00, $F8, $7D, $01
	db $F8, $08, $6C, $21
	db $F8, $00, $6D, $21
	db $00, $08, $7C, $21
	db $00, $00, $7D, $21
ASSERT @ == $75F7

SECTION "A12 variant0 primary OAM 14", ROMX[$75F7], BANK[$30]
A12Variant0PrimaryOAM14::
	db $0F ; Original record count.
	db $E8, $04, $44, $21
	db $E8, $FC, $45, $21
	db $E8, $F4, $46, $21
	db $E8, $EC, $47, $21
	db $F0, $04, $54, $21
	db $F0, $FC, $55, $21
	db $F0, $F4, $56, $21
	db $F0, $EC, $57, $21
	db $F8, $04, $64, $21
	db $F8, $FC, $65, $21
	db $F8, $F4, $66, $21
	db $00, $04, $74, $21
	db $00, $FC, $75, $21
	db $00, $F4, $76, $21
	db $00, $EC, $77, $21
ASSERT @ == $7634

SECTION "A12 variant0 primary OAM 15", ROMX[$7634], BANK[$30]
A12Variant0PrimaryOAM15::
	db $0C ; Original record count.
	db $F0, $08, $18, $21
	db $F0, $00, $19, $21
	db $F0, $F8, $1A, $21
	db $F0, $F0, $1B, $21
	db $F8, $08, $28, $21
	db $F8, $00, $29, $21
	db $F8, $F8, $2A, $21
	db $F8, $F0, $2B, $21
	db $00, $08, $38, $21
	db $00, $00, $39, $21
	db $00, $F8, $3A, $21
	db $00, $F0, $3B, $21
ASSERT @ == $7665

SECTION "A12 variant0 primary OAM 16", ROMX[$7665], BANK[$30]
A12Variant0PrimaryOAM16::
	db $0E ; Original record count.
	db $E8, $F0, $04, $01
	db $E8, $F8, $05, $01
	db $E8, $00, $06, $01
	db $E8, $08, $07, $01
	db $F0, $F0, $14, $01
	db $F0, $F8, $15, $01
	db $F0, $00, $16, $01
	db $F0, $08, $17, $01
	db $F8, $F8, $25, $01
	db $F8, $00, $26, $01
	db $F8, $08, $27, $01
	db $00, $F8, $35, $01
	db $00, $00, $36, $01
	db $00, $08, $37, $01
ASSERT @ == $769E

SECTION "A12 variant0 primary OAM 17", ROMX[$769E], BANK[$30]
A12Variant0PrimaryOAM17::
	db $12 ; Original record count.
	db $E8, $08, $00, $29
	db $E8, $00, $01, $29
	db $E8, $F8, $02, $29
	db $E8, $F0, $03, $29
	db $F0, $08, $10, $29
	db $F0, $00, $11, $29
	db $F0, $F8, $12, $29
	db $F0, $F0, $13, $29
	db $F8, $08, $20, $29
	db $F8, $00, $21, $29
	db $F8, $F8, $22, $29
	db $F8, $F0, $23, $29
	db $00, $08, $30, $29
	db $00, $00, $31, $29
	db $00, $F8, $32, $29
	db $00, $F0, $33, $29
	db $EA, $E9, $09, $21
	db $F2, $E9, $0A, $21
ASSERT @ == $76E7

SECTION "A12 variant0 primary OAM 18", ROMX[$76E7], BANK[$30]
A12Variant0PrimaryOAM18::
	db $13 ; Original record count.
	db $E8, $08, $40, $21
	db $E8, $00, $41, $21
	db $E8, $F8, $42, $21
	db $E8, $F0, $43, $21
	db $F0, $08, $50, $21
	db $F0, $00, $51, $21
	db $F0, $F8, $52, $21
	db $F0, $F0, $53, $21
	db $F8, $08, $60, $21
	db $F8, $00, $61, $21
	db $F8, $F8, $62, $21
	db $F8, $F0, $63, $21
	db $00, $08, $70, $21
	db $00, $00, $71, $21
	db $00, $F8, $72, $21
	db $00, $F0, $73, $21
	db $00, $FC, $51, $29
	db $00, $F4, $52, $29
	db $00, $EC, $53, $29
ASSERT @ == $7734

SECTION "A12 variant0 primary OAM 19", ROMX[$7734], BANK[$30]
A12Variant0PrimaryOAM19::
	db $14 ; Original record count.
	db $E8, $F0, $48, $01
	db $E8, $F8, $49, $01
	db $F0, $F0, $58, $01
	db $F0, $F8, $59, $01
	db $F8, $F0, $68, $01
	db $F8, $F8, $69, $01
	db $E8, $08, $48, $21
	db $E8, $00, $49, $21
	db $F0, $08, $58, $21
	db $F8, $08, $68, $21
	db $F8, $00, $69, $21
	db $F0, $00, $0B, $01
	db $00, $F0, $07, $09
	db $00, $F8, $08, $09
	db $00, $08, $07, $29
	db $00, $00, $08, $29
	db $00, $F0, $46, $09
	db $00, $F8, $47, $09
	db $00, $08, $46, $29
	db $00, $00, $47, $29
ASSERT @ == $7785

SECTION "A12 variant0 primary OAM 20", ROMX[$7785], BANK[$30]
A12Variant0PrimaryOAM20::
	db $16 ; Original record count.
	db $EB, $F0, $4A, $01
	db $EB, $F8, $4B, $01
	db $F3, $F0, $5A, $01
	db $F3, $F8, $5B, $01
	db $FB, $F0, $6A, $01
	db $FB, $F8, $6B, $01
	db $03, $F0, $7A, $01
	db $03, $F8, $7B, $01
	db $EB, $08, $4A, $21
	db $EB, $00, $4B, $21
	db $F3, $08, $5A, $21
	db $F3, $00, $5B, $21
	db $FB, $08, $6A, $21
	db $FB, $00, $6B, $21
	db $03, $08, $7A, $21
	db $03, $00, $7B, $21
	db $00, $FD, $4D, $09
	db $00, $05, $4E, $09
	db $00, $0D, $4F, $09
	db $00, $FA, $4D, $29
	db $00, $F2, $4E, $29
	db $00, $EA, $4F, $29
ASSERT @ == $77DE

SECTION "A12 variant0 primary OAM 21", ROMX[$77DE], BANK[$30]
A12Variant0PrimaryOAM21::
	db $10 ; Original record count.
	db $E8, $F0, $48, $01
	db $E8, $F8, $49, $01
	db $F0, $F0, $58, $01
	db $F0, $F8, $59, $01
	db $F8, $F0, $68, $01
	db $F8, $F8, $69, $01
	db $E8, $08, $48, $21
	db $E8, $00, $49, $21
	db $F0, $08, $58, $21
	db $F8, $08, $68, $21
	db $F8, $00, $69, $21
	db $F0, $00, $0B, $01
	db $00, $F0, $07, $09
	db $00, $F8, $08, $09
	db $00, $08, $07, $29
	db $00, $00, $08, $29
ASSERT @ == $781F

SECTION "A12 variant0 primary OAM 22", ROMX[$781F], BANK[$30]
A12Variant0PrimaryOAM22::
	db $10 ; Original record count.
	db $E8, $08, $40, $21
	db $E8, $00, $41, $21
	db $E8, $F8, $42, $21
	db $E8, $F0, $43, $21
	db $F0, $08, $50, $21
	db $F0, $00, $51, $21
	db $F0, $F8, $52, $21
	db $F0, $F0, $53, $21
	db $F8, $08, $60, $21
	db $F8, $00, $61, $21
	db $F8, $F8, $62, $21
	db $F8, $F0, $63, $21
	db $00, $08, $70, $21
	db $00, $00, $71, $21
	db $00, $F8, $72, $21
	db $00, $F0, $73, $21
ASSERT @ == $7860

SECTION "A12 variant0 primary OAM 23", ROMX[$7860], BANK[$30]
A12Variant0PrimaryOAM23::
	db $13 ; Original record count.
	db $E8, $F0, $40, $01
	db $E8, $F8, $41, $01
	db $E8, $00, $42, $01
	db $E8, $08, $43, $01
	db $F0, $F0, $50, $01
	db $F0, $F8, $51, $01
	db $F0, $00, $52, $01
	db $F0, $08, $53, $01
	db $F8, $F0, $60, $01
	db $F8, $F8, $61, $01
	db $F8, $00, $62, $01
	db $F8, $08, $63, $01
	db $00, $F0, $70, $01
	db $00, $F8, $71, $01
	db $00, $00, $72, $01
	db $00, $08, $73, $01
	db $00, $FC, $51, $09
	db $00, $04, $52, $09
	db $00, $0C, $53, $09
ASSERT @ == $78AD

SECTION "A12 variant0 primary OAM 24", ROMX[$78AD], BANK[$30]
A12Variant0PrimaryOAM24::
	db $10 ; Original record count.
	db $E8, $F0, $48, $01
	db $E8, $F8, $49, $01
	db $F0, $F0, $58, $01
	db $F0, $F8, $59, $01
	db $F8, $F0, $68, $01
	db $F8, $F8, $69, $01
	db $E8, $08, $48, $21
	db $E8, $00, $49, $21
	db $F0, $08, $58, $21
	db $F8, $08, $68, $21
	db $F8, $00, $69, $21
	db $F0, $00, $0B, $01
	db $00, $F0, $09, $09
	db $00, $F8, $0A, $09
	db $00, $08, $09, $29
	db $00, $00, $0A, $29
ASSERT @ == $78EE

SECTION "A12 variant0 secondary OAM table", ROMX[$78EE], BANK[$30]
A12Variant0SecondaryOAMTable::
	dw A12Variant0SecondaryOAM0
	dw A12Variant0SecondaryOAM1
	dw A12Variant0SecondaryOAM2
ASSERT @ == $78F4

SECTION "A12 variant0 secondary OAM 0", ROMX[$78F4], BANK[$30]
A12Variant0SecondaryOAM0::
	db $03 ; Original record count.
	db $60, $F8, $41, $09
	db $60, $00, $42, $09
	db $60, $08, $43, $09
ASSERT @ == $7901

SECTION "A12 variant0 secondary OAM 1", ROMX[$7901], BANK[$30]
A12Variant0SecondaryOAM1::
	db $03 ; Original record count.
	db $00, $F8, $41, $09
	db $00, $00, $42, $09
	db $00, $08, $43, $09
ASSERT @ == $790E

SECTION "A12 variant0 secondary OAM 2", ROMX[$790E], BANK[$30]
A12Variant0SecondaryOAM2::
	db $01 ; Original record count.
	db $00, $00, $40, $09
ASSERT @ == $7913
