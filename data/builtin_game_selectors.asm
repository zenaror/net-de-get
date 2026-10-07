; ROM0 lookup used by dispatch $254E and title-list A $14:$4D88.
; PROBABLE: first $10 Index values address this table (static CP $10 gate).
; Entries are native MBC6 8 KiB selectors, NOT RGBDS 16 KiB bank numbers.
; No game names or title translations are inferred from these values.
SECTION "Built-in game window selectors", ROM0[$3CD8]
BuiltinGameWindowBSelectors::
	db $54, $51, $38, $30, $33, $35, $3A, $3D
	db $3F, $41, $43, $45, $48, $49, $56, $FF
.end:
ASSERT .end - BuiltinGameWindowBSelectors == FIRST_FLASH_GAME_INDEX
; Index $0F points to $FF. Preserve it; its intended use remains unresolved.
