; PROBABLE routine consumed by FinishVBlankCallback at ROM0 $069E.
; SYNTHETIC prefix / independently forced restore tails; A1E target unexecuted.
SECTION "VBlank banked mapper call", ROM0[$2242]
CallBankA1EAndRestoreMapping::
	ld a, [$C663]
	ld [$37FF], a
	ld [$C115], a
	ld a, [$C664]
	ld [$3800], a
	ld [$C116], a
	ld a, $1E
	ld [$27FF], a
	ld [$C113], a
	ld a, $00
	ld [$2800], a
	ld [$C114], a
	call NativeA1EEntry
	ld a, [$C672]
	and a, a
	jr nz, .alternateRestore
	ldh a, [$FFAB]
	ld [$27FF], a
	ld [$C113], a
	ldh a, [$FFAC]
	ld [$2800], a
	ld [$C114], a
	ldh a, [$FFAD]
	ld [$37FF], a
	ld [$C115], a
	ldh a, [$FFAE]
	ld [$3800], a
	ld [$C116], a
	ret
.alternateRestore:
	ld a, [$CB81]
	ld [$27FF], a
	ld a, [$CB82]
	ld [$2800], a
	ld a, [$CB83]
	ld [$37FF], a
	ld a, [$CB84]
	ld [$3800], a
	ret
ASSERT @ == $22A7
