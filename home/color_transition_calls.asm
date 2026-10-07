; PROBABLE original resident thunks for color preparation and advancement.
SECTION "Color transition thunks 0177-017F", ROM0[$0177]
ResidualROM00_0177::
StartColorSubtractTransition:: jp PrepareColorSubtractTransition
StartColorAddTransition:: jp PrepareColorAddTransition
StepColorTransition:: jp AdvanceColorTransition
ASSERT @ == $0180
