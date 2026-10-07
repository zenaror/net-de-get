; PROBABLE static per-palette upload roles. No natural LCD-on trace.
SECTION "Palette entry thunks", ROM0[$0171]
UploadBackgroundPaletteEntry::
	jp UploadBackgroundPaletteEntryBody
UploadObjectPaletteEntry::
	jp UploadObjectPaletteEntryBody
.end:
ASSERT .end - UploadBackgroundPaletteEntry == 6

SECTION "Palette entry upload", ROM0[$0799]
UploadBackgroundPaletteEntryBody::
	push af
REPT 3
	sla a
ENDR
	ld c, $80
	or c
	ldh [$FF68], a
REPT 8
	ld a, [hli]
	ldh [$FF69], a
ENDR
	pop af
	inc a
	ret
UploadObjectPaletteEntryBody::
	push af
REPT 3
	sla a
ENDR
	ld c, $80
	or c
	ldh [$FF6A], a
REPT 8
	ld a, [hli]
	ldh [$FF6B], a
ENDR
	pop af
	inc a
	ret
.end:
ASSERT .end - UploadBackgroundPaletteEntryBody == $4E
