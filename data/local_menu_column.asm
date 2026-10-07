; PROBABLE column: state 0 queues width 1, height 9, single-plane flag $80.
; This read interval does not establish the full extent of the following data.
SECTION "Local menu column", ROMX[$4224], BANK[$0A]
LocalMenuColumn::
	db $80, $80, $80, $80, $80, $80, $80, $80, $80
.end:
ASSERT .end - LocalMenuColumn == 9
