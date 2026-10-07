; PROBABLE static main-state pointers; no universal index bound established.
SECTION "Main state pointers", ROM0[$03A8]
MainStatePointers::
	dw MainState00
	dw MainState01
	dw MainState02
	dw MainState03
	dw MainState04
	dw MainState05
	dw MainState06
	dw MainState07
	dw MainState08
	dw MainState09
ASSERT @ == $03BC
