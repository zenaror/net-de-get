; PROBABLE software roles, based on static callers documented in maintenance.
DEF wFlashRetry EQU $CEE4
DEF wFlashSoftwareFlags EQU $CEE9 ; helper checks/clears bit 0

; Original flash callback uses shared minigame scratch; not a nesting stack.
DEF wFlashCallbackSavedSelector EQU wMinigameSavedWindowASelector
DEF wFlashCallbackSavedType EQU $C66E
