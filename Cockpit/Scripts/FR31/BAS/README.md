# FR31 BAS databases

The FR31 loads one BAS database when its cockpit device initializes. It uses the
canonical `mission.theatre` value when available and falls back to DCS's
`get_terrain_related_data("name")` API. For example, the Caucasus terrain uses
`Caucasus.lua`. If a matching file is unavailable, `default.lua` is loaded.
Known alternate terrain identifiers are normalized by the loader; identifiers
containing `Kola` (such as `KolaMap` or `OrbxKola`) select the Kola database.
Internal DCS identifiers such as `GermanyCW`, `MarianaIslands`, `SinaiMap`, and
`Falklands` are presented on the kneeboard with readable map names.

Map-specific databases are included for Afghanistan, Caucasus, Cold War
Germany, Iraq, Kola, Marianas, Marianas WWII, Nevada, Normandy 2.0, Persian
Gulf, Sinai, South Atlantic, Syria, and The Channel.
The fallback contains 21 generic airfields using the Caucasus channel plan.

Every database returns a Lua table keyed by numeric BAS group. Numeric key `1`
is displayed as group `001`; valid keys therefore run from `1` through `999`.
Each group has a descriptive name and frequencies in Hz for its five panel
sub-channels:

```lua
return {
    [1] = {
        name = "Example airfield",
        A = 118.000E6,
        B = 121.500E6,
        C = 130.000E6,
        C2 = 243.000E6,
        D = 250.000E6,
    },
}
```

DCS terrain airport data can be consulted while assembling these files, but
the databases remain explicit because DCS does not define the FR31-specific
group numbers or A/B/C/C2/D assignments and does not expose complete radio
data consistently on every terrain.
