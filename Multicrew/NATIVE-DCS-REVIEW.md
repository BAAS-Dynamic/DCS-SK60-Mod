# Native DCS multicrew reference review

Subsequent implementation decision: the user selected a relay on the existing
DCS server host, with automatic seat pairing. See [the current build](SERVER-HOSTED.md).
This review preserves the evidence for future native transport improvements.

Reviewed 2026-09-09 against repository HEAD
`3628753709b4390e70507e0cdaaa3f151b0f7b48` and the current experimental changes.

## Decision

Investigate **pilot-to-co-pilot state over DCS's existing multiplayer connection
before building a separate transport**. The earlier conclusion that an external
connection was necessary was premature. There is a concrete native numeric-state
path in this repository, but no verified complete shared-panel implementation.

If this path works, the players join the same SK60 in ordinary DCS multiplayer.
There is no additional service, VPN, companion application, invitation exchange,
or SK60-specific port setup. The normal DCS multiplayer server/session remains.
This does not mean DCS multiplayer itself is serverless.

The target remains the same panel for the left pilot and right co-pilot, with the
pilot retaining authority. Reverse commands and control handover are deferred.

## Evidence in the references

Paths below are relative to the repository root.

| Reference | Observed implementation | What it establishes |
|---|---|---|
| `SK60/SK-60.lua:618` | `net_animation` includes engine arguments 303–310, fuel 354 and electrical/control arguments 401, 402, 404–408, 417, 418, 420, 604, 605. | The aircraft already declares numeric state for DCS network animation replication. This is more relevant than inventing a separate socket first. |
| `SK60/EFM/ExternalFlightModel/SK-60_FM/SK-60_FM.cpp:1342` | The EFM writes normalized RPM, EGT, oil pressure and temperature to external arguments. Later blocks write fuel and electrical state. | A real producer exists; these are not merely unused entries in a list. |
| `SK60/Cockpit/Scripts/Systems/dcms_hud.lua:275` | Reads external arguments 303–306 for engine displays. | A cockpit consumer already exists. Correct delivery and electrical gating in the second seat must be checked in DCS. |
| `UH60 REF/UH-60L.lua:499` | `net_animation` lists controls, lighting, doors and other external arguments. | Native external-animation sharing is used by the reference. It does not prove arbitrary cockpit parameter sharing. |
| `UH60 REF/Cockpit/Scripts/Systems/Avionics.lua:64` | Reads external argument 14 into the stabilator indicator parameter. | Another example of external numeric state feeding an interior indicator. |
| `UH60 REF/Cockpit/Scripts/utils.lua:834` | `updateNetworkArgs` reads the local `NETWORK_UPDATE_ARG` parameter and applies actions. | This is a consumer of messages, not the network transport itself. |
| `UH60 REF/Cockpit/Scripts/ASN128/device/ASN128.lua:528` and `command_defs.lua:766` | Dispatches `startServer` and `connectServer` commands to the EFM. | The reference has a custom networking workflow. The available Lua does not establish a native DCS message transport for `NETWORK_UPDATE_ARG`. |
| `UH60 REF/ScriptHook/bhHook.lua` | Uses LuaSocket TCP to `127.0.0.1:9800` for gunner target information. | This hook is a local target-data bridge; it is not evidence of built-in crew synchronization. |
| `MB-339 REF/Cockpit/Backseat.lua:145` | Writes gauge values into external arguments 500 onward. | Useful precedent for representing interior instruments as external numeric arguments. |
| `MB-339 REF/MB-339PAN.lua:193` | Its active network list does not include those 500-series gauge arguments; the corresponding list at the bottom of `Backseat.lua` is commented out. | The supplied files do **not** prove those backseat gauges are replicated between PCs. External-model animation alone is insufficient evidence. |
| `MB-339 REF/Cockpit/device_init.lua` | Instantiates Lua devices and a compiled `Armament.dll`. | Some implementation is opaque. Do not infer a reusable complete synchronization API from a binary's presence. |
| `AlphaJet Ref/autoload.lua:35` | Explicit TODO for multicrew seat detection; the author could not access the back seat. | This reference is not a demonstrated multicrew solution. |
| `A4 REF/ExternalFM/include/Cockpit/ccParametersAPI.h:154` | Resolves `avCommunicator::sendNetMessage(bool)`. | A communicator-specific method, not an arbitrary payload send/receive API. |
| `Source Info/SDK_Perso/include/Cockpit/Base/Header/Avionics/avDevice.h:79` | Declares C++ `serialize(Serializer&)`. | Serialization exists internally, but the declaration alone does not expose a callable Lua network channel or establish compatibility with current DCS. |
| `Source Info/SDK_Perso/include/Cockpit/Base/Header/Avionics/avLuaDevice.h` | Declares Lua-device lifecycle/command functions; no explicit Lua network-payload registration API appears here. | No ready-to-use generic Lua synchronization interface was found in these headers. This is a finding about the supplied files, not proof no such DCS interface exists. |

Also searched the A-4 EFM API headers, SK60 EFM API headers and altimeter-reference
headers. No generic EFM multicrew packet callback was found there. The SDK
reference headers are not proof of a supported modern binary interface.

## SK60 issues that the native implementation must address

1. **The co-pilot's EFM returns early.** `SK-60_FM.cpp:433` checks
   `IsFmMaster()` and the non-master returns before normal gauge updates,
   including `GaugeSystem.update_engine_values()` around line 602. Receiving
   network arguments is therefore not sufficient to refresh EFM-driven needles.
   A follower display update must run without advancing the aircraft simulation.
2. **External values can be overwritten locally.** The experimental guard in
   `ed_fm_set_draw_args` currently depends on `MC_ENABLED`, which the old mailbox
   device enables from the external-transport configuration. A native mode must
   protect received state without depending on that configuration.
3. **Local Lua still owns power and switch state.** `electric_system.lua` updates
   its own switch targets and electrical parameters. `dcms_hud.lua` gates engine
   displays on local electrical status. A valid engine argument can therefore
   coexist with a blank display. Native follower logic must address both.
4. **Identical argument numbers do not join separate namespaces.** Listing 401
   in `net_animation` does not automatically synchronize cockpit argument 401 or
   `PTN_401`. An explicit producer/consumer mapping is required.
5. **Electrical bus values are not necessarily switch positions.** EFM outputs
   402/404 use `MainACBusA/B`; the network-list comments describe switches. Those
   values must not be treated as exact physical switch positions without tracing
   their producers. Failed/unpowered buses and selected switches can differ.
6. **Full panel coverage remains unproven.** Digital strings, radio tuning,
   navigation pages, radar contacts, warning logic and initialization require
   individual mapping or a verified native serialization interface. Do not
   represent arbitrary strings or hundreds of values as animation arguments
   until transport range, precision, rate and capacity have been measured.

An apparent oil-gauge mismatch needs a precise qualification: the reader names
`OP_RIGHT` and `OT_LEFT` use crossed argument numbers, but their assignments to
gauge indices are also crossed. The two swaps cancel: the final output mapping
is 307→OP_LEFT, 308→OP_RIGHT, 309→OT_LEFT, 310→OT_RIGHT. This is confusing source
naming, **not evidence that the displayed pressure/temperature are swapped**.

## Native validation before expanding coverage

Use the existing 303–310 engine channels first, plus fuel 354 and main-power 401.
Do not allocate a large new argument bank or assume unused model arguments work.

On two PCs in the same DCS aircraft, with the experimental Export transport
disabled, record the pilot and co-pilot's external argument values and their
corresponding local panel parameters separately. Keep the pilot in control.

- Cold start: operate main power, then start each engine separately. Check whether
  received raw arguments change even when a co-pilot gauge remains blank/frozen.
- Hot start and joining an already running aircraft: verify current state is
  available without replaying prior switch clicks.
- Change RPM gradually and in steps; compare range, precision, rate and latency.
- Leave/rejoin the right seat and respawn into a different aircraft. Verify no
  stale state and no cross-aircraft contamination.
- Compare raw values with and without local co-pilot writers to isolate overwrite
  behavior. Do not run the external snapshot adapter simultaneously.
- For actual implementation, verify a passive co-pilot display update does not
  run the EFM simulation or send control inputs back to the pilot.

If raw arguments arrive correctly, implement a small explicit follower display
mapping, fix local power gating/ownership, then expand system by system. If they
do not, investigate the native write/read callbacks and current DCS behavior
before drawing a conclusion about external networking.

## Status

This review is source inspection, not a two-PC DCS test. No full native sync claim
is made. The previous socket/relay prototype and partial desktop-app work remain
in the working tree, but are superseded as the default design by this native-first
investigation. The previous overlay is still an external-transport prototype;
it has not become a native implementation merely because this review was added.
