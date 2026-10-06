# Minigame maintenance: evidence boundaries

Investigation started 2026-10-06 after Rafael asked whether the original Net de
Get can delete, overwrite or format downloaded minigames. Reference ROM SHA256:
`9fb1e6e4a637796b8624bd2de6c9abaa9e758546b620cb5dc8441b07c288bc63`.

A BOX is a user-visible grouping in SRAM. A mapper selector identifies an 8 KiB
window. A flash erase sector covers a different region. A change in one does
not prove a change in the others.

## Natural menu observations

- **CONFIRMED (menu displayed):** the local minigame submenu offers
  `あそぶ` (play), `いれかえ` (rearrange/swap) and `けす` (delete).
  The delete confirmation warns that deleted content must be downloaded again;
  its default is No. The displayed warning does not establish billing behavior.
- **CONFIRMED (bounded artificial two-game fixture, installed Linux runtime):**
  choosing rearrange for the first BOX2 game and selecting the first empty slot
  in BOX3 changed slot records from `10 01 11 01 FF 00` to
  `11 01 10 02 FF 00`. The complete flash sidecar stayed identical. The moved
  C PAD opened in BOX3 after a fresh-core boot, counted A and returned normally.
  This is movement/order of Index/Box records, not executable replacement.
  Evidence: `/tmp/netdeget-two-games-v2-3ceisrfx/swap-confirm/` and
  `swap-reopened/`. The fixture was staged before boot; gameplay used joypad only.
- **CONFIRMED (bounded inspection):** the Options screen shows text speed,
  cursor-position behavior and sound. No flash/BOX format option was observed
  there. This is not proof that no other initialization shortcut exists.
- The mGBA owner reports a **natural single-game delete and fresh-core PASS**
  using a save actually obtained through C PAD download, with the slot removed
  and the complete flash unchanged. Evidence is
  `/tmp/mgba-netdeget-delete-acquired-5r9iv5lf/` and
  `/tmp/mgba-netdeget-delete-reopened-fwxzco_n/`. This establishes removal from
  the stored list in that case; it does not establish physical flash erasure.

The installed Linux library used in this maintenance work reports runtime
`ed393f522`; SHA256
`d764a3ea9606d05c932e01b9dc7b2741a8edee87e89727c1adb8b55ad9578516`.
Hardware remains unvalidated.

## Static call paths — PROBABLE

These are byte-decoded paths, not complete natural instruction traces. All
banked references below name native MBC6 selectors, not 16 KiB tool banks.

| Path | Native selector / CPU address | Interpretation and limit |
| --- | --- | --- |
| Local menu | A selector 20, `4000` | File base `28000`, physical tool bank `0A` |
| Action dispatch | A20:`4303` | Reads selected action at WRAM `D01C` |
| Rearrange selection | A20:`4344-4361` | Stores source selection and changes UI state |
| Confirmed delete branch | A20:`43C0-4484` | Removes an Index/Box pair and invokes internal maintenance callbacks |
| Pair removal loop | A20:`440B-4415` | Shifts pairs until an FF Index terminator |
| Flash-maintenance callback | A20:`442D` -> ROM0:`02A0` -> ROM0:`3EDC` -> A16:`4FD6` | Sets internal action `C67E=2`; selected arguments and runtime execution require tracing |
| Candidate sector rebuild | A16:`5018`, `5085`, `5073` | Calls ROM0 `138D` erase helper and `3C3B` B-window copy/program helper while enumerating remaining games; not evidence that the single-game delete performed erasure |
| Save-file removal | A20:`447E` -> ROM0:`01BC` -> `0D50` | Deletes the associated four-character SRAM filesystem entry; separate from flash content |
| Select-held entry | A20:`4010-4020` -> ROM0:`3E00` | Reinitializes/rebuilds SYS1 by scanning flash markers/block counts/checksums; the decoded routine does not issue a flash erase opcode |

The `3E00` path places detected games into BOX1. A natural held-Select test
now confirms the catalog-rebuild behavior described below. It does not format
flash. Do not equate an erase-capable chip with a menu feature.

## Failed artificial delete fixtures

The first artificial two-game fixture accidentally replaced the old FF
terminator without adding the new one. It is invalid for delete conclusions.
A second fixture fixed that terminator and its SYS1 checksum; deleting from it
still produced invalid-bank accesses and a bad final state, with flash unchanged.
Neither case proves correct delete behavior or a core defect. Prefer two actual
natural downloads before validating neighbor preservation and sector rebuilding.
Do not change emulator expectations or undocumented SYS1 fields to make those
artificial runs pass.

## Natural two-download maintenance and replacement

**CONFIRMED (natural local downloads, installed runtime):** G001 and G002
were acquired through the host into offsets `00000` and `20000`, with Index/Box
records `10 00 20 01 FF 00`. Deleting G001 from that arrangement removed its
record without changing flash. A fresh core opened the surviving G002, counted
all eight buttons and returned. Evidence: `/tmp/mgba-netdeget-local-hihkiz03/`,
`/tmp/mgba-netdeget-delete-two-natural-thioc91t/` and
`/tmp/mgba-netdeget-neighbor-reopen-x6mu1o_f/` (mGBA owner).

**CONFIRMED (natural UI move):** moving G001 to the second BOX2 position
changed records to `20 01 10 01 FF 00`, with the entire flash unchanged.
Evidence: `/tmp/netdeget-two-games-v2-3ceisrfx/natural-two-move/`.
The games still occupy different physical erase sectors; a shared BOX does
not imply a shared sector.

**CONFIRMED (failure reproduced):** deleting the first game, G002, from that
new arrangement changed records to `10 01 FF 01 FF 00`, but caused invalid
mapper accesses and a white screen. The flash remained identical. Unlike the
earlier artificial failures, this save came from two actual downloads followed
by ordinary UI movement. Evidence:
`/tmp/netdeget-two-games-v2-3ceisrfx/natural-two-same-box-delete/`.
This is an open maintenance failure, not a passing delete test.

**CONFIRMED (mGBA owner natural replacement round):** downloading changed
G001 (`C PAD NEW`) appended a new copy at `40000`, with records
`10 00 30 01 20 01 FF 00`; existing G001/G002 payloads remained intact.
Fresh-core title/input/exit checks passed. Evidence:
`/tmp/mgba-netdeget-local-s6yeg0hf/` and
`/tmp/mgba-netdeget-new-reopen-m93c_4zx/`.
This demonstrates same-ID download append in this state, not occupied-space
replacement.

**PROBABLE (static allocation):** native A16 `50BA-516B` scans flash-sector
occupancy, skips the reserved sector, and selects the least-used candidate
(`511E-5126`). `516C` searches for room inside that candidate. This explains
successive copies in initially empty sectors. Natural occupied-sector reuse
requires a separate trace; no full storage/overwrite claim follows.

## Pending checks

1. Trace and correct the natural MOVE→DELETE failure, then repeat the complete
   natural route and fresh-core checks against the corrected runtime.
2. Trace allocation after all active sectors contain a valid game, distinguishing
   append, copying, compaction and physical erasure.
3. Trace whether the held Start+Select exit chord reaches the Select-held host
   reconstruction shortcut. Do not change fixture exit behavior without a new
   artifact identity and validation.
4. No physical flash-format result is established. The observed Options menu
   and metadata reconstruction shortcut do not establish an erase-all feature.

Temporary G002 and replacement-G001 artifacts are original C PAD variants with
unchanged diagnostic ABI. They are not production content and their successful
packaging alone is not a successful installation or overwrite test. No reference
ROM, save, credentials, private server response or generated binary is committed.

### Additional copy-path detail

PROBABLE static: ROM0 `3C3B` copies source window B to WRAM `D400` in
2048-byte chunks (`3C71-3C7F`), maps destination window B from BC, sets write
enable and remaining length 0800, then calls the B writer at `13FD` from
`3C9F`. It loops four chunks per 8 KiB block and advances source/destination
selectors. This is distinct from the previously validated installer callback
using the A writer `1568`. Candidate delete compaction needs its own trace.

ROM0 `1377` clears retry byte CEE4; it is not a flash-enable helper. `1362`
uses `137C` to check CEE9 bit0, and `1387` clears that software bit. The B erase
entry is `138D` (push HL/call1362); the old decode seed at `1390` was inside
a call operand. Do not seed a CFG at the interior byte or infer register
semantics from that earlier boundary ambiguity.

## Natural held-Select rebuild and recovery

**CONFIRMED (installed runtime, copy of naturally acquired/deleted save):**
starting from the mGBA single-game delete result, holding A+Select while
entering Minigames restored the G001 slot from `FF 00 FF 00` to
`10 00 FF 00`, with the complete flash sidecar unchanged. A fresh core opened
the recovered C PAD from BOX1 item16, counted A, released it and returned with
Start+Select. Flash stayed identical throughout. This connects the observed
recovery behavior with the static scan path without claiming an instruction
trace of every call.

Artifacts: `/tmp/netdeget-two-games-v2-3ceisrfx/rebuild-select-long/` and
`rebuild-reopened/`. Inputs to the rebuild were ordinary joypad pulses:
`0:900, 8:3, 0:180, 1:3, 0:360, 1:3, 0:60, 5:180, 0:300`; mask 5 is A+Select.
A shorter 30-frame hold ended before the local-entry check and did not rebuild
the list. The fresh-core route uses the normal BOX1 list, sixteen Down pulses
and the Play submenu; it does not redirect the CPU.

This case demonstrates that single-game delete is not a physical wipe: the
old valid header/program remained available for a later catalog reconstruction.
The rebuild operates on SYS1 and grouping; it is not evidence of sector erase
or an arbitrary flash-format feature. Effects on nonzero progress/levels were
not tested, and static initialization should not be generalized to real saves.

## First wrong-ID trace in natural MOVE→DELETE

**CONFIRMED (installed emulator trace):** replaying the failed natural save
with normal joypad input and instruction stepping captured the following:

| PC / mapping | Observed emulator state |
| --- | --- |
| A16 `5018` → ROM0 `138D`, B112 | Before erase, flash read-bank latch invalid; spare selector `70` |
| ROM0 `1359`, B112 | After erase, latch valid for window B / bank112; flash mode0, command0, operation active but not busy |
| A20 `445E`, B16 | Flash disabled; the latch still names bank112 |
| A20 `446A`, B16 | Flash enabled again; reads at `6005` / `6044` return `FF` / `FF` with the latch still bank112 |
| A20 `447E` → ROM0 `0D50` | Copied ID at `DCF7-DCFA` is `FF FF FF FF`, passed to SRAM save-file removal |

No retained-game copy at `3C3B` occurred in this route: the other game's header
belongs to a different physical sector. The incorrect ID is observed before
the later mapper/stack failure. Source G002 has a valid `G002` header at
flash offset `20000`; `FF FF FF FF` is not its ID.

Evidence: `/tmp/netdeget-natural-delete-idtrace-8ag246n6/trace.log` and the
read-only instrumentation source `fixtures/maintenance/trace.c`. The tracer
was compiled with all defines from the installed library's `flags.make`,
including `USE_LIBMOBILE`, to match the internal struct ABI.

**HYPOTHESIS (core cause):** the remembered bank from the spare-sector erase
continues to redirect B reads after the host disables and re-enables flash,
so the remapped game's ID is read from the erased spare instead. The trace
establishes the emulator state and wrong ID; it does not establish hardware
latch lifetime, the correct fix, or correctness of remaining maintenance paths.

Trace input identities (synthetic copies only; files remain outside Git):

- SRAM SHA256: `6ae61c4764455b3524d004ea3780c8d3270f0fee6af642b5debab84195918003`.
- Flash SHA256: `3ef4290116c5bf5210f36b6e2444c812994d6923e2ed64c84cb4e99c39106ccc`.
- Trace log SHA256: `2dc64e7c406715a3c52b3ed912531675d354a5843ddf92298a2f8538c5e67a85`.

### Independent candidate-core comparison

**CONFIRMED (candidate emulator, same input snapshot and joypad replay):**
with the mGBA owner's limited candidate invalidating the read-bank latch when
flash is disabled in array mode and the operation is not busy, the trace changes
at the first wrong read:

| Observation | Installed baseline | Candidate |
| --- | --- | --- |
| A20 `445E`, flash disabled | Latch valid, bank112 | Latch invalid |
| A20 `446A`, flash enabled, B16 | `6005=FF`, `6044=FF` | `6005=01`, `6044=FF` |
| A20 `447E` / ROM0 `0D50`, file ID | `FFFFFFFF` | `47303032` (`G002`) |
| After 180 release frames | Bad mapper/stack state | Normal host `517E`, SP `FFF6` |

The candidate removed the same Index/Box record and left the full flash
unchanged. Evidence: `/tmp/netdeget-candidate-idtrace-nh5yb2_t/trace.log` and
`report.json`; candidate library SHA256:
`0122452480576dd1942e932523f30a3e95ddc288fc94906184e1fe2b3fe8fbbc`.
This independent comparison links the observed wrong ID to the retained latch
in this emulator route. It does not validate physical hardware lifetime,
occupied-sector copying or all maintenance operations. At this checkpoint the
candidate remains uncommitted, with broader regression and fresh-core checks
owned by the mGBA chat.

### Occupied-sector retention and fresh-core execution

**CONFIRMED (mGBA owner run, report/logs inspected):** candidate allocation
from a baseline with seven occupied sectors retained a byte-exact G001 copy at
`E0000` and installed the new payload byte-exact at `E2000`. The report also
confirms the seven original sectors and hidden/metadata region stayed intact.
The relocated G001 record became Index `80`, followed by new Index `81`.
Evidence: `/tmp/mgba-netdeget-local-1hqcsm7h/report.json`.

Both relocated programs opened after fresh-core boot: new Index81 at A selector
113 (`/tmp/mgba-maintenance-candidate-neighbor-6hwgpf6p/run.log`, stages14/30/32)
and copied G001 Index80 at A selector112
(`/tmp/mgba-maintenance-candidate-neighbor-03x3qwkg/run.log`, stages44/60/62).
Each counted all eight buttons once (`0101010101010101`) and returned to host
`517E` with SP `FFF6`. Both reports record unchanged flash during execution.
These observations validate this occupied-allocation retention route in the
candidate emulator. Legacy regression results and the later physical reuse
round remain pending at this checkpoint.

### Physical reuse with retention

**CONFIRMED (mGBA owner run, report inspected):** the next occupied-sector
allocation in the candidate erased sector0, copied G002 byte-exact into offset0
and installed the new payload byte-exact at `2000`. The tail `4000-1FFFF`
was erased (`FF`); every other sector and the hidden/metadata region stayed
intact, including the relocated G001 copy at `E0000`. Evidence:
`/tmp/mgba-netdeget-local-2cw0297h/report.json`.

This demonstrates physical sector erasure/reuse with retention during natural
allocation in this candidate route. It does not establish a user-visible format
operation or that downloading the same ID overwrites its previous instance.
The mGBA owner reports 30/30 CTest passes including four added regression cases;
MBC6 Test ROM comparison remains pending at this checkpoint.

## Exit chord reaches host reconstruction — natural instruction trace

**CONFIRMED (candidate emulator, ordinary joypad route):** launching the
recovered G001 from BOX1 and exiting with `12:3, 0:300` captured, in order:

- native A20 `4010`, held joypad `FF96=0C`;
- native A20 `401D`, held joypad `FF96=0C`;
- ROM0 `3E00`, held joypad `FF96=0C`.

The exit chord's Select bit therefore reaches the host's reconstruction shortcut
before release. The run ends normally at host `517E`. Evidence:
`/tmp/netdeget-select-exit-trace-c34mlhjk/trace.log` and `macro.json`.
Its input is a copy of the naturally acquired/deleted/recovered single-game
snapshot `rebuild-select-long`, with normal BOX1 navigation (sixteen Down
pulses), Play, then Start+Select. No guest-memory or CPU injection was used.
The published trace fixture now includes these PCs and the held joypad value.

**PROBABLE (fixture improvement):** waiting for the exit chord to be released
before returning to the host should avoid this accidental shortcut. Existing
C/assembly payloads remain unchanged; any change needs new artifact hashes and
natural execution checks. This is independent of the core's flash-latch fix.
