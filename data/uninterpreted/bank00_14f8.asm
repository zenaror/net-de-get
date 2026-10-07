; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $14F8-$164C.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:14F8-164C", ROM0[$14F8]
ResidualROM00_14F8::
	db $E5, $CD, $62, $13, $CD, $71, $13, $F3, $CD, $4D, $16, $2E, $02, $CD, $E9, $12
	db $3E, $80, $EA, $55, $55, $CD, $4D, $16, $E1, $CD, $E9, $12, $21, $00, $40, $36
	db $30, $FB, $21, $A3, $C5, $F0, $4D, $CB, $7F, $28, $0B, $3E, $07, $22, $3E, $B2
	db $22, $3E, $01, $77, $18, $09, $3E, $03, $22, $3E, $D9, $22, $3E, $00, $77, $21
	db $A3, $C5, $7E, $D6, $01, $22, $4F, $7E, $DE, $00, $22, $47, $7E, $DE, $00, $77
	db $B0, $B1, $28, $12, $21, $00, $40, $CB, $7E, $28, $E4, $CB, $6E, $20, $0A, $36
	db $F0, $CD, $59, $13, $AF, $C9, $21, $00, $40, $36, $F0, $CD, $59, $13, $37, $C9
	db $E5, $D5, $21, $A3, $C5, $71, $23, $70, $CD, $62, $13, $F3, $CD, $4D, $16, $2E
	db $02, $CD, $E9, $12, $3E, $A0, $EA, $55, $55, $FB, $69, $60, $CD, $E3, $12, $CD
	db $71, $13, $D1, $E1, $06, $80, $1A, $22, $13, $E5, $D5, $21, $E6, $CE, $5E, $23
	db $56, $1B, $05, $72, $2B, $73, $7B, $B2, $D1, $E1, $28, $08, $78, $A7, $20, $E6
	db $3E, $01, $18, $01, $AF, $EA, $A5, $C5, $2B, $36, $00, $D5, $FA, $E4, $CE, $A7
	db $28, $13, $F0, $4D, $CB, $7F, $28, $05, $11, $0A, $1A, $18, $03, $11, $05, $0D
	db $1B, $7B, $B2, $20, $FB, $F0, $4D, $A7, $28, $05, $11, $A8, $61, $18, $03, $11
	db $D4, $30, $1B, $7B, $B2, $28, $12, $7E, $CB, $7F, $28, $F6, $CB, $67, $28, $12
	db $36, $F0, $D1, $CD, $59, $13, $3E, $02, $C9, $36, $F0, $D1, $CD, $59, $13, $3E
	db $02, $C9, $36, $F0, $CD, $6C, $13, $D1, $E5, $D5, $1B, $3E, $80, $90, $47, $1A
	db $BE, $20, $1E, $2B, $1B, $05, $20, $F7, $FA, $A5, $C5, $A7, $20, $07, $D1, $E1
	db $CD, $59, $13, $AF, $C9, $21, $A3, $C5, $2A, $46, $4F, $D1, $E1, $23, $C3, $68
	db $15, $D1, $E1, $21, $E4, $CE, $34, $7E, $FE, $02, $20, $08, $CD, $59, $13, $3E
	db $02, $36, $00, $C9, $21, $A3, $C5, $2A, $66, $6F, $CD, $F8, $14, $38, $ED, $CD
	db $59, $13, $3E, $01, $C9
ASSERT @ == $164D
