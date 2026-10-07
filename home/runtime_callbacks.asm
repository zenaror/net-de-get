; PROBABLE callback roles from static callers; no new natural interrupt trace.
SECTION "Runtime callback thunks", ROM0[$0150]
StoreRuntimeCallback0::
	jp StoreRuntimeCallback0Body
SetRuntimeInterruptStub0::
	jp SetRuntimeInterruptStub0Body
StoreRuntimeCallback1::
	jp StoreRuntimeCallback1Body
SetRuntimeInterruptStub1::
	jp SetRuntimeInterruptStub1Body
.end:
ASSERT .end - StoreRuntimeCallback0 == $0C

SECTION "Runtime callback setters", ROM0[$0661]
StoreRuntimeCallback0Body::
	ld hl, $FF8E
	ld [hl], e
	inc hl
	ld [hl], d
	ret
SetRuntimeInterruptStub0Body::
	push af
	ld hl, $C67F
	ld a, d
	or e
	jr z, .empty
	ld a, $C3
	ld [hli], a
	ld [hl], e
	inc hl
	ld [hl], d
	jr .return
.empty:
	ld a, $D9
	ld [hl], a
.return:
	pop af
	ret
StoreRuntimeCallback1Body::
	ld hl, $FF92
	ld [hl], e
	inc hl
	ld [hl], d
	ret
SetRuntimeInterruptStub1Body::
	push af
	ld hl, $C682
	ld a, d
	or e
	jr z, .empty
	ld a, $C3
	ld [hli], a
	ld [hl], e
	inc hl
	ld [hl], d
	jr .return
.empty:
	ld a, $D9
	ld [hl], a
.return:
	pop af
	ret
.end:
ASSERT .end - StoreRuntimeCallback0Body == $38
