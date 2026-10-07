; PROBABLE original resident helper contracts; bounded synthetic CPU probes.
SECTION "Resident helpers 2685-269B", ROM0[$2685]
ResidualROM00_2685::
ResolveMinigameSelector::
	cp a, FIRST_FLASH_GAME_INDEX
	jr nc, MinigameSelector_2696
	add a, LOW(BuiltinGameWindowBSelectors)
	ld l, a
	ld a, HIGH(BuiltinGameWindowBSelectors)
	adc a, $00
	ld h, a
	ld e, [hl]
	ld d, MBC6_ROM
	jr MinigameSelector_269B
MinigameSelector_2696::
	sub a, FIRST_FLASH_GAME_INDEX
	ld e, a
	ld d, MBC6_FLASH
MinigameSelector_269B::
	ret
ASSERT @ == $269C
