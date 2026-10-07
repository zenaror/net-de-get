; Entry prefix only: native A selector $14, CPU $4000-$4029.
; Execution continues at $402A; this is not a complete function.
; PROBABLE static names. Natural held-Select observations are documented
; in docs/research/minigame-maintenance.md, without proving every instruction.
; $01B6 receives BC=$02A3 and DE=$3ED8; its resulting HL remains unresolved.
SECTION "Local minigame menu entry prefix", ROMX[$4000], BANK[$0A]
LocalMinigameMenuEntry::
	ld a, $01
	ldh [rSVBK], a
	xor a, a
	call $0168
	call ClearFlashSoftwareFlag
	call $0279
	ldh a, [hHeldButtons]
	and a, BUTTON_SELECT_MASK
	jr z, .initializeBox
	ld bc, $02A3
	ld de, $3ED8
	call $01B6
	call RebuildLocalMinigameList
	call $01B9
.initializeBox:
	xor a, a
	ld [wCurrentGameBox], a
	call $5BC6
LocalMinigameMenuEntryEnd:
ASSERT LocalMinigameMenuEntryEnd - LocalMinigameMenuEntry == $2A
