; PROBABLE static dispatch roles; SYNTHETIC callback/register probes.
SECTION "Return table and interrupt dispatch", ROM0[$05F5]
DispatchReturnTable::
	add a, a
	pop hl
	ld e, a
	ld d, $00
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	push de
	pop hl
	jp hl
DispatchVBlankCallback::
	push af
	push bc
	push de
	push hl
	ld a, $01
	ldh [$FF8A], a
	ld hl, $FF8E
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld h, d
	ld l, e
	ld a, l
	or a, h
	jp z, FinishVBlankCallback
	ld de, FinishVBlankCallback
	push de
	jp hl
DispatchLCDStatCallback::
	push af
	push bc
	push de
	push hl
	ld hl, $FF92
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld h, d
	ld l, e
	ld a, l
	or a, h
	jr z, RestoreInterruptRegisters
	ld de, RestoreInterruptRegisters
	push de
	jp hl
DispatchFF8CCallback::
	push af
	push bc
	push de
	push hl
	ld hl, $FF8C
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld h, d
	ld l, e
	ld a, l
	or a, h
	jr z, RestoreInterruptRegisters
	ld de, RestoreInterruptRegisters
	push de
	jp hl
DispatchFF90Callback::
	push af
	push bc
	push de
	push hl
	ld hl, $FF90
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld h, d
	ld l, e
	ld a, l
	or a, h
	jr z, RestoreInterruptRegisters
	ld de, RestoreInterruptRegisters
	push de
	jp hl
InterruptReturnOnly::
	push af
	push bc
	push de
	push hl
	jp RestoreInterruptRegisters
ASSERT @ == $0661

SECTION "Interrupt register returns", ROM0[$0699]
; Preserve the old source-range symbol as an address alias.
ResidualROM00_0699::
RestoreInterruptRegisters::
	pop hl
	pop de
	pop bc
	pop af
	reti
FinishVBlankCallback::
	call CallBankA1EAndRestoreMapping
	pop hl
	pop de
	pop bc
	pop af
	reti
ASSERT @ == $06A6
