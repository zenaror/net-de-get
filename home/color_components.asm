; PROBABLE original color component conversion; synthetic CPU evidence.
SECTION "Color components 08FB-0924", ROM0[$08FB]
ExpandPackedColorComponents::
ColorComponents_08FB::
	xor a, a
	ld [de], a
	inc de
	ld a, [hli]
	ld b, a
	and a, $1F
	rlca
	rlca
	rlca
	ld [de], a
	inc de
	xor a, a
	ld [de], a
	inc de
	ld a, b
	and a, $E0
	rrca
	rrca
	ld b, a
	ld a, [hl]
	and a, $03
	rrca
	rrca
	or a, b
	ld [de], a
	inc de
	xor a, a
	ld [de], a
	inc de
	ld a, [hli]
	and a, $7C
	rlca
	ld [de], a
	inc de
	dec c
	jr nz, ColorComponents_08FB
	ret
ASSERT @ == $0925

; PROBABLE original color component conversion; synthetic CPU evidence.
SECTION "Color components 0925-096E", ROM0[$0925]
ExpandInvertedColorDeltas::
ColorComponents_0925::
	ld a, [hl]
	and a, $1F
	ld b, a
	ld a, $1F
	sub a, b
	rrca
	rrca
	ld b, a
	and a, $C0
	ld [de], a
	inc de
	ld a, b
	and a, $07
	ld [de], a
	inc de
	ld a, [hli]
	and a, $E0
	swap a
	rrca
	ld b, a
	ld a, [hl]
	and a, $03
	swap a
	rrca
	or a, b
	ld b, a
	ld a, $1F
	sub a, b
	rrca
	rrca
	ld b, a
	and a, $C0
	ld [de], a
	inc de
	ld a, b
	and a, $07
	ld [de], a
	inc de
	ld a, [hli]
	and a, $7C
	rrca
	rrca
	ld b, a
	ld a, $1F
	sub a, b
	rrca
	rrca
	ld b, a
	and a, $C0
	ld [de], a
	inc de
	ld a, b
	and a, $07
	ld [de], a
	inc de
	dec c
	jr nz, ColorComponents_0925
	ret
ASSERT @ == $096F

; PROBABLE original color component conversion; synthetic CPU evidence.
SECTION "Color components 096F-0994", ROM0[$096F]
Pack64ColorComponents::
	ld c, $40
ColorComponents_0971::
	ld a, [hli]
	inc hl
	and a, $F8
	rrca
	rrca
	rrca
	ld b, a
	ld a, [hli]
	inc hl
	rlca
	rlca
	ldh [$FF9D], a
	and a, $E0
	or a, b
	ld [de], a
	inc de
	ldh a, [$FF9D]
	and a, $03
	ld b, a
	ld a, [hli]
	inc hl
	rrca
	and a, $7C
	or a, b
	ld [de], a
	inc de
	dec c
	jr nz, ColorComponents_0971
	ret
ASSERT @ == $0995
