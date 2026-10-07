; Address equates only: no WRAM allocation or initializer is emitted.
; PROBABLE descriptive names from static accesses; preserve the alias below.
DEF hWindowBSelector EQU $FFAD
DEF hWindowBType EQU $FFAE
DEF wWindowBSelectorMirror EQU $C115
DEF wWindowBTypeMirror EQU $C116
DEF wTitleListBankOrIndex EQU $C5C5 ; saved selector, then overwritten by game Index
DEF wTitleListSavedType EQU $C5C6
DEF wTitleListDestinationLow EQU $C5C7
DEF wTitleListDestinationHigh EQU $C5C8
DEF wTitleListItemIndex EQU $C5CF
DEF wCurrentGameBox EQU $D001
DEF wTitleListCount EQU $D003
DEF wGameIndexBoxPairs EQU $D1E6
DEF wGameTitleList EQU $D3C2

; Dispatcher $254E saves the selector but restores ROM type unconditionally.
DEF hWindowASelector EQU $FFAB
DEF hWindowAType EQU $FFAC
DEF wWindowASelectorMirror EQU $C113
DEF wWindowATypeMirror EQU $C114
DEF wMinigameFlashSelector EQU $C66C
DEF wMinigameSavedWindowASelector EQU $C66D

; PROBABLE scan scratch roles from ROM0 $3E00; not a WRAM bank allocation.
DEF wLocalScanSector EQU $C5C4
DEF wLocalScanDestinationLow EQU $C5C9
DEF wLocalScanDestinationHigh EQU $C5CA
DEF wLocalScanReservedSector EQU $C5CB

DEF rSVBK EQU $FF70
DEF hHeldButtons EQU $FF96

DEF wLocalMenuState EQU $D000 ; byte loaded by $406C dispatcher
