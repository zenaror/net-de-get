; PROBABLE static handler; state number is its literal table index.
; Native A $14; physical RGBDS bank $0A lower half.
; Keep numeric fields/callees where their meaning is not yet established.
SECTION "Local menu state 4", ROMX[$4303], BANK[$0A]
LocalMenuState4::
	ld a, [$D007]
	ld b, a
	ld a, [$D002]
	add a, b
	ld c, a
	ld a, [$D01C]
	cp $FF
	jr nz, .at431B
	ld a, $01
	ld [wLocalMenuState], a
	jp .at43BF
.at431B:
	and a
	jr nz, .at433D
	ld a, [$D003]
	cp c
	jp z, .at43BF
	ld b, c
	ld a, [$D001]
	ld c, a
	call $4CDA
	ld a, [$C5C3]
	ld [$C671], a
	xor a
	ld [$C5A3], a
	call $455F
	jp .at43BF
.at433D:
	ld [$D020], a
	cp $01
	jr nz, .at4364
	ld a, $02
	ld [wLocalMenuState], a
	ld a, [$D002]
	ld [$D00B], a
	ld a, [$D007]
	ld [$D00C], a
	ld a, [$D001]
	ld [$D00A], a
	ld a, [$D003]
	ld [$D00D], a
	jp .at43BF
.at4364:
	xor a
	ld [$C001], a
	ld b, $16
	ld hl, $C020
	xor a
.at436E:
	ld [hli], a
	inc hl
	inc hl
	inc hl
	dec b
	jr nz, .at436E
	ld a, $10
	ld [$C1C2], a
	ld a, $02
	ld de, $5BEA
	call $01E3
	xor a
	call $01FE
	ld a, $03
	ld c, $02
	ld de, $5BEA
	call $01E6
	xor a
	call $01FE
	ld hl, $5C4D
	call $5152
	ld a, $02
	ld de, $5BEA
	call $01E3
	ld hl, $5C36
	ld bc, $0000
	call $01EF
	ld a, $05
	ld [$D01D], a
	ld a, $01
	ld [$D01C], a
	ld a, $03
	ld [wLocalMenuState], a
	ld a, $02
	ld [$D01E], a
.at43BF:
	ret
.end:
ASSERT .end - LocalMenuState4 == $BD
