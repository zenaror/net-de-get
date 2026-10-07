; MBC6 selectors address independent 8 KiB windows, not RGBDS banks.
DEF MBC6_WINDOW_SIZE EQU $2000
DEF MBC6_ROM EQU $00
DEF MBC6_FLASH EQU $08
DEF rMBC6WindowBSelector EQU $37FF ; alias within selector register range
DEF rMBC6WindowBType EQU $3800

; Addresses only; names describe the observed stores, not hardware timing.
DEF rMBC6FlashReadControl EQU $0C00
DEF rMBC6FlashWriteControl EQU $1000
