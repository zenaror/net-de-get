; PROBABLE original variant selector and position/queue producer.
; Physical bank07 upper8KiB maps in A0F; preserve8-bit RLCA/wrap.
SECTION "A0F position 6306-6319", ROMX[$6306], BANK[$07]
SelectA0FDisplayVariant::
	ld a, [$C767]
	cp a, $04
	jr c, A0FPosition_4314
	ld a, $01
	ld [$C76B], a
	jr A0FPosition_4319
A0FPosition_4314::
	ld a, $00
	ld [$C76B], a
A0FPosition_4319::
	ret
ASSERT @ == $631A

SECTION "A0F position 638A-63BE", ROMX[$638A], BANK[$07]
QueueA0FPositionedObject::
	ld a, [$C766]
	cp a, $05
	jr c, A0FPosition_4393
	add a, $01
A0FPosition_4393::
	cp a, $0B
	jr c, A0FPosition_4399
	add a, $01
A0FPosition_4399::
	rlca
	rlca
	rlca
	add a, $10
	ld [$C768], a
	ld a, [$C767]
	rlca
	rlca
	rlca
	rlca
	add a, $50
	ld [$C769], a
	ld c, $00
	ld a, [$C76B]
	ld b, a
	ld a, [$C768]
	ld e, a
	ld a, [$C769]
	ld d, a
	call ResidentJump025E
	ret
ASSERT @ == $63BF
