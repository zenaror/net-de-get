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
and stack assertions, the maintained fixture reports **7,825 assertions**.
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

Forty `$461A` indicator fixtures combine blink bit on/off, five offsets and
four counts. They check both four-byte OAM-source entries, unchanged hidden
entry fields and adjacent sentinels. Offsets 251/252/255 deliberately exercise
eight-bit offset+5 wrapping; natural admissibility and display behavior are not
established by these memory/register fixtures.

Thirty-six held-input pairs cover equal and changed bytes, irrelevant-bit changes,
bit $10/$20 priority, unchanged absent descriptors and adjacent sentinels at
$478D. Four transitions chain that producer into consumer body $5A0E, skipping
callbacks, and check original one-cell sources in both VRAM planes, padding and
consumed flags. The cases are forced, LCD-off and SYNTHETIC; neither natural
input admissibility nor rendered indicators is established.

Text-step probes cover timer 0/2/3/255 and a zero source token with modes
1/2/255. They return before the unextracted text sink, checking counters,
pointers, state and buffer guards. Nonempty token output is only static here.
Cursor probes exhaust all 256 frame bytes for $2DC3 arithmetic, then check
20 list entries, 16 removal entries and 20 movement entries and OAM guards.
They do not establish natural row/category bounds or rendered motion.
Sixteen unhandled-input combinations return from $4940 with tested menu fields
unchanged. Four pair-lookup cases cover first/second match, exhaustion and
B=$FF on a synthetic 256-pair list; natural list capacity is not established.

Sixteen unhandled action-input fixtures return from $4C6F without modifying the
tested fields. Fifteen $4C3E cases combine indices 0/1/6/16/255 and source lengths
0/3/16 in a correctly sized 675-byte synthetic SYS1. They check the zero-inclusive
or 16-byte copy, nibble-swap address arithmetic and all other payload bytes.
Closing disables SRAM; the harness explicitly remaps disposable SRAM to inspect
it afterward. No real save, arbitrary-record capacity or natural extreme-index
admissibility is established. $46C1 is reconstructed statically; its complete
text/description execution has not received a new probe here.

RST-table probes cover all 256 A values, stopping at the loaded target before
executing it. They check eight-bit doubling, the consumed table-pointer return
address, stack and registers. Three callback slots have null/WRAM callback cases
with saved-register restoration, plus a return-only path. Two VBlank cases stop
at $069E before its maintenance call $2242; they check flag $FF8A and saved stack
words, not natural interrupts or complete VBlank processing.
Four startup-prefix cases use A=$11/0/$80/$FF, stopping before the call at $0373.
They check HRAM, fixed WRAM and all seven banked WRAM windows, RETI stub bytes,
SP, model-result byte and A selector/type. Setup is forced and LCD is off; this
does not exercise A $16:$4000 initialization or natural boot/main dispatch.


Four forced DMG fallback-prefix cases enter native A $16:$416C with LCD off,
vary the previous B selector and stop at $419D before sound helper $0252.
They check B $1F ROM mapping through shadow fields and mapped bytes, preserved
BC/DE/HL/SP, palettes, scroll/window and sound routing. Eight added assertions
are SYNTHETIC; they do not execute the complete startup, HALT loops, natural
boot, real DMG hardware or LCD-on timing.


Main-state probes force all 256 byte indices at $0391 and stop at $03A5 before
JP HL executes the selected target. They check eight-bit doubling, the loaded
word, saved return address, SP and preserved BC/input. Out-of-table reads are
reproduced, not declared naturally admissible. Seven forced handlers at
$047C+6*i check writes of 3/4/5/1/2/7/6 to $C623, bounded returns and preserved
BC/DE/HL (14 assertions). These 270 added assertions do not establish natural
main-state execution or the external callees of states 0/1/2.


Remaining main-state probes add 527 assertions. All 256 values of $C623 enter
only the post-callback tail $058A: 7 survives and every other value becomes 2.
Four return tails check state writes/register pairs; five prefixes stop before
external $0264 and check arguments (4/10/3/2/13) and the state-6 zero write.
State 9 is split into a mapping-prefix probe stopped before $44AA and a separately
forced tail at $05C2 that discards a stacked return before jumping to $02B8 with
A=$11. No external callee is skipped inside a claimed complete execution: these
are independent forced entries, not natural main-state or restart traces.


Resident-jump probes check all 84 JP slots at $01BC+3*i, stopping at their
literal targets before any target instruction executes (84 assertions).
Banked dispatcher probes cover 256 byte indices in each of the A/B paths:
3*A wraps to eight bits, a selector/word is loaded, the prior selector/type
is saved at depth zero and a return address is pushed. They stop before JP HL
($2429/$248C). Each restore tail ($242A/$248D) is then entered independently
with the saved fields, never implying that the original target returned.
These add 1536 assertions including bounded returns. Previous type $08 tests
restoration of a flash mapping flag, without programming/erase or saves.
Out-of-table records can cause invalid-flash-selector diagnostics while the
original prefix writes the selector before forcing type ROM; no universal
index, stack depth or callback admissibility is claimed.


A16 save/restore helper probes use selectors 0/1/$14/$7F and types 0/$08,
checking stored pairs, DE+1, preserved BC/HL, A16/type-ROM mapping and the other
window's shadow fields. Four wrapper prefixes stop before $4227/$424D/$42CB/
$42EF; independently forced return tails restore their saved pairs. The first
wrapper does not save AF; the other three preserve the supplied AF value across
restoration. These add 44 assertions including helper/tail bounded returns.
No target execution, natural boot, interrupt-state guarantee or hardware claim.


Five positive copy counts (1/2/50/255/256) verify $2613 pointers, BC exhaustion,
bytes and untouched destination boundaries; BC=0 is not tested as an empty copy.
A disposable existing SYS0 directory/header with a 50-byte payload drives full
original wrappers $1689/$169D through open, copy, close/checksum and A-window
restore. Payload directions, A=0 result, mapping and stored checksums are checked.
These add 16 assertions. This remains SYNTHETIC SRAM: no disk saves, SYS0 creation,
smaller-record safety, initialization $424D, natural menu or hardware claims.


Three VBlank mapper cases ($C672=0/1/$FF) stop at $2264 before native A1E's
target call. Separate forced tails at $2267 check actual mapped bytes, unchanged
register pairs and HRAM fields, and the C113-C116 shadow-update difference.
Nine added assertions do not execute A1E:$4000 or natural VBlank/IRQ timing.


A1E tick probes add 250 assertions: 64 complete bodies with one active slot,
counters 0/1/2/$FF and remainders 1/$FF (other slots/global paths inactive);
eight stops before external handlers; 56 forced routing-tail mask cases; one
inactive whole body. They check countdown wrap, remainder/reload, untouched slots
and the exact $FF25 mask expression. No natural VBlank, active CF86 global flow,
external-handler execution, audible correctness or hardware is established.


A1E global-path probes add 130 assertions: exact lower-slot/global clear with
upper/adjacent sentinels retained, 32 upper-flag combinations using active1/$FF
and masked readable audio registers, and 32 complete ticks with period1/$FF,
counter0/1/2/$FF and phase0/14/15/$FF. Incremented phase $0F executes both helpers.
Slots remain inactive in those integrated cases. These prove only synthetic
state/register effects; no slot handlers, natural playback, timing or hardware.


Slot0 probes add 578 assertions: 256 opcode dispatches stopped before their
bodies, 128 global-phase clamp cases, 19 B0 short/extended countdown streams,
four FD and four FE streams, five B1 threshold cases and one tick->B0 chain.
Short countdowns retain CF05. Extended bytes follow the original shift/OR
expression. FE count1 does not store zero and uses the current pointer; count0
uses the saved loop pointer. WRAM streams are synthetic; no complete opcode
coverage, universal bounds, playback, frequency table or hardware proof.


Slot1 probes add 1,320 assertions: 256 opcode stops, 19 B0 countdown streams,
all 256 B1 parameters, all 256 C0 parameters and one complete tick->B0 chain.
B1 updates CF88 bits 1/5 and CF19, retaining CF28. C0 reads two-byte records
from a synthetic WRAM table via CF96/CF97, masked index plus one. Short
countdowns retain CF15, and CF04 remains untouched. This checks slot-specific
behavior without inferring equivalence to slot0's bits 0/4 and three-byte stride.
Other opcode bodies, natural playback, universal stream/table bounds and audio
correctness remain outside the evidence. No real save or original ROM write.
