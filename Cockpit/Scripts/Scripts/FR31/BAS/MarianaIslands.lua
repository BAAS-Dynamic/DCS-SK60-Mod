-- Marianas FR31 BAS database.
-- A and B are derived from Aerodrome_Data_and_Frequencies_Day_by_DimOn_latest.
-- C and C2 are proposed approach/package channels, and D is the proposed UHF
-- guard/ATC backup. All frequencies use valid 25 kHz FR31 channels.
return {
    [1] = { name = "Rota", A = 123.600E6, B = 250.000E6, C = 130.125E6, C2 = 300.125E6, D = 243.000E6 },
    [2] = { name = "Antonio B. Won Pat Intl", A = 118.100E6, B = 340.200E6, C = 130.075E6, C2 = 300.075E6, D = 243.000E6 },
    [3] = { name = "Tinian", A = 123.650E6, B = 250.050E6, C = 130.225E6, C2 = 300.225E6, D = 243.000E6 },
    [4] = { name = "Saipan", A = 125.700E6, B = 256.900E6, C = 130.175E6, C2 = 300.175E6, D = 243.000E6 },
    [6] = { name = "Andersen AFB", A = 126.200E6, B = 250.100E6, C = 130.025E6, C2 = 300.025E6, D = 243.000E6 },
}
