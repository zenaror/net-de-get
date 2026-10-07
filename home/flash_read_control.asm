; ROM0 $1359-$138C. PROBABLE static reconstruction and helper names.
; Specific natural mapper observations are documented separately; no claim
; of a natural trace covering every instruction or hardware validation.
SECTION "Flash read and software controls", ROM0[$1359]
DisableFlashReads::
	call SetFlashWriteControl
	dec a
	ld [rMBC6FlashReadControl], a
	jr ClearFlashWriteControl

EnableFlashReads::
	call CheckFlashSoftwareFlag
	ret c
	call SetFlashWriteControl
	ld [rMBC6FlashReadControl], a
; Fall through: preserve the original $1000 store and return to the caller.
ClearFlashWriteControl::
	xor a
	ld [rMBC6FlashWriteControl], a
	ret

SetFlashWriteControl::
	ld a, $01
	ld [rMBC6FlashWriteControl], a
	ret

ClearFlashRetry::
	xor a
	ld [wFlashRetry], a
	ret

CheckFlashSoftwareFlag::
	ld hl, wFlashSoftwareFlags
	bit 0, [hl]
	jr nz, .set
	xor a
	ret
.set:
	scf
	ret

ClearFlashSoftwareFlag::
	ld hl, wFlashSoftwareFlags
	res 0, [hl]
	ret
FlashReadControlEnd:
ASSERT FlashReadControlEnd - DisableFlashReads == $34
