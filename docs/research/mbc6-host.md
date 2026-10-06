# Net de Get MBC6 host-path evidence

## Scope

This note records only the host ROM behavior needed for mGBA's MBC6 model. It is not a complete ROM disassembly. The original ROM is external; all observations below refer to SHA-256 `9fb1e6e4a637796b8624bd2de6c9abaa9e758546b620cb5dc8441b07c288bc63`.

## Bank model

MBC6 exposes independent 8 KiB windows: A at `$4000-$5FFF` and B at `$6000-$7FFF`. The banked ROM file offset for selector `n` and in-window offset `i` is `n * 0x2000 + i`. Analysis tools that label physical 16 KiB banks require translating file offsets; their bank number is not an MBC6 selector.

## Static control-flow findings

All addresses in this section are CPU addresses and, for ROM0, equal file offsets. Evidence is byte decoding from the SHA-256-checked host ROM, cross-checked against the partial GhidraBoy listing and CFG read/write/xref output. Static control flow is **PROBABLE**, not a natural runtime trace.

- **PROBABLE — common mapper helpers:** `00:12E9-12F7` writes L to `$2000` (window A selector), H to `$2800` (window A chip/type map), and mirrors both in WRAM. `00:12BF-12CD` does the corresponding window B writes to `$3000/$3800`. The two selector/map pairs are independent in the actual instruction stream.
- **PROBABLE — dispatch thunk:** `00:026D` jumps to `00:254E`. At `00:254E`, A is preserved in B and compared with `$10`. Values `<$10` index a table at ROM0 `$3CD8`; the selected ROM selector is written to `$27FF`, `$2800` is set to zero (ROM), and `$4000` is called (`00:2576`). For values `>= $10`, code at `00:2594` subtracts `$10`, writes the result to `$27FF`, sets `$2800` to `$08` (flash map), calls `$4000` at `00:25AE`, then restores the saved selector and maps ROM again. `$026D` is thus a real bank-aware dispatcher entry, but forcing PC/A to it bypasses list parsing and selection.
- **Selector conversion:** for the flash branch, selector `n = A - $10` addresses an 8 KiB flash window at `$4000-$5FFF`. Its flash file offset is `n * 0x2000 + (CPU_address - 0x4000)`. For any analysis tool using physical 16 KiB banks, derive `fileOffset / 0x4000`; do not call selector `n` a physical bank. Example: selector `$10` (dispatcher input `$20`) corresponds to flash file offset `$20000`, physical bank `$08`; input `$10` selects selector `$00`, offset 0. This arithmetic describes mapping, not which game/menu slot yields a given A value.
- The prior CFG labels around `$0365` are only partially decoded in the available artifacts. Treat the earlier claim that selector `$16` there is used to reach offset `$2C000` as **HYPOTHESIS** until byte-level instruction context and a natural trace are recovered; do not rely on it for mapper conclusions.

## Flash code paths found in the host ROM

**PROBABLE from static decoding** (the bytes are directly confirmed; runtime execution and chip semantics are not): the ROM has parallel flash helpers for each MBC6 window, all in ROM0.

| Function/routine | Window B | Window A | Observed instruction behavior |
|---|---:|---:|---|
| Map selector/type helper | `$12BF-$12CD` writes `$3000/$3800` | `$12E9-$12F7` writes `$2000/$2800` | Writes selector and type independently; mirrors them in `$CEFC-$CEFF`. |
| Unlock helper | `$14E2-$14F7` | `$164D-$1662` | Temporarily maps selector 2 then 1 in the matching window; writes `$AA` at `$7555` / `$5555`, `$55` at `$6AAA` / `$4AAA`. |
| Sector erase | `$1390-$13AF` | `$14F8-$1519` | Writes `$80` after unlock, repeats unlock, writes `$30` at selected window address `$6000` / `$4000`. |
| Buffered program | `$1400-$1425` | `$1570-$1590` | Issues `$A0` at unlock address and writes up to `$80` bytes from source buffer through selected window. |
| Poll/verify | `$1423-$14DF` | `$158E-$1647` | Polls status bit 7, treats bit 4/bit 5 as error paths, writes `$F0`; then compares source and flash array bytes and retries/returns error as decoded. |

The disassembly has control-flow ambiguities at `$1390` and `$13FF` (possible code/data overlap), so routine boundaries above are descriptive ranges, not fully reconstructed symbols. Erase polling checks DQ7 and DQ5; program polling checks DQ7 and DQ4. Program code issues `$F0` before array readback and then compares against the source buffer. Erase code does not appear to read back the erased sector after `$F0`. This is evidence about the host's software expectations, not independent confirmation of Macronix silicon behavior.

Dan Docs infers that the erase-selected bank remains active for flash I/O after `$F0` until a later flash opcode, while the other 8 KiB window can read its ordinary selected bank. That is compatible with this code's polling through the selected window, but remains an inference and should not be generalized beyond this cartridge.

Confidence remains `PROBABLE` because this path has not yet been confirmed by a natural trace in the host ROM. The prior 12,000-frame mGBA smoke run proves boot and continuous execution only.

## MBC6 details for emulator coordination

All findings here are **PROBABLE** static instruction evidence from the ROM hash above. No natural trace or physical cartridge capture is available for these operations.

- The byte-level RGBDS excerpts in [`src/rom0/mbc6_helpers.asm`](../../src/rom0/mbc6_helpers.asm) cover only the two independent selector/type helpers (`00:12BF-12CD`, `00:12E9-12F7`) and unlock helpers (`00:14E2-14F7`, `00:164D-1662`). They are not a full ROM source reconstruction.
- The host's B-window erase/poll path accesses `$6000`; its A-window counterpart accesses `$4000`. In each decoded poll loop, DQ7 is checked through the same window used for that operation, with DQ5 checked on erase and DQ4 on program. The decoded code does not show a status read through the opposite window. This is limited to the decoded routines; it does not establish the chip's cross-window behavior during status mode.
- After an erase poll writes `$F0`, control calls `$1359` and returns; the decoded erase path does not read back array data. `$1359` calls `$1371` (write `$01` to `$1000`), stores `$00` at `$0C00`, then calls `$136C` (write `$00` to `$1000`). After a program poll writes `$F0`, control calls `$136C`, then compares flash data against the source buffer through the operation's same window. These are observed register writes; do not equate them with a specific hardware mode transition without further evidence. We have no trace showing the next opcode accepted after `$F0` or whether an opposite-window read occurred between the reset write and the next command.
- The erase routines set selector 2 while issuing the `$80` command sequence, then restore the saved target address/bank context before writing `$30` at `$6000` (B) or `$4000` (A). This is consistent with the target address selecting the sector. The source does not yet establish the physical sector-number formula independently. The `$0400/$0800` accesses in nearby code have not been conclusively mapped to hidden-map selection/address semantics; no claim is made here about hidden-map reads through either window.
- No natural parser/loader trace has yet demonstrated local catalogue recognition. Shonumi reports the `MNGL` header in `h0000.cgb`, a `RomList.cgb` request, and a normal box-selection/download flow, but this is external reverse-engineering evidence, not our host trace. Our synthetic dispatcher run at `00:026D` bypassed catalogue parsing. A disposable SRAM fixture with recomputed additive SYS1 checksum was later loaded in a headless run; after boot, the candidate slot bytes had been normalized/cleared and the CPU remained at `$4027`. That run did not show a natural list or game entry, and does not prove why the slot was cleared. The fixture was temporary and is not included.

The first partial RGBDS excerpt is deliberately limited to routines whose instruction boundaries and operands are unambiguous. Sector erase, status polling, hidden-map selection, and the natural loader remain disassembly/analysis notes rather than reconstructed RGBDS source.

## Analysis tooling and limits

The first analysis used the Mobile Trainer project's SM83 `cfg.py` and GhidraBoy setup as technical references. The Mobile Trainer skill itself is scoped only to that project. Its CFG assumes 16 KiB physical banks and only infers MBC5 bank writes, so MBC6 selectors and independent 8 KiB windows need explicit translation/seeds. GhidraBoy's headless analysis was partial and is only a cross-check.

Temporary artifacts from the first milestone are outside this repository under `/tmp/netdeget-*`; they are disposable and not authoritative sources.

The byte listings used for the focused routine map are `/tmp/netdeget-flash-decoded.out`, `/tmp/netdeget-flash-mbc-map.out`, `/tmp/netdeget-flash-candidates.out`, and `/tmp/netdeget-ghidra-out/analysis/ghidra_disasm_bank00.txt`. They are generated artifacts, not inputs to trust in place of the ROM. Header/hash was rechecked during this work: `9fb1e6e4a637796b8624bd2de6c9abaa9e758546b620cb5dc8441b07c288bc63`.

## Payload, catalogue, and box distinction

- **CONFIRMED (source/code structure):** the Maker reference stores seven box names and 128 SRAM slot records with separate Index and Box bytes; the minigame header stores game ID/title/category/genre but no box assignment. The payload in flash and its visible slot/box organization are distinct data. Source: the local Maker clone `/tmp/net-de-get-maker-review/include/ram/sram.asm`, `include/header.asm`, and `push.py`.
- **PROBABLE:** adding NASU to another box requires a coherent flash payload entry plus a valid SRAM slot mapping; changing only the payload cannot assign a box. The precise interpretation of box byte values, slot index to flash offset relation, SYS1 checksum, and whether this Maker-generated structure is sufficient for the host's natural catalogue remain to be proven against the host's parser/trace.
- A proposed Box 2 fixture in `/tmp/mgba-netdeget-test/box2/` is expressly **unvalidated**. It used index `$10` based on forced dispatch and box code `$01` by inference; its SYS1 checksum was stale. Do not call it valid or load it as evidence. The general proposal is to clone a disposable valid baseline, modify one slot/box entry, recompute the checksum using the actual host format, verify bytes/hash, and then run a natural menu trace.
- Shonumi's article reports that selecting the minigame-list option requests `RomList.cgb`, while `h0000.cgb` requires `MNGL` magic. This external account plus Maker source helps frame the parser, but is not evidence that the current flash fixture will be recognized. Keep boot/title, synthetic dispatch, natural list recognition, game entry, and gameplay as separate outcomes.

## Open items directly relevant to MBC6

- **PROBABLE, with local emulator regression evidence:** the documented hidden-region read sequence is six writes (`AA/55/77` twice). The original mGBA implementation expected nine; the current uncommitted MBC6 change was corrected and a mCore harness read a seeded hidden byte after the six-write sequence. No physical cartridge was tested.
- **PROBABLE, with local emulator regression evidence:** flash program-buffer addresses select A6:A0 slots; programming starts when a written slot is repeated, and the trigger address selects the target page/bank. The mGBA change now accepts partial and out-of-order fills. A temporary mCore harness verified partial/out-of-order data, trigger-selected page/bank, and untouched bytes. No physical cartridge was tested.
- **PROBABLE, with local emulator regression evidence:** `$F0` in a new buffer slot is payload; `$F0` on a repeated slot aborts the pending buffer. A temporary mCore harness passed both cases. The command is not hardware-verified.
- The same harness observed a busy status byte before operation completion. A separate harness saved and restored mGBA state during a busy program operation and confirmed completion after restore. These validate the emulator's timing/state handling, not physical timing accuracy.
- Iceboy documents that flash write protection blocks sector 0 and the hidden map region, but sectors 1-7 can still be programmed and erased with protection enabled. The implementation intentionally applies the enable/protect checks to sector 0 and hidden data, not as a whole-chip write lock.
- **Maker fixture / direct dispatcher smoke:** compiled `net-de-get-maker`'s `example/nasu/main.asm` with RGBDS 1.0.3, ran its `fix.py`, and manually assigned ID `G001` (the transform normally done by `push.py`, without connecting to MySQL). The resulting 5,703-byte minigame payload SHA-256 is `ee452580194b2252b2969bdde0bbd2dd48d8f3a7ae138f5402f0968dab12c302`. It was placed at flash offset 0 in a disposable 0x100101-byte `.sav.flash` sidecar; all other flash bytes and metadata were erased (`FF`). A headless mCore harness loaded the original host ROM and that sidecar, then set A=`$10` and PC=`$026D` to invoke the host's real bank-aware dispatch thunk. The host selected flash bank 0 and executed the wrapper at `$4000`, its jump to `$406F`, and the NASU entry code, which then called back into host API code. The run continued for 2,000,000 SM83 steps without a crash. This confirms payload/flash mapping and dispatch entry, but it is a **synthetic dispatch**, not natural menu recognition from `RomList.cgb`/`h0000.cgb`, not proof of normal game selection, and not a full interactive gameplay test. No DB publisher, network server, REON service, or persistent user save was used.
- The local MBC6 Test ROM repository now has commit `045b4d3` (two commits ahead of `origin/main`, not pushed). Its current safe artifact has SHA-256 `45822e9df1cd06dcc98f8875116c8a106552fd46ace0f38933a20549f1174828`. Re-run on the current mGBA working tree: 16,030 frames, 15 PASS, 0 FAIL, 0 SKIP, 5 INFO; M6TS checksum valid. The gated destructive artifact `/tmp/mbc6-test-TD7-TD8.gbc` has SHA-256 `5c71c5959c8c6e810de3a77a0ea84b6ab3a1878c7bfe1ae2f2c562b0e2c01376`; it ran in a disposable save fixture for 16,030 frames with 21 PASS, 0 FAIL, 1 SKIP, 6 INFO, checksum valid. These ROM results exercise the test program against the local emulator; they are not hardware evidence.
- The focused mCore harness passed hidden six-write unlock, partial/out-of-order programming, trigger-selected target page/bank, busy status, most-recent-slot repeat, `$F0` as payload, and `$F0` abort. The busy savestate and legacy sidecar split harnesses also pass. These are emulator implementation regressions, not physical-chip validation.
- The mGBA sidecar is named `.sav.flash`; it stores flash array + 256-byte hidden data + protection metadata (`0x100101` bytes). A temporary harness loaded an older combined `.sav`, split it on sync, and verified SRAM-only `.sav` plus `.sav.flash` sizes. Net de Get itself sees mapped chip contents, not the filename.
- **Unresolved source disagreement:** status reads through the non-operation window and bank selection after erase differ between Iceboy's chip notes and Dan Docs' inference from Net de Get. The current implementation keeps these behaviors isolated pending a focused test/stronger ROM evidence; neither is claimed as confirmed hardware behavior.
- Still needed: focused MBC6 Test ROM coverage for cross-window status/remapping and save/savestate paths; build the Qt frontend in an environment with Qt development packages; and run a valid disposable Net de Get minigame fixture through recognition/launch if the maker format can provide one. The current Podman image lacks Qt development packages, so the Qt target was unavailable in this turn. The safe/destructive ROM cases do not prove that the host ROM recognizes a real installed minigame.
- Do not expand into full URL/server or source reconstruction unless needed to explain an MBC6 behavior or Rafael changes the scope.

## External references checked

- [Pan Docs — MBC6](https://gbdev.io/pandocs/MBC6.html) for the two 8 KiB ROM windows, SRAM windows, and MBC6/flash context.
- [endrift's MBC6 research thread](https://gbdev.gg8.se/forums/viewtopic.php?id=544) for register descriptions and observed command sequences. This thread itself labels several details tentative; treat its command examples as hardware research notes, not a datasheet.
- [Shonumi, Edge of Emulation: Mobile Adapter GB Part 1](https://shonumi.github.io/articles/art14.html), especially the Net de Get section, for reported `h0000.cgb`/`MNGL`, `RomList.cgb`, download-to-box UI, wrapper layout, flash write/readback, and SRAM footer behavior. These are the author's emulator/disassembly findings and guide follow-up, but do not substitute for a trace of this fixture in our current core.
- [Shonumi, Dan Docs — Net de Get](https://shonumi.github.io/dandocs.html#ndg) for additional software/mapper interpretation. Where this differs from the MBC6 thread, keep the disputed mapper behavior explicitly unresolved pending direct evidence.
