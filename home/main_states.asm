; PROBABLE main-state flow: consumed by MainStatePointers / ROM0 $0391.
; Explicit tables and SYNTHETIC state-write/dispatch probes; no natural boot.

SECTION "Main states 03BC-0406", ROM0[$03BC]
ResidualROM00_03BC::
MainState00::
	ld a, $00
	ld b, $00
	call ResidentJump0264
	ld a, $01
	ld [$C623], a
	ret
MainState01::
	ld a, $06
	ld b, $00
	call ResidentJump0264
	ld a, $02
	ld [$C623], a
	ret
MainState02::
	call ResidentJump0288
	ld a, [$C706]
	add a, a
	ld d, $00
	ld e, a
	ld hl, MainStateCompareWords
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
	call ResidentJump0228
	pop hl
	jp nz, .at0402
	ld a, [$C665]
	cp a, $81
	ld a, $00
	jp z, MainState02ConditionalDispatch
.at0402:
	ld a, $01
	jp MainState02ConditionalDispatch
ASSERT @ == $0407

SECTION "Main states 0407-040C", ROM0[$0407]
MainStateCompareWords::
	dw $0021
	dw $005B
	dw $005C
ASSERT @ == $040D

SECTION "Main states 040D-041C", ROM0[$040D]
MainState02ConditionalDispatch::
	and a, a
	jr z, MainState02ResultDispatch
	call ResidentJump0288
	ld a, [$C706]
	ld hl, MainState02BranchPointers
	push hl
	jp DispatchReturnTable
ASSERT @ == $041D

SECTION "Main states 041D-0422", ROM0[$041D]
MainState02BranchPointers::
	dw MainState02Branches
	dw MainState02Branch1
	dw MainState02Branch2
ASSERT @ == $0423

SECTION "Main states 0423-046D", ROM0[$0423]
MainState02Branches::
	ld hl, $6000
	ld de, $0021
	call ResidentJump0246
	ld a, $81
	call ResidentJump024C
	jr MainState02ResultDispatch
MainState02Branch1::
	ld hl, $6000
	ld de, $005B
	call ResidentJump0246
	ld a, $81
	call ResidentJump024C
	jr MainState02ResultDispatch
MainState02Branch2::
	ld hl, $6000
	ld de, $005C
	call ResidentJump0246
	ld a, $81
	call ResidentJump024C
MainState02ResultDispatch::
	ld a, $07
	ld b, $00
	call ResidentJump0264
	ld a, [$C214]
	ld hl, MainStateResultPointers
	add a, a
	ld e, a
	ld d, $00
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld hl, MainState02Return
	push hl
	ld l, e
	ld h, d
	jp hl
MainState02Return::
	ret
ASSERT @ == $046E

SECTION "Main states 046E-047B", ROM0[$046E]
MainStateResultPointers::
	dw WriteMainState03
	dw WriteMainState04
	dw WriteMainState05
	dw WriteMainState01
	dw WriteMainState02
	dw WriteMainState07
	dw WriteMainState06
ASSERT @ == $047C

SECTION "Main states 047C-04A5", ROM0[$047C]
WriteMainState03::
	ld a, $03
	ld [$C623], a
	ret
WriteMainState04::
	ld a, $04
	ld [$C623], a
	ret
WriteMainState05::
	ld a, $05
	ld [$C623], a
	ret
WriteMainState01::
	ld a, $01
	ld [$C623], a
	ret
WriteMainState02::
	ld a, $02
	ld [$C623], a
	ret
WriteMainState07::
	ld a, $07
	ld [$C623], a
	ret
WriteMainState06::
	ld a, $06
	ld [$C623], a
	ret
ASSERT @ == $04A6
