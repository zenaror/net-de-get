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


### A0F variant and position producer chain

Every65536 C766/C767 pair executes4306 variant selection,438A position and
queue production, then0261 expansion of original ROM objects. The model
retains both sequential byte comparisons/increments,3/4 RLCA and wrapping
10/50 additions. Variant0 is selected only for C767<4. The queue uses table
index0 and selected variant, then the exact160-byte shadow, guard, capacity
and restored mapper fields are checked. Counts0/15/16/255 verify that a full
queue rejects the record while position fields still update.393225 assertions
are added. This forced original-component chain does not establish natural
menu geometry, OAM DMA or screen identity. Relative JR targets use physical
labels; the linker rejected subtracting2000 from relative targets before the
final byte-identical build. Semantics remain PROBABLE.


### A0F setup, terminated-list count and callback cleanup

512 original409C prefixes cover everyC765 byte and initialVBK0/1 with WRAM
banks3/7, stopping at4134. They check19 initialized fields, guards, table,
callbacks/stubs, effectiveWRAM1/VBK0 and IME after EI. Four complete4141
calls clear callbacks and RETI stubs while preserving operand bytes.
44AE was measured as a C74E zero-terminated list counter, not a rendering
resource call.68 complete counter calls cover lengths0..16 and bytes1/FD/FE/FF;
C76C counts entries, C76D counts FE/FF, retaining8-bit counters.96 complete
409C setup calls cover four modes, three lengths, four byte classes and two
prior B windows. All12 fields loaded from original B5A6000 header, HL600C,
mode/count fields and actual restored-window bytes are checked.848 assertions
are added. Lists are bounded synthetic WRAM and the header is original ROM;
no natural menu, installed callback, IRQ or audio stream runs. No universal
list bound/unterminated behavior is claimed. Semantics remain PROBABLE.


### A0F complete graphics and tilemap initialization

512 LCD-off calls cover every C765 byte and initial VBK0/1; eight LCD-on
calls cover modes0/1/80/FF and both initial planes. Each call has a finite
2000000-step bound. All8192 bytes of both VRAM planes are checked: original
1600 graphics bytes go to8800..8E3F in the incoming plane, selected20x2
map/attributes go to9800 with stride32, and the same two-byte cell repeats
120 times at983C..98B3. Every other byte remainsA5. Final VBK0, preserved
mode and A120 are checked. The original raw cells are88/00 orE0/07.
1040 assertions are added. These are SYNTHETIC forced calls using original
ROM resources, not natural screen, palette, OAM DMA or physical timing
proof. Resource boundaries come from measured consumers; gaps and wider
objects remain uninterpreted. Semantics stay PROBABLE.


## A0F original selection adjustment

Complete forced calls to 431A and 433F cover all 65536 row/column byte
pairs per routine. 431A preserves AF and snaps C766 to 1/6/11 for incoming
A >= 4, with thresholds 5 and 10; lower rows retain the original column.
433F reads C767 and, for rows >= 4, remaps only 0/7 to11, 2/10 to6,
and 5/12 to1. All other columns remain unchanged. Guards are checked;
the first routine covers all16 valid flag patterns. 131072 complete calls
add262144 assertions. These are SYNTHETIC byte domains, not evidence of
natural menu input bounds. Original bytes are preserved; semantics stay
PROBABLE. The resources referenced by C773/C774 remain separately bounded
by their resident consumers, not by these selection routines.


## Resident color component conversion

08FB expands packed words to three 16-bit components multiplied by2048;
0925 emits (31-component)*64. Both ignore input bit15 and use a trailing
C decrement, so C0 processes256 colors. Complete calls cover all65536
words per expander and all256 count bytes with patterned inputs. Output
bytes, source/destination advancement, finalC and guards are checked.
096F forces64 colors and packs the three high bytes with literal rotations
and masks, skipping low bytes; 256 patterned384-byte sources cover every
high-byte value at each position. Arbitrary high bytes are not clamped.
131840 calls add263680 assertions. All inputs are SYNTHETIC WRAM; this does
not prove natural palettes, visible colors or timing. Semantics remain
PROBABLE. Original64-color preparation at07E7/0805 is statically separate:
its128-byte read starting4E20 overlaps the extracted tilemap at4E68..4E9F.
The overlap is retained, with no claim of an independent resource object.


## Color transition preparation, scaling and ticks

07E7 initializes192 accumulator words toF800 and C21F;0805 initializes
from64 original packed colors and C220. Both derive deltas and call088D.
Parameter2 retains words and returns32;0/1 shift right2/1;other byte values
shift left parameter-2 with16-bit wrap. Return counts are read from actual
ROM addresses, including code beyond the nine-byte count prefix for high
parameters. Such reads are tested, not declared natural valid parameters.
256 scaler cases and1024 complete preparations cover every parameter and
both original A0F resources4E20/52EC. Finite1000000-step caps are used.
0830 gives C220 addition priority, otherwise C21F subtraction; active
paths decrement only their counter, update192 words with carry/borrow
and wrap, pack64 colors and set C221=1. Bothzero leaves buffers/flag intact.
768 complete ticks cover all counter bytes and conflicts. Four original
resource chains run mode4 preparation and all eight ticks, checking all
accumulators/deltas/packed colors at every step.2116 calls add4232 asserts. Each of the32 chain ticks also calls the original
018C upload with LCDoff and checks all64 BG and64 OBJ bytes, clearedflag
and preserved AF/BC/HL.
This is SYNTHETIC execution, not natural menu/VBlank/LCD-on upload or
hardware proof. The4E20..4E9F overlap with tilemap remains intact.


## A0F input dispatch and bounded action prefixes

41C5 gating covers every65536 busy/state pair and all256 add-counter bytes
in state63. Active input is blocked by C1B8; state63 clears only withC220=0.
73728 complete direction calls cover all16 masks, each byte axis and nine
boundary values on the other axis. Original upper-stream requests use a
synthetic pointer table and empty channel record; no code is substituted
and no natural sound is claimed. Full queue guards and position fields
are checked. The literal right/left/down/up order and asymmetric row snap
are modeled, including byte wrap outside normal input bounds.
6912 bounded button prefixes cover all256 bytes, nine positions and three
terminated lists. They stop before451F/43F0/455D/47AA or return normally.
Destination/SP, precedence, column choice, state, variant and countdown
are checked; these stops do not prove the callee return or natural menu.
139520 complete calls and6912 prefixes add292864 assertions. Semantics
remain PROBABLE; no safety of unterminated lists is asserted.


## A0F action helper contracts

43BF selector complete calls cover all65536 mode/input pairs, exact four
pointer choices and fallback, without resource extent claims.3072 trim
prefixes at451F cover every counter byte, four preceding-byte classes and
three auxiliary counts, comparing258 memory bytes to a mutation model.
Counter aliasing is retained; count1 reads the preceding guardC74D, so
artificial FE/FF guards can produce byte underflow. Nonzero cases stop
before45A0 redraw.128 dispatcher calls with button02 and zero count return
completely through the original empty upper-stream fixture and position
producer. This does not prove nonempty-list redraw or natural counters.
4628 complete row drawing covers512LCDoff and8LCDon cases, both initial
VBKs and all256 byte values at each tile/attribute input position via
patterned seeds. All8192 bytes in each VRAM plane are checked: inputpair
at9A02,8E/8F at9A08,90/91 at9A0E with unchanged C777/C778 attributes.
FinalVBK0 and C775/C776=90/91 are checked.138512 assertions are added.
Semantics stay PROBABLE; no natural screen/IRQ/hardware timing proof.


## Indexed text setup, preparation and blocking consumer

2753 computes DE+8*A and reads five fields of the eight-byte record.
Coordinates are stored with byte increments1/2; width, zero-height fallback
C, kind, lookup/base address, returned HL/DE/A/BC and kind-derived flags
are checked.65536 coordinate pairs use all byte indices and bases9800/FFF0;
256 explicitzero-height cases cover every fallbackC.48 calls check the
four original A0F records5268..5287. Trailing three bytes remain literal,
with no larger table extent asserted.
2799 delegates configuration, then kindzero fills via2D53, while nonzero
kind calls2BFE.64 complete kindzero preparations check both full VRAM
planes with LCDoff/on;16 other-kind prefixes stop before2BFE. An initial
fixture column origin was rejected: fill uses C1A4 directly and C1A7-1.
Expected origin was corrected without changing original ROM bytes.
28BE loops2E15 untilstate3, then clearsstate.256 zero-control cases cover
all repeat counters;256 composite streams2,1,3,A5,1,0F,0 use a null callback
and test repeat-byte wrap, newline and control0F without input waiting.
72 complete original-record/glyph/terminator chains with LCDon check all
8192 bytes perplane, original16-byte HDMA font transfer, state/pointer,
glyph counters and actual restored A-window bytes. Glyphs16/127/253 and
counts0/1/106 remain forced inputs.66560 complete calls and16 prefixes
add133080 assertions. No natural menu, physical timing, arbitrary-stream
termination or nonnull-callback behavior is claimed. Semantics stay
PROBABLE; original Japanese bytes are preserved.


## Queued text frame and full nonzero-kind preparation

The 2BFE..2D45 frame body selects tile base6C for kind1,75 otherwise.
It fills all cells, not just the perimeter: top/middle/bottom rows use
three consecutive tile variants each. Every cell writes plane0 tile and
plane1 C1A3 attribute with original STAT waits and DI/EI. Initial VBK is
restored; incoming IME is not preserved. Width0 means256 interior cells;
doubled height wraps as a byte and zero means256 middle rows. No clipping.
An independent sequential row/cell model accounts for wide-row overlaps.
1024 complete calls cover all256 kinds, bothVBKs and LCDoff/on.512 calls
cover all256 widths with height1 and LCDoff.64 complete calls start at
original preparation thunk1E6 using ROM records0/3, bothVBKs, LCDoff/on,
four attributes and two fallbacks. Check entire8192 bytes perplane,
AF/BC/DE/HL and unchanged guards/state/cursor fields.
Eight height0/128 prefixes with widths1/29 and bothVBKs stop at2C79,
HL=A000,C=1,SP=CFFC before the last middle row leaves VRAM. Verify the
top plus255 middle rows and saved-VBK stack boundary. Do not execute
outside-VRAM accesses or claim complete return for these extreme cases.
1600 full calls plus8 prefixes add3216 assertions. All inputs remain
SYNTHETIC; semantics PROBABLE, with no natural geometry/menu/IRQ or
physical timing claim.


## A0F redraw count predicate and marked row

4496..44AD returns A=1 iff bytewrapped(C76C-C76D)<C76F, else0. B is
the difference,C the capacity; flags remain from CP.65536 count/marker
pairs with capacity=markers also exhaust all difference/capacity pairs,
not all independent three-field combinations. Verify AF/BC, preserved
DE/HL and unchanged WRAM fields.
474C..47A9 clears cursor/delay, computes9800+32*byte(C1A7-1)+C1A4+C770
in16bits using original resident0231 multiplication, and writes C771
cells (zero256) as plane0 tile88 / plane1 attribute07. Restore VBK with
original STAT waits/DI/EI; no clipping or preservation of initial IME.
65536 coordinate prefixes use derived offset/count bytes and stop4788
before the first write, including non-VRAM destinations. Verify HL,
BC/DE, saved AF on stack, cleared fields and full VRAM unchanged after
the group.1024 complete calls exhaust counts, bothVBKs and LCDoff/on
within VRAM; check AF/BC/DE/HL, guards and entire8192 bytes perplane.
66560 complete calls plus65536 prefixes add264193 assertions. All are
SYNTHETIC, interpretation PROBABLE. Natural geometry/count admissibility,
menu appearance, hardware timing and caller45A0 remain open.


## Complete A0F list redraw and nonempty trim/action chains

45A0..4627 forces glyph counter 70, configures record 1/2 by mode bit 0,
renders C74E through the original blocking consumer, resets the counter,
and uses wrapped nonmarker count to place original pairs 89/00 and 8A/00.
The first cell is at 9882+count+C76E. The previous text row receives one
88/07 cell via C770=count,C771=1; following cells extend to capacity.
No metadata/stream consistency check or wider resource extent is asserted.
512 empty-stream calls cover all modes and both VBKs with LCD off, using
derived count/capacity/offset bytes. 216 LCD-on calls cover modes 0/1/2/255,
both VBKs, lengths 0/1/8, three metadata classes and offsets 0/2/4.
Sixteen FE/FF -> glyph16 -> terminator chains check original font payloads
and the marker glyph one row above without advancing the column. Sixteen
complete nonempty trim/dispatcher calls remove the last glyph and redraw.
The independent memory model applies font transfers, glyph map writes and
decorations in order, including overwritten cells. Check all 8192 bytes
of both planes, fields/state/pointer/VBK and real A-window restoration/HDMA.
760 complete calls add 1520 assertions. Null callbacks, bounded streams
and chosen VRAM geometry remain SYNTHETIC; semantics PROBABLE. Natural
menu, arbitrary streams, metadata admissibility and physical timing remain open.


## Original resource grid and mode cycle

468B..474B configures record0, marks offsets30/70 or10/50 by input<2,
copies a20x1 two-plane footer by global mode zero/nonzero, then renders
a4x3 grid at columns0/6/12 and rows0/2/4/6. Resource selection uses global
bit0; footer/fallback conditions use global zero/nonzero. Footer forces
VBK0. Original glyph streams and Japanese bytes remain unmodified.
455D..459F increments C76A as a byte and resets only result4 to0, then
draws the grid and indicator. High inputs are not normalized modulo4.
The first oracle failed case10: it assumed three fallback text repeats.
D is saved once per row but glyph rendering clobbers D within a row. The
first fallback returns D=1 here, so subsequent columns continue at5464
and5465 empty terminators; final pointer5466. The corrected oracle follows
D and stream pointer, and explicit source includes those reached bytes.
No original byte changed and no natural defect is asserted.
32 full grid calls cover inputs0/1/2/255 and global0/1/2/255 with bothVBKs.
1024 full mode cycles cover every old mode byte, global0/1 and bothVBKs.
16 dispatcher chains execute the complete cycle. All have LCD on, null
callbacks, real font payloads and unchanged mapper window after HDMA.
The memory model applies marker glyphs, cursor advances/wrap, font uploads,
footer, marked cells and indicator writes in original order. Verify both
entire8192-byte planes, state/pointers/counters/VBK and guards.
1072 complete calls add2144 assertions. Semantics remain PROBABLE and
SYNTHETIC, without natural menu, palette visibility, audio or hardware timing.


## Original selected list insertion and marker compatibility

43F0..4495 chooses a glyph by mode and byte coordinate remap/rotations,
with glyph10 for nonzero global/odd mode/row>=3. Target is C74E+C76C.
Plain glyphs require wrapped nonmarker count below capacity. FE/FF read
target-2 and reject an existing marker; otherwise classify target-1 with
offset0 then40. On acceptance, move the previous glyph, insert marker,
increment marker count, append zero and redraw with incremented total.
44D7..451E compares C against B+85/96/8A/9A/9F/A4 byte thresholds. E=FF
uses the final interval only; other E values use earlier branches too.
Independent oracle checks final A/flags/D and preserved BC/E/HL.
131072 B/C pairs with E0/FF cover both branches;4096 additional cases
cover all E bytes with four B offsets and four C values.65536 coordinate
prefixes use derived mode/count and global0/1, stopping444B before mutation.
Check actual mapped source byte (high domains can read beyond measured
resources), destination saved on stack, fields and whole VRAM unchanged.
3840 full insertion/redraw calls cover modes0..3, global0/1/2/255,15x4
coordinates,two capacities,bothVBKs;16 dispatcher chains also return.
Model post-list, capacity/marker acceptance and rejection, original font
payloads/HDMA, cursor/state/counters, mapper restoration and both8192-byte
VRAM planes in write order. Sixteen complete early-rejection calls cover existing FE/FF at target-2,
both selected markers, bothVBKs and LCDoff/on with unchanged wholeVRAM.
Four artificial length0/1 FE/FF prefixes stop
445D before the backward read at C74C/C74D; no further execution/natural
defect claim.139040 full calls and65540 prefixes add409161 assertions.
SYNTHETIC/PROBABLE only: no natural menu, universal metadata/stream domains
or hardware timing. Japanese bytes and published symbols are preserved.


## A0F callbacks, frame wait and palette fade

PROBABLE/SYNTHETIC: 4096 complete no-op callbacks (all A bytes and 16 flags),
one original 09EB HRAM DMA installer and 512 complete OAM/palette callbacks
(all dirty bytes, both VBKs, LCD off). Check the actual ten installed bytes,
C000..C09F to OAM, raw BG/OBJ palette readback, AF/BC/DE/HL, guards and both
8192-byte VRAM planes. The rejected bit-15 masking oracle was corrected to
raw readback; no hardware color visibility is asserted.

256 complete frame waits cover all initial FF8A bytes. A timing event scheduled
before HALT observes the halted CPU and injects IE/IF with IME false. Flag zero
continues spinning until explicitly supplied with 1. Injection after an unposted
HALT blocked the host stepping call in the core event loop; scheduling a producer
fixes the fixture contract without changing the core or original bytes.

1024 complete fades cover original pointers 4E20/52EC, all CF86 bytes and both
VBKs. Check each original wait, eight transition ticks, 192 accumulators/deltas,
64 final 7FFF colors, guards and unchanged hardware palette/whole VRAM. Nonzero
CF86 is held for two extra waits, then explicitly released. No natural audio,
IRQ handler or frame producer executes. Reading 128 bytes at 4E20 crosses 4E68;
this is not a claim about an independent palette object's extent. The 5888
semantic calls plus DMA installer add 20987 assertions, total 3702286.


## Complete A0F display entry and input exit

32 complete original4000 calls cover modes0/1/2/255, both initialVBKs,
choice0 with empty/one-glyph lists, choice1 with one glyph, and choice1 rejection
on an empty list followed by release/repress and choice0. One original09EB
DMA installer also runs. The core setKeys API supplies A; original polling
generates edges. No forced FF97 flag substitutes for polling.

Check original font source selected before empty-list mode3 mutation, the exact
448-byte consecutive font copy on plane1, indexed record order0,1+modebit0,
optional3, setup/grid/redraw/indicator state, preserved list, stack/return,
cleared callbacks, loop counter, actual restored A/B mappings and completed HDMA.
LCD is active for original STAT/HDMA waits; the font snapshot explicitly stops
and restarts LCD. LCD-off initially stopped at2F9E; this was a fixture
precondition failure. Source bytes are unchanged.

Scheduled fixture wakes observe HALT with IME false; CF86 is held at2 during
eight addition ticks and explicitly released. Return addresses47C2/409A separate
fade waits from main-loop waits: state63 receives one extra main wait before
the next iteration clears it. The rejected-choice family also samples an actual
A release for one loop before repressing. Addition leaves the startup subtraction
counter pending; the final main-loop tick subtracts once. Check all192 accumulator
and delta words,64 packed output colors, subtraction count6 or4,dirty1 and128
unchanged hardware palette bytes. No original IRQ uploader/frame producer/audio
progress or natural menu timing is asserted. Reading448 bytes at50E0 crosses
published text/object records and does not establish an exclusive font extent.
These33 complete calls add789 assertions,total3703075; PROBABLE/SYNTHETIC only.


## Resident joypad polling and repeat

PROBABLE/SYNTHETIC: original261C counter increment falls through2620 polling;
resident0279/027C now name these routines. Preserve all repeated JOYP reads.
FF97=(previous XORsample)&sample; FF96=sample; deselect JOYP. Repeat compares
sample&F3 againstFF99, excluding Select/Start. Change resetsFF9A and outputs
edge/marker1; equality increments counter masked9F,zero->80. Counter bit7
with low two bits zero outputs edge|masked state/marker0; otherwise edge/marker1.
No physical frame duration is inferred from a call-count repeat mechanism.

Run with core allowOpposingDirections false and true, then restore its old value.
The independent model suppresses opposite direction pairs only with false;
this is the core fixture policy, not physical-controller evidence. For each
policy,65536 key/previous pairs cover edges with a changed repeat state,
65536 key/previous-repeat pairs cover comparison flags with other fields derived,
and65536 key/counter pairs cover matched-repeat counters. These are separate
parameter domains, not the full product of all independent state fields.
256 calls per policy exhaust prior frame-counter bytes.256 traces per policy
run96 original polls with48 held,16 released,32 A-inverted samples and independently
chained expected state. Check AF/BC/DE/HL,HRAM state,edges,repeat,marker,wraps,
guards and JOYP deselection. Both8192-byte VRAM planes remain A5 at group end.
442880 complete calls add885761 assertions,total4588836. No natural IRQ/menu,
hardware debounce or physical timing claim.


## Resident selector and text/font configuration

PROBABLE/SYNTHETIC:4096 selector calls cover all256 indices and16 input flags.
Index<0x10 reads the published native8KiB selector table, otherwise returns
D08/Eindex-0x10. No mapper selection or admissibility validation is performed;
native index0F remainsFF.196608 setter calls cover all65536 DE words for each
C1C0/C219/C1AB field, adjacent guards, preserved AF/BC/DE and final HL=field+1.
AF seeds are derived from the word, not every independent-register product.
C1C0 is read as a control3 callback by the published consumer; C219 remains
named by address because its semantic role is not established here.

2048 complete plane initializations cover all256 raw A bytes, both prior VBKs,
LCDoff/on and actual A-window0F/16. C21C deliberately names the other window:
the original simple32-byte4EE0->97E0 copy uses current mapping. Raw A nonzero
adds attr bit3, while VBK uses only bit0. Check six reset bytes, origin9800,
five attr fields,C1AF,guards,AF/BC/DE/HL,real mapped bytes and whole bothVRAMplanes.
3072 complete font loads cover all256 raw plane bytes,both priorVBKs,LCDoff/on,
original A0F sources4F60/50E0 and B5A source6800. Independently capture448 source
bytes, then restore different prior A16/B05 mappings/mirrors before execution.
The original banked copy uses C21C/C21D and restores both mappings; compare
288 bytes at96C0 and160 at8760 with every other byte of both8192-byte planes.
Check registers,fields/guards,copy completion and actual
restored A/B bytes. Copy DI/EI leaves IME enabled; no prior-IME restoration claim.

205824 complete calls add411648 assertions,total5000484 plus24 verifier tests.
No flash-font domain,exclusive resource extent,natural callbacks/menus,Japanese
interpretation,visible colors or physical timing proof. Original bytes preserved.

## Resident CGB speed switches ($25CB–$2612)

PROBABLE contracts from original KEY1/STOP flow and synthetic full CPU calls.
The $0270/$0273 thunks now name SwitchToDoubleSpeed/SwitchToNormalSpeed.
16384 tested calls cover both initial modes, both target modes, all 256 IE
bytes and all 16 upper-nibble flags. Initial speed is established by the
original helper itself, never by mutating the core speed field. Another
16385 setup/cleanup calls execute that same original code.

The transition path prepares KEY1, saves IE, masks IE, deselects JOYP, executes
STOP and polls bit7, clears JOYP/IF, then restores saved AF/IE. Early return
leaves IE/IF/JOYP untouched. Tests check bounded return, SP, actual speed and
CPU multiplier, KEY1 readback, IE/IF/JOYP, AF/BC/DE/HL, a WRAM guard and IME.
A after transition equals saved IE; early return A is KEY1 readback. Flags
come from the initial BIT7 (carry preserved), including the saved flags after
transition. LCD/timer/serial are disabled and IME false for these synthetic
calls; no pending-interrupt race or physical STOP timing is asserted.

49153 new assertions give total5049637, plus24 verifier tests. Existing core
GBStop toggles speed when KEY1 prepare bit is set; that core behavior is
emulator evidence, not hardware proof. No natural caller trace is added.

## Flash callback dispatcher ($24B9–$254D)

PROBABLE flow contracts, not natural callback behavior. Synthetic RET bytes
are temporarily placed directly in disposable in-memory flash backing; no
flash programming command, original-ROM edit or disk save is involved.
The whole backing including extra metadata is compared after byte restoration.

65536 complete calls cover targets4100/5FFF/6000/6100, all128 valid 8KiB
flash selectors, allfour prior A/B ROM/flash type combinations, software bit0
clear with reads initially off or bit0 set with reads already on, and all16
input flag nibbles. Prior selectors are fixed distinct A16/B0F for ROM and
A03/B05 for flash; no exhaustive prior-selector claim.

Stop at actual mapped target to check RET byte, pushed return address, SP,
AF/BC/DE/HL, shared C66D/C66E scratch and adjacent guards, HRAM/mirror fields
and enabled reads. Resume the target RET through the entire original restore
tail, checking final registers, IME true, actual restored bytes of both
windows and disabled flash reads/write enable/operation. The B path copies
saved B values into A HRAM mirrors but leaves physical A and its WRAM mirrors
unchanged. Preserve this original asymmetry; do not treat HRAM as physical
mapping evidence. Restored prior flash windows read FF after reads are disabled.
The scratch is shared with minigame dispatch, not a nesting stack.

Two negative prerequisite prefixes set bit0 while reads are off: the helper
skips enabling reads and target readback is FF. Stop before target execution;
a separate forced cleanup call is not completion of that callback. No safety
for arbitrary target addresses, callbacks that overwrite scratch, IRQ races,
natural downloaded code or physical flash execution is established.

131078 new assertions give total5180715 plus24 verifier tests. The first
probe exposed an incorrect independent CP half-borrow expectation at H=5F;
the oracle was corrected to flags50 (low nibble F minus0 has no half-borrow),
without changing any original byte. Full calls and negative prefixes were
then rerun from the final source.

## Selection field initializer ($28E3–$2944)

PROBABLE field/flow contract from static consumers in adjacent joypad code
and complete synthetic calls. Fields remain named by address. HL is stored
atC20A/B; B/C/D/E are stored atC20D..C210. C212/C213/C214/C21B become0;
C215/C216 becomeFF. C20C/C218/C219/C21A and adjacent guards are preserved.

Independent model: divideByte(x,0) gives quotient255/remainderx, otherwise
ordinary unsigned quotient/remainder. Let (q1,r1)=divideByte(D,E) and
(q2,r2)=divideByte(q1,C). C217=(q2+(r2!=0)) modulo256.
C211=C when r2=0, otherwise (r2+(r1!=0)) modulo256. The conditional third
division recomputes r1. Do not replace this formula with a general ceiling
formula: original arithmetic performs truncation in the stated order.
Final AF=FF80, B=0, C=E if r2!=0 else originalC, DE=(q1,E), HL=C217.
The original pointer is stored, not dereferenced by this initializer.

987136 complete calls: all65536 D/E pairs for each of seven C values
{0,1,2,3,7,16,255}; all65536 C/D pairs for each of seven E values from the same
set; all65536 HL pointers with fixedB=37/C=4/D=43/E=3; all256 B bytes and
all16 flags with those fixed arithmetic inputs. Arithmetic-axis flags are
derived from inputs, not independently exhaustive. This is two exhaustive
byte axes with boundary divisors, not the entire C/D/E Cartesian product.
Each call checks bounded return, all19 field/guard bytes plusC209, and full
final AF/BC/DE/HL. No natural validity for zero divisors, pointer contents,
visible menu size or drawing/activation call at2945 is asserted.

2961408 new assertions give total8142123 plus24 verifier tests. Residual
28E3 alias stays at28E3; remaining2945..2BFD retains literal Japanese bytes.

## Selection activation and drawing ($2945–$294D, $30BC–$3189)

PROBABLE original draw flow with bounded synthetic text. DrawSelectionText
preserves AF/BC/DE/HL, fills the region, computes an 8-bit entry skip from
C212*C20E*C210, scans zero-terminated records, then renders with the existing
blocking text helper. A record whose byte before zero is02 continues the
skip scan. ActivateSelectionText setsC213=1 and calls the same drawing body;
its final A is1 and incoming flags/BC/DE/HL survive.

1512 empty-record calls cover rows1..3, columns1..3, pages0..2, limit bytes
{0,1,2,3,5,9,16}, both priorVBKs, direct/activation entry and flags10/F0.
Independent bounded model uses first limit test (page+1)*relativeRow, then
entry index page*rows*columns+relativeRow*columns+column. Limit+1 and limit-1
are byte wrapped. This model covers small nonzero dimensions; it is not an
oracle for all dimension/overflow combinations. Normal completion restores
C1BD=0; an early abort leaves the remaining row count. This is original
asymmetric cleanup, not a repaired behavior. Check registers, text pointer,
cursor/activation/counters, guarded corpus and both whole8192-byte VRAMplanes.
The only writes for empty text are the exact two-plane fill rectangle.

24 LCD-on calls add actual glyphs16/127/253, both coupled C1AF/priorVBK values
0/1, direct/activation entry, and plain versus skipped02,00 continuation
corpus. Capture actual16-byte font sources under selector2, then restore
priorA0F. Check final fields/registers, mapper mirrors and whole bothVRAMplanes:
font16 bytes at96B0 in plane1, tile6B at9841, attr23 and other fill/guard bytes.
The original renderer leaves VBK1 after attribute writes before starting
HDMA; font upload is therefore in plane1 in both tested C1AF cases. No font
plane was forced by the fixture and no timing stage was bypassed.

First probes caught two incorrect oracle assumptions: the first row test
uses (page+1)*relativeRow, not (page*rows+2*relativeRow)/2; glyph upload stays
in plane1, not the C1AF plane. Completed HDMA source4010/dest96C0/remaining0
was observed before correcting the latter expectation. Original bytes were
unchanged; both full planes remain compared.

1536 complete calls add4608 assertions,total8146731 plus24 verifier tests.
No arbitrary terminated corpus, zero dimensions, high page/overflow domain,
unterminated scan safety, natural menu, Japanese interpretation or hardware
execution/timing proof. Remaining selection input294E..2BFD stays literal.

## Selection input, cursor modes and notification ($294E–$2BFD)

PROBABLE original controller contracts. Direction priority in FF98 is
40 >80 >20 >10; FF97 bit0 confirms only if no direction branch was taken.
Vertical movement may redraw via the original DrawSelectionText; horizontal
movement wraps columns. Confirmation stores the byte-wrapped combined index
in C214 and clears C213. C215 caches the incoming page before movement.

297984 complete traced calls:98304 calls over eight bounded row/page/column
states, both modes0/2,all256 FF98 bytes,edge0/1,four frames and capacities0/15/16;
3072 calls cover all256 frame bytes at two states,both modes,three capacities;
131072 calls cover the entire FF98/FF97 byte product at one fixed state and
both modes;65536 confirmations cover all page/row pairs with rows7,columns13,
column=(page+row)mod256 and mode derived from page. No full state Cartesian
product or natural validity for high confirmation fields is asserted.

The independent model compares page/row/column,activation,page/row caches,
redraw count, actual sound request A at024F, callback calls/counter, mapped
window bytes and guards. Original sound request and native A1E installer
execute against a disposable zero-channel WRAM header: no audible stream
or real SFX claim. Original redraw and synthetic callback body execute in
full; no core state forcing or instruction skip replaces these calls.

Compare all64 descriptor bytes, prefix/unused bytes and queue saturation.
Mode0 emits paired cursors; mode2 emits one cursor with original frame jitter.
Common page indicators blink on bit4; their early return can defer the C216
update and callback until a later frame. Check all four jitter phases and
cursor/page tile animations across full frame byte domain. Geometry remains
fixed in this matrix; field/queue checks do not claim a new full VRAM domain.

8192 inactive calls cover all256 initial A values,16flags,two key presets,
with mode derived from A among0/1/2/255. The inactive guard returnsAF0080,
preservesBC/DE/HL and leaves guarded fields unchanged. Another256 mode prefixes
execute the real return-table dispatcher, stopping at0600 before jpHL. Index(mode*2) wraps as a byte with no range guard;
mode1 and129 read literal0000, not a no-op. ADD HL,DE replaces H/C while
retaining Z from doubling A. This tests selection of raw targets, not safety
or admissibility of arbitrary modes/callback targets.

306176 complete calls plus256 prefixes add910848 assertions,total9057579,
plus24 verifier tests. Initial equivalence caught using the sound body symbol
instead of the original024F thunk; the call now names ResidentJump024F and
retains original bytes. A raw-mode oracle was corrected for ADD HL flags. A process fault was traced to source/runtime ABI drift: current source
3bae8be adds an mCore function pointer absent from loaded431041 runtime.
The runner now compares tracked include headers with the runtime Git commit
before compiling and reports exit status/artifacts on failure. Tests use a
private source checkout at431041; documentation-only source changes remain
allowed when headers match. Raw-mode prefixes stop before jpHL so invalid
mode targets are not executed; valid modes0/2 run in full elsewhere.
No original ROM modification, real saves, Japanese translation, natural IRQ,
audible SFX, hardware or universal parameter validity is established.

To reproduce the431041 ABI source without changing another chat's checkout:

```sh
git clone --shared --no-checkout /path/to/mgba /tmp/netdeget-mgba-source-431041ac6
git -C /tmp/netdeget-mgba-source-431041ac6 checkout --detach 431041ac6
# Pass this checkout as MGBA_SOURCE with the matching431041 build.
```

A changed tracked include tree is rejected before compiling/executing the
probe. This is an ABI provenance gate, not a verdict on the newer mGBA build.


## A12 selection caller, dispatcher, frame wait and SYS0 cleanup

PROBABLE, original flow plus forced-entry CPU evidence. Physical09 lower half
is MBC6 A12. Source4000-4156 separates entry, initialization, cleanup,
dispatcher, three-word table and no-op RET; original ResidualROM09_4000 stays.
The entry actually calls initialization;32768 prefixes cover256 fill patterns,
8 initial SVBK values and16 flags, stopping before404C SYS0 load. They compare
all64 cleared C5A3-C5E2 bytes (C5C3 subsequently FF), guards, C218=2,
WRAM2, pushed4003 return and AF/BC/DE/HL. Later initialization resources and
callback installation are static flow only, not a complete initialization trace.

4096 dispatcher prefixes cover every state/flag pair, stopping before414E
JP HL. Independent target reads use4150+((state*2)&255); stack contains414F
and original C100 return. States0/128 execute the real4156 no-op and both
RET instructions in32 cases; other raw targets are never executed here.

4096 frame-wait tails execute real HALT with a scheduled fixture wake that
does not setFF8A. Four complete zero-flag polling iterations remain waiting;
explicit fixture FF8A=80 then releases the original loop. State0 reaches402D
cleanup prefix; every other state reaches4003. Registers/stack and guards are
checked. No natural IRQ producer or ISR execution is inferred from this event.

4096 full exit/cleanup calls execute402D->4121, actual SYS0 storage wrapper,
50-byte store/checksum/close and callback/stub clearing. A disposable in-memory
existing SYS0 record covers256 payload patterns times16 flags. Exact payload,
checksum, adjacent guard, both restored mapper windows, SRAM disable, zero
callback pointers and RETI opcodes are checked; empty-stub operands retain their
prior values. No disk save is loaded/written, no flash programming occurs.
The first wait/cleanup AF oracle omitted H set by AND A; corrected without
changing ROM code.135200 additional assertions; total9192779, plus24 verifier tests. Complete
initialization, handlers4157/421D and callback4239 are still untested as a whole;
natural menu/audio/IRQ, Japanese interpretation and hardware remain unproved.


## A12 variant dispatch, idle exit and DMA/palette callbacks

PROBABLE: original flow plus synthetic execution. The new source extracts
4157–4250 (250 bytes), preserving ResidualROM09_4157. The four-word table is
separate from code. Raw variant dispatch doubles C5A8 as a byte and pushes
416C as return; no range guard. Four measured targets use text selectors
61/63/65/66 and C21D=0 before calling numerical callee5051. Later callees
remain static; their complete execution is not established here.

4096 prefixes cover all variant bytes and 16 flags, stopping before JP HL.
16384 prefixes traverse both original dispatchers, the four variants, all
prior C21D bytes and 16 flags. They stop at the actual5051 call target and
check selectors/guards and three nested return addresses. 262144 forced tails
after preceding calls cover every counter/option byte pair in all four variants:
variants0–2 increment C5E5 by1 for option0, otherwise4; variant3 always adds1.
They stop before the next call and compare wrap, independent INC/AND flags,
registers and guards. Initial flags derive from option; no full flags Cartesian
product is claimed for these tails.

1048576 complete idle-gate calls cover all C220/CF86 bytes and 16 incoming
flags; only a zero OR clears C5A3. 8192 complete no-op/window callback calls
cover every incoming AF:422F returns unchanged,4230 sets WX=A7/WY=0.
2560 full4239 callback calls use actual installed HRAM DMA with LCD disabled:
all C5A9 bytes with dirty0/1/255, and all dirty bytes with C5A9=0/1, both VBKs.
DMA runs only for nonzero C5A9; palette upload depends independently on C221.
Check all160 OAM bytes, source and adjacent guards, all128 palette bytes,
both entire unchanged VRAM planes, registers and scroll/window reset. FF8A
is preserved, not produced by this callback body. This is not an IRQ trace.

2705410 added assertions, total11898189, plus24 verifier tests. The focused
fixture first required spacing after a hexadecimal literal ending in E in C;
that was a compile fix only, not a ROM change. No disk save, natural menu/audio,
physical timing, Japanese interpretation or universal raw-state validity is
established. Complete callee chains remain pending in the canonical README.


## A12 tile frames and byte multiplication

PROBABLE static/forced-entry contracts. Four sections extract4FFF–50C7 and
5CFF–5D10 (219 bytes); existing aliases remain. Copy destination is9800+x+32*y,
source is big endian C5F7/C5F8, dimensions C5E2/C5E3. The original banked helper
copies both complete planes. Source advance is twice the low byte of area:
256 tiles advance0;289/279 tiles advance66/46, despite full578/558-byte copies.
No widened arithmetic or correction is introduced.

98304 full multiplication calls cover all65536 HL words with derived AF and
eight selected HL words with all4096 AF values. ProductHL=H*L, A/BC/DE preserved,
finalF=C0. Tick testing has1249280 cases:all threshold/counter pairs x16 flags;
all frame-count/index pairs xloop0/1/255 with derived flags;all loop bytes x16
flags at one completion boundary.526608 calls return completely;722672 stop
at the original copy call target. Independent CP/SUB flags, wrap, completion,
loop restart pointer, guards and call stack are compared. Those prefixes do not
execute the copy and do not prove natural validity of every field combination.

240 full direct/tick/loop/setup calls use shapes1x1,2x3,3x2,16x16,17x17,31x9,
real resource ROM in both A/B windows and WRAM payloads, both VBKs, LCDoff/on.
Setup uses a seven-byte WRAM header; actual original code consumes it and calls
copy before clearing the two counters. Exact fields/registers, original mapper
restore, every byte of both VRAM planes, WRAM source/guards and low-product
advance are checked. Zero dimensions are excluded. No ROM-resource patching,
disk saves, natural IRQ/audio/menu, hardware timing or Japanese meaning proof.

2695888 new assertions; total14594077, plus24 verifier tests. Further static
consumer4C11–4C40 calls setup5093 with6A96/6AB1 after guards; those resources
and preceding4BE6 remain pending, not a tested complete consumer chain.


## A12 state recurrence and variant1 frame trigger

PROBABLE, static and synthetic evidence. New source4BDD–4C40 is100 bytes.
Seed writes HL into C5D2/C5D3, preserves flags/BC/DE/HL, returns A=H. Step
uses `(17*state+5C93)&FFFF`; D=newlow/E=newhigh, A=newhigh, BC preserved,
HL=intermediate17*state. Independent ADC flags include low-byte carry.
196608 full calls cover both entries, all65536 states with derived AF and
eight selected states with all4096 AF values.

Consumer guards C5A4=6/C5CF=1/C5E4=0. First step E=0 selects6A96; otherwise
second step E&15=0 selects6AB1; otherwise returns.1048576 state/flags cases
have979184 complete non-trigger returns and69392 prefixes to actual5093 setup,
checking recurrence, steps, target, stack/registers/flags and guards.12288 full
calls vary each guard byte with16 flags, fixing the other guards; not a full
Cartesian product. No injected RNG results or instruction bypass.

Four mapping controls use C21C=63 but actualB05 versusB63. Only B63 reads the
expected two seven-byte headers; wrong-bank cases stop before setup execution.
Requested resource field is not a current-mapping proof. Candidate27/31-byte
resource objects remain literal; no natural B63 entry assumption is promoted.

24 integrated cases use two seeds per outcome, both VBKs and LCDoff/on. Under
explicit B63 preparation, original consumer/setup and all resource frames run:
five2x1 frames or four3x1 frames, then terminal tick with no extra copy. Fixture
sets the frame counter to8 between ticks. Compare full two-plane VRAM after
every frame, original resource bytes, registers/fields, mapping and completion.
The initial oracle needed A=H for the setter and the9800 tilemap limit (excluding
9C00); fixed without ROM changes.2515196 new assertions,total17109273,plus24
verifier tests. Natural mapping/frame timing/random use/menu/IRQ, Japanese
interpretation and hardware remain unproved; no disk saves or ROM edits.

## A12 variant2 paired-tile cycle

`CycleA12Variant2TilePairs` at A12:4C41-4C87 is PROBABLE from its
published variant2 caller and forced execution. It visits9920-9933, advancing
`(17*state+5C93)&FFFF` once per column. A generated high byte masked with7F
must be zero to inspect the upper byte. A5/A6/A7 become A6/A7/A5 and their
lower-row bytes at +32 become A9/AA/A8; other values and columns stay intact.
This code neither selects VBK nor waits for LCD access. The LCD-off contract
must not be generalized to unrestricted LCD-on bus access or natural cadence.

75776 complete calls: all65536 seeds with derived flags/tile inputs and
alternating VBK; then20 selected seeds (one high-zero trigger at each column),
all256 upper-byte values at that column and both VBKs. Independent twenty-step
arithmetic/substitution models check state, all forty bytes across two row spans,
registers/flags and adjacent WRAM guards.280 cases additionally compare every
byte in both complete8192-byte VRAM planes. High128 candidate behavior is
covered by the all-seed corpus, not by the selected high-zero corpus. Input
flags are derived, not a full seed/flags Cartesian product.

303404 new assertions,total17412677,plus24 verifier tests. The initial oracle
incorrectly compared the entire FF4F readback to the selected bit; correcting
its mask resolved that fixture failure without changing original bytes.
Natural caller timing, visual meaning, IRQs and hardware remain unproven.

## A12 indexed text region and window wrappers

PROBABLE helpers4C88-4CFC (117 bytes) and four indexed8-byte records5314-5333
(32 bytes). PrepareA12TextRegion saves A atC5C4, calls both actual indexed
thunks01E3/01E6 with the same table, stores the index atC5A5 and clearsC1C2.
First five fields consumed: x,y,width,height,frame kind; the trailing three
bytes stay literal, without an asserted purpose. Raw indices are not clamped.

ShowA12TextWindow waits for STAT bit1 clear, sets LCDC bits5/6 and reaches
original audio thunk024F with A9A. HideA12TextWindowAndCopy clears those bits
and calls0294 with A87,BC0,HL1408,DED000. CopyA12CurrentTextRegion first
configures the selected C5A5 record, then calls0294 with A7,BC0,
HL=(width+2,2*height+2),DED000. The actual resident wrapper16D6 temporarily
maps A16 and invokes the already published banked background-copy helper:
source WRAM7, two planes, high A bit selects9C00 versus9800, mapper restored.
These operations copy a prepared source; no implicit zeroing is inferred.

16384 bounded prefixes: both indexed helpers with all256 indices and16 flags
stop at01E3 before consuming arbitrary records; both LCD control helpers
with all256 LCDC values and16 flags stop at their real audio/copy thunk.
Checks include stack return, arguments, masks and relevant untouched fields.
Show's audio body is not executed by this new corpus.

84 complete calls:64 frame preparations (four records, both VBKs, LCDoff/on,
four attrs) and20 original resident copies (fixed20x8 hide and four dynamic
record sizes, both VBKs and LCDoff/on). Independent models compare both
complete8192-byte VRAM planes, fields/guards; preparation also checks terminal
registers/flags. Copy cases check source bytes/guard, mapper and WRAM restoration.
Synthetic origin9800 and prepared WRAM7 are fixture preconditions; no natural
source production, timing, arbitrary dimensions/indices, Japanese interpretation
or hardware claim.32936 new asserts,total17445613,plus24 verifier tests.

## A12 resource reset, variant dispatcher and tick

PROBABLE133-byte control unit4CFD-4D81: two resets, dispatcher, four-word
pointer table, four HL setters and tick. Published ResidualROM09_4CFD remains
an alias. Resource destinations stay numeric6BBD/6AD0/6AE5/6A3D: the current B
mapping is not established by a setter. Reset clearsC5CC/C5CE; extended reset
also clearsC5E4/E5/E6/E7, then both dispatch and call actual reader4D82.

Dispatcher doubles the raw C5A8 byte with wrap; pushes return4D3B and jumps
to the selected word. Indices128-131 alias0-3; this does not validate other
indices. Tick subtracts thresholdC5CB from counterC5CC. Below threshold it
tail-jumps4EEA. Otherwise it clears the counter and increments C5CE with wrap;
equality with countC5CD copies phaseC5D1 toC5CF and calls reset, otherwise
stores the new index and dispatches. Both advancing routes reach reader4D82.

1122304 bounded prefixes:4096 all raw dispatcher indices/flags before JP HL;
4096 both reset entries/eight supported raw aliases/all phase bytes with derived
flags before reader;1048576 all threshold/counter byte pairs/16 flags with
fixed index6/count10/variant0;65536 all count/index byte pairs with threshold0,
variant3,derived flags and fixed transition phaseA5.522240 threshold cases stop
at movement4EEA; remaining threshold cases reach reader. Frame corpus covers
256 equality/reset pairs including index255/count0, and65280 normal advances.
No downstream reader/movement body is executed by these prefixes. Models check
real stack returns/nesting, registers/flags and exact counter/phase/guard writes.

192 complete calls:four direct HL setters and dispatcher raw0-3/128-131,
all16 flags.2244992 new asserts,total19690605,plus24 verifier tests. Natural
counter producer/cadence, mapping/resource contents, arbitrary selector validity,
Japanese semantics and hardware remain unproved; no VRAM or ROM is changed by
this new corpus. The extended reset preserves neighboring dimensions/loop bytes.

## A12 mapped resource reader and coordinate helpers

PROBABLE236-byte unit: LoadA12ResourceFrame4D82-4DFD, wrapped offsets4E7A-4EA2,
unsigned distances4EA3-4EE9. Reader backs up FFAD/FFAE inFF9D/FF9E, writes
C21C/C21D to actual B mapper and FFAD/FFAE, then uses byte-wrapped phase*2
pointer lookup. Count byte is followed by four-byte records indexed with a
full16-bit frame*4. Initial FF/FE call original effects4FAF/50C8 (not extracted
or completed in this corpus). The ordinary record fills C5D0,D7,D8,CB;
lookahead skips one FF record and then one FE record if present, fillsD1,D9,DA,FD.
Coordinates subtract C9/D0 with byte wrap; distances are absolute differences
of the resulting unsigned bytes. No clipping or signed-distance interpretation.

1118208 complete calls:4096 offset tuples (all256 byte values in each of four
fields via odd permutations,16 flags),1048576 distance cases (all pairs/16 flags,
Y is reversed X pair, not a four-coordinate Cartesian product),65536 reader
cases (all phase/frame bytes,derived flags, synthetic WRAM pointer table/records).
Reader corpus has16384 of each lookahead shape: ordinary,FF,FE,FF+FE. Independent
models check registers/flags, pointers, fields/counter guards and mapper backups.

36864 prefixes:28672 seven requested ROM selectors0/5/61/63/65/66/7F with all
phase bytes/16 flags stop before actual pointer read4DA2; independent four-byte
ROM signatures at6000 check window selection.8192 initial FF/FE cases cover all
frame bytes/16 flags with derived phases, stop at their actual effect entries
with original stack return/CP flags and unchanged remaining fields. Effect bodies
are not replaced with stubs. Both entire VRAM planes stay untouched over the
common reader/effect-prefix corpus.

Actual B remains selected on ordinary return. FF9D/FF9E hold old5/0; FFAD/FFAE
become63/0 while resident C115/C116 deliberately remain5/0 in these fixtures.
This distinction must not be collapsed into a universal mirror/restore rule.
Modes tested here are ROM0, not flash. No natural table geometry, producer,
frame cadence, sentinel effects, full-window/all-selector claim or hardware proof.
2441217 new assertions,total22131822,plus24 verifier tests. Synthetic records
are memory-only and the immutable external ROM is never patched.

## A12 FF tile and FE upper-stream effects

PROBABLE96-byte unit: ApplyA12ResourceTileEffect4FAF-4FFE(80),
ApplyA12ResourceAudioEffect50C8-50D7(16). Reader calls their names; published
ResidualROM09_50C8 stays an alias. FF consumes four marker bytes, takes a
little-endian header pointer from bytes2/3, reads seven tile-header fields,
executes the original CopyA12TileFrame, increments C5CE and clearsC5E5/E7.
HL restores to marker+4, not the tile payload end. Original source advance
remains2*((width*height)&255), including area256 and above.

FE passes marker byte1 through actual024F/RequestA1EUpperStreams, consumes
remaining two bytes, increments C5CE with INC flags (carry preserved). It does
not skip execution of the stream installer.4096 prefixes cover all request
bytes/16 flags before024F with original stack return and untouched index.

69680 complete calls:65536 FE request/index byte pairs with derived flags,
synthetic128-word table and one-channel program; requests below128 retain upper
slots and CF82, high-bit requests install the real channel1 stream and clearCF82.
Lower slots remain intact.4096 FF calls cover all indices/16 flags at1x1 with
alternating VBK, row guards and exact payload;24 more cover six shapes1x1,2x3,
3x2,16x16,17x17,31x9,both VBKs,LCDoff/on,both entire VRAM planes/source guard.
24 integrated reader calls execute FF,FE,FF+FE chains with both VBKs,LCD states,
indices0/255 and independent exact fields/registers/payload/full-VRAM models.

The ordinary reader's old C115 mirror is updated to actual current B by the
real copy/audio wrappers. FF replaces FF9D with tile width; it is not a stable
reader backup across effects. Integrated FF changes BC/DE through the real
copy; FE preserves the caller registers before its final index INC. No invented
register preservation.147600 new asserts,total22279422,plus24 verifier tests.
Prepared WRAM headers/payload/audio records are synthetic; no arbitrary geometry,
natural resource table, audio waveform/cadence, flash or hardware claim.

## A12 C601 text-mode controller

PROBABLE109-byte UpdateA12TextModeController4B70-4BDC. Four published variant
handlers now call its name. C601zero returns. Nonzero/non-FF requiresC5CF1,
sets phase2 and calls actual ResetA12ResourceFrame. Mode1 then tail-jumps5C2F;
mode2 setsC73A1,prepares text record0,shows window,queues pointer5695 and sets
C601FF; other modes return. FF tests FF97 bit0 to clearC1C2 before text busy
C1B8 gate. Idle calls real hide/copy,sets phase1,resets resources,clearsC601,
optionally calls5C55 ifC73B nonzero,then clears that pending byte.

2097152 whole-entry guard cases:all C601/C5CF bytes/16 flags with busy1/edge0;
all FF97/C1B8 bytes/16 flags with C601FF.2088992 complete guarded returns,
8160 actual first-call prefixes (4064 reset,4096 hide). Independent flag/field
models check original stack returns,mode/phase writes,bit0 clear and guards.

12288 forced suffix cases:all mode bytes/16 flags at4B88,all prior phase bytes/
16 flags at4BC2,all pending bytes/16 flags at4BCA. Stop at actual tails/calls
or complete local returns.4096 further full suffix calls at4BD7 cover all AF
and flag preservation. These entries begin after unexecuted callees: they are
local suffix evidence,never substituted calls/returns or a whole-path proof.
No new complete reset/text/resource/5C2F/5C55 integration is claimed.

4227072 new asserts,total26506494,plus24 verifier tests. Initial reset-prefix
oracle omitted N from equal CP; corrected expectedC0 instead of80,without
changing original bytes. Natural mode/input/text trace,Japanese meaning,tails
5C2F/5C55,IRQ/cadence and hardware remain unconfirmed.


## A12 pending text and actions (5C2F-5CFE)

PROBABLE contracts, not a natural menu trace. The original ROM is unchanged.
The six-byte table at56AD contains21 records; the forced scanner fragment at5BEB
stops at the first FF at572B. No meaning is assigned to the next three FF bytes.
All256 byte inputs and16 flags are tested at the scanner fragment and at the
actual dispatcher boundary before reading the action byte. C73B zero wraps to
index255; arbitrary indices are not claimed to be naturally valid.

All256 indices/16 flags also execute the forced5C37 message suffix through the
real queue body. Complete5C2F calls cover all21 original pointers, both VBK and
LCD states, and16 flags, with real frame preparation/window/audio/queue bodies.
Both entire8192-byte VRAM planes are independently compared with the frame model.
No Japanese string interpreter is run. Audio input tables are synthetic.

The18 zero-action records run with16 flags. The three nonzero actions each run
through the real dispatcher and color transition with all256 C5A3 values and16
flags. The192 expanded components/deltas are compared against an independent
bit-component model of the actual original resources. Register/state/guard
checks include C706 preservation in action3 and INC overflow/half-carry flags.
This unit adds44,224 assertions; suite total26,550,718. Natural controller/input
integration, Japanese semantics, physical timing and hardware remain unproven.


## Complete pending record scanner (5BDA-5C2E)

PROBABLE, called statically at4054; complete initialization is not exercised.
4096 prefixes cover all256 C706 values and16 flags through the real5BEB
boundary: C5A8 receives C706, C5A4 reads C708+C706 without a clamp.
16384 whole-entry calls cover four variants, all256 progress bytes and16 flags,
with varied prior field bytes. There are1344 matches and15040 sentinel returns.
Independent21-row threshold/value models check progress/pending, selected field,
C5A4/C5A8/C738, adjacent guards, registers, flags and original stack return.
On a match the third byte updates the selected field; second byte1 selects
variant3 and clearsC738. No-match retains pending/progress after the initial
variant/value copy. Existing symbols and Japanese bytes remain unchanged.
Adds36864 assertions, suite total26587582. Natural initialization/menu execution,
record meaning, hardware and IRQ/timing remain unproven.


## Resource command dispatcher (4AC9-4B6F)

PROBABLE contracts: all four A12 handlers call this routine statically.
16384 complete calls cover four variants, all256 commands and16 flags;8192
additional complete calls cover the eight transition commands and all256 state
values. Real0255 countdown and017A color preparation bodies execute. The192
components/deltas are checked against a bit-component model, with original ROM
source words, exact registers/flags/state/guards and command retention.
Zero/unrecognized commands return; F0 writesC738=1. F1/F2/F3 setC214=0/1/2,
F1 also clearsC624. F4/F5/F6 call countdown and setC214=4,C706=1/2/0.
F7 setsC214=6 and FE sets4. Eight transition commands clearC213/C1C4,
use53B2+128*C5A8 in mode4 and incrementC5A3. No clamp.
4096 forced4B4C suffixes cover every raw variant/flag, stopping before real017A;
they check arithmetic/stack/arguments without asserting natural palette validity
or executing those arbitrary resources. Adds53248 asserts,total26640830.
No natural handler/resource flow, Japanese meaning, IRQ/timing or hardware proof.


## Input mode and nested dispatch (470F,4764,485A,4940)

PROBABLE static plus synthetic contracts. Whole input entry tests1048576 pairs
of all mode/edge bytes and16 flags:1045504 complete guard returns and3072 actual
first-audio-call boundaries. C600 must be1; bit0 overrides bit1. Bit0 selects9D
and confirmation, bit1 alone selects9E and cancellation, neither returns.
16384 raw dispatcher prefixes test all indices/flags through original pushed
returns, stopping before JP HL. Wrapped doubled offsets are not clamped.
16384 isolated return-label calls test every AF and preserved register.
The initial table has three targets; each subdispatcher has six action pointers.
No fourth initial pointer is inferred from following code.

12288 confirmations execute actual upper audio then stop before the selected
variant, checking three targets, all prior C214 bytes/flags and bit0+bit1 priority.
4096 complete cancellations cover64 eligible edge bytes,16 flags,both VBK/LCD,
with real audio/hide/copy bodies. Whole8192-byte VRAM planes and immutable320-byte
synthetic WRAM7 source/guard are compared independently. Cancellation clears
C213/input/mode and preserves the tested neighboring fields/mapping state.
Audio tables/source image are synthetic; no natural saves or injected returns.
Adds2166784 assertions,total28807614. Confirmation target bodies, natural input/menu,
Japanese meaning, index validity, physical timing/IRQ and hardware remain unproven.


## Eighteen input action bodies (4786-4859,487C-493F,4962-4A35)

PROBABLE whole original-code contracts.4608 direct calls cover all256 C5A4
values across18 bodies with varied flags.576 complete470F->variant->action chains
cover values0/1/2/3/5/6/7/255, bothVBK/LCD and varied flags, with actual upper audio,
hide/two-plane copy,tile setup and resource reset/read bodies. No fake return.
Original resources are mapped in B61/63/65; original Japanese bytes are retained.
All actions clearC213,setC600=2,configure tiles and set a phase before reset.
Actions0/1 share a header,phases7/8; actions2/3 use phases3/5, including five
threshold header branches. Actions4/5 use phases4/6 for variants0/1,6/4 for2.
Headers and first/next resource records are modeled independently; all reset
first records are ordinary. Lookahead FF/FE skips are modeled without claiming
an executed effect. Geometry,payload pointer advance,normalization/distances,
registers,phase/counter/field/guard contracts are checked.
Whole VRAM comparison composes original tile payload over the synthetic320-byte
WRAM7 window image; both8192-byte planes and immutable source/guard are checked.
Audio/window inputs synthetic. Adds21312 assertions,total28828926. No natural
input/menu trace, Japanese meaning, arbitrary-index validity, IRQ/timing/hardware
proof. Original resource data remains unextracted; bodies alone are refined.


## Resource wrappers, position copies and OAM emitters

PROBABLE contracts.16384 wrapper entry prefixes cover all prior C21D bytes/flags,
stopping at actual50DF/4D54 calls. Request61/63/65/66 writes are not mapper writes.
196608 forced first-three suffixes cover all counter/acceleration pairs with
varied flags;4096 fourth suffixes cover each counter/flag. First three increment
counter by1 or4, fourth by1; suffixes omit earlier callees explicitly.
131072 complete position-copy calls cover all XY pairs for4E65/51E5, varied flags.

4096 complete4DFE/5188 calls cover all count bytes at availability0/1/40/255,
and all availability bytes at count0/1/3/255, with varied indices/coordinates.
Tables/records synthetic. Availability0 returns. Primary copiesC1C7 toC5F5 and
decrements per record; secondary usesC5F5 without decrement. Doubled table index
wraps in byte. DestinationC000+4*((40-availability)&255) uses low-byte-only E
increments; zero count loops256 times. Coordinate additions wrap. Compare all
C000-C3FF bytes, complete registers/flags/pointers/mapping/mirrors and source.
Adversarial destination ranges may overwrite other WRAM fields, includingC115/
C116; these overwrites are checked by the memory model, not claimed natural.
Mapper/HRAM backup writes precede the loop; they do not themselves update WRAM
selector mirrors. Initial dirty-memory setup is followed by explicit requested/
mirror fields. The original remained unchanged after fixture/oracle corrections.
Adds688128 asserts,total29517054. No complete wrapper/tick execution, natural
OAM/capacity trace, Japanese meaning, IRQ/timing or hardware proof.
