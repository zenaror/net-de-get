; CONFIRMED: four fixed-ROM JP thunks and their byte addresses.
; Their callees are described by static instruction effects only.
SECTION "Resident display jump thunks", ROM0[$0165]
ResidentDisplayJumpTable::
ResidualROM00_0165::
ResidentJump0165::
	jp WriteA16DigitTileOrMarker
ResidentJump0168::
	jp ConfigureSTATAndIEFromA
ResidentJump016B::
	jp InitializeLCDCToC3
ResidentJump016E::
	jp WaitForLY91AndDisableLCDC
ASSERT @ == $0171
