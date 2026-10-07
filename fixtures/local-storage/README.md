# Synthetic local-storage CPU probes

These probes force PC and registers into selected original ROM0 helpers and the banked menu dispatcher. They are
**SYNTHETIC**, not natural menu execution, and do not establish hardware behavior.
No save file is loaded, no flash command is issued, and the original ROM is only
read. SRAM/WRAM setup affects the disposable core's memory only.

From the repository root:

```sh
make storage-probe REFERENCE_ROM="/external/original.gbc" MGBA_SOURCE="/path/mgba" MGBA_BUILD="/path/build"
make private-storage-check REFERENCE_ROM="/external/original.gbc" MGBA_SOURCE="/path/mgba" MGBA_BUILD="/path/build"
```

The runner requires a matching shared-library build and C compiler. It reads all
ABI feature defines from `CMakeFiles/mgba.dir/flags.make`, uses the generated
includes, clears loader overrides, checks the executed library's version/commit,
and checks the original ROM hash before/after. Logs and the executable go to a
new temporary directory. A bounded instruction limit rejects missing returns.

Coverage: all 256 byte indices for directory address arithmetic and header
pointer reads; four result-register cases; a matching name and four one-byte
mismatches; free/matching/full 130-entry directory fixtures; one record checksum;
directory checksum match/mismatch; eight word-comparison cases; forced first-record creation, existing open without resizing, and checksum update on close. Including return
and stack assertions, the maintained fixture reports **1,636 assertions**.
Recovery adds six fixtures: empty, one/two valid records, invalid first/second checksum, and a valid checksum summing to zero. Clearing checks every byte of the selected 4 KiB SRAM window and preservation of the other window. All 256 arithmetic indices are tested, but this does not mean all are admissible
in the original search, whose static upper bound is `$82`.

The probes cover helpers, only bounded forced-entry open/create/close cases, not persistence,
complete recovery guarantees, allocation capacity, arbitrary corrupted records or natural execution.
Semantic names remain PROBABLE. The maintained research note explains the
static paths and distinguishes these fixtures from natural evidence.

The menu dispatcher is mapped with native A selector `$14` and tested at `$406C`.
Six table indices and two deliberately out-of-range inputs (`$06`, `$80`) verify
the indirect destination, unchanged stack and unchanged input. Each run stops
before executing its target. `$80` demonstrates eight-bit rotation, not widened
multiplication; these inputs do not establish natural state admissibility.

State 1 at `$42CD` is tested with every nonzero byte at `$C21F`: it returns
without invoking downstream callees and preserves BC/DE/HL and that byte. The
zero path and states 2/3 have exact-byte checks only; their callees are not covered
by these forced-entry fixtures. The meaning of `$C21F` is not established.
