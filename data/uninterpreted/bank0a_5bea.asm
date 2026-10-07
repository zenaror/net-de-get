; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $0A, address $5BEA-$5C09.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 0A:5BEA-5C09", ROMX[$5BEA], BANK[$0A]
ResidualROM0A_5BEA::
	db $02, $03, $0A, $05, $00, $00, $00, $00, $05, $01, $08, $01, $00, $00, $00, $00
	db $00, $0E, $12, $01, $01, $00, $00, $00, $01, $04, $10, $04, $01, $00, $00, $00
ASSERT @ == $5C0A
