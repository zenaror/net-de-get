; Four bytes passed in DE to OpenLocalStorageRecord by the local menu.
; PROBABLE record-name role from the four-byte comparison in $0F3E/$0F81.
; This is not CPU code; $3EDC begins the next routine outside this section.
SECTION "Local menu storage name", ROM0[$3ED8]
LocalMenuStorageName::
	db "SYS1"
.end:
ASSERT .end - LocalMenuStorageName == 4
