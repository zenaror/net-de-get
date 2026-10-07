; PROBABLE pending record scan/update, called by initialization at4054.
; Raw C706 indexes C708 directly; no range clamp or natural validity claim.
SECTION "A12 pending scanner 5BDA-5C2E", ROMX[$5BDA], BANK[$09]
UpdateA12PendingRecord::
	ld a, [$C706]
	ld [$C5A8], a
	ld d, $00
	ld e, a
	ld hl, $C708
	add hl, de
	ld a, [hl]
	ld [$C5A4], a
	ld hl, A12PendingRecords
	ld de, $0006
	ld c, $01
A12PendingScanLoop::
	ld a, [hl]
	cp a, $FF
	jr z, A12PendingScanEnd
	ld b, a
	ld a, [$C705]
	cp a, b
	jr z, A12PendingScanMatch
	add hl, de
	inc c
	jr A12PendingScanLoop
A12PendingScanEnd::
	ret
A12PendingScanMatch::
	inc a
	ld [$C705], a
	ld a, c
	ld [$C73B], a
	inc hl
	push hl
	inc hl
	ld a, [hli]
	push af
	ld a, [$C5A8]
	ld d, $00
	ld e, a
	ld hl, $C708
	add hl, de
	pop af
	ld [hl], a
	ld [$C5A4], a
	pop hl
	ld a, [hl]
	cp a, $01
	ret nz
	ld a, $03
	ld [$C5A8], a
	xor a, a
	ld [$C738], a
	ret
ASSERT @ == $5C2F
