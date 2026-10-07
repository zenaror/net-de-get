; PROBABLE startup status callback and menu setup/VRAM/callback helpers.
; SYNTHETIC prefixes, LCD-off fill and callback clear; no natural menu claim.
SECTION "A16 menu 41EA-4226", ROMX[$41EA], BANK[$0B]
ResidualROM0B_41EA::
BankA16StartupStatusCallback::
	and a, a
	jr nz, BankA16Menu_421E
	ld bc, $02A3
	ld de, $3ED8
	call OpenLocalStorageRecord
	ld a, l
	or a, h
	jr z, BankA16Menu_421A
	ld de, $0112
	add hl, de
	ld de, $C655
	ld bc, $0010
	call ResidentJump0276
	ld a, $10
	ld hl, $C655
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	xor a, a
	ld [hl], a
	ld hl, $C655
	call ResidentJump01E9
BankA16Menu_421A::
	call CloseLocalStorageRecord
	ret
BankA16Menu_421E::
	ld a, $0D
	ld de, $4F5A
	call ResidentJump01E3
	ret
ASSERT @ == $4227

SECTION "A16 menu 4AF0-4B35", ROMX[$4AF0], BANK[$0B]
InitializeA16MenuDisplay::
	xor a, a
	ldh [$FF4F], a
	ld [$C1C2], a
	ld [$C1C4], a
	ld [$C5A4], a
	ld [$C5A5], a
	ld [$C5A9], a
	ld a, $01
	ld [$C5A3], a
	call BankA16_4227
	ld hl, $4E7A
	ld de, $8800
	ld bc, $0050
	call $0198
	call FillA16MenuBackgroundPlanes
	ld a, $04
	ld hl, $4EDA
	call ResidualROM00_0177
	di
	ld de, $4B91
	call StoreRuntimeCallback0
	ld de, $0000
	call SetRuntimeInterruptStub0
	call StoreRuntimeCallback1
	call SetRuntimeInterruptStub1
	ei
	ret
ASSERT @ == $4B36

SECTION "A16 menu 4B36-4B77", ROMX[$4B36], BANK[$0B]
FillA16MenuBackgroundPlanes::
	xor a, a
	ldh [$FF4F], a
	ld hl, $9800
	ld bc, $0400
BankA16Menu_4B3F::
	di
BankA16Menu_4B40::
	ldh a, [$FF41]
	and a, $02
	jr nz, BankA16Menu_4B40
	ld a, $80
	ld [hl], a
	ei
	ldh a, [$FF41]
	and a, $02
	jr nz, BankA16Menu_4B3F
	inc hl
	dec bc
	ld a, c
	or a, b
	jr nz, BankA16Menu_4B3F
	ld a, $01
	ldh [$FF4F], a
	ld hl, $9800
	ld bc, $0400
BankA16Menu_4B60::
	di
BankA16Menu_4B61::
	ldh a, [$FF41]
	and a, $02
	jr nz, BankA16Menu_4B61
	ld a, $00
	ld [hl], a
	ei
	ldh a, [$FF41]
	and a, $02
	jr nz, BankA16Menu_4B60
	inc hl
	dec bc
	ld a, c
	or a, b
	jr nz, BankA16Menu_4B60
	ret
ASSERT @ == $4B78

SECTION "A16 menu 4B78-4B90", ROMX[$4B78], BANK[$0B]
ClearA16MenuCallbacks::
	di
	ld de, $0000
	call SetRuntimeInterruptStub0
	call StoreRuntimeCallback0
	call StoreRuntimeCallback1
	call SetRuntimeInterruptStub1
	call ResidentJump01DA
	ei
	xor a, a
	ld [$C1C2], a
	ret
ASSERT @ == $4B91
