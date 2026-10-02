-- Builds the mission-specific FR31 data shown on the dynamic kneeboard page.
dofile(LockOn_Options.script_path .. "FR31/FR31_presets.lua")
dofile(LockOn_Options.script_path .. "FR31/FR31_bas_database.lua")

local FREQ_STEP_HZ = 25E3
local NR_PRESET_COUNT = 10
local MISSION_RADIO_INDEX = 1

local function is_valid_fr31_frequency(freq_hz)
    if freq_hz == nil or freq_hz < 104E6 or freq_hz > 407.975E6 then
        return false
    end

    if freq_hz > 161.975E6 and freq_hz < 223E6 then
        return false
    end

    return math.floor((freq_hz / FREQ_STEP_HZ) + 0.5) * FREQ_STEP_HZ == freq_hz
end

local function normalise_frequency(freq)
    local numeric_freq = tonumber(freq)
    if numeric_freq == nil then
        return nil
    end

    if numeric_freq < 1E6 then
        return numeric_freq * 1E6
    end

    return numeric_freq
end

local function copy_default_nr_presets()
    local presets = {}
    for preset = 0, NR_PRESET_COUNT - 1 do
        presets[preset] = FR31_PRESETS[preset]
    end
    return presets
end

local function load_mission_nr_presets()
    local presets = copy_default_nr_presets()
    if get_aircraft_mission_data == nil then
        return presets
    end

    local radio_data = get_aircraft_mission_data("Radio")
    local radio = radio_data and radio_data[MISSION_RADIO_INDEX]
    local channels = radio and radio.channels
    if channels == nil then
        return presets
    end

    local zero_based = channels[0] ~= nil
    for preset = 0, NR_PRESET_COUNT - 1 do
        local channel_index = zero_based and preset or preset + 1
        local freq_hz = normalise_frequency(channels[channel_index])
        if is_valid_fr31_frequency(freq_hz) then
            presets[preset] = freq_hz
        end
    end

    return presets
end

local function get_theatre_name()
    local theatre = FR31_get_bas_theatre()
    if type(theatre) ~= "string" or theatre == "" then
        return "UNKNOWN TERRAIN"
    end

    return string.upper(theatre)
end


function FR31_get_kneeboard_data()
    return {
        theatre = get_theatre_name(),
        nr = load_mission_nr_presets(),
        bas = FR31_load_bas_database(),
    }
end
