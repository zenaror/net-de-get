; PROBABLE static main-state pointers; no universal index bound established.
SECTION "Main state pointers", ROM0[$03A8]
MainStatePointers::
	dw MainState00
	dw MainState01
	dw MainState02
	dw $04A6
	dw $056A
	dw $0577
	dw $057F
	dw $0597
	dw $05A4
	dw $05B1
ASSERT @ == $03BC
