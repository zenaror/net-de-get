; PROBABLE remaining main-state entries and consumed tables.
; SYNTHETIC prefixes/tails only: external callees and natural boot untested.

SECTION "Main states 04A6-04D6", ROM0[$04A6]
ResidualROM00_04A6::
MainState03::
	call $0288
	ld a, [$C706]
	add a, a
	ld d, $00
	ld e, a
	ld hl, MainState03CompareWords
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
	push hl
	ld hl, $C666
	ld c, [hl]
	inc hl
	ld b, [hl]
	ld l, c
	ld h, b
	call $0228
	pop hl
	jp nz, .at04D2
	ld a, [$C665]
	cp a, $81
	ld a, $00
	jp z, MainState03ConditionalDispatch
.at04D2:
	ld a, $01
	jp MainState03ConditionalDispatch
ASSERT @ == $04D7

SECTION "Main states 04D7-04DC", ROM0[$04D7]
MainState03CompareWords::
	dw $0021
	dw $005B
	dw $005C
ASSERT @ == $04DD

SECTION "Main states 04DD-04EC", ROM0[$04DD]
MainState03ConditionalDispatch::
	and a, a
	jr z, LocalMinigameSelectionBody
	call $0288
	ld a, [$C706]
	ld hl, MainState03BranchPointers
	push hl
	jp DispatchReturnTable
ASSERT @ == $04ED

SECTION "Main states 04ED-04F2", ROM0[$04ED]
MainState03BranchPointers::
	dw MainState03Branches
	dw MainState03Branch1
	dw MainState03Branch2
ASSERT @ == $04F3

SECTION "Main states 04F3-051D", ROM0[$04F3]
MainState03Branches::
	ld hl, $6000
	ld de, $0021
	call $0246
	ld a, $81
	call $024C
	jr LocalMinigameSelectionBody
MainState03Branch1::
	ld hl, $6000
	ld de, $005B
	call $0246
	ld a, $81
	call $024C
	jr LocalMinigameSelectionBody
MainState03Branch2::
	ld hl, $6000
	ld de, $005C
	call $0246
	ld a, $81
ASSERT @ == $051E

SECTION "Main states 0564-05C7", ROM0[$0564]
ResidualROM00_0564::
ResetMainState02::
	ld a, $02
	ld [$C623], a
	ret
MainState04::
	ld a, $04
	ld b, $00
	call $0264
	ld a, $02
	ld [$C623], a
	ret
MainState05::
	ld a, $0A
	ld b, $00
	call $0264
	ret
MainState06::
	xor a, a
	ld [$C623], a
	ld a, $03
	ld b, $00
	call $0264
	ld a, [$C623]
	cp a, $07
	jr z, .at0596
	ld a, $02
	ld [$C623], a
.at0596:
	ret
MainState07::
	ld a, $02
	ld b, $00
	call $0264
	ld a, $08
	ld [$C623], a
	ret
MainState08::
	ld a, $0D
	ld b, $00
	call $0264
	ld a, $02
	ld [$C623], a
	ret
MainState09::
	ld a, $16
	ld [$27FF], a
	ldh [$FFAB], a
	ld a, $00
	ld [$2800], a
	ldh [$FFAC], a
	call $44AA
	ld a, $11
	pop hl
	jp StartCartridgeProgram
ASSERT @ == $05C8
