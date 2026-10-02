-- FR31 NR-mode frequency presets.
--
-- Each table key maps to the last digit of the displayed NR channel:
-- [0] displays as channel 100, [1] as 101, and so on through 109.
-- Frequencies are defined in Hz and must be valid FR31 channels.
FR31_PRESETS = {
    [0] = 243.000E6,
    [1] = 261.000E6,
    [2] = 251.000E6,
    [3] = 250.000E6,
    [4] = 261.500E6,
    [5] = 273.000E6,
    [6] = 130.000E6,
    [7] = 131.000E6,
    [8] = 132.000E6,
    [9] = 133.000E6,
}

-- BAS presets are loaded separately from FR31/BAS for the active DCS terrain.
