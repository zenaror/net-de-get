; PROBABLE resident A1E pointer loader/request wrappers, thunk consumers.
; SYNTHETIC full mapper/register checks; no natural playback or IRQ timing.
SECTION "Resident A1E setup 22A7", ROM0[$22A7]
ResidualROM00_22A7::
RequestA1ELowerStreams::
	push af
	push bc
	push de
	push hl
	di
	ld [$CF80], a
	ld [$C66B], a
	ld [$C665], a
	ld a, [$C663]
	ld [$C666], a
	ld a, [$C664]
	ld [$C667], a
	ld a, [$C663]
	ld [$37FF], a
	ld [$C115], a
	ld a, [$C664]
	ld [$3800], a
	ld [$C116], a
	ld a, $1E
	ld [$27FF], a
	ld [$C113], a
	ld a, $00
	ld [$2800], a
	ld [$C114], a
	call NativeA1ELowerStreamEntry
	ldh a, [$FFAB]
	ld [$27FF], a
	ld [$C113], a
	ldh a, [$FFAC]
	ld [$2800], a
	ld [$C114], a
	ldh a, [$FFAD]
	ld [$37FF], a
	ld [$C115], a
	ldh a, [$FFAE]
	ld [$3800], a
	ld [$C116], a
	ei
	pop hl
	pop de
	pop bc
	pop af
	ret
RequestA1EUpperStreams::
	push af
	push bc
	push de
	push hl
	di
	ld [$CF82], a
	ld a, [$C663]
	ld [$37FF], a
	ld [$C115], a
	ld a, [$C664]
	ld [$3800], a
	ld [$C116], a
	ld a, $1E
	ld [$27FF], a
	ld [$C113], a
	ld a, $00
	ld [$2800], a
	ld [$C114], a
	call NativeA1EUpperStreamEntry
	ldh a, [$FFAB]
	ld [$27FF], a
	ld [$C113], a
	ldh a, [$FFAC]
	ld [$2800], a
	ld [$C114], a
	ldh a, [$FFAD]
	ld [$37FF], a
	ld [$C115], a
	ldh a, [$FFAE]
	ld [$3800], a
	ld [$C116], a
	ei
	pop hl
	pop de
	pop bc
	pop af
	ret
RequestA1EBothStreamsAndTick::
	push af
	push bc
	push de
	push hl
	di
	ld a, $80
	ld [$CF80], a
	ld a, $80
	ld [$CF82], a
	ld a, [$C663]
	ld [$37FF], a
	ld [$C115], a
	ld a, [$C664]
	ld [$3800], a
	ld [$C116], a
	ld a, $1E
	ld [$27FF], a
	ld [$C113], a
	ld a, $00
	ld [$2800], a
	ld [$C114], a
	call NativeA1ELowerStreamEntry
	call NativeA1EUpperStreamEntry
	call NativeA1EEntry
	ldh a, [$FFAB]
	ld [$27FF], a
	ld [$C113], a
	ldh a, [$FFAC]
	ld [$2800], a
	ld [$C114], a
	ldh a, [$FFAD]
	ld [$37FF], a
	ld [$C115], a
	ldh a, [$FFAE]
	ld [$3800], a
	ld [$C116], a
	xor a, a
	ld [$C665], a
	ld [$C666], a
	ld [$C667], a
	ld [$C66B], a
	ei
	pop hl
	pop de
	pop bc
	pop af
	ret
BeginA1EGlobalCountdown::
	ld a, $02
	ld [$CF86], a
	ld a, $01
	ld [$CF87], a
	xor a, a
	ld [$C665], a
	ld [$C666], a
	ld [$C667], a
	ld [$C66B], a
	ret
ASSERT @ == $23E4
