# Net de Get input tester fixture

This is a small original homebrew payload for checking the eight joypad input
bits through the Net de Get minigame path in a disposable mGBA save. It is not
the original game and does not contact a server or write SRAM/flash while it
runs. Do not use a personal or real-cartridge save for this fixture.

Build with RGBDS (`rgbasm`, `rgblink`) and Python 3:

```sh
./build.sh
```

The build writes `input_tester.flash`, a zero-padded payload image for one 8 KiB
MBC6 block. It is ignored by Git. Provision it only in a disposable copy of
the previously validated local NASU fixture save: replace flash bytes at offset
0 without truncating the sidecar, preserve the existing
Index/Box slot selection and recompute the fixture's SYS1 checksum. Keep the
original fixture files unchanged. The payload ID is `G001`; title is `PAD
TEST`.

Hold Start and Select together to return to the host. The fixture restores
STAT/IE and clears the four Maker interrupt callbacks before returning.
In the tested disposable fixture the host changes the stored Box from 2 to 1;
select item 16 in BOX1 to relaunch. The exact cause of this host assignment
change is still unresolved.

When launched, the payload repeatedly calls host API `$027C`, draws its own
small tile font directly into the background map, and records:

- `$D800`: frames elapsed, wrapping at 256
- `$D801`: newly pressed input mask from `$FF97`
- `$D802`: held input mask from `$FF96`
- `$D803-$D80A`: per-bit new-press counters (bits 0 through 7)

Read the bytes in mGBA's debugger after pressing each control. The latest
headless mGBA capture is legible: it shows `PAD TEST`, all eight controls, held
state, and hexadecimal press counts. The harness also requires the framebuffer
to change on each injected press and release. This validates the fixture's
emulated display only; it does not establish physical hardware behavior. The
input bit order follows the Game Boy joypad register encoding (buttons in bits
0-3, directions in bits 4-7).

Evidence boundary: calling `$027C` and the `$FF96/$FF97` values are based on
the Maker API comments and the existing host analysis. The mGBA chat reports natural BOX2 listing, launch and eight-input logging
on the corrected fixture. The joypad-only natural runner also passes exit and BOX1 item-16 relaunch;
synthetic dispatch alone would only validate payload execution.

## Headless input run

`run_headless.c` is a diagnostic harness for an mGBA build with MBC6 support.
It boots the host for 900 frames, then **synthetically** sets CPU `PC=$026D`
and `A=$10` to enter flash selector 0. It injects A, B, Start, Select, Right,
Left, Up, and Down one at a time and checks the corresponding per-bit counter
in WRAM. This validates the fixture's input logging once executing; it does not
validate catalog listing, natural menu selection, download, or hardware.

Example compile/run (adjust paths for the local mGBA checkout/build):

```sh
MGBA_ROOT="/path/to/mgba"
MGBA_BUILD="/path/to/mgba-build"
cc -O2 -DENABLE_VFS -DENABLE_DIRECTORIES -DENABLE_INPUT \
  -I"$MGBA_ROOT/include" -I"$MGBA_BUILD/include" fixtures/input-tester/run_headless.c \
  -L"$MGBA_BUILD" -Wl,-rpath,"$MGBA_BUILD" -lmgba \
  -o /tmp/netdeget-padtest-runner
/tmp/netdeget-padtest-runner "/path/to/Net de Get.gbc" \
  /tmp/netdeget-padtest-run
```

The save directory must contain a disposable pair named `padtest.sav` and
`padtest.sav.flash`. For the recorded run, both came from the disposable GUI
fixture under `/tmp/netdeget-box2-run`; the flash sidecar's first bytes were
replaced with this payload. The original reference ROM and any original save
were not written.

Recorded result on 2026-10-06: all eight input-bit counters were exactly `1`
and each held mask matched the injected button. Every press and release
changed the framebuffer; the harness returned `overall=PASS` at 160x144. The
final capture is `screen_final.ppm` in the disposable save directory.
Emulator build metadata was
`0.11-feature/mbc6-complete-9334-fca224b25-dirty`. The run used a synthetic
dispatcher entry, so that earlier run alone did not verify local recognition/listing.
The later natural run below provides that evidence.

## Natural launch, input, exit and relaunch

`run_natural.c` controls only joypad keys, runs frames and reads snapshots;
it does not inject CPU/register/memory state. The script copies a previously
validated **disposable BOX2 fixture** into a new temporary directory, replaces
its first flash block with PAD, and runs:

1. Natural BOX2 launch.
2. Eight individual presses, expecting counters `0101010101010101`.
3. Start+Select exit and release.
4. BOX1, Down sixteen times, A/submenu, A/Start, expecting cleared counters
   and advancing PAD frames on re-entry in the same core.

```sh
./fixtures/input-tester/run_natural.sh ORIGINAL_ROM MGBA_ROOT MGBA_BUILD \
  DISPOSABLE_BOX2_SAV DISPOSABLE_FLASH
```

The script checks the external ROM hash before/after and that flash stays
unchanged through gameplay. It requires the validated slot Index/Box `10/01`
at SRAM `$04F2/$04F3`; no personal save should be supplied. Recorded PASS on
2026-10-06: `/tmp/netdeget-pad-natural-` directory printed by the runner,
mGBA Linux library built at HEAD `4c8066be4`. A separate fresh-core run using
the post-exit save also relaunched through BOX1 item16.

The current state lives in WRAM bank 1 at `$D800-$D813`, in the Maker
minigame workspace. The earlier `$C700` version overlapped host state and
must not be reused. The earlier synthetic input record above belongs to that
version. The corrected payload is 8 KiB with SHA-256
`0e42875ef2569905d056f895ab5d6998e4f17709875dd27f13cbd9b20c2158b0`.
The observed Box relocation is reproducible but is not yet explained by an
instruction trace. A repeated PC `$517E` at frame boundaries is the ordinary
host VBlank wait and was not evidence of a freeze.
