dofile(LockOn_Options.script_path.."devices.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."FR31/FR31_presets.lua")
dofile(LockOn_Options.script_path.."FR31/FR31_bas_database.lua")

local dev = GetSelf()
make_default_activity(0.05)

local fr31_display_enable = get_param_handle("FR31_DSP_ENABLE")
local fr31_active_freq = get_param_handle("FR31_ACTIVE_FREQ")
local fr31_mode = get_param_handle("FR31_MODULATION")
local fr31_freq_hz = get_param_handle("FR31_FREQ_HZ")
local fr31_powered = get_param_handle("FR31_POWERED")
local fr31_backing_available = get_param_handle("FR31_BACKING_AVAILABLE")
local fr31_operating_mode = get_param_handle("FR31_OPERATING_MODE")
local fr31_nr_preset = get_param_handle("FR31_NR_PRESET")
local fr31_entry_active = get_param_handle("FR31_ENTRY_ACTIVE")
local fr31_entry_length = get_param_handle("FR31_ENTRY_LENGTH")
local fr31_frequency_valid = get_param_handle("FR31_FREQ_VALID")
local bas_suffix_enables = {
    A = get_param_handle("FR31_BAS_SUFFIX_A_ENABLE"),
    B = get_param_handle("FR31_BAS_SUFFIX_B_ENABLE"),
    C = get_param_handle("FR31_BAS_SUFFIX_C_ENABLE"),
    D = get_param_handle("FR31_BAS_SUFFIX_D_ENABLE"),
    ["2"] = get_param_handle("FR31_BAS_SUFFIX_2_ENABLE"),
}
local DISPLAY_DIGIT_COUNT = 5
local fr31_digits = {}
local fr31_digit_enables = {}
for i = 1, DISPLAY_DIGIT_COUNT do
    fr31_digits[i] = get_param_handle("FR31_DIGIT_" .. i)
    fr31_digit_enables[i] = get_param_handle("FR31_DIGIT_" .. i .. "_ENABLE")
end
local radio_power = get_param_handle("RADIO_POWER")
local main_power = get_param_handle("PTN_401")
local mode_switch = get_param_handle("PTN_717")

local FREQ_STEP_HZ = 25E3
local DEFAULT_FREQ_HZ = 124.8E6
local MODE_MANUAL = 1
local MODE_NR = 2
local MODE_BAS = 3
local DEFAULT_NR_PRESET = 0
local NR_DISPLAY_PREFIX = "10"

local NR_PRESET_COUNT = 10
local MISSION_RADIO_INDEX = 1
local digit_buffer = ""
local entry_active = false
local current_freq_hz = DEFAULT_FREQ_HZ
local current_modulation = 0 -- 0 = AM, 1 = FM
local operating_mode = MODE_MANUAL
local current_nr_preset = DEFAULT_NR_PRESET
local current_bas_group = nil
local current_bas_subchannel = nil
local last_backing_radio_available = 0
local FR31_BAS_PRESETS = {}

local function bool_to_number(value)
    return value and 1 or 0
end

local function frequencies_differ(left_hz, right_hz)
    return math.abs(left_hz - right_hz) >= 1
end

local digit_commands = {
    [Keys.FR31_Key_0] = "0",
    [Keys.FR31_Key_1] = "1",
    [Keys.FR31_Key_2] = "2",
    [Keys.FR31_Key_3] = "3",
    [Keys.FR31_Key_4] = "4",
    [Keys.FR31_Key_5] = "5",
    [Keys.FR31_Key_6] = "6",
    [Keys.FR31_Key_7] = "7",
    [Keys.FR31_Key_8] = "8",
    [Keys.FR31_Key_9] = "9",
}

for command,_ in pairs(digit_commands) do
    dev:listen_command(command)
end

dev:listen_command(Keys.FR31_Mode)
dev:listen_command(Keys.FR31_Clear)
dev:listen_command(Keys.FR31_Manual_Mode)
dev:listen_command(Keys.FR31_NR_Mode)
dev:listen_command(Keys.FR31_BAS_Mode)


local function set_display_text(text)
    local display_index = 1

    for i = 1, DISPLAY_DIGIT_COUNT do
        fr31_digit_enables[i]:set(0)
        fr31_digits[i]:set(0)
    end

    for i = 1, string.len(text) do
        local char = string.sub(text, i, i)
        if display_index <= DISPLAY_DIGIT_COUNT and char ~= "." then
            fr31_digits[display_index]:set(tonumber(char) or 0)
            fr31_digit_enables[display_index]:set(1)
            display_index = display_index + 1
        end
    end
end

local function clear_bas_suffix_display()
    for _,handle in pairs(bas_suffix_enables) do
        handle:set(0)
    end
end

local function set_bas_display()
    clear_bas_suffix_display()

    if current_bas_group == nil then
        set_display_text(digit_buffer)
        return
    end

    set_display_text(string.format("%03d", current_bas_group))
    if current_bas_subchannel == nil then
        return
    end

    local suffix_letter = string.sub(current_bas_subchannel, 1, 1)
    bas_suffix_enables[suffix_letter]:set(1)
    if current_bas_subchannel == "C2" then
        bas_suffix_enables["2"]:set(1)
    end
end

local function format_frequency_text(freq_hz)
   -- The real FR31 shows five digits without a decimal. The sixth kHz digit is
   -- always entered as an implicit trailing zero, so 243.150 MHz displays as
   -- 24315.
    local frequency_khz_text = string.format("%06d", math.floor((freq_hz / 1E3) + 0.5))
    return string.sub(frequency_khz_text, 1, 5)
end

local function format_entry_text()
    return digit_buffer
end

local function format_nr_channel_text()
    return NR_DISPLAY_PREFIX .. tostring(current_nr_preset)
end

local function is_powered()
    return main_power:get() > 0.5
end

local function is_valid_fr31_frequency(freq_hz)
    if freq_hz == nil or freq_hz < 104E6 or freq_hz > 407.975E6 then
        return false
    end

    if freq_hz > 161.975E6 and freq_hz < 223E6 then
        return false
    end

    return math.floor((freq_hz / FREQ_STEP_HZ) + 0.5) * FREQ_STEP_HZ == freq_hz
end

local function is_uhf_fr31_frequency(freq_hz)
    return freq_hz ~= nil and freq_hz >= 223E6 and freq_hz <= 407.975E6
end

local function get_backing_radio()
    local uhf_radio = GetDevice(devices.UHF_RADIO)
    if uhf_radio ~= nil then
        last_backing_radio_available = 1
        return uhf_radio
    end

    last_backing_radio_available = 0
    return nil
end

local function get_backing_radio_frequency()
    local uhf_radio = get_backing_radio()
    if uhf_radio ~= nil then
        local ok, radio_freq_hz = pcall(function()
            return uhf_radio:get_frequency()
        end)

        if ok then
            last_backing_radio_available = 1
            return radio_freq_hz
        end
    end

    last_backing_radio_available = 0
    return nil
end

local function publish_fr31_state()
    fr31_freq_hz:set(current_freq_hz)
    fr31_active_freq:set(current_freq_hz / 1E6)
    fr31_mode:set(current_modulation)
    fr31_powered:set(bool_to_number(is_powered()))
    fr31_backing_available:set(last_backing_radio_available)
    fr31_operating_mode:set(operating_mode)
    fr31_nr_preset:set(current_nr_preset)
    fr31_entry_active:set(bool_to_number(entry_active))
    fr31_entry_length:set(string.len(digit_buffer))
    fr31_frequency_valid:set(bool_to_number(is_valid_fr31_frequency(current_freq_hz)))
end

local function apply_fr31_frequency(freq_hz)
    current_freq_hz = freq_hz
    publish_fr31_state()
end

local function apply_radio_device_frequency(freq_hz)
   -- The DCS communicator behind FR31 is an avUHF_ARC_164. Keep it on its
   -- last valid UHF channel while the logical FR31 tunes VHF; SRS reads the
   -- authoritative FR31_FREQ_HZ parameter directly.
    if not is_uhf_fr31_frequency(freq_hz) then
        return
    end

    local uhf_radio = get_backing_radio()
    if uhf_radio ~= nil then
        local ok = pcall(function()
            uhf_radio:set_frequency(freq_hz)
        end)
        last_backing_radio_available = bool_to_number(ok)
    end

    local freqency_EFM_exchange = get_param_handle("RADIO_UHF_FREQ_EXC")
    local freq_uplink_signal = get_param_handle("RADIO_2EFM_CHANGED")
    local freq_efm_signal = get_param_handle("RADIO_EFM_CHANGED")
    freqency_EFM_exchange:set(freq_hz / 1E3)
    freq_uplink_signal:set(1)
    freq_efm_signal:set(0)
end

local function set_radio_frequency(freq_hz)
    apply_fr31_frequency(freq_hz)
    apply_radio_device_frequency(freq_hz)
end

local function sync_from_backing_radio()
   -- Keep the FR31 control head authoritative while the pilot is entering
   -- digits. The backing DCS radio can still update FR31 when an external
   -- radio-menu action changes the communicator frequency, but it must not
   -- erase an in-progress keypad entry.
    if entry_active or not is_uhf_fr31_frequency(current_freq_hz) then
        return
    end

    local radio_freq_hz = get_backing_radio_frequency()
    if is_valid_fr31_frequency(radio_freq_hz) and frequencies_differ(radio_freq_hz, current_freq_hz) then
        apply_fr31_frequency(radio_freq_hz)
    else
        publish_fr31_state()
    end
end

local function set_radio_modulation(modulation)
    current_modulation = modulation
    fr31_mode:set(modulation)

   -- Keep the backing ARC-164 in AM. SRS reads the FR31 AM/FM switch from
   -- the exporter, and forcing FM into this native UHF device can destabilize
   -- DCS builds that only implement AM for avUHF_ARC_164.
    local uhf_radio = get_backing_radio()
    if uhf_radio ~= nil then
        local ok = pcall(function()
            uhf_radio:set_modulation(MODULATION_AM or 0)
        end)
        last_backing_radio_available = bool_to_number(ok)
    end

    publish_fr31_state()
end

local function get_nr_preset_frequency(preset)
    if FR31_PRESETS == nil then
        return nil
    end

    return FR31_PRESETS[preset]
end

local BAS_SUBCHANNELS = {
    [1] = "A",
    [2] = "B",
    [3] = "C",
    [4] = "C2",
    [5] = "D",
}

local function get_bas_frequency(group, subchannel)
    local group_presets = FR31_BAS_PRESETS and FR31_BAS_PRESETS[group]
    if group_presets == nil then
        return nil
    end

    return group_presets[subchannel]
end

local function load_bas_presets_for_terrain()
    FR31_BAS_PRESETS = FR31_load_bas_database()
end

local function select_bas_subchannel(digit)
    if current_bas_group == nil then
        return
    end

    local subchannel = BAS_SUBCHANNELS[digit]
    local freq_hz = get_bas_frequency(current_bas_group, subchannel)
    if subchannel == nil or not is_valid_fr31_frequency(freq_hz) then
        return
    end

    current_bas_subchannel = subchannel
    set_radio_frequency(freq_hz)
end

local function normalise_mission_frequency(freq)
    if freq == nil then
        return nil
    end

    local numeric_freq = tonumber(freq)
    if numeric_freq == nil then
        return nil
    end

   -- DCS mission radio channel data is normally stored in MHz, while the
   -- FR31 preset table uses Hz. Accept Hz as well so hand-built mission data
   -- or future DCS changes do not require another conversion path.
    if numeric_freq < 1E6 then
        return numeric_freq * 1E6
    end

    return numeric_freq
end

local function set_nr_preset_if_valid(preset, freq)
    local freq_hz = normalise_mission_frequency(freq)
    if is_valid_fr31_frequency(freq_hz) then
        FR31_PRESETS[preset] = freq_hz
        return true
    end

    return false
end

local function get_mission_radio_channels()
    if get_aircraft_mission_data == nil then
        return nil
    end

    local mission_radio_data = get_aircraft_mission_data("Radio")
    if mission_radio_data == nil or mission_radio_data[MISSION_RADIO_INDEX] == nil then
        return nil
    end

    return mission_radio_data[MISSION_RADIO_INDEX].channels
end

local function load_nr_presets_from_mission()
    if FR31_PRESETS == nil then
        FR31_PRESETS = {}
    end

    local mission_channels = get_mission_radio_channels()
    if mission_channels == nil then
        return false
    end

    local loaded_any = false
    local has_zero_based_channels = mission_channels[0] ~= nil

    for preset = 0, NR_PRESET_COUNT - 1 do
        local channel_index = has_zero_based_channels and preset or preset + 1
        loaded_any = set_nr_preset_if_valid(preset, mission_channels[channel_index]) or loaded_any
    end

    return loaded_any
end

local function select_nr_preset(preset)
    local preset_freq_hz = get_nr_preset_frequency(preset)
    if not is_valid_fr31_frequency(preset_freq_hz) then
        return
    end

    current_nr_preset = preset
    set_radio_frequency(preset_freq_hz)
end

local function apply_buffer_if_complete()
    if string.len(digit_buffer) < 5 then
        return
    end

    local frequency_entry = digit_buffer .. "0"
    local mhz = tonumber(string.sub(frequency_entry, 1, 3))
    local khz = tonumber(string.sub(frequency_entry, 4, 6))
    local freq_hz = (mhz * 1E6) + (khz * 1E3)

    if is_valid_fr31_frequency(freq_hz) then
        set_radio_frequency(freq_hz)
    end

    digit_buffer = ""
    entry_active = false
end

local function update_display()
    local powered = is_powered()
    fr31_display_enable:set(bool_to_number(powered))

   -- Do not gate the DCS/SRS radio availability on the FR31 display power.
   -- The old SK60 kept RADIO_POWER on after initialization; tying this shared
   -- parameter to PTN_401 causes SRS to connect briefly, then drop the aircraft
   -- once the cold-start electrical state settles.
    radio_power:set(1.0)
    fr31_active_freq:set(current_freq_hz / 1E6)

    clear_bas_suffix_display()
    if operating_mode == MODE_BAS then
        set_bas_display()
    elseif operating_mode == MODE_NR then
        set_display_text(format_nr_channel_text())
    elseif entry_active then
        set_display_text(format_entry_text())
    else
        set_display_text(format_frequency_text(current_freq_hz))
    end

    publish_fr31_state()
end

function post_initialize()
    load_bas_presets_for_terrain()
    load_nr_presets_from_mission()
    get_backing_radio()
    select_nr_preset(current_nr_preset)
    if not is_valid_fr31_frequency(current_freq_hz) then
        set_radio_frequency(DEFAULT_FREQ_HZ)
    end
    set_radio_modulation(mode_switch:get() > 0.5 and 1 or 0)
    update_display()
end

function SetCommand(command, value)
    if command == Keys.FR31_Mode then
        set_radio_modulation(value > 0 and 1 or 0)
        update_display()
        return
    end

    if value <= 0 or not is_powered() then
        update_display()
        return
    end

    if command == Keys.FR31_Manual_Mode then
        operating_mode = MODE_MANUAL
        digit_buffer = ""
        entry_active = false
        update_display()
        return
    end

    if command == Keys.FR31_NR_Mode then
        operating_mode = MODE_NR
        digit_buffer = ""
        entry_active = false
        select_nr_preset(current_nr_preset)
        update_display()
        return
    end


    if command == Keys.FR31_BAS_Mode then
        operating_mode = MODE_BAS
        -- Selecting BAS starts a fresh three-digit group entry, just like CL.
        -- Once a group is accepted, digit keys select its subchannels until
        -- CL (or BAS again) explicitly clears the group.
        digit_buffer = ""
        current_bas_group = nil
        current_bas_subchannel = nil
        entry_active = true
        update_display()
        return
    end

    if command == Keys.FR31_Clear then
        if operating_mode == MODE_MANUAL then
            digit_buffer = ""
            entry_active = true
        elseif operating_mode == MODE_BAS then
            digit_buffer = ""
            current_bas_group = nil
            current_bas_subchannel = nil
            entry_active = true
        end
        update_display()
        return
    end

    local digit = digit_commands[command]
    if digit ~= nil then
        if operating_mode == MODE_NR then
            select_nr_preset(tonumber(digit))
        elseif operating_mode == MODE_BAS then
            if current_bas_group ~= nil then
                select_bas_subchannel(tonumber(digit))
            elseif entry_active then
                digit_buffer = digit_buffer .. digit
                if string.len(digit_buffer) == 3 then
                    local group = tonumber(digit_buffer)
                    if group ~= nil and group >= 1 and group <= 999 and FR31_BAS_PRESETS[group] ~= nil then
                        current_bas_group = group
                        current_bas_subchannel = nil
                    end
                    digit_buffer = ""
                    entry_active = false
                end
            end
        elseif entry_active then
            digit_buffer = digit_buffer .. digit
            if string.len(digit_buffer) > 5 then
                digit_buffer = string.sub(digit_buffer, -5)
            end
            apply_buffer_if_complete()
        end
    end

    update_display()
end

function update()
    sync_from_backing_radio()

    local switch_modulation = mode_switch:get() > 0.5 and 1 or 0
    if switch_modulation ~= current_modulation then
        set_radio_modulation(switch_modulation)
    end

    update_display()
end

need_to_be_closed = false

-- SK60 shared cockpit integration
dofile(LockOn_Options.script_path .. "Multicrew/runtime.lua").install(23)
