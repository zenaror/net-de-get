; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $1186-$118E.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:1186-118E", ROM0[$1186]
ResidualROM00_1186::
	db $7D, $EA, $C5, $C1, $7C, $EA, $C6, $C1, $C9
ASSERT @ == $118F
