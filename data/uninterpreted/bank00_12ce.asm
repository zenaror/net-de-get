; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $12CE-$12E8.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:12CE-12E8", ROM0[$12CE]
ResidualROM00_12CE::
	db $7D, $EA, $00, $30, $7C, $EA, $00, $38, $C9, $21, $FC, $CE, $2A, $EA, $00, $30
	db $7E, $EA, $00, $38, $C9, $F3, $CD, $E9, $12, $FB, $C9
ASSERT @ == $12E9
