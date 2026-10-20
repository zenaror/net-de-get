; CONFIRMED: three fixed-ROM JP thunks and their encoded destinations.
; Only the first destination has a named body in this source tree.
SECTION "Resident OAM setup jump thunks", ROM0[$018F]
ResidentOAMJumpTable::
ResidualROM00_018F::
ResidentJump018F::
	jp InstallOAMDMARoutine
ResidentJump0192::
	jp $0A03
ResidentJump0195::
	jp $0A0E
ASSERT @ == $0198
