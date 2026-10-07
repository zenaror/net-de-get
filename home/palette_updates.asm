; PROBABLE static palette-upload role; no natural LCD timing evidence.
SECTION "Pending palette thunk", ROM0[$018C]
UploadPendingCGBPalettes::
	jp UploadPendingCGBPalettesBody
.end:
ASSERT .end - UploadPendingCGBPalettes == 3

SECTION "Pending palette upload", ROM0[$0995]
UploadPendingCGBPalettesBody::
	push af
	ld a, [$C221]
	and a
	jr z, .return
	xor a
	ld [$C221], a
	push bc
	push hl
	ld hl, $C222
	ld b, $08
	ld a, $80
	ldh [$FF68], a
.background:
REPT 8
	ld a, [hli]
	ldh [$FF69], a
ENDR
	dec b
	jr nz, .background
	ld b, $08
	ld a, $80
	ldh [$FF6A], a
.objects:
REPT 8
	ld a, [hli]
	ldh [$FF6B], a
ENDR
	dec b
	jr nz, .objects
	pop hl
	pop bc
.return:
	pop af
	ret
.end:
ASSERT .end - UploadPendingCGBPalettesBody == $56
