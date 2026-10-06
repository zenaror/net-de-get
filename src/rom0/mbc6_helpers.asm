; Partial RGBDS reconstruction of four unambiguous ROM0 routines.
; Source image SHA-256:
;   9fb1e6e4a637796b8624bd2de6c9abaa9e758546b620cb5dc8441b07c288bc63
;
; PROBABLE: byte-level static disassembly. These routines have not been
; captured in a natural execution trace. This file is an excerpt, not a
; standalone or complete ROM source tree.

SECTION "MBC6 map window B", ROM0[$12BF]
MBC6_MapWindowB:
	ld de, $CEFC
	ld a, l
	ld [$3000], a
	ld [de], a
	inc de
	ld a, h
	ld [$3800], a
	ld [de], a
	ret

SECTION "MBC6 map window A", ROM0[$12E9]
MBC6_MapWindowA:
	ld de, $CEFE
	ld a, l
	ld [$2000], a
	ld [de], a
	inc de
	ld a, h
	ld [$2800], a
	ld [de], a
	ret

SECTION "MBC6 unlock window B", ROM0[$14E2]
MBC6_UnlockWindowB:
	ld hl, $0802
	call MBC6_MapWindowB
	ld a, $AA
	ld [$7555], a
	ld l, $01
	call MBC6_MapWindowB
	ld a, $55
	ld [$6AAA], a
	ret

SECTION "MBC6 unlock window A", ROM0[$164D]
MBC6_UnlockWindowA:
	ld hl, $0802
	call MBC6_MapWindowA
	ld a, $AA
	ld [$5555], a
	ld l, $01
	call MBC6_MapWindowA
	ld a, $55
	ld [$4AAA], a
	ret
