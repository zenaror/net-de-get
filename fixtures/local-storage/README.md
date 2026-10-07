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
and stack assertions, the maintained fixture reports **1,839 assertions**.
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

Three bounded state-4 fixtures test `$D01C=$FF`, `$D01C=1`, and `$D01C=0`
with the index sum matching `$D003`. They check return, the resulting state and
saved fields. These paths have no external calls. Other state-4 paths and all
of state 5 remain exact-byte checks only.

The two-plane tilemap-copy helper at `$01A4/$0B15` is tested with LCD off for
4×1, 20×2 and 3×3 dimensions. Checks cover both VRAM planes, consecutive source
bytes, 32-byte destination row stride, untouched destination padding, BC/DE
preservation, HL advancement and restoration of VBK bit 0. This does not test
LCD-on timing, arbitrary dimensions or naturally rendered menu appearance.

Additional LCD-off checks exercise linear sizes 1/17/32, single-plane rectangles
4×1/20×2/3×3, and banked linear/two-plane copies through both native 8 KiB
windows using ROM type. They check copied data, untouched padding, register
outcomes, both selector/type mirrors and restored mapper contents. Single-plane
copy consumes B/C and advances DE by a 32-byte stride per row; the two-plane
wrapper preserves BC/DE. No zero counters, window crossing, flash source types
or LCD-on timing is covered.

Pending-menu transfers are entered at `$5A0E`, after the two external callbacks.
Eight positive widths (1/3/4/7/8/9/20/32) with height 2 check active flags `$80`
and 1, descriptor consumption and padding. Other cases cover an inactive queue,
the original nine-byte column at `$4224` in plane 1, and the independent `$D309`
6×10 tail starting in planes 0/1. Plane 1 at entry may produce only one pass;
these fixtures do not establish what the skipped callbacks configure naturally.
Zero dimensions, arbitrary pointers and LCD-on safety remain outside coverage.

Palette fixtures at `$018C` cover inactive/active `$C221`, both 64-byte palette
sets and AF/BC/DE/HL preservation, LCD off. The original installer `$09EB`
copies its ten-byte DMA template into disposable HRAM; checks cover exact bytes,
adjacent-byte preservation and the 160-byte OAM transfer. One integrated fixture
enters `$5A08` with the installed DMA, inactive palettes and one queued byte.
This is synthetic full-entry coverage, not natural setup or hardware timing proof.

Four isolated original-copy calls use the actual state-0 source/destination
ranges: A `$14:$5C0A` (16), B `$15:$6002` (6144), A `$14:$5CE2` (160),
and B `$15:$71B4` (32). They compare every copied byte, trailing sentinel,
registers, selected VRAM plane and restored mapper values. Setup is forced and
LCD is off; no complete state-0 or naturally rendered graphics claim follows.

Local housekeeping checks clear exactly 160 WRAM OAM-source bytes at `$C000`,
register outcomes and a trailing sentinel. Six header-sum fixtures cover empty
list, skipped builtin index, accepted counts 3/16, rejected 17, marker mismatch
and duplicate synthetic entries that wrap 272 to 16. Header bytes are injected
directly into disposable core flash backing and restored; no program/erase
command or save file is used. Checks also cover disabled read/write controls and
the visited B selector/type remaining selected, not restored. Count units and
natural duplicate-list admissibility are not established.

Callback setter fixtures use DE=0/1/$5A08/$BEEF/$FFFF on both pointer slots
and both interrupt-stub setters. Checks cover little-endian pointers, JP/RETI
opcodes, preserved registers and unchanged operand bytes for a null target.
They do not dispatch an interrupt, execute those targets or establish admissibility
of the deliberately unusual addresses. A later integrated fixture covers full menu-runtime initialization with a
synthetic, correctly sized record; this does not establish natural execution.

Per-entry palette probes cover indices 0..7 for background/object palettes and
verify that other entries remain unchanged. Full `$481B` initializes every entry
from its original eight-byte source. `$45FF` is exercised with fresh and existing
correctly sized SYS1 records: all 675 destination bytes and a trailing sentinel
are checked. A full `$5BC6` fixture checks storage, palettes, flags and registration
of `$5A08`. These are LCD-off synthetic cases; no short/corrupted-record safety
or naturally initialized menu claim follows.
