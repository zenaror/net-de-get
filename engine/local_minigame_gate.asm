; RGBDS excerpt for the local selected-index gate.
; Source image SHA-256:
;   9fb1e6e4a637796b8624bd2de6c9abaa9e758546b620cb5dc8441b07c288bc63
;
; PROBABLE: reconstructed from byte-level decoding at ROM0 $051E-$0563.
; The selected local UI path has now been observed in the mGBA GUI, but this
; exact gate has not yet been hit by an instruction trace of that GUI route.

DEF LocalMinigameSelectionBody EQU $0521
EXPORT LocalMinigameSelectionBody

SECTION "Local minigame selection gate", ROM0[$051E]
LocalMinigameSelectionGate:
	call $024C
ASSERT @ == LocalMinigameSelectionBody
	ld a, [$C624]
	ld [$C671], a
	ld a, $08
	ld b, $00
	call $0264

	ld hl, $C84B
	ld bc, $0005
.clearBuffer:
	xor a
	ld [hli], a
	dec bc
	ld a, c
	or b
	jr nz, .clearBuffer

	ld a, [$C671]
	ld [$C628], a
	cp $FF
	jp z, ResetMainState02
	call $026D
	ld a, [$C628]
	call $029D
	ld a, [$C671]
	and $10
	ret nz
	ld a, $0B
	ld b, $00
	call $0264
	ld a, $01
	ld b, $00
	call $0264
	ret

; Interpretation limits:
; - $C624 is copied to $C671 and passed in A to the real minigame dispatcher.
; - $FF skips $026D; any other value enters it. Treat $C624 as a candidate
;   selected-game index; the exact SRAM Index-to-WRAM assignment is not traced.
; - $0264 is a separate callback-table dispatcher, not the minigame dispatcher.
