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
