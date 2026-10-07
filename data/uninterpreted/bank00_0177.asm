; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $0177-$018B.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:0177-018B", ROM0[$0177]
ResidualROM00_0177::
	db $C3, $E7, $07, $C3, $05, $08, $C3, $30, $08, $C3, $8D, $08, $C3, $FB, $08, $C3
	db $25, $09, $C3, $6F, $09
ASSERT @ == $018C
