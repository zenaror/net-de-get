; PROBABLE original A0F display entry/loop; bounded synthetic control only.
; Original resources remain untranslated; IRQ/audio progress needs separate evidence.
SECTION "A0F display entry 6000-609B", ROMX[$6000], BANK[$07]
ResidualROM07_6000::
A0FDisplayEntry::
	call InitializeA0FDisplay - $2000
	call InitializeA0FGraphicsAndTilemap - $2000
	ld a, $81
	call ResidentJump024C
	ld a, $01
	call ResidentJump01D4
	ld hl, ResidualROM07_6F60 - $2000
	ld a, [$C765]
	or a, a
	jr z, A0FEntry_4027
	ld hl, ResidualROM07_6F60 + $180 - $2000
	ld a, [$C74E]
	or a, a
	jr nz, A0FEntry_4027
	ld a, $03
	ld [$C765], a
A0FEntry_4027::
	ld a, $0F
	ld [$C21C], a
	ld a, $00
	ld [$C21D], a
	call ResidentJump01E0
	ld a, $00
	ld c, $00
	ld de, A0FTextRegionRecordPrefix - $2000
	call ResidentJump01E6
	ld a, [$C765]
	and a, $01
	inc a
	ld c, $00
	ld de, A0FTextRegionRecordPrefix - $2000
	call ResidentJump01E6
	ld a, [$C765]
	and a, $01
	or a, a
	jr z, A0FEntry_405F
	ld a, $02
	inc a
	ld c, $00
	ld de, A0FTextRegionRecordPrefix - $2000
	call ResidentJump01E6
A0FEntry_405F::
	ld a, $00
	call DrawA0FResourceGrid - $2000
	call RedrawA0FListText - $2000
	call DrawA0FModeIndicatorRow - $2000
	ld a, [$C773]
	ld l, a
	ld a, [$C774]
	ld h, a
	ld a, $04
	call StartColorSubtractTransition
A0FDisplayMainLoop::
	call ResidentJump0279
	call ResidentJump01EC
	call ResidentJump0261
	call StepColorTransition
	call DispatchA0FInput - $2000
	ld a, [$C772]
	cp a, $00
	jr nz, A0FEntry_4097
	call ResidentJump0261
	call ClearA0FDisplayCallbacks - $2000
	ld a, [$C764]
	ret
A0FEntry_4097::
	call WaitA0FFrameFlag - $2000
	jr A0FDisplayMainLoop
ASSERT @ == $609C
