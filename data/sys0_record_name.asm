; PROBABLE four-byte record identifier read by OpenLocalStorageRecord.
SECTION "SYS0 record name", ROM0[$17B3]
ResidualROM00_17B3::
SYS0RecordName::
	db "SYS0"
ASSERT @ == $17B7
