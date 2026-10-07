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
and stack assertions, the maintained fixture reports **971,353 assertions**.
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


Slot2 adds 1,320 assertions: 256 dispatch stops, 19 B0 duration streams, all256
B1 parameters, all256 C0 parameters and one tick->B0 chain. B1 edits CF88 bits
2/6, retaining the slot1 CF19 sentinel. C0 masks the index into CF27, reads a
two-byte pointer through CF98/CF99 at 2*(parameter&31), then copies16 bytes to
wave RAM. Synthetic WRAM supplies32 pointers and32 distinct16-byte waves; the
wave channel is disabled before each case. Short durations retain CF25 and the
slot1 CF14 sentinel. No active-channel wave-RAM behavior, natural playback,
other opcode bodies, universal stream/table safety or audible correctness proof.


Slot3/shared-clear adds 1,328 assertions: 256 dispatch stops (including B0/E0
returning as unknown), 19 countdowns through C0, all256 B1/C0 parameters, one
tick->C0 chain and four complete FF streams through the lower-slot handlers.
B1 edits bits3/7 and CF39; C0 consumes a parameter without other slot-field
writes. FF clears exactly its16-byte slot while preserving the other112 bytes
in CF00-CF7F. These do not prove other command bodies, natural playback or audio
correctness. The numeric word-read base4A0E overlaps shared-clear instructions;
no total table extent is assumed or substituted into the binary.


Slot4 adds 1,328 assertions: all256 opcode stops, 19 B0 durations, all256 B1/C0
parameters, four FE count cases (0/1/2/FF) and one tick->B0 chain. Every opcode
below90 selects the audio tail, unlike lower-slot early returns. B1 edits CF89
bits0/4 retaining CF88; C0 reads three-byte records at3*((value&31)+1). FE reads
CF4C but stores its decrement in CF0C, retaining CF4C; count1 uses the current
stream without storing zero, count0 uses the saved stream. Original cross-slot
writes are preserved. FF stops before external51C7; no external FF helpers,
other bodies, natural playback, universal stream safety or audio correctness.


Slot5 adds 1,328 assertions: 256 dispatch stops,19 B0 streams,all256 B1/C0
parameters,four FE counts0/1/2/FF and one tick->B0. B1 edits CF89 bits1/5; C0
uses two-byte records via CF96/CF97 at2*((parameter&31)+1). FE updates CF5C
above1 and retains CF0C, contrasting with the original slot4 cross-slot write.
Count1 retains1 and uses the current stream; otherwise the saved pointer is
used. FF stops before51C7. No external FF helpers, other bodies, natural
playback, universal stream/table bounds or audio correctness are established.


Slot6 adds 1,328 assertions: 256 dispatch stops,19 B0 streams,all256 B1/C0
parameters,four FE counts0/1/2/FF and one tick->B0. B1 edits CF89 bits2/6; C0
uses masked pointers via CF98/CF99 and copies16 bytes to wave RAM with the
channel disabled, retaining CF67 rather than storing its index. Synthetic WRAM
supplies32 pointers/waves. FE updates CF6C above1, retaining CF0C. FF stops
before51C7. No active-channel wave RAM, external FF helpers, other bodies,
natural playback, arbitrary bounds or audible correctness are established.


Slot7 and upper FF helpers add 9,528 assertions. Core cases:256 dispatch stops,
19 C0 durations,all256 B1/C0 parameters,four FE counts and one tick->C0. B1 uses
CF89 bits3/7; C0 stores the raw parameter in CF77; B0 returns as unknown.
4,096 complete E0/E1 streams use eight CF72 bases and every parameter. E0
forms (base&7)|((((base>>4)+value)&15)<<4); E1 forms
(base&F0)|(((base&7)+value)&FF). These preserve the original wrap/OR and update
CF7E/CF7F without storing into CF72. Four complete upper FF chains clear only
the selected16-byte slot and mask its routing bits, retaining other slot fields.
Restoration/reset helpers execute, but their audible correctness is not asserted.
No natural playback, all other bodies, table extent, IRQ timing or hardware.


Stream installation adds 2,564 assertions. 508 lower cases cover127 indices and
counts1-4, checking relative pointers, first-byte-plus-one counters and64-byte
backup. CF80=FF is a reserved resume request, not lower index127. 512 upper
cases cover128 indices and channels1-4, checking exact slot clearing/pointers
and routing activation. 256 inactive requests retain state. Additional cases
check literal initialization from5000,128-byte clear with guards, DE word read,
FF backup resume with a synthetic wave source and setup->two ticks->four lower
handlers. No natural record launch, malformed counts/channels, universal bounds
or audio correctness. The12 initialization bytes overlap original code; their
copy is checked without interpreting them as naturally valid pointer data.


Resident A1E setup adds60 assertions: three B-bank pointer-load cases,16 lower
and eight upper full request wrappers across two previous mapper configurations,
a combined request followed by the resident tick and one global-countdown
request. Actual mapped ROM bytes and restoration shadows are checked; wrappers
preserve AF/BC/DE/HL. The combined synthetic record reaches lower/upper B0
handlers via resident calls. Original DI/EI remains: prior IME preservation and
natural IRQ timing are not asserted. No natural launch, arbitrary record safety
or audio correctness; WRAM records/streams remain synthetic.


Actual-ROM B21/B5B/B5C header cases add15 assertions. Each checks the original
index1 record's count4, loads12 header bytes through resident thunk0246, then
requests lower index1 through024C and verifies all four relative stream pointers
and first-byte-plus-one counters. Records are original ROM bytes; entries are
forced; the later prefix cases below extend execution through the first tick.
No natural menu or playback is established.
Native B5C maps physical bank2E's lower half into B6000-7FFF.


The actual-ROM cases now add6 assertions for a resident first tick, checking
twelve stream-pointer/countdown endpoints after zero-duration command chaining.
B21 endpoints/counts:6642/0B,691D/0B,6BB2/24,6D3B/18; B5B:65EB/1B,698C/0E,
6CD1/1D,6ECA/02; B5C:6642/3B,6862/07,7037/05,77BE/01. These execute bounded
prefixes of original streams, not a natural menu launch, complete playback,
all future loops, timing or audible correctness.

### Original C0 records and wave bytes

The three original-record cases also check the slot0 three-byte fields,
slot1 two-byte fields and slot2 masked index after the forced first tick.
Slot0/1 C0 use index+1 and strides3/2; slot2 uses index directly to fetch a
little-endian wave pointer. B21 selects6039/6053/6069→60BB, B5B selects
6024/6043/6065→609B, B5C selects6024/6041/606D→60DB (mapped B addresses).
A separate forced4825 call with wave channel disabled checks all16 original
wave bytes and countdown7. Nine additional assertions do not establish
natural playback, active wave-RAM access or audible correctness.

### Twelve original straight-line stream continuations

The bounded framing model accepts only lower-slot commands implemented by the
known handlers, bounds every parameter/countdown read and caps800 events per
slot. Fixed endpoints and event counts cover3996 positive-count events.
It rejects unknown opcodes and truncated short/long durations in maintained
negative fixtures. The model reproduces original long-count bit splitting and
the tick's high-byte decrement/low-byteFF transition, rather than replacing
these with conventional16-bit arithmetic.

After forced header/request/first-tick setup,2433/3899/3838 full resident2242
calls (10170 total) match the predicted pointer and both countdown fields for
all active slots, with mapper shadows restored each time. Slots are disabled
only after the last bounded event is loaded. B21 slot2 stops at6D29; the static
8000 tail at6D29..6D2A would chain straight intoFE and is not run here.
Other slot stops coincide with the firstFE position. In these linear-body cases
noFE is executed, and
this does not establish complete-loop playback, natural IRQ timing or audio.

### First original FE edges and artificial FF fallback

The final-event snapshots retain all16 slot bytes before deactivation.
Twelve assertions check the original lastFD pointers and zero loop counters.
Forced handlers43E7/45A1/4752/48EC then execute the original FE edges from
those snapshots, including B21 slot2's zero-count tail. Saved pointers and
resulting pointer/countdown fields are checked against fixed contracts.
B21/B5B restart the measured first events; B5C restarts after an introduction.

Separate forced count1 cases place each pointer atFE; the original00 duration
chains intoFF, clearing exactly16 bytes and retaining neighboring guards.
This is artificial fallback reachability; it does not establish a natural exit
from original zero-count loops, complete repeated playback, timing or audio.
The unit adds60 assertions. The handler addresses are verified against the
published symbol map; the initial erroneous43E6 entry was rejected before
publication and corrected to43E7.

### A16 menu initialization and status callback

Four forced4AF0 prefixes check five cleared fields, C5A3=1 and VBK0 before
4B07 calls the external resource helper. Four full4B36 calls with LCD off
fill1024 cells on each VRAM plane (80 in plane0,00 in plane1), retain guards,
and return with BC0/HL9C00/VBK1. Patterns and initial VBK are varied.
Two independent4B21 tails install4B91 in HRAM callback0 and empty the other
callback/stubs, retaining unused stub operands. Two complete4B78 calls clear
all callbacks, C219/C21A through2723 and C1C2 while retaining C1C4.
Three41EA branch prefixes stop before storage/display calls, checking their
arguments for A0/1/FF. The unit adds23 assertions, without establishing complete
initialization/status execution, LCD-on safety, natural menu or prior IME
preservation. DI/EI remain the original instructions.

### Installed A16 refresh and banked background rectangle

Eight full4B91 calls cover requests0/1/80/FF and initial WRAM banks1/3.
Active refresh copies14x6 cells per plane from bank7:D000 sequentially,
then overlays81..84/00..00 at9A2F..9A32 and clearsC5A9. The inactive path
retains VRAM, C63A and VBK. Full map comparisons include outside cells and
guards; active calls restore WRAM bank but end VBK0. Four direct4391 calls
cover source banks3/7, both9800/9C00 bases, origin(3,2), dimensions4x2 and
source order across both planes. All calls use LCD off, HRAMFF80=RET and
C221=0. They do not establish DMA, pending palette upload, natural menu or
active-LCD timing. The unit adds24 assertions.

### A16 field dispatch and numeric tile bytes

256 stopped dispatches verify the doubled8-bit index, actual pointer and
pushed4BDC return, without executing unknown destinations. The eight extracted
entries are a bounded prefix, not an index-admissibility claim. Six byte fields
are checked for every0..255 value (1536 cases); two word fields use18 boundary
values each (36 cases), including25599/25600/25601/65534/65535. Eight actual
table entries reach the same pre-presentation stops with the return frame.
All handlers stop before01E9; expected bytes, zero terminator and guards are
checked. Original encoding retains10/20 markers,4E47 for values above99 and
word quotient low-byte wrap before leading-marker adjustment. The independent
model does not substitute ordinary decimal text. The unit adds1836 assertions;
no presentation call, natural field meaning or full unknown-index flow is run.

### Original fixed-width arithmetic via resident thunks

All65536 byte pairs are checked for low product, wide product and division,
including divisor0. Every DE value is checked with BCFFFF for low word product;
324 representative word pairs cover other BC values. Every word dividend is
checked for divisors0/100/255, plus126 boundary cases with1/2/10/127/128/129/254.
Products and preserved/clobbered registers are checked after complete calls.
Byte division uses mathematical quotient/remainder for nonzero divisor and
literal H=input/LFF for0. Word division uses an independent16-round model with
an8-bit intermediate remainder and low quotient byte, retaining overflow.
256/255 returns H0/L0; word divisor0 returns H=input low byte/LFF. This does
not replace the original algorithm with ordinary wide division. The unit adds
918404 assertions; complete synthetic domains do not establish natural caller
admissibility or arbitrary-divisor correctness beyond the tested contracts.


### Queued tile-text resident state machine

Four pointer inputs verify01E9 setter fields, guards and register effects.
All256 state indices stop before DispatchReturnTable jumps to the selected
pointer; doubled8-bit wrap is retained and unknown targets never execute.
States0/3 and a terminated state2 complete through01EC.2048 delay-prefix cases
cover delays0/1/2/255, input bit0 and every counter byte, stopping before2E15
or joypad polling. All256 input masks cover independent state4 tails and
state2 tails (bit0 clear returns; set stops before2D53). Three nonterminating
state2 prefixes stop before2DD0. Two independent tails verify state reset and
four-count wrap. The unit adds3221 assertions. Unknown renderers are not
stubbed or called; no full state1/4 path, natural display or input timing is
established. PROBABLE semantic names remain bounded by static callers and
these SYNTHETIC cases.


### Queued controls and four-byte display records

Every count byte exercises118F: counts below16 write E,D,C,B and increment;
16..255 preserve all64 record bytes and guards.4096 packed coordinate cases
verify the literal byte arithmetic of2DE7, not widened pixel geometry.512
cursor-wrapper calls exercise every FF8B byte with empty/full queues.
Every terminator repeat count and control2 operand completes.512 control3
cases use a null callback or the original27D5 RET as an artificial callback;
no natural callback behavior is claimed.25600 column progressions and5120
control1 calls retain prior-column comparison, zero-column return, row+2,
8-bit wrap and exact equality with twice the height.2000 ordinary-byte
prefixes stop before2F1C; FE/FF retain carry, C decrement and C1BE flag.
Control0F completes; control4 stops before2D53.256 state4 dispatcher calls
now complete with the real cursor producer; one terminating state1 path
returns at its four-count boundary.75733 assertions are added. Rendering,
queue consumption, natural input/LCD timing and actual text callbacks remain
unverified; all these forced CPU paths are SYNTHETIC, semantics PROBABLE.


### Original glyph renderer and HDMA

All65536 row/column pairs exercise2FE0 with doubled8-bit row indexing and
original words; the32-row extracted prefix does not bound admissible indices.
All65536 glyph/counter pairs stop at2F6B before tilemap helper/HDMA trigger,
checking source3F00+16*glyph, destination96B0-16*count, tile6B-count, DI,
VBK and mapper fields. HDMA3 readback is the raw written byte in this core,
not the destination mask applied when DMA starts; an initial masked-readback
expectation was rejected and corrected.36 complete LCD-on cases cover glyphs
0/15/16/127/254/255, counts0/1/106 and initialVBK0/1. Every byte of both8KiB
VRAM planes is checked, including16 actual mapped source bytes transferred
into plane1, tile/attribute map cells and untouched guards. PendingHDMA=0,
counter, saved mapper pair andVBK restoration plus finalIME are checked.
196680 assertions are added. Forced LCD-on calls are SYNTHETIC; they do not
prove natural menu/glyph meaning, physical timing or arbitrary caller
admissibility. EI is original and does not restore prior IME state.


### Original queued-text rectangle fill

56 complete LCD-off calls cover widths1/4/32/0 and heights1/2/0/128, two
tile-selection values and initialVBK0/1. Combinations of zero width with
256 rows are excluded because they would extend beyond VRAM. Zero width
executes256 columns; doubled byte height0 executes256 rows. The32x256 case
exceeded the default100000-step call cap; this group uses an explicit finite
2000000-step cap, leaving the other calls at their default.36 further cases
use direct0201, control4 through020D and state2 through01EC, with LCD-off/on,
C1AA0/1/FF and bothVBKs. Every byte of both8KiB planes, overlaps, guards,
restoredVBK, fields and caller transitions is checked.184 assertions are
added. The tests preserve decrement wrap and exact stride rather than
normalizing zero dimensions. These are SYNTHETIC forced inputs, not natural
screen geometry, IRQ or physical timing evidence; semantics remain PROBABLE.


### Display queue to160-byte shadow

544 direct-record cases cover counts0..16,16 patterns and A/B table-address
branches.512 expanded-object cases cover every count byte and two position
patterns; both pointer levels and objects reside in synthetic WRAM. Output
is checked byte-for-byte, including zero tail, guard, field order, raw offset
wrap,40-entry truncation and actual restored mapper-window bytes. Calls use
resident0261; an initial wrong thunk was rejected by the byte checks.
One artificial expanded40-then-directFF prefix stops at122A with capacity0
andSPCFF8 before any mismatched pops: the no-space branch skips the popAF
performed on the successful direct path. The probe does not execute the
corrupted return or claim natural reachability. Large expanded objects alone
complete normally with40 emitted entries.2113 assertions are added. These
SYNTHETIC cases establish shadow bytes only, not actual OAM DMA, sprites,
real object-table bounds or natural menu behavior; semantics stay PROBABLE.


### Original A0F display table and objects

Four0258 setter calls verify pointer bytes, guards and preserved registers.
The original409C setup prefix stops at40B2 before callback installation,
checking mapper fields and5288 pointer setup. Three mapped-data checks verify
5288->529E and variants0/1->52A2/52C3 with8/10 pieces. Both original objects
are expanded for every65536 X/Y pair. Every shadow byte, zero tail, guard,
remaining capacity and restoredA window is checked.262156 assertions are
added. Data is original mapped ROM; indices and positions are forced. No
natural sprite identity, full table extent, menu setup or OAM DMA is claimed.
Physical bank07 upper8KiB maps at A0F4000; source pointer expressions retain
physical label minus2000. Confidence remains PROBABLE.
