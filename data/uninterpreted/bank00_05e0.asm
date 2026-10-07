; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $05E0-$05F4.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:05E0-05F4", ROM0[$05E0]
ResidualROM00_05E0::
	db $14, $00, $40, $12, $00, $40, $13, $00, $40, $10, $B8, $56, $0F, $00, $40, $71
	db $00, $40, $76, $00, $40
ASSERT @ == $05F5
