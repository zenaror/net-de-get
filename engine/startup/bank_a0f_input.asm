; PROBABLE original input flow; forced gating/direction calls, no natural menu trace.
SECTION "A0F input 61C5-61F0", ROMX[$61C5], BANK[$07]
ResidualROM07_61C5::
DispatchA0FInput::
	ld a, [$C1B8]
	or a, a
	ret nz
	ld a, [$C772]
	cp a, $00
	jr z, A0FInput_41F0
	cp a, $63
	jr nz, A0FInput_41EA
	ld a, [$C220]
	or a, a
	jr nz, A0FInput_41F0
	ld a, [$C220]
	or a, a
	jr z, A0FInput_41E3
	jr A0FInput_41F0
A0FInput_41E3::
	ld a, $00
	ld [$C772], a
	jr A0FInput_41F0
A0FInput_41EA::
	call HandleA0FInput - $2000
	call QueueA0FPositionedObject - $2000
A0FInput_41F0::
	ret
ASSERT @ == $61F1

; PROBABLE original input flow; forced gating/direction calls, no natural menu trace.
SECTION "A0F input 61F1-6305", ROMX[$61F1], BANK[$07]
HandleA0FInput::
	ldh a, [$FF98]
	and a, $10
	jr z, A0FInput_420C
	ld a, $83
	call ResidentJump024F
	ld a, [$C766]
	inc a
	cp a, $0F
	jr c, A0FInput_4206
	ld a, $00
A0FInput_4206::
	ld [$C766], a
	call RemapA0FColumnOnLastRow - $2000
A0FInput_420C::
	ldh a, [$FF98]
	and a, $20
	jr z, A0FInput_4228
	ld a, $83
	call ResidentJump024F
	ld a, [$C766]
	dec a
	cp a, $FF
	jp nz, A0FInput_4222 - $2000
	ld a, $0E
A0FInput_4222::
	ld [$C766], a
	call RemapA0FColumnOnLastRow - $2000
A0FInput_4228::
	ldh a, [$FF98]
	and a, $80
	jr z, A0FInput_4246
	ld a, $82
	call ResidentJump024F
	ld a, [$C767]
	inc a
	call SnapA0FColumnForIncomingRow - $2000
	cp a, $05
	jr c, A0FInput_4240
	ld a, $00
A0FInput_4240::
	ld [$C767], a
	call SelectA0FDisplayVariant - $2000
A0FInput_4246::
	ldh a, [$FF98]
	and a, $40
	jr z, A0FInput_4264
	ld a, $82
	call ResidentJump024F
	ld a, [$C767]
	dec a
	cp a, $FF
	jr nz, A0FInput_425E
	ld a, $04
	call SnapA0FColumnForIncomingRow - $2000
A0FInput_425E::
	ld [$C767], a
	call SelectA0FDisplayVariant - $2000
A0FInput_4264::
	ldh a, [$FF97]
	and a, $02
	jr z, A0FInput_4275
	ld a, $85
	call ResidentJump024F
	call $451F
	jp A0FInput_4305 - $2000
A0FInput_4275::
	ldh a, [$FF97]
	and a, $01
	jp z, A0FInput_42DD - $2000
	ld a, [$C767]
	cp a, $04
	jp c, A0FInput_42D3 - $2000
	ld a, [$C766]
	cp a, $01
	jr nz, A0FInput_4295
	ld a, $84
	call ResidentJump024F
	call $455D
	jr A0FInput_4305
A0FInput_4295::
	cp a, $06
	jr c, A0FInput_4305
	and a, $08
	rrca
	rrca
	rrca
	ld [$C764], a
	xor a, $01
	add a, $84
	call ResidentJump024F
	ld a, [$C764]
	or a, a
	jr z, A0FInput_42C6
	ld hl, $C74E
	ld a, [hl]
	or a, a
	jr z, A0FInput_42BF
	dec hl
A0FInput_42B6::
	inc hl
	ld a, [hl]
	cp a, $10
	jr z, A0FInput_42B6
	or a, a
	jr nz, A0FInput_42C6
A0FInput_42BF::
	ld a, $85
	call ResidentJump024F
	jr A0FInput_4305
A0FInput_42C6::
	call ResidentJump0255
	ld a, $63
	ld [$C772], a
	call $47AA
	jr A0FInput_4305
A0FInput_42D3::
	ld a, $84
	call ResidentJump024F
	call $43F0
	jr A0FInput_4305
A0FInput_42DD::
	ldh a, [$FF97]
	and a, $08
	jr z, A0FInput_42F7
	ld a, $84
	call ResidentJump024F
	ld a, $0B
	ld [$C766], a
	ld a, $04
	ld [$C767], a
	call SelectA0FDisplayVariant - $2000
	jr A0FInput_4305
A0FInput_42F7::
	ldh a, [$FF97]
	and a, $04
	jr z, A0FInput_4305
	ld a, $84
	call ResidentJump024F
	call $455D
A0FInput_4305::
	ret
ASSERT @ == $6306
