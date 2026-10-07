; PROBABLE palette source: both upload helpers read exactly eight bytes.
; Following identical bytes are excluded until their consumers are established.
SECTION "Local menu white palette", ROMX[$487E], BANK[$0A]
LocalMenuWhitePalette::
	db $FF, $7F, $FF, $7F, $FF, $7F, $FF, $7F
.end:
ASSERT .end - LocalMenuWhitePalette == 8
