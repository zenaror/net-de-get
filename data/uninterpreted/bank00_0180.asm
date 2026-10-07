; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $0180-$018B.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:0180-018B", ROM0[$0180]
ResidualROM00_0180::
	db $C3, $8D, $08, $C3, $FB, $08, $C3, $25, $09, $C3, $6F, $09
ASSERT @ == $018C
