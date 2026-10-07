; Entry prefix only: native A selector $14, CPU $4000-$4029.
; Execution continues at $402A; this is not a complete function.
; PROBABLE static names. Natural held-Select observations are documented
; in docs/research/minigame-maintenance.md, without proving every instruction.
; Storage open receives requested size $02A3 and name SYS1; see local_storage.asm.
SECTION "Local minigame menu entry prefix", ROMX[$4000], BANK[$0A]
LocalMinigameMenuEntry::
	ld a, $01
	ldh [rSVBK], a
	xor a, a
	call $0168
	call ClearFlashSoftwareFlag
	call ResidentJump0279
	ldh a, [hHeldButtons]
	and a, BUTTON_SELECT_MASK
	jr z, .initializeBox
	ld bc, $02A3
	ld de, LocalMenuStorageName
	call OpenLocalStorageRecord
	call RebuildLocalMinigameList
	call CloseLocalStorageRecord
.initializeBox:
	xor a, a
	ld [wCurrentGameBox], a
	call $5BC6
LocalMinigameMenuEntryEnd:
ASSERT LocalMinigameMenuEntryEnd - LocalMinigameMenuEntry == $2A
