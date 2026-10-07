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

- The byte-level RGBDS excerpts in [`home/mbc6.asm`](../../home/mbc6.asm) cover only the two independent selector/type helpers (`00:12BF-12CD`, `00:12E9-12F7`) and unlock helpers (`00:14E2-14F7`, `00:164D-1662`). They are not a full ROM source reconstruction.
- The host's B-window erase/poll path accesses `$6000`; its A-window counterpart accesses `$4000`. In each decoded poll loop, DQ7 is checked through the same window used for that operation, with DQ5 checked on erase and DQ4 on program. The decoded code does not show a status read through the opposite window. This is limited to the decoded routines; it does not establish the chip's cross-window behavior during status mode.
- After an erase poll writes `$F0`, control calls `$1359` and returns; the decoded erase path does not read back array data. `$1359` calls `$1371` (write `$01` to `$1000`), stores `$00` at `$0C00`, then calls `$136C` (write `$00` to `$1000`). After a program poll writes `$F0`, control calls `$136C`, then compares flash data against the source buffer through the operation's same window. These are observed register writes; do not equate them with a specific hardware mode transition without further evidence. We have no trace showing the next opcode accepted after `$F0` or whether an opposite-window read occurred between the reset write and the next command.
- The erase routines set selector 2 while issuing the `$80` command sequence, then restore the saved target address/bank context before writing `$30` at `$6000` (B) or `$4000` (A). This is consistent with the target address selecting the sector. The source does not yet establish the physical sector-number formula independently. The `$0400/$0800` accesses in nearby code have not been conclusively mapped to hidden-map selection/address semantics; no claim is made here about hidden-map reads through either window.
- Earlier headless harnesses and the synthetic dispatcher run at `00:026D` did not establish a natural list or launch. A later manual GUI run in mGBA Linux does establish natural local selection and gameplay for the disposable Maker fixture; see “Natural local minigame launch” below. The GUI observation does not turn the older headless matrix into a menu trace.

The first partial RGBDS excerpt is deliberately limited to routines whose instruction boundaries and operands are unambiguous. Sector erase, status polling, hidden-map selection, and the natural loader remain disassembly/analysis notes rather than reconstructed RGBDS source.

## Analysis tooling and limits

### Natural local-slot checkpoint (2026-10-06)

- **CONFIRMED (headless mGBA trace, disposable fixtures):** the candidate `.sav` has SYS1 length `$02A3`; stored additive checksum `$0AC4` matches the recomputed value. Its slot bytes at `$04F0-$04F4` are `0E 00 10 00 FF`. The flash sidecar is a disposable Maker NASU candidate with its payload header checksum corrected after assigning ID `G001`.
- **CONFIRMED (bounded trace only):** after 1,200 frames the CPU is at `$4027` (A selector `$0B`, B selector `$0D`); Start then wait leaves it at `$4027`; A then wait ends at `$5D63` (A selector `$12`, B selector `$61`). The slot bytes and SYS1 checksum remain unchanged throughout these phases.
- **Scope of this headless trace:** it does not reach a local list/box-selection screen or show the slot Index being resolved. The later GUI run below supplies the natural-recognition and launch evidence. The exact host routine that reads the Index/header still needs to be identified before reconstructing that path in source.
- **CONFIRMED (limited input matrix):** starting from the same boot point, B, Select, Right, Left, Up, and Down each leave the CPU at `$4027` after a 3-frame pulse and 60-frame wait. Start+B, Start+Select, Start+Right, and Start+Left each reach `$5D63` after the pulse and `$401D` after a 300-frame wait. This identifies a repeated input path only; the harness framebuffer output is visibly corrupted, so these PCs are not assigned a screen/menu label.
- **CONFIRMED (follow-up timing matrix):** during the post-Start attract/demo interval, a second Start or A pulse of 1 frame reaches PC `$5D65` at frame 1444; 30- and 120-frame pulses end at PC `$401D` (frames 1473 and 1563). All six runs finish with selectors A=`$12`, B=`$61`, slot bytes unchanged, and SYS1 checksum `$0AC4`. These inputs do not establish a route to local list selection.
- Fixture files remain under `/tmp/netdeget-natural-exp/validated/`; they are not repository inputs. The ROM hash was rechecked as `9fb1e6e4a637796b8624bd2de6c9abaa9e758546b620cb5dc8441b07c288bc63`.

### Runtime callback and launch-gate map

- **CONFIRMED (byte-level runtime map, headless mGBA):** the PCs in the input matrix are callback/graphics code, not the minigame dispatcher. ROM0 `$0451` sets A=`$07`, B=`$00`, then calls `$0264`; `$0264` jumps to `$23E4`, which selects a three-byte callback at `$05C8 + 3*A` and jumps through it. Table index 6 at `$05DA` is selector `$0B`, address `$4000`; index 7 at `$05DD` is selector `$12`, address `$4000`. The live callback at `$23E4` returned to `$0458`; for index 7 its target was `$12:$4000`, and the pushed return was `$242A`.
- **CONFIRMED (caller/return and mapper context):** PC `$4027` ran with MBC6 A selector `$0B` and stack return `$242A`; file offset `$16027` (physical 16 KiB bank `$05`, upper half). PC `$401D` ran with A selector `$12`, stack return `$242A`; file offset `$2401D` (physical bank `$09`). PC `$5D63` ran with A selector `$12`, B selector `$61`, HL=`$6000`, DE=`$9800`, BC=`$0400`; stack return `$5E86`. Its caller at `$5E83` calls `$5D5C`, a VRAM-safe copy loop; `$5D63` is inside that loop. The input matrix did not execute `$026D`/`$254E`.
- **PROBABLE (static launch gate):** ROM0 `$0521` copies WRAM `$C624` to `$C671`. The following code compares `$C671` with `$FF`: `$FF` skips the launch call, otherwise it calls minigame dispatcher `$026D` with A=`$C671`. This makes `$C624` a candidate selected-game index, but the exact SRAM slot Index-to-`$C624` assignment has not been traced. No literal references to the Maker labels `sGameArrangement` or the box-name addresses were found; indirect SRAM parsing remains possible. A byte-level excerpt is in [`engine/local_minigame_gate.asm`](../../engine/local_minigame_gate.asm), with the callback data in [`data/runtime_callback_table.asm`](../../data/runtime_callback_table.asm).

### Natural local minigame launch (2026-10-06)

- **CONFIRMED (manual GUI runtime reported by Rafael, mGBA Linux at `d4096cc00`):** with the original host ROM (SHA-256 `9fb1e6e4a637796b8624bd2de6c9abaa9e758546b620cb5dc8441b07c288bc63`) loaded from its permanent path and saves isolated under `/tmp`, a 5,703-byte Maker NASU payload (`G001`) at flash offset 0 appeared in BOX1 as item 16. The fixture has Index `$10` at SRAM offset `$04F2`, Box `$00` at `$04F3`, and valid SYS1 checksum `$0AC4`. The observed route was title Start → X menu → X minigames → BOX1 list/NASU → X submenu (Start/Info) → X Start → NASU title → X gameplay; GAME OVER followed after about five seconds. The flash sidecar remained byte-for-byte unchanged (SHA-256 `882397c8b568e13cb63d45cc30f72821eb9ba946454012f23551acc2f3dd67fc`); SRAM changed during gameplay.
- **CONFIRMED (Box 2 fixture, same GUI run):** changing the Box byte at `$04F3` from `$00` to `$01` and recomputing SYS1 changed the stored checksum from `$0AC4` to `$0AC5`. A 1,200-frame headless boot also preserved the slot and checksum. In the GUI, BOX2 listed NASU and the same route reached GAME OVER. Both saves were disposable `/tmp` fixtures; neither the original ROM nor real saves were modified.
- **Evidence boundary:** the GUI run confirms natural local recognition, selection, launch, and a bounded gameplay outcome. It is separate from the earlier headless callback trace; the GUI session did not provide an instruction trace proving which code reads SRAM offsets `$04F2/$04F3`, how the flash header is validated, or whether its route passes through `$026D`. No hardware or network test is claimed.

The first analysis used the Mobile Trainer project's SM83 `cfg.py` and GhidraBoy setup as technical references. The Mobile Trainer skill itself is scoped only to that project. Its CFG assumes 16 KiB physical banks and only infers MBC5 bank writes, so MBC6 selectors and independent 8 KiB windows need explicit translation/seeds. GhidraBoy's headless analysis was partial and is only a cross-check.

Temporary artifacts from the first milestone are outside this repository under `/tmp/netdeget-*`; they are disposable and not authoritative sources.

The byte listings used for the focused routine map are `/tmp/netdeget-flash-decoded.out`, `/tmp/netdeget-flash-mbc-map.out`, `/tmp/netdeget-flash-candidates.out`, and `/tmp/netdeget-ghidra-out/analysis/ghidra_disasm_bank00.txt`. They are generated artifacts, not inputs to trust in place of the ROM. Header/hash was rechecked during this work: `9fb1e6e4a637796b8624bd2de6c9abaa9e758546b620cb5dc8441b07c288bc63`.

### Wrapper/parser lead (2026-10-06)

- **PROBABLE, static-only lead:** physical 16 KiB bank `$18`, CPU `$4092` (file offset `$060092`; MBC6 selector `$30`, window A) passes `DE=$4009` and `BC=$0002` to ROM0 `$01B6` (stub to `$0CA5`). `$0CA5` saves that source pointer, searches the catalog table, then a successful branch reloads the selected record pointer and computes `HL=DE+9` before passing it to `$1176`. This is a nine-byte-prefix pointer path, but the selected record's exact format is not established; it is not proof that `$4009` is an HTTP wrapper body.
- **PROBABLE, static-only lead:** ROM0 `$0FAC` obtains a pointer from the six-byte table at `$A002` via `$1162`, reads a 16-bit value at `pointer +6/+7`, and performs bounds arithmetic using `pointer + value +9`. ROM0 `$0F15` reads the same field and sums `value +7` bytes starting at `pointer +2`. These instructions show a size-bounded block operation, but do not establish that this pointer is the HTTP wrapper base or how its fields map to the documented wrapper. Treat it as a parser candidate only.
- **HYPOTHESIS (document/code offset comparison, not a parser identification):** Dan Docs describes the download wrapper as comment length `L` at byte 0, uncompressed size at offsets `L+5/+6`, check bytes at `L+7/+8`, and payload at `L+9`. If `$A002`'s pointer were wrapper byte 0 and `L=1`, its size at `pointer+6/+7` would align with the documented uncompressed-size field. However, the code's `pointer + size +9` differs by one from the expected exclusive end `pointer + size +10` under that same interpretation. Pointer bias, `L`, the meaning of this size, and `$0FAC`'s end convention are unresolved, so this is a comparison lead only. Source: [Dan Docs, Net de Get wrapper](https://shonumi.github.io/dandocs.html#ndg).
- **Scope boundary:** Rafael authorized a local synthetic test of Net de Get writing bytes to flash, after offline MBC6 tests. This permits following only the local byte-to-flash path needed for that check; generic Mobile Adapter/REON protocol work remains outside scope. No synthetic serial trace has been run. The unresolved `$A002`/`$0FAC` candidate remains separate and static-only.
- **PROBABLE, static caller and writer interface:** the A-window buffered program routine begins at ROM0 `$1568` (the command sequence begins at `$1570`). A caller exists in physical 16 KiB bank `$03`, window B selector 6, CPU `$61F4-$620B` (file offset `$00C1F4-$00C20B`; conventional 16 KiB tool listing `$41F4-$420B`): it loads `HL` from `$DF17/$DF18`, sets `$CEE6/$CEE7` to `$1000`, sets `DE=$D000`, and calls `$1568`; it branches on the returned A value. The writer saves `BC` and uses it to map the target A-window selector, saves `HL` (flash address) and `DE` (source pointer), and consumes the remaining count from `$CEE6` in chunks of at most `$80`, retrying a page after readback mismatch. `$CEE9` gates entry through `$1362`. This is a static link from a staged buffer at `$D000` to the flash writer, but does not establish who fills that buffer or prove a natural download trace. The selector setup and the relationship to `$0FAC/$0F15` remain unresolved.
- **CONFIRMED (synthetic local mGBA trace, not a natural download):** the test seeded a deterministic 4 KiB block in WRAM bank 1 at `$D000`, then entered the real ROM caller at its post-wait point, physical 16 KiB bank `$03` mapped as 8 KiB selector 6 in window B (`PC=$61E6`). That leaves window A free for the writer: selector 1 at `$2000`, flash chip-map bit `$08` at `$2800`; the caller/writer enabled MBC6 flash and write-enable through `$0C00/$1000`. With `BC=$0801`, target `HL=$4000`, and `$CEE6/$CEE7=$1000`, the ROM writer completed 32 program-buffer triggers of up to `$80` bytes. Mapper events were window A, selector 1, target range `$002000-$002F80`; final PC was `$6224`, A was zero, and `$CEE6/$CEE7` reached zero. The mapped 4 KiB region changed from erased `$FF` data (pre-run SHA-256 `f47a8ec3e9aff2318d896942282ad4fe37d6391c82914f54a5da8a37de1300c6`) to the effective staged bytes with zero mismatches. Three bytes in the synthetic buffer are the configured `$DF12/$DF17/$DF18` variables. After core unload, the disposable `.sav.flash` target at file offset `$2000` matched those effective bytes; reopening the ROM in a fresh core also yielded zero mismatches and `busy=0`. Test sidecar SHA-256: `bb1974fbcff7c4ae4a1b40e8ef47cb78a5c3ca6182b085ffcbe5adc453ec55bc`. mGBA binary metadata: `0.11-feature/full_server-9334-fca224b25`. This proves the prepared-buffer→Net de Get ROM writer→MBC6 emulation→sidecar persistence path only. It does not prove natural buffer production, service/download behavior, or hardware behavior.
- **Correction — PROBABLE (static), exercised in synthetic runtime:** `$FF8A` is VBlank readiness, not a network handshake. Vector `$0040` jumps to `$0601`; `$0607` writes 1 to `$FF8A`. The writer callback at selector 6/window B `$61C5` waits for and clears it. ROM0 `$35C2` maps A; `$35D7` maps B. `$CEE9` remains a software status bit of unresolved origin, separate from mapper flash enable.

### ROM producer → WRAM → flash (2026-10-06)

- **PROBABLE (static call chain):** ROM0 installer `$36BC` maps A selector `$10` at `$3708`, maps B selector 6 at `$379F`, and calls `$4000` at `$37B6` with source SRAM bank 2, `HL=$B000`, callback `DE=$61C5`. Selector `$10` is file offset `$20000`, physical 16 KiB bank 8 lower half. The callback programs a 4 KiB WRAM buffer via ROM0 `$1568`.
- **CONFIRMED (synthetic producer-entry trace, not natural acquisition):** the harness stages an artificial wrapper in disposable SRAM, enters the actual ROM producer at A selector `$10:$4000`, and lets the ROM parse, decode/copy, fill WRAM bank 4 at `$D000`, wait on real VBlank, and call its actual flash writer. No output bytes are injected into the writer buffer. Synthetic CPU entry and mapper/shadow setup are explicit in `fixtures/host-writer/trace.c`.
- **PROBABLE (static parser), exercised by synthetic cases:** `$40FB` skips comment length `L`, reads reserved byte `L+1`, mode `L+2` (0/raw or 5/compressed), input length `L+3/+4`, output length `L+5/+6`, check bytes `L+7/+8`, and body at `L+9`. The recorded matrix uses `L=3` (`abc`). Raw reader `$4B57` skips 256 bytes after each output chunk of at most 512 bytes. A flat raw body failed after the first chunk; adding those skipped bytes passed. This is the ROM reader's tested SRAM contract, **not proof of HTTP framing**. Mode 5 wrappers produced by the external Maker `bmvj_compress.py` passed without raw-mode gaps.
- **CONFIRMED (four synthetic runs):** 5,000 deterministic bytes and the corrected 8,192-byte PAD payload each pass in raw and compressed modes. Every run returns `PC=$C100`, `A=0`, `busy=0`, writes 64 flash program buffers at offsets `$002000-$003F80`, and matches all declared output bytes. A fresh core reopens the generated `.sav.flash` with zero mismatches. Reproduction script: `fixtures/host-writer/run.sh`; recorded artifacts: `/tmp/netdeget-producer-y9ans3`. Linked binary metadata: `0.11-feature/full_server-9334-fca224b25` (not a claim that the library was built from current checkout HEAD).
- **CONFIRMED (synthetic partial final buffer):** output length 5,000 invokes two 4 KiB callbacks. The final 3,192 bytes outside declared length contain 3,179 nonzero bytes retained from the previous buffer. Do not assume zero padding for partial output. Declared content matches exactly; final partial-block serialization needs the length/checksum contract when constructing valid minigames.
- **PROBABLE (static checksum):** ROM0 `$38B0` reads the block count at flash B `$6005`, sums that many 8 KiB blocks while excluding checksum bytes `$606D/$606E`, and compares the expected little-endian word there. Bytes `$3B/$B3` take an early return with Z set; this special case is separate from the additive comparison. The PAD build now emits the complete zero-padded declared block with this additive checksum and entry offset `$006F`, following the Maker header. Synthetic entry to `$38B0` on the reopened PAD flash returns Z=1; flipping one payload bit returns Z=0, in both modes. Natural PAD validation is coordinated with the mGBA chat; these producer runs do not claim it.
- **Limits:** no HTTP receive trace, network acquisition, adapter exchange, server download, or hardware validation is established by this matrix. The `$A002/$0FAC` catalog candidate remains separate. ROM hash before and after all runs stayed `9fb1e6e4a637796b8624bd2de6c9abaa9e758546b620cb5dc8441b07c288bc63`; saves are fresh temporary fixtures.

## Payload, catalogue, and box distinction

- **CONFIRMED (source/code structure):** the Maker reference stores seven box names and 128 SRAM slot records with separate Index and Box bytes; the minigame header stores game ID/title/category/genre but no box assignment. The payload in flash and its visible slot/box organization are distinct data. Source: the local Maker clone `/tmp/net-de-get-maker-review/include/ram/sram.asm`, `include/header.asm`, and `push.py`.
- **CONFIRMED (manual GUI runtime, mGBA Linux at `d4096cc00`, as reported by Rafael):** a disposable Box 2 fixture changed the slot Box byte from `$00` to `$01` at SRAM offset `$04F3`, recomputed the SYS1 additive checksum from `$0AC4` to `$0AC5`, and preserved Index `$10` at `$04F2`. A 1,200-frame headless boot also preserved the slot and checksum. The GUI listed NASU in BOX2 and followed the same natural launch route described below through GAME OVER. This validates the fixture's Box assignment in this run; it does not prove hardware behavior.
- Shonumi's article reports that selecting the online minigame-list option requests `RomList.cgb`, while `h0000.cgb` requires `MNGL` magic. That online account remains external evidence; the local GUI route above is direct emulator evidence. Keep boot/title, list, slot selection, dispatcher, game entry, and gameplay as separate outcomes.

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
- Still needed: trace the GUI route instruction-by-instruction to identify the routines that read Index/Box, validate or map the flash header, and enter `$026D` (if used). The GUI run is emulator evidence only; no physical cartridge run is claimed. Cross-window MBC6 status/remapping and save/savestate test coverage remain separate emulator work.
- Do not expand into full URL/server or source reconstruction unless needed to explain an MBC6 behavior or Rafael changes the scope.

## External references checked

- [Pan Docs — MBC6](https://gbdev.io/pandocs/MBC6.html) for the two 8 KiB ROM windows, SRAM windows, and MBC6/flash context.
- [endrift's MBC6 research thread](https://gbdev.gg8.se/forums/viewtopic.php?id=544) for register descriptions and observed command sequences. This thread itself labels several details tentative; treat its command examples as hardware research notes, not a datasheet.
- [Shonumi, Edge of Emulation: Mobile Adapter GB Part 1](https://shonumi.github.io/articles/art14.html), especially the Net de Get section, for reported `h0000.cgb`/`MNGL`, `RomList.cgb`, download-to-box UI, wrapper layout, flash write/readback, and SRAM footer behavior. These are the author's emulator/disassembly findings and guide follow-up, but do not substitute for a trace of this fixture in our current core.
- [Shonumi, Dan Docs — Net de Get](https://shonumi.github.io/dandocs.html#ndg) for additional software/mapper interpretation. Where this differs from the MBC6 thread, keep the disputed mapper behavior explicitly unresolved pending direct evidence.

### PAD natural input and incomplete exit validation

- **CONFIRMED (natural emulator run reported by mGBA chat, HEAD `4c8066be4`):** corrected PAD payload (8,192 bytes, SHA-256 `bc411ff218748c2e3f08977f82b8812fb0673ec69d4538eef345f274ea18b1a7`) launches through BOX2 and records all eight controls with counters `0101010101010101`, held mask zero after release.
- **CONFIRMED (natural joypad-only mGBA run, HEAD `4c8066be4`):** corrected WRAM version exits with Start+Select and relaunches in the same core. Host changes slot Box `$04F3` from 1 to 0; select item 16 in BOX1 using sixteen Down pulses, then A/submenu and A/Start. Final `PC=$425F`, A selector 0, PAD frame counter 165, held mask zero, all eight counters reset. Input matrix before exit was `0101010101010101`. Screenshot `/tmp/netdeget-pad-relaunch-l6dmnjkk/final.png` confirms PAD re-entry; ROM and full flash sidecar remain unchanged. Fresh-core boot of post-exit save also relaunches via BOX1 item16 (`/tmp/netdeget-pad-box1-item16-qj_l_3cn`). The earlier fixed Right/A/A macro looked in empty BOX2; it did not establish a freeze. The cause of the host Box relocation remains unresolved.

- **Fixture correction (source, synthetic matrix and natural relaunch passed):** original PAD state at `$C700-$C713` overlapped host working state; post-game API `$029D` reaches A selector `$16:$4C87`, which reads `$C705` and `$C73C` before updating SRAM. PAD state now uses Maker workspace WRAM bank 1 `$D800-$D813`; new 8 KiB payload SHA-256 `0e42875ef2569905d056f895ab5d6998e4f17709875dd27f13cbd9b20c2158b0`. All four producer/reopen tests and the checksum corruption tests pass with this version. The natural input test reported by mGBA also passes; natural exit and route-aware relaunch now pass. No MBC6 regression is inferred.

- **Local HTTP body handoff:** `/tmp/netdeget-http-pad/0000.G001.cgb` is the complete 1,013-byte Maker mode-5 wrapper (L=0), SHA-256 `0c7e9f6b68878bde8d2610e3b553023f81305b4765a82303c2d992e5633d973a`. Header `00 00 05 EC 03 00 20 00 00` declares input 1,004 and output 8,192 bytes. That exact body passes the synthetic producer and fresh-core persistence checks. REON/mGBA chats have its disposable path and metadata for local transport testing. Natural HTTP acquisition remains unverified.

- **Updated independent HTTP fixture:** corrected WRAM version is `/tmp/netdeget-http-pad-wram1/0000.G001.cgb`, 1,014 bytes, SHA-256 `a8f6e181ddedf0f5d0b1b8e164d9e41edcddaadd14cf0c9f4730ede455560a24`; header `00 00 05 ED 03 00 20 00 00`. Exact-body producer/reopen and original/corrupted checksum checks pass. The previous served fixture was left unchanged so the HTTP test version remains traceable.

### Online catalog visibility gate (2026-10-06)

- **CONFIRMED (natural transport/buffer capture reported by mGBA):** GET and authenticated empty POST return identical 430-byte catalogs, SHA-256 `b0d304609d7aa7c623feb70afe629215c6c8a289b5092d193e34eb704f3a9155`, count 5 and offsets `$18/$78/$B8/$F8/$170`. Only four baseline games appear. Removing the installed slot, then erasing all flash in a disposable checksum-valid fixture, does not make PAD visible; installed-ID filtering alone is not an explanation.
- **CONFIRMED (natural WRAM snapshot):** `/tmp/mgba-online-n7kfh2sm/stage-88.wram` has the five-record response in bank 5 at `$D000`; bank 2 `$DA81` contains accepted indexes `00 01 02 03`, `$DBC1=1` omitted entry and `$DBC6=$FF`.
- **PROBABLE (static ROM gate, correlated with that natural buffer):** native A selector 23 `$4A93` resolves a record to WRAM bank 5 `$D000 + offset`. Filter `$495E` reads minimum levels at `+$0C..+$0E`, hidden gate words at `+$10/+$12`. UI reads title length at `+$14`; download reads blocks at `+$04` and ID at `+$06..+$09`. The custom serializer used offsets four bytes earlier; its title bytes become gate words `$5008/$4441`. Accepted baseline title lengths are at `+$14`. A four-byte zero prefix is the justified local retest candidate; prefix semantics remain unknown. See `engine/catalog_record_gate.asm`.
- **External-source disagreement:** the published [Dan Docs record layout](https://shonumi.github.io/dandocs.html#ndg) describes levels/title four bytes earlier than the observed ROM. Use the ROM and a natural retest to resolve this fixture contract; no server production change is established here.

- **CONFIRMED (natural corrected catalog):** REON's four-byte-prefix correction returns 434 bytes, count 5, SHA-256 `8f072d41c39146380053abe0281835b4a639511a523cd5963bc67ef222aec043`. `/tmp/mgba-online-n7kfh2sm/corrected-98.png` was inspected: PAD TEST is visible and selected. This confirms the encoder correction's visibility effect; individual field semantics remain tied to the static routine map until a targeted instruction trace.
- **CONFIRMED (bounded natural download stage, reported by mGBA chat):** the ROM requests `0000.G001.cgb`, completes GB00 authentication and receives the exact 1,014-byte wrapper (GET and follow-up POST). It shows a download-complete dialog. Final Box selection, flash persistence and launch from the acquired payload are still being checked; the dialog alone is not end-to-end persistence evidence.

### Natural local HTTP acquisition and flash installation

- **CONFIRMED (natural joypad route reported by mGBA, disk bytes independently checked):** starting from the disposable erased-flash fixture, the corrected catalog exposes PAD; GET/GB00 authentication/GET 200 and follow-up POST return the exact Maker wrapper. The first download-complete dialog precedes flash programming. A → choose Box → Right/BOX2 → A completes storage (stage 114, `/tmp/mgba-online-n7kfh2sm/installed-box.png`, inspected).
- **CONFIRMED (persisted bytes):** `/tmp/mgba-online-n7kfh2sm/padtest.sav.flash` first 8,192 bytes exactly match corrected PAD SHA-256 `0e42875ef2569905d056f895ab5d6998e4f17709875dd27f13cbd9b20c2158b0`, with zero mismatches; flash offsets `$002000-$0FFFFF` remain entirely `$FF`; hidden/protection metadata match the erased initial sidecar. Complete sidecar SHA-256 `cf6d32c72339ee34bc0029142a7cf0a8e7b35935544302a779a0a52c10bc511b`. SRAM slot is Index/Box `10/01`. No original ROM or real save was changed.
- **Boundary:** this is a local HTTP/adapter fixture and emulator runtime outcome, using isolated DNS and TCP80→localhost8088 remapping. It is not production service, physical adapter or flash hardware evidence. Natural launch/input/exit/relaunch of this acquired payload now passes in the same core; fresh-core reopen is checked separately.

- **CONFIRMED (natural end-to-end same-core outcome):** the mGBA macro restores the erased initial sidecar before every run, then performs boot/menu → disposable adapter/ISP/GB00 → corrected catalog → wrapper download → BOX2 storage → local BOX2 PAD launch → eight presses/releases → Start+Select exit → BOX1 item16 relaunch. No CPU/register injection is used. `/tmp/mgba-online-n7kfh2sm/typed.log` stage 126 launches PAD, stage 142 records counters `0101010101010101` with held zero, stage 144 returns to host, and stage 180 re-enters PAD at `PC=$425F`, A selector 0, frame count 165, counters all zero. Those log values were checked directly. Macro: `/tmp/mgba-online-password-run.py`; runner source `/tmp/mgba-netdeget-local-http.c`; Linux checkout HEAD `4c8066be47ff`. Payload persists exactly, with remaining flash and metadata unchanged as above. Fresh-core reopening of the acquired save now also passes, as recorded below.

- **CONFIRMED (fresh-core reopening, log inspected):** `/tmp/mgba-downloaded-reopen-7fc8_kt9/reopen.log` stage 44 naturally launches acquired PAD via BOX1 item16 (`PC=$425F`, A selector 0, frame count 165, counters zero). Stage 45 presses A (held 1, counter `0100000000000000`), stage 46 releases (held zero), and stage 48 returns to host after Start+Select. Flash remains unchanged. Linked library `/tmp/mgba-mbc6-head-linux/libmgba.so.0.11.0` SHA-256 was independently checked as `4f1f2c68084400eaa544131bdc3b6b807a7f688e7edd8baf83d2fcabffb43f9d`; this hash prefix is not a Git HEAD. Checkout HEAD is `4c8066be47ff2881c70974280297e04227965c4f`. Full original ROM hash remains unchanged.

## Publication and integration recheck (2026-10-06)

Rafael authorized publication and selected the existing `main` branches for
this analysis repository and the Maker. This repository remains a partial
analysis, not a complete ROM reconstruction or server implementation.

- **CONFIRMED (byte equivalence):** RGBDS 1.0.3 assembled all four excerpts;
  their linked section bytes matched the read-only reference ROM exactly:
  runtime callback table 6 bytes, catalog record pointer 49 bytes, local
  selection gate 70 bytes, mapper/unlock helpers 74 bytes. Reproduce with
  `python3 tools/check_excerpts.py ORIGINAL_ROM`. Byte equivalence does not
  establish a natural instruction trace or resolve field semantics.
- **CONFIRMED (repeated natural fixture run):** PAD BOX2 launch, eight inputs,
  Start+Select exit and BOX1 item16 re-entry passed in
  `/tmp/netdeget-pad-natural-c7rNHe`. Full flash and original ROM stayed unchanged.
- **CONFIRMED (repeated synthetic producer/writer runs):** raw/compressed 5000
  and 8192-byte cases passed, all declared bytes matched, each fresh core reopened
  with zero mismatches, and original/corrupted checksums returned Z=1/Z=0.
  Evidence: `/tmp/netdeget-producer-X13U3X`. Partial-output padding still retains
  earlier buffer content; it is not guaranteed zero. CPU entry remains synthetic.
- These reruns used the pinned Linux library at `/tmp/mgba-mbc6-head-linux`,
  runtime commit `358230c82773aec67dff2995eb77fbd84f8ea8a2`. They do not imply a
  repeat of production acquisition or hardware validation. The later mGBA
  documentary checkpoint and platform build runs are maintained by its owner.
- The original Maker guides/examples and C integration are now published in
  `zenaror/net-de-get-maker`; C PAD passed local and production acquisition,
  controls, return and fresh-core persistence as documented in its
  `docs/validation.md`. Reaction remains offline-only. No accounts, credentials,
  ROM, saves or server responses from those rounds are committed here.
- Test ROM received exact host offsets and evidence boundaries for its offline
  work: A writer entry 1568, final-slot trigger 15B1 (`LD [HL],0` after `DEC HL`),
  4 KiB callback at selector6/windowB 61C5, checksum 38B0 and dispatcher026D.
  Opposite-window status, post-erase selector and hidden-map interpretations
  remain unresolved; preserve external cartridge-specific reset references.


## Incremental disassembly verification cycle (2026-10-06)

The published excerpts now include the local dispatcher at ROM0 `$254E-$25CA` and the local-list rebuild/template-copy code at ROM0 `$3E00-$3ED7`. Their semantic names remain **PROBABLE**; static byte equivalence does not establish natural execution of all branches. The entry HL allocation and the `$38B0` callee remain unresolved in this source tree.

`make verify REFERENCE_ROM="/external/path/game.gbc"` assembles, checks section boundaries and entry symbols against `config/excerpts.tsv`, runs 11 synthetic checker tests, and compares all emitted sections against the hash-checked external original. The final pass compared **12 sections / 837 bytes** with no difference. It excludes padding and makes no complete-ROM reconstruction claim.

The same cycle passed in a private source copy. A baseline assembled from prior published `6312b21` had 30 address symbols; all 30 remain at the same coordinates in the candidate. The private candidate and working-tree sparse images are identical. Local artifacts: `/tmp/netdeget-private-cycle-m0z212gg`; final equivalence artifacts: `/tmp/netdeget-excerpt-equivalence-cmtqfp11`. Temporary artifacts are supporting receipts; the maintained manifest and scripts reproduce the checks.

Negative fixtures demonstrate rejection of altered section bytes, missing/extra/moved sections, missing/moved/duplicate entry symbols, invalid coordinates, overlapping intervals and equally truncated byte slices. These fixtures test the checker, not the game or hardware. The original ROM was opened read-only and its hash was rechecked after comparison.


### Checksum follow-up

ROM0 `$38B0-$391B` is now extracted as `CheckLocalMinigameChecksum` (108 bytes).
**PROBABLE static interpretation:** stored bytes `$606D/$606E` equal to `$3B/$B3`
return early with Z set. Otherwise BC starts with the two's-complement negative
of the sum of those stored bytes; the routine adds bytes read through window B,
restores its saved selector, and compares BC with the stored little-endian word.
The scan caller tests NZ after this call. This describes the decoded arithmetic,
not a new natural checksum trace or a guarantee for arbitrary payload sizes.

The page counter D is formed by `SWAP A; RLCA` on the byte at `$6005` and then
consumed by an 8-bit decrement loop. Preserve that operation rather than
replacing it with widened multiplication: e.g. input `$08` produces D=`$01`,
while zero D wraps the loop through 256 iterations. The static interpretation
must retain those cases; the meaning of exceptional counts remains unresolved.
Window B advances to the next selector whenever HL reaches `$8000` and restarts
at `$6000`. No original ROM logic was patched.

Final gates passed: **13 sections / 945 bytes**, 11 synthetic checker tests,
private candidate identical to the working-tree image, and all 45 address symbols
from published `4dc64ca` unchanged. Artifacts: `/tmp/netdeget-private-cycle-mxhfid_h`
and `/tmp/netdeget-excerpt-equivalence-2xa_anya`. `make private-check` now maintains
this reproducible source-copy and published-symbol preservation check.


### Template and menu-entry follow-up

`CopyLocalListTemplate` maps native B selector `$15` and copies `$70` bytes from
CPU `$71D4`; `data/local_list_template.asm` preserves precisely that statically
read interval. File `$2B1D4-$2B243` is RGBDS physical bank `$0A:$71D4-$7243`.
The **PROBABLE** template name does not establish the complete object extent or
individual fields. Raw bytes and original encoding are preserved without translation.

`engine/menus/local_entry.asm` extracts only A selector `$14:$4000-$4029`, ending
before the continuing instruction at `$402A`. It polls through `$0279`, tests
held Select, and calls `$3E00` after `$01B6` with BC=`$02A3`, DE=`$3ED8`.
The resulting HL and its destination allocation remain unresolved. Existing
natural held-Select observations are not expanded into proof of every branch.

Final maintained intervals total **15 sections / 1099 bytes**. The canonical
plan and unknowns are in README; AGENTS references the global OMM project rules
and lists only this project's adaptations, including partial-byte equivalence.


### Local storage open, pointers and bounded CPU probes

**PROBABLE static interpretation:** `$01B6` jumps to `$0CA5`, saving DE as a
four-byte name pointer and BC as requested size in HRAM `$FF9E-$FFA1`.
The menu supplies `SYS1` at `$3ED8` and size `$02A3`. Search `$0F3E` checks
six-byte directory entries at `$A002 + 6 * index`, stops at an empty pointer,
compares all four name bytes, and bounds the search at `$82` entries.

| Unit | Static layout / behavior | Limit |
| --- | --- | --- |
| Directory entry | header pointer +0/+1, name +2..+5 | 130-entry search does not admit arbitrary byte indices |
| Record header | checksum +0/+1, name +2..+5, size +6/+7, continuation byte +8 | names/fields are static interpretations |
| Existing record open | successful name check returns header +9 in HL | stored capacity is not compared to requested BC |
| New record | initializes requested data length, then returns header +9 | no new natural creation trace |
| Result helper `$1176` | preserves AF/DE; records HL at C677/C678 and A at C679 | do not assume one universal meaning for A across callers |

Creation's first-header address `$A30E` follows the two-byte directory checksum
and 130 six-byte entries. The directory-checksum helper `$106D` sums `$030C`
bytes from `$A002`, then compares with `$A000` through `$200A`. `$200A` preserves
HL/DE while its subtraction helper supplies equality/carry flags. Record checksum
`$0F15` reads stored size +7 bytes beginning at header +2. Exceptional zero/wrapped
sizes and the recovery function `$108E` remain separate investigation tasks.
The existing-open failure path at `$0D15` deliberately pops a stack word; it is
preserved, not normalized into a common return convention.

Extracted sections total **23 / 1730 bytes**, compared exactly to the reference.
`fixtures/local-storage/probe.c` runs original opcodes in mGBA with forced entry,
registers and synthetic memory: **1082 assertions** passed on core
`431041ac6e264b119476d47ecf9ab96f03f11d54`, version
`0.11-feature/full_server-9343-431041ac6`. Artifacts:
`/tmp/netdeget-storage-probes-f39woo7r`. These are synthetic helper checks, not
proof of natural opening/creation, complete storage safety or physical hardware.
No save file is loaded and the original ROM hash remains unchanged.

The synthetic fixture also creates a fresh SYS1 record through `$01B6`, checks
HL=`$A317` and the requested `$02A3` length, then forces the stored size to two
bytes and reopens with the larger requested size. That existing-open case leaves
the two-byte stored size unchanged and still returns `$A317`. A forced `$01B9`
close updates the record checksum. These bounded cases test the static distinction
between new/existing records; they do not establish the safety of arbitrary
corrupted records, natural menu operation or disk persistence.


### Directory recovery and SRAM clear

`home/local_storage_recovery.asm` reconstructs ROM0 `$108E-$114E` (193 bytes).
**PROBABLE static interpretation:** recovery clears the directory, walks record
headers from `$A30E`, checks each stored checksum against its data sum, writes
accepted pointers/names into the six-byte directory, and advances by stored
length +9 when header byte +8 requests continuation. A returns the rebuilt count
from `$FF9D`; C is one on checksum mismatch and zero on the decoded termination
paths. No general record-length or recovered-entry capacity guarantee is asserted.

Six forced-entry fixtures exercise empty storage, one/two valid records, checksum
failure in the first/second record, and a valid zero checksum. The invalid-second
case returns A=1/C=1 and retains only the first pointer. The zero-checksum fixture
has a 260-byte payload whose header/data sum is exactly 65536 and stored checksum
zero; it returns A=0/C=0 without inserting the record. This reproduces the static
zero termination condition, not a natural-data occurrence or a proposed ROM fix.

The separate `$113E` helper clears 4096 bytes at `$A000` after writing `$0400`.
The synthetic fixture checks all bytes and unchanged data at `$B000`. It does not
perform flash erase or disk persistence. The expanded fixture has **1110 assertions**;
source interval totals are **24 sections / 1923 bytes**, with exact-byte gates.


### Menu loop and indirect state dispatch

**PROBABLE static interpretation:** native A `$14:$402A-$406B` is the menu loop
and cleanup; `$406C-$407D` reads state `$D000`, rotates it left with `RLCA`,
reads a word and jumps via `JP HL`. `$407E-$4089` is a six-word table whose first
target begins immediately at `$408A`. These intervals are physical RGBDS bank
`$0A`; native mapper selectors remain 8 KiB units. Original redundant branches
are preserved, including a conditional jump to its immediate successor.

Forced-entry probes map A `$14` and stop at the indirect destination before
executing it. States 0..5 select `$408A/$42CD/$42E6/$42F9/$4303/$43C0`. State
`$06` reads the first two code bytes after the table and selects `$26CD`; `$80`
rotates to 1 and selects unaligned `$CD40`. These are synthetic mechanics checks,
not natural invalid-state occurrences or evidence of a safe dispatch bound.
No semantic state names are asserted. The fixture now has **1126 assertions**;
all **27 sections / 2019 bytes** match the reference.


### Menu state handlers 1..3

`engine/menus/local_state_handlers.asm` extracts `$42CD-$4302` as three
return-terminated table targets (25, 19 and 10 bytes). Their names use literal
state indices, not inferred UI meanings. **PROBABLE static interpretation:**
state 1 reads `$C21F` and skips all six calls when nonzero; states 2/3 execute
their original call sequences. External callees remain numeric pending analysis.

Every nonzero `$C21F` value is checked at the original state-1 entry in a
disposable core: bounded return, unchanged input and BC/DE/HL. These 255 fixtures
add 510 assertions, bringing the maintained suite to **1636 assertions**. No
zero-path, downstream-callee or natural-menu execution is asserted here.
The extracted total is **30 sections / 2073 bytes**, all byte-exact.


### State-0 initialization boundary

`engine/menus/local_state_init.asm` extracts native A `$14:$408A-$421D`
(404 bytes). **PROBABLE static interpretation:** it configures graphics/copy
arguments, fills state fields, sets `$D000=1`, selects paths from `$D004` and
`$C703`, and calls the previously extracted title routine `$4D43`. That call
now uses its exported symbol; its address and bytes are unchanged. External
callees and undecoded data pointers retain their original numeric values.

The interval stops at its `RET`; bytes `$421E-$42CC` are excluded from this code
unit. References to `$4224/$426D/$4275/$427D` motivate a separate data-consumer
analysis, not decoding that area linearly as instructions. The static exact-byte
total is **31 sections / 2477 bytes**. The **1636 synthetic assertions** still
cover earlier helpers and dispatch/early-return cases; they do not execute this
initialization or establish natural graphics/menu behavior.


### Remaining table targets: states 4 and 5

`$4303-$43BF` (189 bytes) and `$43C0-$450E` (335 bytes) complete the six
return-terminated table targets in the partial source. All table words now use
exported labels, preserving bytes and addresses. **PROBABLE static interpretation:**
state 4 branches from `$D01C`, saves fields or invokes external action/presentation
helpers; state 5 shifts list bytes, updates SYS1 through `$01B6/$01B9`, invokes
external storage/flash helpers, rebuilds titles and returns state to 1. These
callees and their natural combinations still require independent evidence.

Three original-entry state-4 fixtures stop by `RET` without external calls:
`$D01C=$FF` sets state 1; `$D01C=1` sets state 2 and copies the observed fields;
`$D01C=0` with the sum equal to `$D003` retains state 4 and saved-field sentinels.
The suite now has **1642 synthetic assertions**. State-5 execution is not probed
here; no new flash-format, persistence, capacity or hardware claim follows.
The total is **33 sections / 3001 byte-exact bytes**.


### Two-plane tilemap copy and bounded data tables

**PROBABLE static interpretation:** thunk `$01A4` jumps to `$0B15-$0B5E`.
The helper saves VBK bit 0, sets plane 0, reads B bytes for each of C rows,
advances the destination to a 32-byte row boundary, and repeats in plane 1
with consecutive source bytes. It restores BC/DE and the saved plane bit;
HL advances by twice B*C for the observed positive dimensions. Interrupt and
STAT polling instructions are retained, without a hardware timing claim.

The existing menu arguments bound `$426D-$4274` and `$4275-$427C` to eight
bytes each (4×1×2), and `$427D-$42CC` and `$450F-$455E` to 80 bytes each
(20×2×2). These four intervals are extracted as data, not instructions.
Other references such as `$4224` require their own consumer analysis.

Three forced-entry, LCD-off fixtures use 4×1, 20×2 and 3×3 synthetic dimensions,
check both planes and sentinel padding, HL advancement, BC/DE preservation and
restored VBK. No LCD-on timing, zero/wrapped dimensions or natural visual
behavior is established. The suite has **1648 assertions**, and source totals
are **39 sections / 3254 byte-exact bytes**.


### Banked graphics wrappers and full-menu map

**PROBABLE static interpretation:** `$019E` calls `$0A68-$0AE3`, which selects
window A when H < `$60`, otherwise B, from selector/type at `$C21C/$C21D`.
It saves the corresponding HRAM selector/type, calls linear copy `$0A50-$0A67`
and restores mapper registers and mirrors. `$01A7` reaches `$0B5F-$0C5B`,
which wraps the two-plane row copy with the same A/B choice and restoration.
No-op `LD A,A` instructions and STAT/DI/EI sequences are preserved.

`$01A1/$0AE4-$0B14` copies a single plane, consumes B/C to zero and advances
DE by 32 bytes per completed row. The two-plane helper instead restores BC/DE.
Three positive dimensions and three positive linear sizes are forced in a
disposable core with LCD off; six cases per banked wrapper cover A/B, ROM type,
data, padding and mapper restoration. The suite has **1684 assertions**.
These checks do not establish flash-source behavior, zero counters, crossing
8 KiB windows, arbitrary pointers or natural LCD timing.

State 0 passes BC=`$2020` to `$01A4` with HL=`$5208`, bounding two consecutive
32×32 planes at A `$14:$5208-$5A07`. The **2048 bytes** are stored as data,
not decoded instructions, in `data/local_menu_full_tilemap.asm`. No full-menu
rendering trace is asserted. Source totals: **46 sections / 5761 bytes**.


### Pending transfer descriptors and the nine-byte column

**PROBABLE static interpretation:** A `$14:$5A08-$5B25` calls `$FF80/$018C`,
then processes ten six-byte descriptors at `$D028`: destination word, width,
height and source word. It copies the destination into scratch `$D022/$D023`,
invalidates the queued word with `$FFFF`, then copies each positive-width row
with unrolled 8-byte/4-byte groups and 1..3 remainder bytes. Destination rows
advance by 32 bytes. `$D021=$80` leaves the current VRAM plane selected; other
active flags toggle after a pass and repeat only while the toggled bit is 1.
This does not prove a universal two-plane contract independent of entry VBK.

The state-0 descriptor gives destination `$98A1`, width 1, height 9 and source
`$4224`. Only that nine-byte read interval `$4224-$422C` is extracted as data;
its symbol now supplies the original low/high immediate bytes in state 0.
The independent `$D309` tail writes six bytes per row for ten rows from `$D34A`
to `$988D`, then applies its current-plane toggle/repeat condition.

Forced-entry probes skip the two callbacks by entering `$5A0E`, LCD off. They
cover eight widths in single/alternating-plane modes, inactive queue, the
original column in plane 1 and the `$D309` tail starting in planes 0/1. They
check consumed destinations, copied data, row stride, padding and flags. No
natural callback preparation, zero dimensions, arbitrary destination bounds or
LCD-on safety follows. Suite: **1724 assertions**. Source: **48 sections /
6056 byte-exact bytes**.


### Palette callback and relocated OAM DMA template

**PROBABLE static interpretation:** `$018C` reaches `$0995-$09EA`, preserving
AF and, on the active `$C221` path, BC/HL while it uploads 64 bytes to each
CGB palette data port from `$C222`. The source flag is cleared first.
`$09EB-$09F8` copies exactly ten executable bytes from `$09F9-$0A02` into
HRAM `$FF80-$FF89`. That template loads `$C0`, triggers OAM DMA at `$FF46`,
waits using the original 40-iteration loop and returns. The relative branch
bytes remain valid after relocation.

LCD-off, forced-entry fixtures check inactive/active palette data, preserved
registers, exact HRAM bytes with adjacent-byte sentinel and all 160 OAM bytes
from synthetic `$C000`. An integrated fixture enters the original `$5A08`,
executes the installed DMA and inactive-palette callback, then consumes a
one-byte descriptor. This adds bounded synthetic full-entry coverage while
retaining the earlier after-callback fixtures. No natural initialization, LCD-on
behavior or physical DMA timing is established. Suite: **1734 assertions**;
source: **52 sections / 6169 byte-exact bytes**.


### State-0 graphics source intervals and shared template

**PROBABLE static interpretation:** the banked-copy arguments in state 0 read
A `$14:$5C0A-$5C19` into VRAM plane 1 at `$9000`, B `$15:$6002-$7801` into
plane 0 at `$8000`, A `$14:$5CE2-$5D81` into `$8100`, and 32 bytes at B
`$15:$71B4-$71D3` into `$8000`. All have ROM type. These read intervals are
not asserted to be the full semantic extent of each graphics object.

The 6144-byte B read overlaps the already reconstructed `$71D4-$7243` list
template. It is emitted once: the new segments are `$6002-$71D3` (4562 bytes)
and `$7244-$7801` (1470 bytes), while the existing template contributes 112.
Both native selectors use physical RGBDS bank `$0A` in independent 8 KiB halves.
State-0 references use symbols; no bytes or old symbols moved.

Four forced banked-copy calls, LCD off, reproduce the exact original lengths
and destinations and compare every output byte, trailing sentinel, registers
and restored selectors. They do not execute the entire state-0 routine, verify
natural rendering or establish arbitrary pointer/length safety. Suite: **1742
assertions**. Source: **56 sections / 12377 byte-exact bytes**.


### OAM buffer and bounded flash-header sum

**PROBABLE static interpretation:** `$5B26-$5B30` clears 160 bytes in the OAM
source buffer at `$C000`. `$5B31-$5B8B` swaps `$D06B` into scratch `$C5CB`,
zeros other scratch, enables flash reads and scans index/box pairs at `$D1E6`
until index `$FF`. It ignores builtin indices below `$10`, selects B flash
with selector index minus `$10`, requires header `$6044=$FF`, accepts count
`$6005` through `$10`, and adds it in eight bits. Result `$C5C9` is stored
at `$D005`. Read/write controls are disabled on exit, while visited B
selector/type and mirrors are left selected. Count units are not newly proved.

Six synthetic header-sum cases include empty, skipped builtin, valid 3/16,
rejected 17, marker mismatch and 17 duplicate count-16 entries (272 wraps to16).
Headers are injected into disposable core backing memory, then restored; no
flash program/erase command, original modification or real save is used. This
does not establish natural duplicates or universal list bounds. An OAM-source
clear fixture checks all 160 bytes, registers and a trailing sentinel. Suite:
**1757 assertions**. Source: **58 sections / 12479 byte-exact bytes**.


### Runtime consumer registration and callback setters

**PROBABLE static interpretation:** `$5BC6-$5BE9` calls `$45FF/$481B`, copies
`$C671` to `$D004`, sets `$C5A3=1`, clears `$D000/$D021/$D309`, and stores
consumer `$5A08` through `$0150` between DI/EI. External callees are still
unextracted; no new full-init or natural callback trace is asserted.

Thunks `$0150/$0156` reach setters `$0661/$067D` that store DE in little-endian
HRAM slots `$FF8E/$FF92`. `$0153/$0159` reach `$0668/$0684`, preserving AF
while writing opcode `$C3` plus DE into WRAM stubs `$C67F/$C682`; a null DE
writes only `$D9` and leaves the following two bytes unchanged. The emitted
mechanics are tested with five DE values on both slots and both stubs.
Tests do not execute the destination or dispatch a natural interrupt. Suite:
**1797 assertions**; source **61 sections / 12583 byte-exact bytes**.


### SYS1 loader, per-entry palettes and full runtime-init fixture

**PROBABLE static interpretation:** `$45FF-$4619` opens SYS1 with requested
size `$02A3`, copies exactly 675 bytes to `$D064-$D306`, and closes the record.
There is no capacity or null-pointer guard added to the original sequence.
The existing-record opener does not resize to requested size; no universal
safety claim follows from this loader.

`$481B-$487D` resets A and repeatedly reloads HL=`$487E` for eight background
and eight object palette calls. `$0171/$0174` reach `$0799/$07C0`; each uploads
eight bytes, advances HL, sets C=`$80` and increments A after restoring AF.
Only the observed read interval `$487E-$4885` is extracted as palette data.

LCD-off probes verify individual slots 0..7, unchanged other slots, all palettes
initialized from the original source, and new/existing correctly sized SYS1
loads with exact destination bytes and a trailing sentinel. An integrated
original-entry `$5BC6` fixture now checks those helpers, flags and registered
consumer `$5A08`. It remains synthetic, without natural initialization, short
record safety or LCD-on timing evidence. Suite: **1839 assertions**. Source:
**66 sections / 12801 byte-exact bytes**.


### OAM list indicators and eight-bit comparison

**PROBABLE static interpretation:** `$461A-$4655` clears the first byte of
OAM-source entries `$C070/$C074`, returns early when `$D006` bit `$10` is set,
shows the upper entry for nonzero `$D002`, and shows the lower entry when
eight-bit `$D002+5` is below `$D003`. Hidden entries retain their other three
bytes. No widening or inferred bounds were added.

Forty forced-entry fixtures combine blink bit on/off, offsets 0/1/251/252/255
and counts 0/5/6/255, checking both entries and adjacent sentinels. Large
offsets are deliberate mechanics checks, not natural invalid-state evidence.
No rendered/natural indicator claim follows. Suite: **1919 assertions**.
Source: **67 sections / 12861 byte-exact bytes**.


### Held-input one-cell queue producer

**PROBABLE static interpretation:** A $14:$478D-$4812 compares the entire held
byte $FF96 with previous $D015. Equal bytes leave descriptors/flag unchanged;
changed bytes optionally write six-byte descriptors at $D046/$D04C for old/new
bits $10/$20, with $10 priority. Destination is $986F or $9864; dimensions are
1x1, with two consecutive source bytes per cell at $4813/$4815/$4817/$4819.
It sets $D021=1 and stores the current held byte, even for irrelevant-bit changes.
The eight original data bytes are emitted separately without translation.

36 forced pairs and four producer-to-consumer-body transitions check descriptor
bytes, guards, flags, both VRAM planes and padding. Consumer callbacks are
skipped in these four cases. No natural trace, LCD-on timing or hardware claim.
Suite: **2003 assertions**; **69 sections / 13003 byte-exact bytes**.


### Text timer, cursor routines and list-input traversal

**PROBABLE static interpretation:** A $14:$4656-$46C0 steps a text buffer with
$D016 scheduling, source $D017/$D018 and row $D01A. Seven forced timer/empty-token
cases return without calling the unextracted text sink $01EF. No universal
buffer capacity or nonempty-output runtime claim.
A $14:$488E-$493F separates three cursor routines and three data bytes at
$48D7-$48D9. ROM0 $2DC3-$2DCF calculates a frame-derived byte displacement.
256 frame-byte probes plus 20/16/20 cursor cases check arithmetic, entry fields
and guards, not natural rendered motion or arbitrary table-index admissibility.
A $14:$4940-$4C3D has exact reconstructed input branches; 16 unhandled-input
cases return without tested menu-field changes. Active paths with unextracted
callees remain static. A $14:$4CDA-$4CEF searches category-tagged pairs, retaining
8-bit B increment/decrement; four probes include exhaustion and B=$FF against
256 synthetic pairs, without implying natural list capacity.

Source: **77 sections / 14089 byte-exact bytes**; CPU suite **2681 assertions**.
19 checker tests now include eight complete-coverage/whole-image cases.
Rafael authorized continuing until a full, independently assembled 1 MiB ROM
matches the reference exactly. The complete gate rejects matching linker padding
without explicit sources; sparse equivalence is still an intermediate result.


### Description preparation, label storage and original cartridge entry

**PROBABLE static interpretation:** $46C1-$478C locates a category/list item,
selects ROM or flash B, copies from $6024 through zero into $D30A and restores B.
The unbounded terminator copy and still-numeric text callees preclude a full
runtime/capacity claim. $4C6F-$4CD9 action input has sixteen forced unhandled-bit
cases preserving tested fields. $4C3E-$4C6E opens SYS1, applies eight-bit SWAP to
the row, adds $0112 to the returned data pointer, copies through zero or 16 bytes,
and closes. Fifteen correctly sized synthetic cases check all 675 payload bytes.
The initial failed expectation read disabled SRAM after close; the corrected
fixture checks the closed bus then remaps disposable SRAM for inspection. No
source-byte correction was needed; no real save or natural extreme-index claim.

Vectors/entry $0000-$0103 and header $0104-$014F preserve exact original bytes,
including explicitly declared reserved zero regions and original checksums.
Branch targets alone do not prove boot/interrupt execution. No rgbfix on partial
output. Source: **83 sections / 14785 byte-exact bytes**; **2773 CPU assertions**,
**19 checker tests**. The integral gate still rejects the partial reconstruction.


### Matching source baseline across the whole ROM

The complete build now emits exactly 1,048,576 bytes with SHA-256
`9fb1e6e4a637796b8624bd2de6c9abaa9e758546b620cb5dc8441b07c288bc63`.
Building reads only committed source and the recorded hash; the reference is
read only by optional validation and was unchanged. Existing 83 analyzed ranges
(14,785 bytes) and all 385 published symbols of 574a20a were preserved.
161 remaining ranges (1,033,791 bytes) are explicit literal source, split at
8 KiB page boundaries and marked **HYPOTHESIS classification / uninterpreted**.
They do not establish functions, data types, natural execution or hardware.
The one-time bootstrap was private and is frozen against project overwrite.
This follows the Mobile Trainer matching-base-then-refinement workflow.

24 checker tests and 2773 synthetic CPU assertions pass. Private validation
checks all address symbols and image equality. Real negative builds mutate a
literal byte or delete a zero page. The latter retains the original hash through
matching linker padding but fails the explicit-source-coverage gate. No original
ROM include, real save, translation, programming/erase or new network feature.


### Startup and return-table/interrupt refinement

$02B8-$03A7 is now instruction source with a separate ten-word table at
$03A8-$03BB. Four forced prefix cases check all WRAM windows/HRAM and explicit
model/selector/stub writes, stopping at $0373 before A $16:$4000 initialization.
They do not establish natural startup or complete main-loop execution.
$05F5-$0660 and $0699-$06A5 expose the return-address table dispatcher and
callback/register-return paths. $0000 is a RST-table entry, not the cartridge's
hardware entry at $0100; the legacy ResetVector symbol is retained as an alias.
256 synthetic indices cover A*2 wrap. Six callback cases and a return-only
case cover register restoration; two VBlank cases stop before maintenance $2242.
Roles remain **PROBABLE**, without natural interrupt/timing or universal indices.

Complete matching source: 249 sections, 1,048,576 bytes; 87 analyzed sections
(15,166 bytes), 162 uninterpreted ranges (1,033,410 bytes). All 546 published
symbols from 3d465b0 preserved in private validation. 24 checker tests and 3053
synthetic CPU assertions pass; original ROM hash and compiled image hash remain
unchanged. There is no translation, real save or new Mobile Adapter/REON feature.


### Native A $16 startup initializer

**PROBABLE**, static instruction flow: the call at ROM0 $0373 enters physical
bank $0B:$4000. `engine/startup/bank_a16.asm` covers $4000-$41E9 (490 bytes),
retaining `ResidualROM0B_4000` as an alias. The model-result field $FF9C branches
on zero to $416C. The preceding path can return at $416B; the fallback path
ends in the HALT/flag wait loop $41DE-$41E9. The following $41EA target and
all remaining callees/data remain numeric until their own boundaries are
established. No interpretation of the suffix is implied by linear adjacency.

Four **SYNTHETIC** entries at $416C vary the previous native B selector, stop
at $419D before $0252, and check B $1F/type ROM, two mapped bytes, preserved
BC/DE/HL/SP, palette/scroll/window and sound-route writes. LCD is off. This does
not establish natural boot, complete startup, HALT/IRQ timing or DMG hardware.
Byte equivalence remains separate from semantic confidence; no translation.

The full source now has 250 sections: 88 analyzed sections (15,656 bytes) and
162 residual ranges (1,032,920 bytes). Full/private checks preserve the complete
ROM hash and all 571 address symbols published at dd6004a. The CPU suite has
3061 assertions, with 24 verifier tests and both actual negative-build cases.


### Main states 0/1/2 and internal pointer tables

**PROBABLE**, static consumers: `home/main_states.asm` refines ROM0 $03BC-$04A5
(234 bytes), preserving `ResidualROM00_03BC`. MainStatePointers references the
three entry points $03BC/$03C9/$03D6 symbolically. Words $0407-$040C are read by
$03E0; branch pointers $041D-$0422 are consumed by DispatchReturnTable via
$0416-$041A; result pointers $046E-$047B are read by $045B-$046C. These are
explicit tables, not instructions obtained by decoding adjacent bytes.
No universal bound on $C706/$C214 or meaning of their values is established.
The remaining $04A6-$051D source is still uninterpreted.

**SYNTHETIC**: 256 indices at $0391 stop before JP HL at $03A5, checking wrapped
byte doubling, loaded target word, pushed $03A6 return, SP and BC/input. Seven
forced result handlers $047C+6*i return after writing $C623=3/4/5/1/2/7/6 and
preserve BC/DE/HL. These add 270 assertions, total 3331; they do not execute the
main-state callees or establish natural main-loop/game behavior.

Full source: 257 sections, 95 analyzed sections (15,890 bytes), 162 residual
ranges (1,032,686 bytes). Full/private gates, 24 checker tests and actual
negative builds pass, preserving all 591 symbols from e48a89c and the full
reference hash. No Japanese bytes, external original or real saves are changed.


### Remaining main-state destinations

**PROBABLE**, static consumers: `home/main_states_remaining.asm` extracts
$04A6-$051D and $0564-$05C7 (220 bytes). State 3 reads words $04D7-$04DC and
return-table pointers $04ED-$04F2; its paths join the pre-existing gate at $0521.
`LocalMinigameSelectionBody` is an address alias, preserving the old gate's local
clearBuffer symbol and entry at $051E. All ten main pointer-table destinations
are now named; $05C8-$05D9 remains an unknown literal interval. ResidualROM
aliases $04A6/$0564 are preserved, and the gate's old extent comment is corrected
to its actual manifest boundary $051E-$0563.

**SYNTHETIC**, 527 new assertions: 256 post-callback tail values at $058A retain
state 7 or write state 2, four other return tails check their writes and register
pairs, five prefixes stop before $0264 with original argument values. State 9's
prefix maps A $16/type ROM before $44AA; a separate forced tail $05C2 consumes
one stacked word and jumps to $02B8 with A=$11. No natural callback or restart
execution, hardware or external-callee behavior is claimed.

Full coverage remains 1,048,576 bytes in 262 sections: 101 analyzed sections
(16,110 bytes), 161 residual ranges (1,032,466 bytes). The suite has 3858 CPU
assertions; full/private gates and 24 verifier tests preserve the original hash
and all symbols published at ddc7cd1. Actual negative builds remain required.


### Resident jump interface and banked callback dispatcher

**PROBABLE**, static reconstruction: $01BC-$02B7 contains 84 JP slots, named
ResidentJumpXXXX in `home/resident_jumps.asm`. Extracted call/jump consumers
now use these symbols. Targets with established source symbols use those names;
remaining targets are numeric, without transferring semantics from a thunk.
The original ResidualROM00_01BC symbol is retained at its published address.

`home/banked_callback_dispatch.asm` extracts $23E4-$24B8 (213 bytes), including
the isolated RET at $24B8. The dispatcher computes 3*A in an eight-bit accumulator
and reads records from $05C8: one native selector plus a little-endian CPU word.
B=0 chooses window A; B!=0 chooses window B. New table fragments $05C8-$05D9
and $05E0-$05F4 flank the unchanged RuntimeCallback_6/7 fragment. The contiguous
layout ends before the instruction entry $05F5 and has 15 records; neither
index checking nor suitability of each CPU target in both windows is proven.
Save/restore fields use C107/C10E for A and C10D/C10F for B; no general nesting
capacity is inferred from these bases or the depth-zero fixtures.

**SYNTHETIC**: 84 thunk probes stop before target execution. 512 dispatcher
prefix probes (256 indices in each window) stop before JP HL and check wrapped
record offsets, loaded word, selector/type, saved pair and return stack word.
Restoration tails are entered separately with the saved fields. They restore
the prior type $08 and selector at depth zero, without running callbacks or
claiming a natural return. Out-of-table inputs can log invalid flash selectors:
the original prefix writes the selector while the old type is still flash,
then forces ROM. This is observed emulator handling of forced invalid inputs,
not proof of hardware or natural callback admissibility. No program/erase.

Full source: 264 sections; 105 analyzed sections (16,614 bytes), 159 unknown
residual ranges (1,031,962 bytes). 5478 CPU assertions, 24 checker tests, full
byte comparison, private symbol/image checks and actual negative builds pass.
All 629 symbols published at a1fb3c7 are preserved. Original reference remains
external/unchanged, and its complete hash is unchanged by the reconstruction.


### A16 wrappers and direct save/restore helpers

**PROBABLE**, static consumers: resident thunks $0282/$0285/$0288/$028B enter
$1663/$1675/$1689/$169D. `home/bank_a16_calls.asm` covers $1663-$16B0 plus
$1783-$17B2 (126 bytes), retaining ResidualROM00_1663. SaveWindowAAndSelect16
stores the current $FFAB/$FFAC pair through DE, advances DE once and writes
native A selector $16/type ROM plus $C113/$C114 shadows. RestoreSavedWindowA
reads that pair, advances DE and restores mapper/shadows. BC/HL are unchanged.
Wrappers use slots $C641/$C643/$C645/$C647 and numeric targets $4227/$424D/
$42CB/$42EF under A16. Three wrappers push AF around restoration; $1663 does
not. All retain original DI/EI ordering, without claiming prior IME restoration.

**SYNTHETIC**: eight explicit selector/type pairs (0/1/$14/$7F, ROM/flash flag)
exercise both helpers. Four wrapper prefixes stop before the banked calls;
separate forced tails check restored fields and the differing AF policy. This
adds 44 assertions, total 5522. No original target or natural boot is executed,
and no flash programming, saves, interrupt timing or hardware proof is added.

Full source: 267 sections, 107 analyzed sections (16,740 bytes), 160 unknown
residual ranges (1,031,836 bytes). All 721 symbols published at 19532c1 remain
at their addresses in private validation. Full comparison, 24 checker tests,
CPU probes and actual negative builds preserve the complete reference hash.


### A16 wrapper bodies and SYS0 record copies

**PROBABLE**, static flow: A16:$4227-$4311 (physical bank0B/file $2C227-$2C311)
is extracted in `engine/startup/sys0_record.asm`. Four wrapper destinations are
symbolic. Two request record SYS0 with BC=$0032; $42CB copies the returned payload
to C700, $42EF copies C700 to the returned payload; both close and return A=0
on the existing-record success branch. The other bodies and error/initialization
paths are retained byte-for-byte but do not receive a complete runtime claim.
ROM0 $17B3-$17B6 is the four-byte identifier, preserving its residual alias;
following bytes remain unknown. The extracted HL→DE copy $2613-$261B performs
a copy before decrementing BC, so zero wraps rather than representing emptiness.

**SYNTHETIC**: five positive copy lengths check exact boundaries and pointers.
A prepared existing SYS0 header/directory and 50-byte payload execute full
original wrappers $1689/$169D, open/copy/close/checksum and mapper restoration.
Payload, result, restored A fields and stored checksums pass. This adds 16 asserts,
5538 total. No SYS0 creation, initialization $424D, short-record capacity or
natural menu/hardware is established. SRAM exists only in disposable core memory.

Full source: 272 sections, 110 analyzed sections (16,988 bytes), 162 unknown
ranges (1,031,588 bytes). Full/private comparison, 24 checker tests, CPU and
actual negative builds pass; 729 symbols e0cbd96 preserved and original hash
unchanged. No translation, reference writes, saves or new network feature.


### VBlank mapper call and restore branches

**PROBABLE**, static consumer $069E and resident thunk0249: $2242-$22A6 is now
`home/vblank_mapper.asm`. B comes from C663/C664; A selects native1E/typeROM,
then calls4000. Afterward C672=0 restores FFAB-FFAE and updates C113-C116;
nonzero restores CB81-CB84 only to mapper registers, without shadow writes.
No purpose beyond this observed code is asserted for those alternate fields.

**SYNTHETIC**: three cases C672=0/1/FF stop before call2264 and independently
enter tail2267. Mapped bytes, BC/DE/HL, HRAM and shadow differences are checked.
No A1E target, natural IRQ/VBlank or timing evidence. Nine new asserts,total5547.
Full source: 274 sections,111 analyzed/17089 bytes,163 unknown/1031487 bytes.
Full/private gates preserve 745 published fabf3fb address symbols, full hash,
24 verifier tests and actual negative-build rejection.


### Native A1E state tick

**PROBABLE**, static call chain: ROM0 $2242 selects A1E and calls4000, whose JP
reaches42B1. `engine/startup/bank_a1e_tick.asm` extracts $4000-$4002 and
$42B1-$43CA (285 bytes), retaining ResidualROM0F_4000. Physical bank0F/file
$3C000 and $3C2B1-$3C3CA correspond to native selector1E in the lower window.
Eight slots use CF01/11/.../71 flags and +4/+5 countdown fields. Active slots
decrement the first byte; on zero they either decrement a nonzero second byte
and reload FF, or call one of eight still-numeric handlers. CF86's active global
path also has unexecuted numeric callees. Final CF84-enabled routing uses
CF88/CF89 to compute the original mask written to FF25. No slot purpose is
promoted to confirmed channel semantics by the register access alone.

**SYNTHETIC**: 64 complete bodies isolate one active slot with counter0/1/2/FF
and remainder1/FF, keeping global paths inactive. Eight probes stop before
handlers. 56 routing-tail cases and one all-inactive body pass. 250 added
assertions,total5797; no natural VBlank, external handler, active global flow,
audible output or hardware claim. Full/private/negative gates preserve 748
symbols61fca2a and whole hash. 277 sections:113 analyzed/17374 bytes,164 unknown
ranges/1031202 bytes, plus 24 verifier tests.
