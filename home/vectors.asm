; Fixed vector bytes and explicitly measured zero-filled reserved regions.
; Jump targets are literal until their bodies are reconstructed.
SECTION "Reset and interrupt vectors", ROM0[$0000]
ResetVector::
	jp $05F5
	ds $0040 - @, 0
VBlankVector::
	jp $0601
	ds 5, 0
LCDStatVector::
	jp $061B
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
	jp $02B8
.end:
ASSERT .end - CartridgeEntry == 4
