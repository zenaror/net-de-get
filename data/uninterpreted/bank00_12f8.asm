; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $12F8-$1358.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:12F8-1358", ROM0[$12F8]
ResidualROM00_12F8::
	db $7D, $EA, $00, $20, $7C, $EA, $00, $28, $C9, $21, $FE, $CE, $2A, $EA, $00, $20
	db $7E, $EA, $00, $28, $C9, $21, $86, $C6, $CB, $C6, $21, $00, $00, $36, $0A, $C9
	db $21, $86, $C6, $CB, $86, $21, $00, $00, $36, $00, $C9, $21, $00, $00, $36, $0A
	db $C9, $21, $86, $C6, $CB, $46, $C0, $21, $00, $00, $36, $00, $C9, $47, $F3, $78
	db $EA, $00, $08, $EA, $FA, $CE, $FB, $C9, $FA, $FA, $CE, $EA, $00, $08, $C9, $47
	db $F3, $78, $EA, $00, $04, $EA, $FB, $CE, $FB, $C9, $FA, $FB, $CE, $EA, $00, $04
	db $C9
ASSERT @ == $1359
