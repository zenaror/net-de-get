; PROBABLE static role, no translation. Native A $14 / physical bank $0A.
SECTION "Local action input", ROMX[$4C6F], BANK[$0A]
HandleLocalActionInput::
	ldh a, [$FF97]
	and a, $01
	jr z, .at4C82
	ld a, $9D
	call ResidentJump024F
	ld a, [$D01D]
	ld [$D000], a
	jr .at4CD9
.at4C82:
	ldh a, [$FF98]
	and a, $20
	jr z, .at4C9B
	ld a, $9C
	call ResidentJump024F
	ld hl, $D01C
	ld a, [hl]
	and a, a
	jr nz, .at4C98
	ld a, [$D01E]
	ld [hl], a
.at4C98:
	dec [hl]
	jr .at4CD9
.at4C9B:
	ldh a, [$FF98]
	and a, $10
	jr z, .at4CB4
	ld a, $9C
	call ResidentJump024F
	ld hl, $D01C
	inc [hl]
	ld a, [$D01E]
	cp a, [hl]
	jr nz, .at4CD9
	ld [hl], $00
	jr .at4CD9
.at4CB4:
	ldh a, [$FF97]
	and a, $02
	jr z, .at4CD9
	ld a, $9E
	call ResidentJump024F
	ld a, [$D01D]
	ld [$D000], a
	ld a, $FF
	ld [$D01C], a
	ld a, $02
	ld de, $5BEA
	call ResidentJump01E3
	xor a, a
	call ResidentJump01FE
	call PrepareLocalDescription
.at4CD9:
	ret
.end:
ASSERT .end - HandleLocalActionInput == $6B
