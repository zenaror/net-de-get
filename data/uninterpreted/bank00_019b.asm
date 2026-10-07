; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $019B-$019D.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:019B-019D", ROM0[$019B]
ResidualROM00_019B::
	db $C3, $68, $0A
ASSERT @ == $019E
