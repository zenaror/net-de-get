; PROBABLE four eight-byte indexed records; only first five fields consumed.
; Full object extent is measured for indices0-3; no general index validity claim.
SECTION "A12 indexed text records 5314-5333", ROMX[$5314], BANK[$09]
A12TextRegionRecords::
	db $00, $00, $12, $02, $01, $00, $00, $00
	db $00, $00, $0E, $03, $01, $00, $00, $00
	db $00, $00, $0B, $02, $01, $00, $00, $00
	db $00, $00, $05, $03, $01, $00, $00, $00
ASSERT @ == $5334
