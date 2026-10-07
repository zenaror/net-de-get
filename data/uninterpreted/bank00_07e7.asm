; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $07E7-$08FA.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:07E7-08FA", ROM0[$07E7]
ResidualROM00_07E7::
	db $F5, $11, $22, $C4, $0E, $40, $CD, $25, $09, $0E, $C0, $21, $A2, $C2, $AF, $22
	db $3E, $F8, $22, $0D, $20, $F8, $F1, $CD, $8D, $08, $EA, $1F, $C2, $C9, $F5, $11
	db $A2, $C2, $0E, $40, $CD, $FB, $08, $0E, $C0, $21, $A3, $C2, $3E, $F8, $96, $23
	db $23, $07, $07, $07, $47, $E6, $C0, $12, $13, $78, $E6, $07, $12, $13, $0D, $20
	db $EB, $F1, $CD, $8D, $08, $EA, $20, $C2, $C9, $FA, $20, $C2, $A7, $28, $29, $3D
	db $EA, $20, $C2, $0E, $C0, $11, $A2, $C2, $21, $22, $C4, $1A, $86, $12, $13, $23
	db $1A, $8E, $12, $13, $23, $0D, $20, $F3, $21, $A3, $C2, $11, $22, $C2, $CD, $6F
	db $09, $3E, $01, $EA, $21, $C2, $18, $2D, $FA, $1F, $C2, $A7, $28, $27, $3D, $EA
	db $1F, $C2, $0E, $C0, $11, $A2, $C2, $21, $22, $C4, $1A, $96, $12, $23, $13, $1A
	db $9E, $12, $13, $23, $0D, $20, $F3, $21, $A3, $C2, $11, $22, $C2, $CD, $6F, $09
	db $3E, $01, $EA, $21, $C2, $C9, $FE, $02, $28, $5E, $38, $2D, $D6, $02, $EA, $A2
	db $C5, $0E, $C0, $21, $22, $C4, $FA, $A2, $C5, $47, $5E, $23, $56, $2B, $CB, $23
	db $CB, $12, $05, $20, $F9, $73, $23, $72, $23, $0D, $20, $EA, $FA, $A2, $C5, $C6
	db $F2, $6F, $3E, $08, $CE, $00, $67, $7E, $C9, $47, $3E, $02, $90, $EA, $A2, $C5
	db $0E, $C0, $21, $22, $C4, $FA, $A2, $C5, $47, $5E, $23, $56, $2B, $CB, $3A, $CB
	db $1B, $05, $20, $F9, $73, $23, $72, $23, $0D, $20, $EA, $FA, $A2, $C5, $C6, $F8
	db $6F, $3E, $08, $CE, $00, $67, $7E, $C9, $3E, $20, $C9, $20, $10, $08, $04, $02
	db $01, $20, $40, $80
ASSERT @ == $08FB
