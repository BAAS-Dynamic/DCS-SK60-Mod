# Shared-panel transfer optimization

The pilot remains authoritative for engine and shared-system values. The co-pilot
receives RPM itself; it does not derive RPM from throttle input.

With a connected peer, the cockpit still checks the selected 854 parameters at up
to 20 Hz. Only changed values are transmitted, without rounding or a dead band.
A complete baseline is sent on connection, every five seconds, and whenever more
than 60% of the values change. An otherwise idle connection sends a heartbeat
every half second. Received unchanged values are not written back to the panel,
and unchanged radio frequencies are not repeatedly applied. Mailbox writes are
also reduced when neither data nor acknowledgements change.

Changes have ordered revision numbers. Missing changes, invalid state or excessive
backlog cause a reconnect and a fresh complete baseline. Ordered changes are never
coalesced as though each were a complete snapshot. A disconnected co-pilot retains
the existing frozen-state behavior. This does not add interpolation, two-way system
control or flight-control handover support.

## Synthetic measurement

Run `python SK60/Multicrew/tests/test_optimization.py --benchmark` to reproduce.
The test uses Lua 5.1, 854 parameters and 1,200 samples representing 60 seconds.
Sizes are panel payload bytes before hexadecimal transport encoding and TLS;
they exclude connection traffic and filesystem operations.

| Continuously changing values | Previous bytes | Optimized bytes | Reduction |
| --- | ---: | ---: | ---: |
| 0 | 8,070,000 | 81,426 | 98.99% |
| 8 | 8,242,697 | 318,902 | 96.13% |
| 500 | 18,689,727 | 15,332,604 | 17.96% |

These are deterministic synthetic scenarios, not measurements of actual DCS
traffic or FPS. Benefits shrink as more values change. Parameter reads still cost
CPU time, and comparison/cache maintenance also has a cost. Real two-PC testing
must check frame times, panel coverage, motion quality, network usage and reconnects.

Both players must install the updated overlay through the new player application
and restart DCS. Use matching current player and server packages.
