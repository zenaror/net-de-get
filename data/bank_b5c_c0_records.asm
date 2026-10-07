; PROBABLE records selected by record1 first-prefix C0 commands.
; Sparse extraction only; table extents and natural audio remain unverified.
SECTION "B5C Slot0C0Record", ROMX[$4024], BANK[$2E]
BankB5CSlot0C0Record::
	db $00, $83, $01
ASSERT @ == $4027

SECTION "B5C Slot1C0Record", ROMX[$4041], BANK[$2E]
BankB5CSlot1C0Record::
	db $E0, $02
ASSERT @ == $4043

SECTION "B5C Slot2WavePointer", ROMX[$406D], BANK[$2E]
BankB5CSlot2WavePointer::
	dw BankB5CSlot2WaveBytes + $2000
ASSERT @ == $406F

SECTION "B5C Slot2WaveBytes", ROMX[$40DB], BANK[$2E]
BankB5CSlot2WaveBytes::
	db $FF, $F0, $00, $09, $99, $90, $00, $0F, $FF, $F7, $77, $7E, $EE, $E0, $00, $0F
ASSERT @ == $40EB
