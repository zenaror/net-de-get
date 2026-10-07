; Fixed vector bytes and explicitly measured zero-filled reserved regions.
; Known resident bodies use symbols; WRAM stub addresses remain literal.
SECTION "RST and interrupt vectors", ROM0[$0000]
; Legacy ResetVector alias retained; this is the RST $00 table dispatch.
ResetVector::
RST00Vector::
	jp DispatchReturnTable
	ds $0040 - @, 0
VBlankVector::
	jp DispatchVBlankCallback
	ds 5, 0
LCDStatVector::
	jp DispatchLCDStatCallback
	ds 5, 0
TimerVector::
	jp $C67F
	ds 5, 0
SerialVector::
	jp $C682
	ds 5, 0
JoypadVector::
	reti
	ds $0100 - @, 0
.end:
ASSERT .end - ResetVector == $100
ASSERT VBlankVector == $0040
ASSERT LCDStatVector == $0048
ASSERT TimerVector == $0050
ASSERT SerialVector == $0058
ASSERT JoypadVector == $0060

SECTION "Cartridge entry", ROM0[$0100]
CartridgeEntry::
	nop
	jp StartCartridgeProgram
.end:
ASSERT .end - CartridgeEntry == 4
