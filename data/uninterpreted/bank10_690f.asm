; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $10, address $690F-$6912.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 10:690F-6912", ROMX[$690F], BANK[$10]
ResidualROM10_690F::
	db $FE, $00, $FF, $2F
ASSERT @ == $6913
