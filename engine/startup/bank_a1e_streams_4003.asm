; PROBABLE native A1E stream installation/helpers.
; SYNTHETIC WRAM records; no natural stream validity or playback.
SECTION "A1E stream setup 4003", ROMX[$4003], BANK[$0F]
ResidualROM0F_4003::
NativeA1ELowerStreamEntry::
	jp InstallA1ELowerStreams
NativeA1EUpperStreamEntry::
	jp InstallA1EUpperStreams
NativeA1EInitializeEntry::
	jp InitializeA1EPointerFields
BackupA1ELowerSlots::
	ld hl, $CF00
	ld de, $CFA0
	ld b, $40
A1EStreams_4014::
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, A1EStreams_4014
	ret
InitializeA1EPointerFields::
	ld hl, $5000
	ld a, [hli]
	ld [$CF92], a
	ld a, [hli]
	ld [$CF93], a
	ld a, [hli]
	ld [$CF90], a
	ld a, [hli]
	ld [$CF91], a
	ld a, [hli]
	ld [$CF94], a
	ld a, [hli]
	ld [$CF95], a
	ld a, [hli]
	ld [$CF96], a
	ld a, [hli]
	ld [$CF97], a
	ld a, [hli]
	ld [$CF98], a
	ld a, [hli]
	ld [$CF99], a
	ld a, [hli]
	ld [$CF9A], a
	ld a, [hli]
	ld [$CF9B], a
	ld a, $FF
	ld [$CF84], a
	ld [$CF88], a
	xor a, a
	ld [$CF89], a
	ret
ReadA1EWordFromDE::
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	ret
ClearAllA1ESlots::
	ld hl, $CF00
	ld b, $80
	ld a, $00
A1EStreams_4069::
	ld [hli], a
	dec b
	jr nz, A1EStreams_4069
	ret
ASSERT @ == $406E
