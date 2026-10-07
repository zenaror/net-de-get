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
