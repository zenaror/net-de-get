; Runtime callback table excerpt referenced by ROM0 $23E4.
; Source image SHA-256:
;   9fb1e6e4a637796b8624bd2de6c9abaa9e758546b620cb5dc8441b07c288bc63
;
; PROBABLE static decode; indices 6 and 7 were cross-checked against the
; headless PC/selector/stack trace. Each entry is MBC6 A selector, then address.

SECTION "Runtime callback table excerpt", ROM0[$05DA]
RuntimeCallback_6:
	db $0B
	dw $4000
RuntimeCallback_7:
	db $12
	dw $4000
