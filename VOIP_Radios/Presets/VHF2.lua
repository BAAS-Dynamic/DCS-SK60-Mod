preset =
{
    Channels =
    {
        [1] = 124.000,
    }, -- end of Channels
    Squelch = true,
    Step = 25000,
    OutputSD = 5,
    RegulationTime = 0.25,
    Ranges =
    {
        [1] =
        {
            minFreq = 118000000,
            maxFreq = 136975000,
            modulation = 0,
        }, -- end of [1]
    }, -- end of Ranges
    Power =
    {
        [1] =
        {
            value = 10,
        }, -- end of [1]
    }, -- end of Power
    InputSD = 50,
    Encryption =
    {
        enable = false,
        key = 1,
        present = false,
    }, -- end of Encryption
    MaxSearchTime = 0,
    FrequencyAccuracy = 1,
    MinSearchTime = 0,
    Guards =
    {
        [1] =
        {
            modulation = 0,
            freq = 121500000,
        }, -- end of [1]
    }, -- end of Guards
    Name = "VHF2",
    ID = "VHF2",
    InputSLZ = 10,
    InnerNoise = 1.1561e-06,
    BandWidth = 1,
} -- end of preset
