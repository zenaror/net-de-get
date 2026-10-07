; PROBABLE access roles from local-storage ROM0 code; address equates only.
DEF hStorageRecordSlot EQU $FF9D
DEF hStorageRecordNameLow EQU $FF9E
DEF hStorageRecordNameHigh EQU $FF9F
DEF hStorageRecordSizeLow EQU $FFA0
DEF hStorageRecordSizeHigh EQU $FFA1
DEF wStorageRecordDataLow EQU $C677
DEF wStorageRecordDataHigh EQU $C678
DEF wStorageRecordSlot EQU $C679
; Neutral register-address names: no interpretation of SRAM window semantics.
DEF hSavedRegister0400 EQU $FFAF
DEF hSavedRegister0800 EQU $FFB0
