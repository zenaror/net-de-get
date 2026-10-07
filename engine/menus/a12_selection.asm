; PROBABLE A12 selection caller/control from original flow and synthetic probes.
; MBC6 A selector $12 maps physical bank $09 lower half.
; Initialization beyond the first SYS0 call remains static; no natural menu/IRQ proof.

SECTION "A12 selection entry 4000-4030", ROMX[$4000], BANK[$09]
ResidualROM09_4000::
A12SelectionEntry::
	call InitializeA12Selection
A12SelectionLoop::
	call ResidentJump0279
	call ResidentJump01EC
	call ResidentJump01F8
	xor a, a
	ld [$C5A9], a
	call DispatchA12SelectionState
	ld a, $01
	ld [$C5A9], a
	call $017D
A12SelectionFrameWait::
	halt
	nop
A12SelectionFlagWait::
	ldh a, [$FF8A]
	and a, a
	jr z, A12SelectionFlagWait
	xor a, a
	ldh [$FF8A], a
	ld a, [$C5A3]
	and a, a
	jr z, A12SelectionExit
	jr A12SelectionLoop
A12SelectionExit::
	call CleanupA12Selection
	ret
ASSERT @ == $4031

SECTION "A12 selection initialization 4031-4120", ROMX[$4031], BANK[$09]
InitializeA12Selection::
	ld a, $02
	ldh [$FF70], a
	ld hl, $C5A3
	ld bc, $0040
A12Selection_403B::
	xor a, a
	ld [hli], a
	dec bc
	ld a, c
	or a, b
	jr nz, A12Selection_403B
	ld a, $FF
	ld [$C5C3], a
	ld a, $02
	ld [$C218], a
	call ResidentJump0288
	ld a, $01
	ld [$C5A3], a
	call UpdateA12PendingRecord
	call ResidentJump028B
	ld a, $1E
	ld [$C5C1], a
	ld a, $1E
	ld [$C5C2], a
	call $4251
	call $43C0
	xor a, a
	ld [$C5A9], a
	ld [$C1BC], a
	ld [$C1BD], a
	ld [$C5FD], a
	ld [$C600], a
	ld [$C601], a
	ld [$C1C2], a
	ld a, $00
	ld [$C1C4], a
	ld a, [$C5A8]
	cp a, $03
	jr z, A12Selection_40B7
	ld a, [$C738]
	and a, a
	jr nz, A12Selection_4098
	ld [$C739], a
	ld [$C73A], a
A12Selection_4098::
	ld a, [$C739]
	cp a, $1E
	jp c, A12Selection_40AB
	ld a, [$C73A]
	and a, a
	jr nz, A12Selection_40AB
	ld a, $02
	ld [$C601], a
A12Selection_40AB::
	ld a, [$C73B]
	cp a, $00
	jr z, A12Selection_40B7
	ld a, $01
	ld [$C601], a
A12Selection_40B7::
	ld a, [$C705]
	ld l, a
	ld a, [$C739]
	ld h, a
	call SeedA12RandomState
	call ResidentJump0282
	ld hl, $C1B5
	ld de, $9C00
	ld a, e
	ld [hli], a
	ld a, d
	ld [hl], a
	ld a, $07
	ldh [$FF4B], a
	ld a, $00
	ldh [$FF4A], a
	ldh a, [$FF40]
	and a, $9F
	ldh [$FF40], a
	ld bc, $0000
	ld a, $14
	ld h, a
	ld a, $08
	ld l, a
	ld de, $D000
	ld a, $07
	call ResidentJump0291
	ld bc, $0000
	ld a, $14
	ld h, a
	ld a, $08
	ld l, a
	ld de, $D000
	ld a, $07
	or a, $80
	call ResidentJump0294
	di
	ld a, $3F
	call $0168
	ld de, UpdateA12SelectionDMAAndPalettes
	call StoreRuntimeCallback0
	ld de, A12SelectionInterruptReturnOnly
	call SetRuntimeInterruptStub0
	ld de, PositionA12SelectionWindow
	call StoreRuntimeCallback1
	ld de, $0000
	call SetRuntimeInterruptStub1
	ei
	ret
ASSERT @ == $4121

SECTION "A12 selection cleanup 4121-4139", ROMX[$4121], BANK[$09]
CleanupA12Selection::
	call ResidentJump028B
	di
	xor a, a
	call $0168
	ld de, $0000
	call SetRuntimeInterruptStub0
	call StoreRuntimeCallback0
	call StoreRuntimeCallback1
	call SetRuntimeInterruptStub1
	ei
	ret
ASSERT @ == $413A

SECTION "A12 selection state dispatcher 413A-414F", ROMX[$413A], BANK[$09]
DispatchA12SelectionState::
	ld a, [$C5A3]
	ld hl, A12SelectionStateTargets
	add a, a
	ld e, a
	ld d, $00
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld hl, A12SelectionDispatchReturn
	push hl
	ld l, e
	ld h, d
	jp hl
A12SelectionDispatchReturn::
	ret
ASSERT @ == $4150

SECTION "A12 selection state targets 4150-4155", ROMX[$4150], BANK[$09]
A12SelectionStateTargets::
	dw A12SelectionNoop, DispatchA12SelectionVariant, FinishA12SelectionWhenIdle
ASSERT @ == $4156

SECTION "A12 selection no-op 4156", ROMX[$4156], BANK[$09]
A12SelectionNoop::
	ret
ASSERT @ == $4157
