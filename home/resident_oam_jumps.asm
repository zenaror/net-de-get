; CONFIRMED: three fixed-ROM JP thunks and their encoded destinations.
SECTION "Resident OAM setup jump thunks", ROM0[$018F]
ResidentOAMJumpTable::
ResidualROM00_018F::
ResidentJump018F::
	jp InstallOAMDMARoutine
ResidentJump0192::
	jp Clear256BytesDescendingFromFEFF
ResidentJump0195::
	jp ClearBothVRAMBanks
ASSERT @ == $0198
