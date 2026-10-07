; PROBABLE held-input indicator producer; static plus SYNTHETIC CPU probes.
; Native A $14, RGBDS physical bank $0A lower half.
SECTION "Queue local held indicators", ROMX[$478D], BANK[$0A]
QueueLocalHeldIndicators::
	ld a, [$D015]
	ld b, a
	ldh a, [$FF96]
	cp b
	jr z, .return
	ld a, [$D015]
	and $10
	jr z, .old20
	ld hl, $D046
	ld a, $6F
	ld [hli], a
	ld a, $98
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, LOW(LocalHeldOldBit10)
	ld [hli], a
	ld a, HIGH(LocalHeldOldBit10)
	ld [hli], a
	jr .current
.old20:
	ld a, [$D015]
	and $20
	jr z, .current
	ld hl, $D046
	ld a, $64
	ld [hli], a
	ld a, $98
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, LOW(LocalHeldOldBit20)
	ld [hli], a
	ld a, HIGH(LocalHeldOldBit20)
	ld [hli], a
.current:
	ldh a, [$FF96]
	and $10
	jr z, .new20
	ld hl, $D04C
	ld a, $6F
	ld [hli], a
	ld a, $98
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, LOW(LocalHeldNewBit10)
	ld [hli], a
	ld a, HIGH(LocalHeldNewBit10)
	ld [hli], a
	jr .changed
.new20:
	ldh a, [$FF96]
	and $20
	jr z, .changed
	ld hl, $D04C
	ld a, $64
	ld [hli], a
	ld a, $98
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, LOW(LocalHeldNewBit20)
	ld [hli], a
	ld a, HIGH(LocalHeldNewBit20)
	ld [hli], a
.changed:
	ld a, $01
	ld [$D021], a
	ldh a, [$FF96]
	ld [$D015], a
.return:
	ret
.end:
ASSERT .end - QueueLocalHeldIndicators == $86
