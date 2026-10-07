; PROBABLE static installer for an executable HRAM template.
; The relative wait branch retains its bytes after relocation to $FF80.
SECTION "OAM DMA installer", ROM0[$09EB]
InstallOAMDMARoutine::
	ld c, LOW(hOAMDMARoutine)
	ld b, $0A
	ld hl, OAMDMATemplate
.copy:
	ld a, [hli]
	ldh [c], a
	inc c
	dec b
	jr nz, .copy
	ret
.end:
ASSERT .end - InstallOAMDMARoutine == $0E

SECTION "OAM DMA template", ROM0[$09F9]
OAMDMATemplate::
	ld a, $C0
	ldh [$FF46], a
	ld a, $28
.wait:
	dec a
	jr nz, .wait
	ret
.end:
ASSERT .end - OAMDMATemplate == $0A
