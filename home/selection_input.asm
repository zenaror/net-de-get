; PROBABLE input priority/cursor contracts; synthetic bounded state domains.
; Mode1 target is literally0000: no null-target guard or no-op claim.

SECTION "Selection input 294E-2AB8", ROM0[$294E]
ResidualROM00_294E::
UpdateSelectionInput::
	ld a, [$C213]
	or a, a
	ret z
	ld a, [$C215]
	ld b, a
	ld a, [$C212]
	cp a, b
	jp z, SelectionInput_2964
	ld a, [$C212]
	ld [$C215], a
SelectionInput_2964::
	ldh a, [$FF98]
	and a, $40
	jr z, SelectionInput_29B0
	ld a, [$C210]
	ld b, a
	inc b
	ld a, [$C20F]
	cp a, b
	jr c, SelectionInput_297A
	ld a, $9B
	call ResidentJump024F
SelectionInput_297A::
	ld a, [$C214]
	or a, a
	jr z, SelectionInput_2987
	dec a
	ld [$C214], a
	jp DispatchSelectionCursor
SelectionInput_2987::
	ld a, [$C217]
	cp a, $01
	jr nz, SelectionInput_2998
	ld a, [$C211]
	dec a
	ld [$C214], a
	jp DispatchSelectionCursor
SelectionInput_2998::
	ld a, [$C212]
	or a, a
	jp z, DispatchSelectionCursor
	dec a
	ld [$C212], a
	ld a, [$C20E]
	dec a
	ld [$C214], a
	call DrawSelectionText
	jp DispatchSelectionCursor
SelectionInput_29B0::
	ldh a, [$FF98]
	and a, $80
	jr z, SelectionInput_2A22
	ld a, [$C210]
	ld b, a
	inc b
	ld a, [$C20F]
	cp a, b
	jr c, SelectionInput_29C6
	ld a, $9B
	call ResidentJump024F
SelectionInput_29C6::
	ld a, [$C212]
	ld c, a
	ld a, [$C217]
	dec a
	cp a, c
	jp z, SelectionInput_29E5
	ld a, [$C214]
	ld c, a
	ld a, [$C20E]
	dec a
	sub a, c
	jr z, SelectionInput_2A08
	inc c
	ld a, c
	ld [$C214], a
	jp DispatchSelectionCursor
SelectionInput_29E5::
	ld a, [$C211]
	ld c, a
	dec c
	ld a, [$C214]
	cp a, c
	jp z, SelectionInput_29F8
	inc a
	ld [$C214], a
	jp DispatchSelectionCursor
SelectionInput_29F8::
	ld a, [$C217]
	cp a, $01
	jp nz, DispatchSelectionCursor
	ld a, $00
	ld [$C214], a
	jp DispatchSelectionCursor
SelectionInput_2A08::
	ld a, [$C212]
	ld c, a
	ld a, [$C217]
	dec a
	sub a, c
	jr z, SelectionInput_2A1C
	inc c
	ld a, c
	ld [$C212], a
	xor a, a
	ld [$C214], a
SelectionInput_2A1C::
	call DrawSelectionText
	jp DispatchSelectionCursor
SelectionInput_2A22::
	ldh a, [$FF98]
	and a, $20
	jr z, SelectionInput_2A4B
	ld a, [$C210]
	cp a, $02
	jr c, SelectionInput_2A34
	ld a, $9C
	call ResidentJump024F
SelectionInput_2A34::
	ld a, [$C21B]
	or a, a
	jr z, SelectionInput_2A41
	dec a
	ld [$C21B], a
	jp DispatchSelectionCursor
SelectionInput_2A41::
	ld a, [$C210]
	dec a
	ld [$C21B], a
	jp DispatchSelectionCursor
SelectionInput_2A4B::
	ldh a, [$FF98]
	and a, $10
	jr z, SelectionInput_2A77
	ld a, [$C210]
	cp a, $02
	jr c, SelectionInput_2A5D
	ld a, $9C
	call ResidentJump024F
SelectionInput_2A5D::
	ld a, [$C210]
	dec a
	ld b, a
	ld a, [$C21B]
	cp a, b
	jr nc, SelectionInput_2A6F
	inc a
	ld [$C21B], a
	jp DispatchSelectionCursor
SelectionInput_2A6F::
	ld a, $00
	ld [$C21B], a
	jp DispatchSelectionCursor
SelectionInput_2A77::
	ldh a, [$FF97]
	and a, $01
	jr z, DispatchSelectionCursor
	ld a, [$C20E]
	ld c, a
	ld a, [$C212]
	call MultiplyAByCLowByte
	ld c, a
	ld a, [$C214]
	ld b, a
	ld a, [$C210]
	call MultiplyAByCLowByte
	ld c, a
	push bc
	ld a, [$C214]
	ld c, a
	ld a, [$C210]
	call MultiplyAByCLowByte
	pop bc
	ld b, a
	ld a, [$C21B]
	add a, b
	ld b, a
	ld a, b
	add a, c
	ld [$C214], a
	xor a, a
	ld [$C213], a
	ret
DispatchSelectionCursor::
	ld a, [$C218]
	ld hl, SelectionCursorTargets
	push hl
	jp DispatchReturnTable
ASSERT @ == $2AB9

SECTION "Selection cursor targets 2AB9-2ABE", ROM0[$2AB9]
SelectionCursorTargets::
	dw QueueSelectionPairedCursor, $0000, QueueSelectionJitterCursor
ASSERT @ == $2ABF

SECTION "Selection page indicators 2ABF-2B4F", ROM0[$2ABF]
QueueSelectionPageIndicators::
	ld a, [$C212]
	or a, a
	jr z, SelectionInput_2AF3
	ld a, [$C1A8]
	ld e, a
	inc e
	inc e
	sla e
	sla e
	sla e
	ld a, [$C1A4]
	add a, e
	ld e, a
	ld a, [$C1A7]
	inc a
	add a, a
	add a, a
	add a, a
	ld d, a
	ldh a, [$FF8B]
	srl a
	srl a
	srl a
	srl a
	and a, $01
	ret z
	ld c, $FF
	ld a, $7C
	ld b, a
	call AppendFourByteDisplayRecord
SelectionInput_2AF3::
	ld a, [$C212]
	ld c, a
	ld a, [$C217]
	dec a
	sub a, c
	jr z, NotifySelectionRowChange
	ld a, [$C1A8]
	ld e, a
	inc e
	inc e
	sla e
	sla e
	sla e
	ld a, [$C1A4]
	add a, e
	ld e, a
	ld hl, $C1A7
	ld a, [$C1A9]
	add a, a
	add a, [hl]
	add a, a
	add a, a
	add a, a
	ld d, a
	ldh a, [$FF8B]
	srl a
	srl a
	srl a
	srl a
	and a, $01
	ret z
	ld c, $FF
	ld a, $7D
	ld b, a
	call AppendFourByteDisplayRecord
NotifySelectionRowChange::
	ld a, [$C216]
	ld c, a
	ld a, [$C214]
	sub a, c
	ret z
	ld a, [$C214]
	ld [$C216], a
	ld hl, $C219
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld h, d
	ld l, e
	ld a, l
	or a, h
	ret z
	ld de, SelectionCallbackReturn
	push de
	jp hl
SelectionCallbackReturn::
	ret
ASSERT @ == $2B50

SECTION "Selection paired cursor 2B50-2BB8", ROM0[$2B50]
QueueSelectionPairedCursor::
	ld a, [$C1A4]
	add a, a
	add a, a
	add a, a
	ld e, a
	ld a, [$C20D]
	inc a
	inc a
	ld c, a
	ld a, [$C21B]
	call MultiplyAByCLowByte
	rlca
	rlca
	rlca
	add a, e
	ld e, a
	ld hl, $C1A7
	ld a, [$C214]
	ld c, a
	add a, a
	add a, [hl]
	add a, $02
	add a, a
	add a, a
	add a, a
	ld c, a
	ld d, a
	ldh [$FF9D], a
	ldh a, [$FF8B]
	srl a
	srl a
	srl a
	and a, $01
	ld c, $FF
	ld h, a
	ld a, $76
	add a, h
	ld b, a
	push bc
	call AppendFourByteDisplayRecord
	ld a, [$C20D]
	inc a
	inc a
	ld c, a
	rlca
	rlca
	rlca
	ld e, a
	ld a, [$C21B]
	call MultiplyAByCLowByte
	rlca
	rlca
	rlca
	add a, e
	ld e, a
	ld a, [$C1A4]
	dec a
	rlca
	rlca
	rlca
	add a, e
	ld e, a
	ldh a, [$FF9D]
	ld d, a
	pop bc
	ld c, $FF
	call AppendFourByteDisplayRecord
	jp QueueSelectionPageIndicators
ASSERT @ == $2BB9

SECTION "Selection jitter cursor 2BB9-2BFD", ROM0[$2BB9]
QueueSelectionJitterCursor::
	ld a, [$C1A4]
	add a, a
	add a, a
	add a, a
	ld c, a
	call LocalCursorHorizontalJitter
	add a, c
	ld e, a
	ld a, [$C20D]
	inc a
	inc a
	ld c, a
	ld a, [$C21B]
	call MultiplyAByCLowByte
	rlca
	rlca
	rlca
	add a, e
	ld e, a
	ld hl, $C1A7
	ld a, [$C214]
	ld c, a
	add a, a
	add a, [hl]
	add a, $02
	add a, a
	add a, a
	add a, a
	ld d, a
	ldh [$FF9D], a
	ldh a, [$FF8B]
	srl a
	srl a
	srl a
	and a, $01
	ld c, $FF
	ld h, a
	ld a, $76
	add a, h
	ld b, a
	call AppendFourByteDisplayRecord
	jp QueueSelectionPageIndicators
ASSERT @ == $2BFE
