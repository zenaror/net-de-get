; PROBABLE three-byte selector/CPU-address records read at ROM0 $23EA.
SECTION "Banked callback records 05E0-05F4", ROM0[$05E0]
ResidualROM00_05E0::
BankedCallbackRecords8::
	db $14
	dw $4000
	db $12
	dw $4000
	db $13
	dw $4000
	db $10
	dw $56B8
	db $0F
	dw $4000
	db $71
	dw $4000
	db $76
	dw $4000
ASSERT @ == $05F5
