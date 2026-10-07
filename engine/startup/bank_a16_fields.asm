; PROBABLE A16 field dispatcher and eight bounded table entries.
; SYNTHETIC prefixes before presentation; no natural field/menu meaning.
SECTION "A16 fields 4BCA-4BDC", ROMX[$4BCA], BANK[$0B]
ResidualROM0B_4BCA::
DispatchA16MenuField::
	ld hl, A16MenuFieldPointerTable
	add a, a
	ld e, a
	ld d, $00
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld hl, ReturnFromA16MenuField
	push hl
	ld l, e
	ld h, d
	jp hl
ReturnFromA16MenuField::
	ret
ASSERT @ == $4BDD

SECTION "A16 field pointer prefix", ROMX[$4BDD], BANK[$0B]
A16MenuFieldPointerTable::
	dw FormatA16MenuField0, FormatA16MenuField1, FormatA16MenuField2, FormatA16MenuField3, FormatA16MenuField4, FormatA16MenuField5, FormatA16MenuField6, FormatA16MenuField7
ASSERT @ == $4BED

SECTION "A16 fields 4BED-4BFE", ROMX[$4BED], BANK[$0B]
FormatA16MenuField0::
	ld a, [$C73D]
	ld hl, $C655
	call FormatA16ByteTiles
	xor a, a
	ld [hl], a
	ld hl, $C655
	call $01E9
	ret
ASSERT @ == $4BFF

SECTION "A16 fields 4BFF-4C10", ROMX[$4BFF], BANK[$0B]
FormatA16MenuField1::
	ld a, [$C73E]
	ld hl, $C655
	call FormatA16ByteTiles
	xor a, a
	ld [hl], a
	ld hl, $C655
	call $01E9
	ret
ASSERT @ == $4C11

SECTION "A16 fields 4C11-4C22", ROMX[$4C11], BANK[$0B]
FormatA16MenuField2::
	ld a, [$C73F]
	ld hl, $C655
	call FormatA16ByteTiles
	xor a, a
	ld [hl], a
	ld hl, $C655
	call $01E9
	ret
ASSERT @ == $4C23

SECTION "A16 fields 4C23-4C39", ROMX[$4C23], BANK[$0B]
FormatA16MenuField3::
	ld a, [$C747]
	ld e, a
	ld a, [$C748]
	ld d, a
	ld hl, $C655
	call FormatA16WordTiles
	xor a, a
	ld [hl], a
	ld hl, $C655
	call $01E9
	ret
ASSERT @ == $4C3A

SECTION "A16 fields 4C3A-4C50", ROMX[$4C3A], BANK[$0B]
FormatA16MenuField4::
	ld a, [$C745]
	ld e, a
	ld a, [$C746]
	ld d, a
	ld hl, $C655
	call FormatA16WordTiles
	xor a, a
	ld [hl], a
	ld hl, $C655
	call $01E9
	ret
ASSERT @ == $4C51

SECTION "A16 fields 4C51-4C62", ROMX[$4C51], BANK[$0B]
FormatA16MenuField5::
	ld a, [$C84B]
	ld hl, $C655
	call FormatA16ByteTiles
	xor a, a
	ld [hl], a
	ld hl, $C655
	call $01E9
	ret
ASSERT @ == $4C63

SECTION "A16 fields 4C63-4C74", ROMX[$4C63], BANK[$0B]
FormatA16MenuField6::
	ld a, [$C84C]
	ld hl, $C655
	call FormatA16ByteTiles
	xor a, a
	ld [hl], a
	ld hl, $C655
	call $01E9
	ret
ASSERT @ == $4C75

SECTION "A16 fields 4C75-4C86", ROMX[$4C75], BANK[$0B]
FormatA16MenuField7::
	ld a, [$C84D]
	ld hl, $C655
	call FormatA16ByteTiles
	xor a, a
	ld [hl], a
	ld hl, $C655
	call $01E9
	ret
ASSERT @ == $4C87
