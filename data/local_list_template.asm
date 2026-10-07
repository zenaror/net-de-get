; Native window B selector $15, CPU $71D4-$7243, file $2B1D4-$2B243.
; Physical RGBDS bank $0A upper half; not native selector $0A.
; PROBABLE list-template interpretation: CopyLocalListTemplate reads $70 bytes.
; This proves the static copied interval, not complete object extent or fields.
; Preserve raw bytes and original text encoding; no translation.
SECTION "Local list template read interval", ROMX[$71D4], BANK[$0A]
LocalListTemplate::
	db $42, $4F, $58, $21, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00
	db $42, $4F, $58, $22, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00
	db $42, $4F, $58, $23, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00
	db $42, $4F, $58, $24, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00
	db $42, $4F, $58, $25, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00
	db $42, $4F, $58, $26, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00
	db $42, $4F, $58, $27, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00
.end:
ASSERT .end - LocalListTemplate == $70
