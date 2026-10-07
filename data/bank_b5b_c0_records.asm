; PROBABLE records selected by record1 first-prefix C0 commands.
; Sparse extraction only; table extents and natural audio remain unverified.
SECTION "B5B Slot0C0Record", ROMX[$6024], BANK[$2D]
BankB5BSlot0C0Record::
	db $00, $83, $01
ASSERT @ == $6027

SECTION "B5B Slot1C0Record", ROMX[$6043], BANK[$2D]
BankB5BSlot1C0Record::
	db $80, $02
ASSERT @ == $6045

SECTION "B5B Slot2WavePointer", ROMX[$6065], BANK[$2D]
BankB5BSlot2WavePointer::
	dw BankB5BSlot2WaveBytes
ASSERT @ == $6067

SECTION "B5B Slot2WaveBytes", ROMX[$609B], BANK[$2D]
BankB5BSlot2WaveBytes::
	db $ED, $CB, $A9, $87, $65, $43, $21, $00, $ED, $CB, $A9, $87, $65, $43, $21, $00
ASSERT @ == $60AB
