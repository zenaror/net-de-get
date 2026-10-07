; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $10, address $606B-$60BA.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 10:606B-60BA", ROMX[$606B], BANK[$10]
ResidualROM10_606B::
	db $CB, $60, $DB, $60, $EB, $60, $FB, $60, $0B, $61, $1B, $61, $2B, $61, $3B, $61
	db $01, $23, $45, $67, $89, $AB, $CD, $EF, $ED, $CB, $A9, $87, $65, $43, $21, $00
	db $01, $23, $45, $67, $89, $AB, $CD, $EF, $ED, $CB, $A9, $87, $65, $43, $21, $00
	db $ED, $CB, $A9, $87, $65, $43, $21, $00, $ED, $CB, $A9, $87, $65, $43, $21, $00
	db $04, $79, $BC, $DE, $ED, $CB, $97, $40, $04, $79, $BC, $DE, $ED, $CB, $97, $40
ASSERT @ == $60BB
