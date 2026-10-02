dofile(LockOn_Options.script_path.."devices.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")

local dev = GetSelf()
make_default_activity(0.05)

local main_power = get_param_handle("PTN_401")
local fr33_active_freq = get_param_handle("FR33_ACTIVE_FREQ")
local fr33_freq_hz = get_param_handle("FR33_FREQ_HZ")
local fr33_powered = get_param_handle("FR33_POWERED")
local fr33_debug_text = get_param_handle("FR33_DEBUG_TEXT")
local fr33_backing_available = get_param_handle("FR33_BACKING_AVAILABLE")
local fr33_debug_text_enabled = false

local MIN_FREQ_HZ = 118.000E6
local MAX_FREQ_HZ = 135.975E6
local DEFAULT_FREQ_HZ = 124.800E6
local FREQ_STEP_HZ = 25E3
local STEP_MHZ_HZ = 1E6
local STEP_100KHZ_HZ = 100E3
local DIAL_ARGS = {950, 951, 952, 953, 954, 955}
local DIAL_PARAM_NAMES = {
    "FR33_DIAL_100MHZ",
    "FR33_DIAL_10MHZ",
    "FR33_DIAL_1MHZ",
    "FR33_DIAL_100KHZ",
    "FR33_DIAL_10KHZ",
    "FR33_DIAL_1KHZ",
}
local MISSION_RADIO_INDEX = 2

local current_freq_hz = DEFAULT_FREQ_HZ
local last_debug_text = nil
local backing_radio_available = 0
local dial_params = {}

for index,param_name in ipairs(DIAL_PARAM_NAMES) do
    dial_params[index] = get_param_handle(param_name)
end

local function bool_to_number(value)
    return value and 1 or 0
end

local function is_powered()
    return main_power:get() > 0.5
end

local function snap_25khz(freq_hz)
    return math.floor((freq_hz / FREQ_STEP_HZ) + 0.5) * FREQ_STEP_HZ
end

local function clamp_frequency(freq_hz)
    return math.min(MAX_FREQ_HZ, math.max(MIN_FREQ_HZ, freq_hz))
end

local function normalise_frequency(freq_hz)
    return clamp_frequency(snap_25khz(freq_hz))
end

local function is_valid_fr33_frequency(freq_hz)
    if freq_hz == nil then
        return false
    end

    if freq_hz < MIN_FREQ_HZ or freq_hz > MAX_FREQ_HZ then
        return false
    end

    return snap_25khz(freq_hz) == freq_hz
end

local function format_frequency_text(freq_hz)
    return string.format("%.3f MHz", freq_hz / 1E6)
end

local function get_backing_radio()
    local vhf_radio = GetDevice(devices.VHF_RADIO)
    if vhf_radio ~= nil then
        backing_radio_available = 1
        return vhf_radio
    end

    backing_radio_available = 0
    return nil
end

local function set_dial_args(freq_hz)
    local freq_khz = math.floor((freq_hz / 1E3) + 0.5)
    local text = string.format("%06d", freq_khz)

    for index,arg in ipairs(DIAL_ARGS) do
        local digit = tonumber(string.sub(text, index, index)) or 0
       -- The cockpit model uses decimal wheel args; 0.0 = digit 0, 0.9 = digit 9.
        local arg_value = digit / 10.0
        dial_params[index]:set(arg_value)
        set_aircraft_draw_argument_value(arg, arg_value)
        if type(set_cockpit_draw_argument_value) == "function" then
            set_cockpit_draw_argument_value(arg, arg_value)
        end
    end
end

local function publish_state(show_message)
    local debug_text = format_frequency_text(current_freq_hz)

    fr33_freq_hz:set(current_freq_hz)
    fr33_active_freq:set(current_freq_hz / 1E6)
    fr33_powered:set(bool_to_number(is_powered()))
    fr33_backing_available:set(backing_radio_available)
    fr33_debug_text:set(debug_text)
    set_dial_args(current_freq_hz)

    if fr33_debug_text_enabled and show_message and debug_text ~= last_debug_text and print_message_to_user ~= nil then
        print_message_to_user("FR33 " .. debug_text)
    end

    last_debug_text = debug_text
end

local function push_backing_radio()
    local vhf_radio = get_backing_radio()
    if vhf_radio ~= nil then
        local ok = pcall(function()
            vhf_radio:set_frequency(current_freq_hz)
            vhf_radio:set_modulation(MODULATION_AM)
        end)
        backing_radio_available = bool_to_number(ok)
    end
end

local function apply_frequency(freq_hz, show_message)
    local normalised_freq_hz = normalise_frequency(freq_hz)
    if not is_valid_fr33_frequency(normalised_freq_hz) then
        return
    end

    current_freq_hz = normalised_freq_hz
    push_backing_radio()
    publish_state(show_message)
end

local function load_initial_frequency()
    if get_aircraft_mission_data == nil then
        return
    end

    local mission_radio_data = get_aircraft_mission_data("Radio")
    if mission_radio_data == nil or mission_radio_data[MISSION_RADIO_INDEX] == nil or mission_radio_data[MISSION_RADIO_INDEX].channels == nil then
        return
    end

    local channels = mission_radio_data[MISSION_RADIO_INDEX].channels
    local has_zero_based_channels = channels[0] ~= nil
    local channel_index = has_zero_based_channels and 0 or 1
    local mission_freq = tonumber(channels[channel_index])

    if mission_freq == nil then
        return
    end

    if mission_freq < 1E6 then
        mission_freq = mission_freq * 1E6
    end

    if is_valid_fr33_frequency(normalise_frequency(mission_freq)) then
        current_freq_hz = normalise_frequency(mission_freq)
    end
end

local function command_direction(value)
    if value == nil or value == 0 then
        return 0
    end

    return value > 0 and 1 or -1
end

local function tune(delta_hz)
    if delta_hz == 0 then
        return
    end

    apply_frequency(current_freq_hz + delta_hz, true)
end

dev:listen_command(Keys.FR33_MHz)
dev:listen_command(Keys.FR33_100kHz)
dev:listen_command(Keys.FR33_25kHz)

function post_initialize()
    load_initial_frequency()
    get_backing_radio()
    apply_frequency(current_freq_hz, true)
end

function SetCommand(command, value)
    if not is_powered() then
        publish_state(false)
        return
    end

    local direction = command_direction(value)
    if command == Keys.FR33_MHz then
        tune(direction * STEP_MHZ_HZ)
    elseif command == Keys.FR33_100kHz then
        tune(direction * STEP_100KHZ_HZ)
    elseif command == Keys.FR33_25kHz then
        tune(direction * FREQ_STEP_HZ)
    end
end

function update()
    push_backing_radio()
    publish_state(false)
end

need_to_be_closed = false

-- SK60 shared cockpit integration
dofile(LockOn_Options.script_path .. "Multicrew/runtime.lua").install(25)
