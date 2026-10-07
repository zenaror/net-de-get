; PROBABLE original display setup; original C74E list and B5A header are measured.
; Synthetic bounded lists permit complete setup; no natural menu/IRQ trace.
SECTION "A0F setup 609C-60B1", ROMX[$609C], BANK[$07]
InitializeA0FDisplay::
PrepareA0FDisplayTablePrefix::
	di
	xor a, a
	ldh [$FF4F], a
	ldh [$FF70], a
	ld a, $0F
	ld [$C21C], a
	ld a, $00
	ld [$C21D], a
	ld hl, A0FDisplayTablePrefix - $2000
	call ResidentJump0258
ASSERT @ == $60B2

SECTION "A0F setup 60B2-6140", ROMX[$60B2], BANK[$07]
ResidualROM07_60B2::
InitializeA0FDisplayContinuation::
	ld de, $47CD
	call SetRuntimeInterruptStub0
	ld de, $47CE
	call StoreRuntimeCallback0
	ld de, $0000
	call StoreRuntimeCallback1
	ld de, $0000
	call SetRuntimeInterruptStub1
	ei
	ld a, $01
	ld [$C772], a
	ld hl, $C766
	ld bc, $0013
A0FSetup_40D6::
	xor a, a
	ld [hli], a
	dec bc
	ld a, c
	or a, b
	jr nz, A0FSetup_40D6
	ld a, $00
	ld [$C766], a
	ld a, $00
	ld [$C767], a
	ld a, $01
	ld [$C772], a
	ld a, [$C765]
	or a, a
	jr z, A0FSetup_4110
	ld a, $02
	ld [$C76A], a
	ld a, $98
	ld [$C775], a
	ld a, $99
	ld [$C776], a
	ld a, $10
	ld [$C76F], a
	ld a, $00
	ld [$C76E], a
	ld hl, $52EC
	jr A0FSetup_412C
A0FSetup_4110::
	ld a, $00
	ld [$C76A], a
	ld a, $94
	ld [$C775], a
	ld a, $95
	ld [$C776], a
	ld a, $08
	ld [$C76F], a
	ld a, $04
	ld [$C76E], a
	ld hl, $4E20
A0FSetup_412C::
	ld a, l
	ld [$C773], a
	ld a, h
	ld [$C774], a
	call CountA0FTerminatedList - $2000
	ld hl, $6000
	ld de, $005A
	call ResidentJump0246
	ret
ASSERT @ == $6141

SECTION "A0F setup 6141-615B", ROMX[$6141], BANK[$07]
ClearA0FDisplayCallbacks::
	di
	ld de, $0000
	call SetRuntimeInterruptStub0
	ld de, $0000
	call StoreRuntimeCallback0
	ld de, $0000
	call StoreRuntimeCallback1
	ld de, $0000
	call SetRuntimeInterruptStub1
	ei
	ret
ASSERT @ == $615C
