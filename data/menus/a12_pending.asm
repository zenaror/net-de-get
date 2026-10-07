; PROBABLE six-byte pending records consumed at 5BEB/5C2F/5C55.
; Keep the four prefix bytes literal; the last word is the queued pointer.
; The scanner terminates at the first FF byte at 572B, outside this table.
SECTION "A12 pending records 56AD-572A", ROMX[$56AD], BANK[$09]
A12PendingRecords::
	db $00, $00, $00, $00
	dw $55B2
	db $02, $01, $01, $00
	dw $572F
	db $08, $01, $02, $00
	dw $57A6
	db $0C, $01, $03, $00
	dw $57BB
	db $10, $01, $04, $00
	dw $5850
	db $14, $01, $05, $00
	dw $58B4
	db $18, $00, $05, $01
	dw $58E5
	db $19, $00, $00, $00
	dw $591F
	db $1C, $01, $01, $00
	dw $594A
	db $20, $01, $02, $00
	dw $5960
	db $24, $01, $03, $00
	dw $5975
	db $28, $01, $04, $00
	dw $59B8
	db $2C, $01, $05, $00
	dw $5A0E
	db $30, $00, $05, $02
	dw $5A33
	db $31, $00, $00, $00
	dw $5A6C
	db $34, $01, $01, $00
	dw $5A96
	db $38, $01, $02, $00
	dw $5AD2
	db $3C, $01, $03, $00
	dw $5B2D
	db $40, $01, $04, $00
	dw $5B67
	db $44, $01, $05, $00
	dw $5B78
	db $48, $00, $06, $03
	dw $5BB0
ASSERT @ == $572B
