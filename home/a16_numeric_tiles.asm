; PROBABLE original tile-byte numeric formatting; no translation.
; Byte arithmetic and overflow cases remain literal.
SECTION "A16 fields 015C-015E", ROM0[$015C]
ResidualROM00_015C::
FormatA16WordTiles::
	jp FormatA16WordTilesBody
ASSERT @ == $015F

SECTION "A16 fields 0162-0164", ROM0[$0162]
FormatA16ByteTiles::
	jp FormatA16ByteTilesBody
ASSERT @ == $0165

SECTION "A16 fields 06A6-06DE", ROM0[$06A6]
ResidualROM00_06A6::
FormatA16WordTilesBody::
	push hl
	push hl
	ld l, e
	ld h, d
	ld c, $64
	call $2057
	ld a, l
	ld d, h
	pop hl
	push de
	call FormatA16ByteTilesBody
	pop af
	call FormatA16ByteTilesBody
	pop hl
	ld b, $04
	ld c, $00
A16Field_06BF::
	ld a, [hl]
	cp a, $10
	jr nz, A16Field_06CC
	ld a, c
	and a, a
	jr z, A16Field_06DA
	ld [hl], $20
	jr A16Field_06DA
A16Field_06CC::
	cp a, $20
	jr nz, A16Field_06D8
	ld a, c
	and a, a
	jr nz, A16Field_06DA
	ld [hl], $10
	jr A16Field_06DA
A16Field_06D8::
	ld c, $01
A16Field_06DA::
	inc hl
	dec b
	jr nz, A16Field_06BF
	ret
ASSERT @ == $06DF

SECTION "A16 fields 0722-0746", ROM0[$0722]
FormatA16ByteTilesBody::
	cp a, $63
	jr z, A16Field_0729
	jp nc, A16Field_0740
A16Field_0729::
	push hl
	ld c, $0A
	call $2046
	ld de, $2020
	add hl, de
	ld a, l
	cp a, $20
	jr nz, A16Field_073A
	ld a, $10
A16Field_073A::
	ld e, h
	pop hl
	ld [hli], a
	ld [hl], e
	inc hl
	ret
A16Field_0740::
	ld a, $4E
	ld [hli], a
	ld a, $47
	ld [hli], a
	ret
ASSERT @ == $0747
