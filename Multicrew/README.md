# SK60 shared cockpit — experimental implementation

**Current build (2026-09-09):** use [DCS-server-hosted SK60 Crew](SERVER-HOSTED.md).
The DCS host runs the relay, clients connect and pair by verified aircraft seats,
and shared-panel updates flow pilot to co-pilot. No central hosting subscription,
invitation codes or VPN are needed. Two-PC DCS testing is still required.
The manual setup below documents the earlier bidirectional prototype.

This is an opt-in shared-cockpit system for the **left-seat pilot (crew index 0)**
and **right-seat co-pilot (crew index 1)**. Both seats use the existing panel. The
pilot simulates the shared systems; the co-pilot sends control requests and receives
complete panel snapshots. There is no separate instructor instrument panel.

**Status:** Lua/transport tests and a Release x64 EFM build have been completed.
This has **not been flight-tested in DCS with two PCs**. Use a separate test copy
of the mod first. This is not a claim of production-ready DCS multicrew support.

## What is implemented

- Shared electrical controls, canopy, gear, flaps/brakes, lighting, warning panel,
  weapon-system controls, navigation controls, FR31/FR33 and transponder controls.
- Pump, starter and throttle idle/cutoff requests are dispatched to the pilot's
  EFM, rather than merely calling the HUD's Lua handler.
- Full parameter snapshots, including instrument values and digital display
  parameters. The generated allowlist also covers direct cockpit argument
  updates for FR33, transponder and navigation controls.
- Late join and reconnect resynchronization without replaying historical toggles.
- Version/schema checks, two-seat pairing by room and DCS aircraft ID, a shared
  authentication token, bounded buffers, command sequence checks and stale-session
  rejection. Received data is parsed; it is never passed to `loadstring`/`dofile`.
- Remote held starter, fire, RNAV-check and wheel-brake inputs are released when
  the link is lost. Queued inputs from a disconnected generation are discarded.
- Existing numeric device IDs are preserved; the bridge is appended as device 27.
- With no enabled configuration, existing cockpit behavior is preserved.

## Boundaries

The left-seat pilot must keep DCS flight-control authority. **Flight-control
handover is not implemented.** Stick, rudder, throttle axes and trim remain DCS/EFM
functions, not an alternate network flight model. Do not use DCS's take-control
command with this experimental shared-system mode enabled.

The co-pilot's shared Lua simulation is suspended while this mode is enabled,
including while disconnected. Its panel retains the last received state and
shared control requests are rejected until fresh snapshots arrive. The pilot
continues to operate normally. Disable the configuration and respawn to return
to independent cockpit behavior.

Personal body/visor settings, menus, intercom/PTT and ejection controls remain local.
This does not add voice transport or change the existing radio-frequency limitations
of the mod. Native radio frequencies are applied locally where the existing radio
supports them; SRS reads the copied radio parameters. Native device internals,
audio timing and DCS network animations still require in-game validation.

Snapshots replicate observable panel state, not all private Lua variables or C++
objects. This is why copying snapshots does not support authority migration.
Commands preserve order within each shared system; independent devices execute
their queues on their own update ticks. There is no global atomic transaction
across a battery action and a starter action in different devices.

## Why the optional networking component

The repository's `net_animation` list carries aircraft draw arguments, and the EFM
queries DCS's master/seat state. Neither provided a verified arbitrary, bidirectional
cockpit-message transport in this checkout. This implementation therefore uses an
Export.lua extension and a small TCP relay. It does not patch DCS binaries,
`MissionScripting.lua`, or the multiplayer server's scripts.

The cockpit and export Lua environments exchange bounded local files under
`Saved Games/<profile>/Logs/SK60Multicrew/`. The export extension uses DCS's bundled
LuaSocket. The relay uses Python's standard library. The cockpit needs its normal
`io`, `os`, and `lfs` facilities; no sanitization bypass is attempted. Environments
that disable these facilities require a different transport adapter.

## Install on both PCs

1. Use the **same revision** of the modified SK60 on both computers. Merge the
   supplied overlay into an existing copy of this repository's SK60 mod; it is
   not a standalone aircraft download and contains no models/textures.
2. Use the supplied rebuilt `bin/SAAB_SK60_FM.dll`, or build
   `EFM/ExternalFlightModel/SK-60_FM/SK-60_FM.vcxproj` as **Release / x64** with
   Visual Studio 2022 (v143). The added EFM guard prevents a non-master station
   overwriting DCS's received animation arguments with stale local engine values.
   Do not mix an old DLL with the test package.
3. Copy `Multicrew/config.example.lua` to
   `Saved Games/<your DCS profile>/Config/SK60Multicrew.lua`.
4. Set `mod_path` to the **absolute aircraft directory containing `Multicrew`**.
   Set `host` to the relay's numeric IPv4 address, `port` to its TCP port, and set
   the same `room` and random `token` on both PCs. No seat setting is needed.
5. Append this block once to the existing
   `Saved Games/<your DCS profile>/Scripts/Export.lua`. Keep any SRS/DCS-BIOS
   content already there. If the file does not exist, create it.

   ```lua
   do
       local ok, cfg = pcall(dofile, lfs.writedir() .. "Config/SK60Multicrew.lua")
       if ok and cfg.enabled then
           dofile(cfg.mod_path .. "/Multicrew/export.lua")
       end
   end
   ```

6. Start the relay, then restart DCS. Join the same SK60 airframe in multiplayer:
   pilot on the left, co-pilot on the right. Wait for the shared-cockpit connected
   message before using the co-pilot controls. A different airframe ID will not pair.

## Run one relay for the pair

Install Python 3.10 or newer on the relay computer. No pip packages are needed.
Use a private LAN or VPN reachable by both PCs. The transport authenticates with
a shared token but is **not encrypted**; do not expose it directly on the Internet.

Generate a token into a local text file (do not commit that file):

```powershell
py -c "import secrets; from pathlib import Path; Path('sk60-token.txt').write_text(secrets.token_hex(32))"
```

Put the token's contents in both local configurations. Start the relay, replacing
the example bind address with the relay computer's LAN/VPN address:

```powershell
py Multicrew/relay.py --bind 192.168.1.20 --port 10660 --token-file sk60-token.txt
```

Allow that TCP port between the two PCs and the relay in the firewall. The pilot's
PC can host the relay; a dedicated server is not necessary. The default bind
address is loopback only. The relay checks the matching aircraft ID supplied by
the clients; it is not integrated with the DCS server's player permissions.

## Two-PC acceptance test (still required)

1. Check single-player behavior with the configuration absent/disabled.
2. Cold start with both seats connected. Operate battery, inverters, generators,
   pumps, starters, idle/cutoff, nav power, canopy, lights, and parking brake from
   each seat. Check actual engine/system behavior as well as the switch animation.
3. Tune FR31/FR33, enter an RNAV waypoint, change course/heading, and alter all
   transponder digits. Compare digital readouts, moving controls, instrument
   needles, flags, and SRS/ATC behavior on both PCs.
4. Pilot taxis and flies; compare gear/flap travel, flight instruments, fuel,
   engine gauges and warning indications. Test both cold and airborne late joins.
5. Disconnect the co-pilot while holding a starter, RNAV check or fire input in
   a safe test mission. Verify release, pilot continuity, and reconnect state.
6. Stop/restart the relay, switch aircraft, try the wrong token/version, and
   reconnect. Confirm no old switch presses execute and different aircraft do not pair.
7. Test simultaneous inputs, quick repeated toggles, higher latency, and existing
   SRS/DCS-BIOS export callbacks. Do not test flight-control handover as supported.

Record DCS version, both `dcs.log` files, both mod/DLL revisions, and a track when
reporting failures. `MC_ENABLED`, `MC_ROLE`, `MC_CONNECTED`, and `MC_OVERFLOW` are
local diagnostic parameters. Export-hook exceptions are logged as `SK60Multicrew`.

## Development and verification

`schema.lua` is a generated, ordered parameter/command allowlist with a fingerprint
of the participating sources. It includes inert zero-valued candidates from
display tables; these are not transferred executable state. Dynamic FR31 digits
and radar contacts are expanded explicitly. Add an explicit mapping when adding
new dynamically named parameters or direct draw-argument controls.

After changing shared device, adapter, EFM or command definitions, run:

```powershell
py SK60/Multicrew/generate_schema.py
```

From the repository root, install the test-only Lua runtime and run the tests:

```powershell
py -m pip install --target .test-deps lupa
py SK60/Multicrew/tests/test_sync.py
```

Tests use Lua 5.1, independent mocked cockpits, the real export-extension logic
with fragmented socket I/O, and real loopback relay sockets. They cover parsing,
complete-state validation, a co-pilot command reaching the pilot and returning as
panel state, duplicates, stale generations, disconnect releases, callback chaining,
seat/aircraft/version isolation, and the disabled path. They cannot establish DCS
API compatibility or replace the two-PC acceptance test above.

## Remove

Set `enabled = false` on both PCs, restart DCS and respawn. The optional Export.lua
block can remain disabled or be removed. Stop the relay. To fully revert, restore
the original Lua files and DLL from your backup. No DCS installation files or
firewall settings are changed by the supplied code.
