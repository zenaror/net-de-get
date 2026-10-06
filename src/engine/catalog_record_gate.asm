; Focused RGBDS excerpt: native MBC6 A selector $17 (decimal 23).
; ROM source SHA-256:
; 9fb1e6e4a637796b8624bd2de6c9abaa9e758546b620cb5dc8441b07c288bc63
; File base $2E000, CPU $4000-$5FFF. This is the upper half of physical
; 16 KiB bank $0B, not a 16 KiB mapper bank.
;
; PROBABLE: static reconstruction, correlated with natural catalog buffers.
; Runtime stage-88.wram: bank 5 contains five records; bank 2 DA81 lists
; 00/01/02/03 only, DBC1=1 omission, DBC6=FF. No hardware claim.

; RGBDS uses physical 16 KiB bank coordinates for this excerpt:
; bank $0B:$6A93 corresponds to native selector $17:$4A93.
SECTION "Catalog record pointer", ROMX[$6A93], BANK[$0B]
CatalogRecordPointer:
	push af
	ld a, 5
	ldh [$FF70], a
	pop af
	push af
	rlca
	inc a
	ld hl, $D001
	add l
	ld l, a
	ld a, 0
	adc h
	ld h, a
	ld a, [hl]
	ld b, a
	pop af
	rlca
	ld hl, $D001
	add l
	ld l, a
	ld a, 0
	adc h
	ld h, a
	ld a, [hl]
	ld hl, $D000
	add l
	ld l, a
	ld a, 0
	adc h
	ld h, a
	ld a, h
	add b
	ld h, a
	ld a, 2
	ldh [$FF70], a
	ret

; Byte offsets relative to the pointer returned above:
; +$04: block count ($47E9-$4804), compared with free/used allocation.
; +$05: category icon candidate ($530F B=5 -> $54F9 -> drawing).
; +$06..$09: four-byte ID copied to DB81 ($4820-$4833).
; +$0C..$0E: three minimum levels ($4972-$499F).
; +$10..$11, +$12..$13: hidden-level gates ($49BD-$4A24).
; +$14: title length ($44D7 and $4AE0), followed by title bytes.
; +$00..$03: unknown reserved prefix; all zero in accepted baseline records.
;
; The earlier serializer placed these fields four bytes earlier. In its
; custom record at file offset $170, +$10..$13 are 08 50 41 44 (title data),
; interpreted as gate words $5008/$4441. A subsequent natural retest with
; a four-byte zero prefix did expose PAD in the catalog. That confirms the
; visibility effect; the exact field meanings remain PROBABLE static analysis.
