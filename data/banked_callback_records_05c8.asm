; PROBABLE three-byte selector/CPU-address records read at ROM0 $23EA.
SECTION "Banked callback records 05C8-05D9", ROM0[$05C8]
ResidualROM00_05C8::
BankedCallbackRecords0::
	db $0B
	dw $5046
	db $16
	dw $48CA
	db $68
	dw $4000
	db $1D
	dw $4000
	db $17
	dw $4000
	db $13
	dw $5000
ASSERT @ == $05DA
