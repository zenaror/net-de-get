; PROBABLE records selected by record1 first-prefix C0 commands.
; Sparse extraction only; table extents and natural audio remain unverified.
SECTION "B21 Slot0C0Record", ROMX[$6039], BANK[$10]
BankB21Slot0C0Record::
	db $00, $40, $02
ASSERT @ == $603C

SECTION "B21 Slot1C0Record", ROMX[$6053], BANK[$10]
BankB21Slot1C0Record::
	db $83, $05
ASSERT @ == $6055

SECTION "B21 Slot2WavePointer", ROMX[$6069], BANK[$10]
BankB21Slot2WavePointer::
	dw BankB21Slot2WaveBytes
ASSERT @ == $606B

SECTION "B21 Slot2WaveBytes", ROMX[$60BB], BANK[$10]
BankB21Slot2WaveBytes::
	db $FF, $FF, $00, $00, $99, $99, $00, $00, $CC, $CC, $00, $00, $FF, $FF, $00, $00
ASSERT @ == $60CB
