; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $01BC-$02B7.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:01BC-02B7", ROM0[$01BC]
ResidualROM00_01BC::
	db $C3, $50, $0D, $C3, $15, $0F, $C3, $6D, $10, $C3, $8E, $10, $C3, $3E, $11, $C3
	db $4F, $11, $C3, $62, $11, $C3, $76, $11, $C3, $9C, $26, $C3, $1C, $27, $C3, $23
	db $27, $C3, $2A, $27, $C3, $31, $27, $C3, $53, $27, $C3, $99, $27, $C3, $AA, $27
	db $C3, $C1, $27, $C3, $BE, $28, $C3, $E3, $28, $C3, $45, $29, $C3, $4E, $29, $C3
	db $FE, $2B, $C3, $46, $2D, $C3, $53, $2D, $C3, $C3, $2D, $C3, $D0, $2D, $C3, $E7
	db $2D, $C3, $15, $2E, $C3, $E9, $2E, $C3, $FA, $2E, $C3, $1C, $2F, $C3, $E0, $2F
	db $C3, $31, $30, $C3, $BC, $30, $C3, $85, $31, $C3, $00, $20, $C3, $0A, $20, $C3
	db $12, $20, $C3, $23, $20, $C3, $35, $20, $C3, $46, $20, $C3, $57, $20, $C3, $6A
	db $20, $C3, $6C, $20, $C3, $8F, $21, $C3, $98, $21, $C3, $D7, $21, $C3, $42, $22
	db $C3, $A7, $22, $C3, $0C, $23, $C3, $5F, $23, $C3, $CC, $23, $C3, $86, $11, $C3
	db $8F, $11, $C3, $8F, $11, $C3, $AA, $11, $C3, $E4, $23, $C3, $B8, $24, $C3, $B9
	db $24, $C3, $4E, $25, $C3, $CB, $25, $C3, $EF, $25, $C3, $13, $26, $C3, $1C, $26
	db $C3, $20, $26, $C3, $85, $26, $C3, $63, $16, $C3, $75, $16, $C3, $89, $16, $C3
	db $9D, $16, $C3, $B1, $16, $C3, $BF, $16, $C3, $D6, $16, $C3, $ED, $16, $C3, $2D
	db $17, $C3, $6F, $17, $C3, $DC, $3E, $C3, $69, $3F, $C3, $3A, $3F, $C3, $4C, $3F
	db $C3, $55, $3F, $C3, $60, $3F, $C3, $8A, $31, $C3, $60, $35
ASSERT @ == $02B8
