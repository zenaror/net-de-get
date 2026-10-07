; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $05C8-$05D9.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:05C8-05D9", ROM0[$05C8]
ResidualROM00_05C8::
	db $0B, $46, $50, $16, $CA, $48, $68, $00, $40, $1D, $00, $40, $17, $00, $40, $13
	db $00, $50
ASSERT @ == $05DA
