; PROBABLE reached two-plane one-cell resources, not a larger table extent.
SECTION "A0F list vacant cells", ROMX[$6F5C], BANK[$07]
A0FListFirstVacantCell::
	db $89, $00
A0FListFollowingVacantCell::
	db $8A, $00
ASSERT @ == $6F60
