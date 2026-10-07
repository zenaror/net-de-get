; PROBABLE byte counters for original zero-terminated C74E list.
SECTION "A0F list count 64AE-64D6", ROMX[$64AE], BANK[$07]
CountA0FTerminatedList::
	ld a, $00
	ld [$C76D], a
	ld a, $00
	ld [$C76C], a
	ld hl, $C74E
A0FList_44BB::
	ld a, [hl]
	or a, a
	jr z, A0FList_44D6
	push hl
	cp a, $FE
	jr c, A0FList_44CB
	ld a, [$C76D]
	inc a
	ld [$C76D], a
A0FList_44CB::
	ld a, [$C76C]
	inc a
	ld [$C76C], a
	pop hl
	inc hl
	jr A0FList_44BB
A0FList_44D6::
	ret
ASSERT @ == $64D7
