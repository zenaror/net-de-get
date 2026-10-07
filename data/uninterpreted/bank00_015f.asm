; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $015F-$0161.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:015F-0161", ROM0[$015F]
ResidualROM00_015F::
	db $C3, $DF, $06
ASSERT @ == $0162
