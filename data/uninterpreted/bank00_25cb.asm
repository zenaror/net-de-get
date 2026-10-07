; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $25CB-$2612.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:25CB-2612", ROM0[$25CB]
ResidualROM00_25CB::
	db $F0, $4D, $CB, $7F, $C0, $3E, $01, $E0, $4D, $F0, $FF, $F5, $AF, $E0, $FF, $3E
	db $30, $E0, $00, $10, $00, $F0, $4D, $CB, $7F, $28, $FA, $AF, $E0, $00, $E0, $0F
	db $F1, $E0, $FF, $C9, $F0, $4D, $CB, $7F, $C8, $3E, $01, $E0, $4D, $F0, $FF, $F5
	db $AF, $E0, $FF, $3E, $30, $E0, $00, $10, $00, $F0, $4D, $CB, $7F, $20, $FA, $AF
	db $E0, $00, $E0, $0F, $F1, $E0, $FF, $C9
ASSERT @ == $2613
