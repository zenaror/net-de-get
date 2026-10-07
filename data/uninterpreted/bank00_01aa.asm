; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $01AA-$01B5.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:01AA-01B5", ROM0[$01AA]
ResidualROM00_01AA::
	db $C3, $5C, $0C, $C3, $5D, $0C, $C3, $5E, $0C, $C3, $6A, $0C
ASSERT @ == $01B6
