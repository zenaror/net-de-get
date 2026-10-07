; PROBABLE resident A1E pointer loader/request wrappers, thunk consumers.
; SYNTHETIC full mapper/register checks; no natural playback or IRQ timing.
SECTION "Resident A1E setup 21D7", ROM0[$21D7]
LoadA1EPointersFromBankB::
	ld a, e
	ld [$C663], a
	ld a, d
	ld [$C664], a
	ld a, [$C663]
	ld [$C666], a
	ld a, [$C664]
	ld [$C667], a
	di
	ld a, [$C663]
	ld [$37FF], a
	ld [$C115], a
	ld a, [$C664]
	ld [$3800], a
	ld [$C116], a
	ei
	ld a, [hli]
	ld [$CF92], a
	ld a, [hli]
	ld [$CF93], a
	ld a, [hli]
	ld [$CF90], a
	ld a, [hli]
	ld [$CF91], a
	ld a, [hli]
	ld [$CF94], a
	ld a, [hli]
	ld [$CF95], a
	ld a, [hli]
	ld [$CF96], a
	ld a, [hli]
	ld [$CF97], a
	ld a, [hli]
	ld [$CF98], a
	ld a, [hli]
	ld [$CF99], a
	ld a, [hli]
	ld [$CF9A], a
	ld a, [hli]
	ld [$CF9B], a
	di
	ldh a, [$FFAD]
	ld [$37FF], a
	ld [$C115], a
	ldh a, [$FFAE]
	ld [$3800], a
	ld [$C116], a
	ei
	ret
ASSERT @ == $2242
