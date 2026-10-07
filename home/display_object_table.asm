; PROBABLE display-table pointer setter; caller and real ROM objects measured.
SECTION "Display table setter 1186-118E", ROM0[$1186]
ResidualROM00_1186::
SetDisplayObjectTablePointer::
	ld a, l
	ld [$C1C5], a
	ld a, h
	ld [$C1C6], a
	ret
ASSERT @ == $118F
