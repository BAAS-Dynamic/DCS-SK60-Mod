dofile(LockOn_Options.script_path.."devices.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.common_script_path..'Radio.lua')

local dev = GetSelf()
local update_time_step = 0.05
make_default_activity(update_time_step)

local MIN_FREQ_HZ = 118.000E6
local MAX_FREQ_HZ = 136.975E6
local STEP_1MHZ = 1.0E6
local STEP_025MHZ = 25.0E3

local vhf2_freq_hz = 124.000E6
local vhf2_freq_param = get_param_handle("VHF2_FREQ_MHZ")

local function clamp_frequency(freq_hz)
    return math.min(MAX_FREQ_HZ, math.max(MIN_FREQ_HZ, freq_hz))
end

local function snap_25khz(freq_hz)
    return math.floor((freq_hz / STEP_025MHZ) + 0.5) * STEP_025MHZ
end

local function push_radio_frequency()
    local radioDevice = GetDevice(devices.VHF2_RADIO)
    if radioDevice ~= nil then
        radioDevice:set_frequency(vhf2_freq_hz)
        radioDevice:set_modulation(MODULATION_AM)
    end

    vhf2_freq_param:set(vhf2_freq_hz / 1.0E6)
end

local function tune(delta_hz)
    vhf2_freq_hz = clamp_frequency(snap_25khz(vhf2_freq_hz + delta_hz))
    push_radio_frequency()
end

dev:listen_command(Keys.VHF2_1MHz_Up)
dev:listen_command(Keys.VHF2_1MHz_Down)
dev:listen_command(Keys.VHF2_25kHz_Up)
dev:listen_command(Keys.VHF2_25kHz_Down)

function post_initialize()
    push_radio_frequency()
end

function SetCommand(command, value)
    if value <= 0 then
        return
    end

    if command == Keys.VHF2_1MHz_Up then
        tune(STEP_1MHZ)
    elseif command == Keys.VHF2_1MHz_Down then
        tune(-STEP_1MHZ)
    elseif command == Keys.VHF2_25kHz_Up then
        tune(STEP_025MHZ)
    elseif command == Keys.VHF2_25kHz_Down then
        tune(-STEP_025MHZ)
    end
end

function update()
end

need_to_be_closed = false
