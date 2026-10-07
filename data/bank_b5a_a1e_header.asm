; PROBABLE twelve-byte A1E header reached by original A0F setup.
; Physical2D lower8KiB maps atB5A6000; numeric words preserve original values.
SECTION "B5A A1E pointer header", ROMX[$4000], BANK[$2D]
ResidualROM2D_4000::
BankB5AA1EPointerHeader::
	dw $617B
	dw $62A4
	dw $600C
	dw $603F
	dw $6061
	dw $614B
ASSERT @ == $400C
