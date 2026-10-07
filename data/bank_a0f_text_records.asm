; PROBABLE four reached eight-byte records; five fields read by2753.
; Trailing bytes are literal; no wider table extent asserted.
SECTION "A0F indexed text records 7268-7287", ROMX[$7268], BANK[$07]
A0FTextRegionRecordPrefix::
	db $00, $06, $12, $05, $01, $00, $00, $00, $05, $02, $09, $01, $00, $00, $00, $00
	db $01, $02, $11, $01, $00, $00, $00, $00, $01, $02, $10, $01, $02, $00, $00, $00
ASSERT @ == $7288
