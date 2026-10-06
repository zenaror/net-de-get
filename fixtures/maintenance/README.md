# Natural maintenance trace

`trace.c` replays ordinary joypad input and reports selected native host PCs,
mapper selectors, flash latch state and the SRAM-file ID argument. It does not
write CPU registers, redirect execution or inject guest memory. Saves must be
synthetic copies acquired through the local fixture server; never use real saves.
The original ROM remains outside Git and is loaded read-only.

Build this source against the exact library being investigated. Internal GB
structs depend on feature defines: use **all** `C_DEFINES` from that library's
`CMakeFiles/mgba.dir/flags.make`, its generated include directory and matching
source includes. For `USE_LIBMOBILE`, include both `src/third-party/libmobile`
and the generated build `libmobile` directory. Omitting these defines can produce
incorrect offsets and misleading latch reports. Link with that same library and
set its directory as the runtime library path.

Invocation:

```text
maintenance-trace EXTERNAL_ROM COPY_SAVE_DIRECTORY KEY_MASK:FRAMES ...
```

The save directory must contain `padtest.sav` and `padtest.sav.flash`, copied
from the completed natural MOVE snapshot. Both copies will be updated by the
emulator. The trace starts instruction stepping at input stage19 (argument22);
earlier stages run normally. It limits diagnostic output to 301 matching PCs.
PPM snapshots and stage diagnostics are written as in `input-tester/run_natural.c`.

The MOVE→DELETE replay used:

```text
0:900 8:3 0:180 1:3 0:360 1:3 0:60 1:3 0:240
16:3 0:90 1:3 0:60 16:3 0:30 16:3 0:30 1:3 0:120
32:3 0:20 1:3 0:180
```

Key masks: A1, B2, Select4, Start8, Right16, Left32, Up64, Down128.
The initial snapshot has G002 then G001 in BOX2, Index/Box pairs
`20 01 10 01 FF 00`, with payloads in separate erase sectors.
See `docs/research/minigame-maintenance.md` for results and evidence limits.

## Occupied-list boundary observer

`boundary.c` uses the same compiler/ABI requirements, arguments and snapshots.
It wraps the CPU store callback, reports selected writes, then delegates each
store unchanged. Hook PC values point just after the guest store instruction.
It neither changes the ROM nor suppresses mapper warnings. To replay the
Index80 entry case, copy the naturally acknowledged occupied-list snapshot
`/tmp/mgba-netdeget-occupied-reopen-mr1suxab/` into a disposable save directory
and use the first nine key/frame pairs of the boot/list macro above. This
observer runs normal frames throughout, without instruction stepping.
