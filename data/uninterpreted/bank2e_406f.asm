; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $2E, address $406F-$40DA.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 2E:406F-40DA", ROMX[$406F], BANK[$2E]
ResidualROM2E_406F::
	db $EB, $60, $FB, $60, $0B, $61, $1B, $61, $2B, $61, $3B, $61, $01, $23, $45, $67
	db $89, $AB, $CD, $EF, $ED, $CB, $A9, $87, $65, $43, $21, $00, $01, $23, $45, $67
	db $89, $AB, $CD, $EF, $ED, $CB, $A9, $87, $65, $43, $21, $00, $ED, $CB, $A9, $87
	db $65, $43, $21, $00, $ED, $CB, $A9, $87, $65, $43, $21, $00, $04, $79, $BC, $DE
	db $ED, $CB, $97, $40, $04, $79, $BC, $DE, $ED, $CB, $97, $40, $FF, $FF, $00, $00
	db $99, $99, $00, $00, $CC, $CC, $00, $00, $FF, $FF, $00, $00, $FF, $FF, $FF, $FF
	db $FF, $FF, $FF, $FF, $FC, $CC, $AA, $99, $55, $33, $21, $00
ASSERT @ == $40DB
