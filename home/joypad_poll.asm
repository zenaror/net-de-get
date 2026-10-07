; PROBABLE original polling/edge/repeat contract; synthetic core key inputs.
; Opposing directions depend on fixture core policy, not hardware evidence.
SECTION "Joypad polling 261C-2684", ROM0[$261C]
ResidualROM00_261C::
TickCounterAndPollJoypad::
	ld hl, $FF8B
	inc [hl]
PollJoypadState::
	ld a, $20
	ldh [$FF00], a
	ldh a, [$FF00]
	ldh a, [$FF00]
	cpl
	and a, $0F
	swap a
	ld b, a
	ld a, $10
	ldh [$FF00], a
	ldh a, [$FF00]
	ldh a, [$FF00]
	ldh a, [$FF00]
	ldh a, [$FF00]
	ldh a, [$FF00]
	ldh a, [$FF00]
	cpl
	and a, $0F
	or a, b
	ld c, a
	ldh a, [$FF96]
	xor a, c
	and a, c
	ldh [$FF97], a
	ld a, c
	ldh [$FF96], a
	ld a, $30
	ldh [$FF00], a
	ld hl, $FF9A
	ldh a, [$FF96]
	and a, $F3
	ld c, a
	ldh a, [$FF99]
	cp a, c
	jr z, Joypad_266B
	ld [hl], $00
	ld a, c
	ldh [$FF99], a
Joypad_2662::
	ldh a, [$FF97]
	ldh [$FF98], a
	ld a, $01
	ldh [$FF9B], a
	ret
Joypad_266B::
	ld a, [hl]
	inc a
	and a, $9F
	jr nz, Joypad_2673
	ld a, $80
Joypad_2673::
	ld [hl], a
	bit 7, a
	jr z, Joypad_2662
	and a, $03
	jr nz, Joypad_2662
	ldh a, [$FF97]
	or a, c
	ldh [$FF98], a
	xor a, a
	ldh [$FF9B], a
	ret
ASSERT @ == $2685
