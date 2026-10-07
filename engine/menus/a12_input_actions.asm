; PROBABLE original input action bodies; synthetic whole-body contracts.
; Resource headers depend on the active B window; Japanese bytes remain original.
SECTION "A12 input action 4786-47A3", ROMX[$4786], BANK[$09]
ResidualROM09_4786::
A12InputAction0_0::
	ld a, $01
	call HideA12TextWindowAndCopy
	ld a, $00
	ld [$C213], a
	ld a, $02
	ld [$C600], a
	ld hl, $6895
	call InitializeA12TileFrames
	ld a, $07
	ld [$C5CF], a
	call ResetA12ResourceFrame
	ret
ASSERT @ == $47A4

SECTION "A12 input action 47A4-47D1", ROMX[$47A4], BANK[$09]
A12InputAction0_3::
	ld a, $01
	call HideA12TextWindowAndCopy
	ld a, $00
	ld [$C213], a
	ld a, $02
	ld [$C600], a
	ld a, [$C5A4]
	cp a, $06
	jp nc, A12InputActionBranch_47C3
	ld hl, $69AC
	call InitializeA12TileFrames
	jr A12InputActionBranch_47C9
A12InputActionBranch_47C3::
	ld hl, $69CB
	call InitializeA12TileFrames
A12InputActionBranch_47C9::
	ld a, $05
	ld [$C5CF], a
	call ResetA12ResourceFrame
	ret
ASSERT @ == $47D2

SECTION "A12 input action 47D2-47EF", ROMX[$47D2], BANK[$09]
A12InputAction0_1::
	ld a, $01
	call HideA12TextWindowAndCopy
	ld a, $00
	ld [$C213], a
	ld a, $02
	ld [$C600], a
	ld hl, $6895
	call InitializeA12TileFrames
	ld a, $08
	ld [$C5CF], a
	call ResetA12ResourceFrame
	ret
ASSERT @ == $47F0

SECTION "A12 input action 47F0-481D", ROMX[$47F0], BANK[$09]
A12InputAction0_2::
	ld a, $01
	call HideA12TextWindowAndCopy
	ld a, $00
	ld [$C213], a
	ld a, $02
	ld [$C600], a
	ld a, [$C5A4]
	cp a, $03
	jp nc, A12InputActionBranch_480F
	ld hl, $68EF
	call InitializeA12TileFrames
	jr A12InputActionBranch_4815
A12InputActionBranch_480F::
	ld hl, $6939
	call InitializeA12TileFrames
A12InputActionBranch_4815::
	ld a, $03
	ld [$C5CF], a
	call ResetA12ResourceFrame
	ret
ASSERT @ == $481E

SECTION "A12 input action 481E-483B", ROMX[$481E], BANK[$09]
A12InputAction0_4::
	ld a, $01
	call HideA12TextWindowAndCopy
	ld a, $00
	ld [$C213], a
	ld a, $02
	ld [$C600], a
	ld hl, $6B74
	call InitializeA12TileFrames
	ld a, $04
	ld [$C5CF], a
	call ResetA12ResourceFrame
	ret
ASSERT @ == $483C

SECTION "A12 input action 483C-4859", ROMX[$483C], BANK[$09]
A12InputAction0_5::
	ld a, $01
	call HideA12TextWindowAndCopy
	ld a, $00
	ld [$C213], a
	ld a, $02
	ld [$C600], a
	ld hl, $6B9E
	call InitializeA12TileFrames
	ld a, $06
	ld [$C5CF], a
	call ResetA12ResourceFrame
	ret
ASSERT @ == $485A

SECTION "A12 input action 487C-4899", ROMX[$487C], BANK[$09]
ResidualROM09_487C::
A12InputAction1_0::
	ld a, $01
	call HideA12TextWindowAndCopy
	ld a, $00
	ld [$C213], a
	ld a, $02
	ld [$C600], a
	ld hl, $6866
	call InitializeA12TileFrames
	ld a, $07
	ld [$C5CF], a
	call ResetA12ResourceFrame
	ret
ASSERT @ == $489A

SECTION "A12 input action 489A-48B7", ROMX[$489A], BANK[$09]
A12InputAction1_3::
	ld a, $01
	call HideA12TextWindowAndCopy
	ld a, $00
	ld [$C213], a
	ld a, $02
	ld [$C600], a
	ld hl, $68CB
	call InitializeA12TileFrames
	ld a, $05
	ld [$C5CF], a
	call ResetA12ResourceFrame
	ret
ASSERT @ == $48B8

SECTION "A12 input action 48B8-48D5", ROMX[$48B8], BANK[$09]
A12InputAction1_1::
	ld a, $01
	call HideA12TextWindowAndCopy
	ld a, $00
	ld [$C213], a
	ld a, $02
	ld [$C600], a
	ld hl, $6866
	call InitializeA12TileFrames
	ld a, $08
	ld [$C5CF], a
	call ResetA12ResourceFrame
	ret
ASSERT @ == $48D6

SECTION "A12 input action 48D6-4903", ROMX[$48D6], BANK[$09]
A12InputAction1_2::
	ld a, $01
	call HideA12TextWindowAndCopy
	ld a, $00
	ld [$C213], a
	ld a, $02
	ld [$C600], a
	ld a, [$C5A4]
	cp a, $06
	jp nc, A12InputActionBranch_48F5
	ld hl, $689D
	call InitializeA12TileFrames
	jr A12InputActionBranch_48FB
A12InputActionBranch_48F5::
	ld hl, $68B4
	call InitializeA12TileFrames
A12InputActionBranch_48FB::
	ld a, $03
	ld [$C5CF], a
	call ResetA12ResourceFrame
	ret
ASSERT @ == $4904

SECTION "A12 input action 4904-4921", ROMX[$4904], BANK[$09]
A12InputAction1_4::
	ld a, $01
	call HideA12TextWindowAndCopy
	ld a, $00
	ld [$C213], a
	ld a, $02
	ld [$C600], a
	ld hl, $6A7F
	call InitializeA12TileFrames
	ld a, $04
	ld [$C5CF], a
	call ResetA12ResourceFrame
	ret
ASSERT @ == $4922

SECTION "A12 input action 4922-493F", ROMX[$4922], BANK[$09]
A12InputAction1_5::
	ld a, $01
	call HideA12TextWindowAndCopy
	ld a, $00
	ld [$C213], a
	ld a, $02
	ld [$C600], a
	ld hl, $6A51
	call InitializeA12TileFrames
	ld a, $06
	ld [$C5CF], a
	call ResetA12ResourceFrame
	ret
ASSERT @ == $4940

SECTION "A12 input action 4962-497F", ROMX[$4962], BANK[$09]
ResidualROM09_4962::
A12InputAction2_0::
	ld a, $01
	call HideA12TextWindowAndCopy
	ld a, $00
	ld [$C213], a
	ld a, $02
	ld [$C600], a
	ld hl, $6800
	call InitializeA12TileFrames
	ld a, $07
	ld [$C5CF], a
	call ResetA12ResourceFrame
	ret
ASSERT @ == $4980

SECTION "A12 input action 4980-49AD", ROMX[$4980], BANK[$09]
A12InputAction2_3::
	ld a, $01
	call HideA12TextWindowAndCopy
	ld a, $00
	ld [$C213], a
	ld a, $02
	ld [$C600], a
	ld a, [$C5A4]
	cp a, $03
	jp nc, A12InputActionBranch_499F
	ld hl, $6855
	call InitializeA12TileFrames
	jr A12InputActionBranch_49A5
A12InputActionBranch_499F::
	ld hl, $6874
	call InitializeA12TileFrames
A12InputActionBranch_49A5::
	ld a, $05
	ld [$C5CF], a
	call ResetA12ResourceFrame
	ret
ASSERT @ == $49AE

SECTION "A12 input action 49AE-49CB", ROMX[$49AE], BANK[$09]
A12InputAction2_1::
	ld a, $01
	call HideA12TextWindowAndCopy
	ld a, $00
	ld [$C213], a
	ld a, $02
	ld [$C600], a
	ld hl, $6800
	call InitializeA12TileFrames
	ld a, $08
	ld [$C5CF], a
	call ResetA12ResourceFrame
	ret
ASSERT @ == $49CC

SECTION "A12 input action 49CC-49F9", ROMX[$49CC], BANK[$09]
A12InputAction2_2::
	ld a, $01
	call HideA12TextWindowAndCopy
	ld a, $00
	ld [$C213], a
	ld a, $02
	ld [$C600], a
	ld a, [$C5A4]
	cp a, $02
	jp nc, A12InputActionBranch_49EB
	ld hl, $6837
	call InitializeA12TileFrames
	jr A12InputActionBranch_49F1
A12InputActionBranch_49EB::
	ld hl, $6846
	call InitializeA12TileFrames
A12InputActionBranch_49F1::
	ld a, $03
	ld [$C5CF], a
	call ResetA12ResourceFrame
	ret
ASSERT @ == $49FA

SECTION "A12 input action 49FA-4A17", ROMX[$49FA], BANK[$09]
A12InputAction2_4::
	ld a, $01
	call HideA12TextWindowAndCopy
	ld a, $00
	ld [$C213], a
	ld a, $02
	ld [$C600], a
	ld hl, $6ACE
	call InitializeA12TileFrames
	ld a, $06
	ld [$C5CF], a
	call ResetA12ResourceFrame
	ret
ASSERT @ == $4A18

SECTION "A12 input action 4A18-4A35", ROMX[$4A18], BANK[$09]
A12InputAction2_5::
	ld a, $01
	call HideA12TextWindowAndCopy
	ld a, $00
	ld [$C213], a
	ld a, $02
	ld [$C600], a
	ld hl, $6AA8
	call InitializeA12TileFrames
	ld a, $04
	ld [$C5CF], a
	call ResetA12ResourceFrame
	ret
ASSERT @ == $4A36
