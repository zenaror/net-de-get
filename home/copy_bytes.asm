; PROBABLE byte copy loop; positive-count SYNTHETIC cases only.
SECTION "Copy bytes HL to DE", ROM0[$2613]
CopyBytesHLToDE::
.loop:
	ld a, [hli]
	ld [de], a
	inc de
	dec bc
	ld a, b
	or a, c
	jr nz, .loop
	ret
ASSERT @ == $261C
