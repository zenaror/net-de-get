; PROBABLE static reconstruction, no new natural trace.
; Preserve all original branches, including JR Z to its immediate successor.
SECTION "Local minigame menu loop", ROMX[$402A], BANK[$0A]
LocalMinigameMenuLoop::
	call DispatchLocalMenuState
	call $017D
	call $01EC
	ld hl, $D006
	inc [hl]
	call $517D
	ld a, [$C5A3]
	or a, a
	jr z, .finish
	jr LocalMinigameMenuLoop
.finish:
	ld a, [$C671]
	cp a, $FF
	jr z, .cleanup
.cleanup:
	ld a, $03
	ld hl, $5188
	call $017A
	call $516E
	call $5B26
	di
	ld de, $0000
	call $0150
	ld de, $0000
	call $0159
	ld de, $0000
	call $0153
	ei
	ret
LocalMinigameMenuLoopEnd:
ASSERT LocalMinigameMenuLoopEnd - LocalMinigameMenuLoop == $42
