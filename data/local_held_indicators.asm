; Original two-plane cells, one tile by one tile; no translation.
SECTION "Local held indicator cells", ROMX[$4813], BANK[$0A]
LocalHeldOldBit10::
	db $EB, $00
LocalHeldOldBit20::
	db $EA, $00
LocalHeldNewBit10::
	db $E9, $01
LocalHeldNewBit20::
	db $E8, $01
.end:
ASSERT .end - LocalHeldOldBit10 == 8
