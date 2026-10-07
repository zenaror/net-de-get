; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $0165-$0170.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:0165-0170", ROM0[$0165]
ResidualROM00_0165::
	db $C3, $47, $07, $C3, $56, $07, $C3, $77, $07, $C3, $82, $07
ASSERT @ == $0171
