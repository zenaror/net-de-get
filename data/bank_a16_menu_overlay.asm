; PROBABLE 4x1 two-plane overlay consumed by refresh4B91.
SECTION "A16 menu overlay", ROMX[$4ECA], BANK[$0B]
A16MenuOverlayBytes::
	db $81, $82, $83, $84, $00, $00, $00, $00
ASSERT @ == $4ED2
