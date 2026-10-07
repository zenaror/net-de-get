; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $0D50-$0F14.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:0D50-0F14", ROM0[$0D50]
ResidualROM00_0D50::
	db $7B, $E0, $9E, $7A, $E0, $9F, $3E, $00, $EA, $00, $04, $3E, $01, $EA, $00, $08
	db $3E, $0A, $EA, $00, $00, $06, $00, $78, $CD, $4F, $11, $1A, $6F, $13, $1A, $67
	db $13, $7D, $B4, $CA, $9C, $0D, $78, $E0, $9D, $F0, $9E, $6F, $F0, $9F, $67, $06
	db $04, $0E, $00, $1A, $13, $BE, $CA, $8A, $0D, $0C, $23, $05, $20, $F5, $79, $B7
	db $28, $3F, $F0, $9D, $47, $04, $78, $FE, $82, $DA, $67, $0D, $AF, $EA, $00, $00
	db $F0, $AF, $EA, $00, $04, $F0, $B0, $EA, $00, $08, $3E, $FF, $C9, $D1, $AF, $EA
	db $00, $00, $F0, $AF, $EA, $00, $04, $F0, $B0, $EA, $00, $08, $3E, $FE, $C9, $D1
	db $AF, $EA, $00, $00, $F0, $AF, $EA, $00, $04, $F0, $B0, $EA, $00, $08, $3E, $FD
	db $C9, $F0, $9D, $CD, $62, $11, $D5, $13, $13, $F0, $9E, $6F, $F0, $9F, $67, $06
	db $04, $0E, $00, $1A, $13, $BE, $CA, $EA, $0D, $0C, $23, $05, $20, $F5, $79, $B7
	db $20, $BB, $F0, $9D, $CD, $15, $0F, $69, $60, $C1, $C5, $0A, $5F, $03, $0A, $57
	db $CD, $0A, $20, $20, $BA, $F0, $9D, $3C, $CD, $4F, $11, $1A, $4F, $13, $1A, $B1
	db $CA, $B6, $0E, $C1, $79, $E0, $A0, $78, $E0, $A1, $06, $00, $78, $CD, $4F, $11
	db $1A, $6F, $13, $1A, $67, $13, $7D, $B4, $CA, $32, $0E, $04, $78, $FE, $82, $DA
	db $1C, $0E, $05, $78, $E0, $9E, $78, $CD, $15, $0F, $F0, $9E, $CD, $62, $11, $D5
	db $69, $60, $4B, $42, $0A, $5F, $03, $0A, $57, $CD, $0A, $20, $C2, $BF, $0D, $D1
	db $D5, $21, $06, $00, $19, $2A, $4F, $7E, $47, $21, $09, $00, $09, $C1, $09, $7D
	db $E0, $A2, $7C, $E0, $A3, $F0, $A0, $5F, $F0, $A1, $57, $D5, $21, $06, $00, $19
	db $2A, $4F, $7E, $47, $21, $09, $00, $09, $C1, $09, $7D, $E0, $A4, $7C, $E0, $A5
	db $5D, $54, $F0, $A2, $6F, $F0, $A3, $67, $CD, $00, $20, $4D, $44, $F0, $A4, $6F
	db $F0, $A5, $67, $F0, $A0, $5F, $F0, $A1, $57, $CD, $13, $26, $3E, $FF, $EA, $00
	db $A0, $3E, $FF, $EA, $01, $A0, $AF, $EA, $00, $00, $F0, $AF, $EA, $00, $04, $F0
	db $B0, $EA, $00, $08, $AF, $C9, $C1, $F0, $9D, $3D, $CD, $62, $11, $D5, $21, $08
	db $00, $19, $AF, $77, $F0, $9D, $3D, $CD, $15, $0F, $D1, $79, $12, $13, $78, $12
	db $3E, $FF, $EA, $00, $A0, $3E, $FF, $EA, $01, $A0, $AF, $EA, $00, $00, $F0, $AF
	db $EA, $00, $04, $F0, $B0, $EA, $00, $08, $AF, $C9, $CD, $62, $11, $D5, $13, $13
	db $78, $E0, $9D, $F0, $9E, $6F, $F0, $9F, $67, $06, $04, $0E, $00, $1A, $13, $BE
	db $CA, $04, $0F, $0C, $23, $05, $20, $F5, $D1, $79, $B7, $20, $02, $AF, $C9, $3E
	db $01, $11, $00, $00, $C9
ASSERT @ == $0F15
