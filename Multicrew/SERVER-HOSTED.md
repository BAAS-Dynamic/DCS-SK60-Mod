# DCS-server-hosted SK60 Crew

Current default: **pilot-owned state with restricted co-pilot commands** for
navigation, radio tuning and transponder. Engine start stays left-seat only.
DCS J flight-control handover remains unfinished. The native transport review remains useful;
this build retains ordinary DCS flight/animation networking and adds the existing
panel-snapshot adapter for shared state that was not verified to synchronize natively.

Start with [player setup](QUICKSTART.txt) and [server setup](SERVER-SETUP.txt).

The player app also offers explicit **Host as pilot** and **Join as co-pilot**
modes. These use a TLS relay inside the pilot app and need no server hook on the
DCS host. See the direct-connection section in the player guide. Manual mode
uses the same optimized cockpit transport and command restrictions but cannot verify aircraft
pairing against a server roster. Automatic routes are ignored in manual mode.

Manual authentication uses PBKDF2-HMAC-SHA256 (600,000 iterations, per-hosting-run
random salt) and mutual HMAC proofs over fresh client/server nonces and the TLS
certificate fingerprint. This is not a PAKE: observed proofs permit offline
guessing of weak passwords. Users choose length and complexity; only an empty
password is rejected. Neither password nor derived key is saved.
The pilot certificate/key is stored under Config/SK60Crew/Direct. Guest tokens
are temporary and authenticated guests cannot claim the pilot role. There is one
guest reservation and at most six authentication starts per minute per host run.
Stop hosting before changing the code; stopping closes the listener and peers.

Manual mode maintains a separate authenticated TLS control connection with a
one-second heartbeat and five-second read timeout. It reserves the co-pilot slot
before DCS starts. A pinned data connection uses the temporary token from that
control session; exiting a cockpit closes data pairing but preserves the crew
connection. Loss of the control session revokes the guest data token/connection.

The co-pilot device emits A:<revision> only after applying a valid optimized state
and while its last state is fresh. These receipts travel in generation-scoped
relay frames. Both apps accept only matching-generation, non-future receipts for
observed state revisions. DCS ready expires after three seconds without local
traffic; Data syncing requires fresh data and a receipt within 2.5 seconds plus
an active pairing. Ordinary packet counts alone cannot activate it. Automatic
server mode supports these receipts too; update its relay and both aircraft overlays.

Selecting Host as pilot fills an empty public-IP field using https://api.ipify.org
over certificate-verified HTTPS. This optional convenience sends no credentials or
DCS data; the provider sees the request's public source IP. Lookup runs in a worker
with a five-second socket timeout, validates a bounded public IPv4 response, and
rejects redirects. Manual entry and retry remain available. Hosting does not depend
on this service and lookup does not test port forwarding or bypass CGNAT/VPN routing.

The server app's connected-client table uses names supplied by its DCS hook.
Only accepted relay peers appear; Paired reflects an active relay generation.
Names update with the roster and disappear on disconnect or lease revocation.

## Components and trust boundary

`crew_app.py` / `server_app.py` provide player and server Windows applications.
`installer.py` checks the aircraft overlay against its current/base hashes, backs
up changed files and rolls back failed writes. SRS/other Export.lua content is
preserved; GameGUI hooks use separate files. Installation requires a DCS restart.

`server_host.py` runs the TLS relay alongside the actual DCS server. It creates a
local certificate and a replenished pool of cryptographically random tickets.
The pool has a fresh instance ID on each relay start. The server DCS hook,
`hooks/server.lua`, assigns tickets using `net.get_player_info` and
`DCS.getUnitProperty(..., DCS.UNIT_TYPE)`; it only admits the two SK60 seat formats
explicitly supported here. It writes a short-lived roster to the local filesystem
and sends each client its own route via targeted DCS server chat.

The player hook, `hooks/client.lua`, accepts route announcements only from DCS's
server player ID 1 and for its own current slot. It clears the route on leaving,
mission/disconnect events or expired announcements. It never evaluates the data.
The listen-server pilot receives a loopback route directly from the server hook.

`auto_client.py` follows the route file, validates the server certificate fingerprint
**before** sending the ticket and supplies a loopback bridge for DCS Export.
Certificate trust is established by the joined DCS server, not a paid/public CA.
The DCS host and local profile files are trusted; this is not a replacement for
DCS's own authentication or protection against an administrator of that computer.
Machine messages are private, but DCS/third-party chat logging should not be
assumed to redact them; do not distribute route files or private announcements.

The relay substitutes the roster's mission/aircraft identity into the handshake.
It does not trust a client-supplied room, aircraft ID or claimed seat. In particular,
DCS mission slot IDs and Export runtime object IDs are not assumed equal. Exactly
one live client is allowed per authorized ticket; the underlying relay also rejects
duplicate seats and schema mismatch. A monitor revokes stale credentials even if
the client sends no further frames. Mission changes, slot changes and restarting
the service invalidate old pairings. Temporary Windows file-replacement gaps retain
only the original four-second roster lease; failed reads never extend it.

## One-way cockpit behavior

The installer selects `one_way=false`, `auto_server=true` and `optimized=true`; the cockpit and relay enforce the restricted avionics command policy. A supporting connection
activates the cockpit wrapper; on an unsupported server it stays inactive until a
pair actually connects. Once activated, loss of snapshots freezes the co-pilot's
shared state rather than simulating a conflicting second copy. Normal personal
controls remain local, and the pilot remains the flight-model authority.

The new mode drops co-pilot shared-system commands in both the Lua wrapper and the
outbound mailbox collector. The hosted relay independently rejects command payloads
from the right seat. It forwards ordered changes and periodic full pilot snapshots, preserving the existing
mailbox validation, generation checks and late-join resynchronization. The EFM
draw-argument guard prevents the activated non-master from overwriting received
external animations. This does not add flight-model authority migration.

`MC_CONNECTED` in the cockpit is the indicator that a valid snapshot has been
applied on the co-pilot. The desktop transport status alone cannot prove DCS
rendered every instrument correctly.

The optimized transport sends only changed values between complete snapshots,
with an idle heartbeat every half second and a full refresh every five seconds.
Missing revisions or excessive backlog trigger reconnection and a fresh baseline.
See [performance measurements and limitations](PERFORMANCE.md).

## Building and testing

Source requirements: Python with Tkinter, `lupa` (Lua 5.1) for tests,
`cryptography` for certificate generation, and PyInstaller for Windows packaging.
The prepared workspace keeps test/build dependencies in `.test-deps` / `.build-deps`.
The EFM must first be built as Release x64 into `.build/bin/SAAB_SK60_FM.dll`.

```
python SK60/Multicrew/tests/test_sync.py
python SK60/Multicrew/tests/test_desktop.py
python SK60/Multicrew/tests/test_hosted.py
python SK60/Multicrew/tests/test_optimization.py
python SK60/Multicrew/tests/test_manual.py
python SK60/Multicrew/build_desktop.py
```

The build regenerates the schema, packages the checked overlay and creates both
Windows executables plus player/server ZIPs and SHA-256 sums under `dist/`.
It runs each frozen app with `--self-test` to check bundled resources and Tk startup.
It does not install anything into a real DCS profile or modify firewall settings.

Tests cover original snapshot behavior, installer rollback, Lua hook identity and
announcement handling, aircraft separation, TLS pinning, seat revocation, stale
routes and read-only enforcement. Actual DCS ABI/hook behavior, shared panel
coverage, packet rates and native device behavior still require multiplayer testing.

## Scope of the DCS integration

The automatic announcement approach follows the pattern demonstrated by the
[SRS server hook](https://github.com/ciribob/DCS-SimpleRadioStandalone/blob/master/Scripts/DCS-SRS-AutoConnectGameGUI.lua).
The new hook code is specific to SK60 and was not copied from that implementation.
The supplied repository references are assessed in [the native review](NATIVE-DCS-REVIEW.md).

Static mission slots only are supported in this first version. GameGUI's
second-seat suffix `_2` maps to cockpit crew index `1`, as demonstrated by
[SRS's client hook](https://github.com/ciribob/DCS-SimpleRadioStandalone/blob/master/Scripts/DCS-SRS/Scripts/DCS-SRSGameGUI.lua).
This mapping and private chat callbacks still need verification on the target
DCS build. Unknown formats fail closed rather than pair to an uncertain aircraft.
Two crew in the same mission slot without matching schema never synchronize.

The earlier `service.py`, `app.py` and invitation-mode APIs remain development
prototypes. They are not launched by either new executable and are not required
by server-hosted mode. There is no central service address or external account.
