; PROBABLE original two-frame tile resources consumed by FF records and 4FAF.
; Geometry/payload layout follows existing copy/tick consumers; no Japanese meaning.
SECTION "A12 variant0 effect tiles0 6800-6836", ROMX[$6800], BANK[$30]
A12Variant0EffectTiles0::
	db $13, $04, $01, $0C, $02, $06, $00
; Frame 0, original two-plane payload.
	db $86, $87, $88, $88, $88, $88, $89, $88, $88, $88, $8A, $8B, $0C, $0C, $0C, $0C
	db $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C
; Frame 1, original two-plane payload.
	db $8C, $8D, $8E, $8E, $8E, $8E, $8F, $8E, $8E, $8E, $90, $91, $0C, $0C, $0C, $0C
	db $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C
ASSERT @ == $6837

SECTION "A12 variant0 effect tiles1 6837-686D", ROMX[$6837], BANK[$30]
A12Variant0EffectTiles1::
	db $13, $04, $01, $0C, $02, $06, $00
; Frame 0, original two-plane payload.
	db $86, $87, $88, $88, $88, $88, $89, $88, $88, $88, $8A, $8B, $0C, $0C, $0C, $0C
	db $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C
; Frame 1, original two-plane payload.
	db $80, $81, $82, $82, $82, $82, $83, $82, $82, $82, $84, $85, $0C, $0C, $0C, $0C
	db $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C
ASSERT @ == $686E

SECTION "A12 variant0 effect tiles2 6A0F-6A51", ROMX[$6A0F], BANK[$30]
A12Variant0EffectTiles2::
	db $0F, $05, $03, $05, $02, $10, $01
; Frame 0, original two-plane payload.
	db $D7, $D8, $D9, $DA, $DB, $DC, $DD, $DE, $DF, $E0, $E1, $E2, $E3, $E4, $E5, $0B
	db $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0C, $0C, $0B, $0B, $0B
; Frame 1, original two-plane payload.
	db $E6, $E7, $E8, $E9, $EA, $EB, $EC, $ED, $EE, $EF, $F0, $F1, $F2, $F3, $F4, $0C
	db $0B, $0B, $0C, $0B, $0B, $0C, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B
ASSERT @ == $6A52
