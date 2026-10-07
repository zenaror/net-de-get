; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $0A03-$0A4F.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:0A03-0A4F", ROM0[$0A03]
ResidualROM00_0A03::
	db $AF, $21, $FF, $FE, $06, $00, $32, $05, $20, $FC, $C9, $AF, $E0, $4F, $21, $00
	db $80, $01, $00, $20, $F3, $F0, $41, $E6, $02, $20, $FA, $3E, $00, $77, $FB, $F0
	db $41, $E6, $02, $20, $EF, $23, $0B, $79, $B0, $20, $E9, $3E, $01, $E0, $4F, $21
	db $00, $80, $01, $00, $20, $F3, $F0, $41, $E6, $02, $20, $FA, $3E, $00, $77, $FB
	db $F0, $41, $E6, $02, $20, $EF, $23, $0B, $79, $B0, $20, $E9, $C9
ASSERT @ == $0A50
