; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $018F-$019D.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:018F-019D", ROM0[$018F]
ResidualROM00_018F::
	db $C3, $EB, $09, $C3, $03, $0A, $C3, $0E, $0A, $C3, $50, $0A, $C3, $68, $0A
ASSERT @ == $019E
