; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $2D, address $6067-$609A.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 2D:6067-609A", ROMX[$6067], BANK[$2D]
ResidualROM2D_6067::
	db $AB, $60, $BB, $60, $CB, $60, $DB, $60, $EB, $60, $FB, $60, $0B, $61, $1B, $61
	db $2B, $61, $3B, $61, $01, $23, $45, $67, $89, $AB, $CD, $EF, $ED, $CB, $A9, $87
	db $65, $43, $21, $00, $01, $23, $45, $67, $89, $AB, $CD, $EF, $ED, $CB, $A9, $87
	db $65, $43, $21, $00
ASSERT @ == $609B
