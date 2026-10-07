; Three bytes before the next routine; index bounds remain unproven.
SECTION "Local remove cursor offsets", ROMX[$48D7], BANK[$0A]
LocalRemoveCursorOffsets::
	db $10, $38, $68
.end:
ASSERT .end - LocalRemoveCursorOffsets == 3
