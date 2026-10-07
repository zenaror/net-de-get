; PROBABLE flash callback dispatcher; original mapper flow and synthetic targets.
; The B path copies saved B values into A HRAM mirrors; preserve that asymmetry.
; No natural callback body, nesting safety or hardware execution claim.
SECTION "Flash callback dispatcher 24B9-254D", ROM0[$24B9]
ResidualROM00_24B9::
DispatchFlashCallback::
	push af
	push hl
	call EnableFlashReads
	pop hl
	pop af
	ld b, a
	ld a, h
	cp a, $60
	jr nc, FlashCallbackWindowB
	ldh a, [hWindowASelector]
	ld [wFlashCallbackSavedSelector], a
	ldh a, [hWindowAType]
	ld [wFlashCallbackSavedType], a
	ld a, b
	di
	ld [rMBC6WindowASelector], a
	ldh [hWindowASelector], a
	ld [wWindowASelectorMirror], a
	ld a, MBC6_FLASH
	ld [rMBC6WindowAType], a
	ldh [hWindowAType], a
	ld [wWindowATypeMirror], a
	ei
	ld de, RestoreFlashCallbackWindowA
	push de
	jp hl
RestoreFlashCallbackWindowA::
	ld a, [wFlashCallbackSavedSelector]
	ldh [hWindowASelector], a
	di
	ld [rMBC6WindowASelector], a
	ld [wWindowASelectorMirror], a
	ld a, [wFlashCallbackSavedType]
	ldh [hWindowAType], a
	ld [rMBC6WindowAType], a
	ld [wWindowATypeMirror], a
	ei
	jr FinishFlashCallback
FlashCallbackWindowB::
	ldh a, [hWindowBSelector]
	ld [wFlashCallbackSavedSelector], a
	ldh a, [hWindowBType]
	ld [wFlashCallbackSavedType], a
	ld a, [wFlashCallbackSavedSelector]
	ldh [hWindowASelector], a
	ld a, [wFlashCallbackSavedType]
	ldh [hWindowAType], a
	ld a, b
	di
	ld [rMBC6WindowBSelector], a
	ldh [hWindowBSelector], a
	ld [wWindowBSelectorMirror], a
	ld a, MBC6_FLASH
	ld [rMBC6WindowBType], a
	ldh [hWindowBType], a
	ld [wWindowBTypeMirror], a
	ei
	ld de, RestoreFlashCallbackWindowB
	push de
	jp hl
RestoreFlashCallbackWindowB::
	ld a, [wFlashCallbackSavedSelector]
	ldh [hWindowBSelector], a
	di
	ld [rMBC6WindowBSelector], a
	ld [wWindowBSelectorMirror], a
	ld a, [wFlashCallbackSavedType]
	ldh [hWindowBType], a
	ld [rMBC6WindowBType], a
	ld [wWindowBTypeMirror], a
	ei
FinishFlashCallback::
	call DisableFlashReads
	ret
ASSERT @ == $254E
