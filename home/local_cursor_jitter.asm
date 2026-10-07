; PROBABLE frame-derived horizontal jitter; no natural display claim.
SECTION "Local cursor horizontal jitter", ROM0[$2DC3]
LocalCursorHorizontalJitter::
	ldh a, [$FF8B]
	srl a
	srl a
	and a, $03
	xor a, $03
	sub a, $02
	ret
.end:
ASSERT .end - LocalCursorHorizontalJitter == $D

