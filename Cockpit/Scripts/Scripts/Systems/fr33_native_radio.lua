dofile(LockOn_Options.common_script_path..'Radio.lua')
dofile(LockOn_Options.common_script_path.."mission_prepare.lua")

dofile(LockOn_Options.script_path.."devices.lua")

local gettext = require("i_18n")
_ = gettext.translate

local dev = GetSelf()
local update_time_step = 0.05
device_timer_dt = update_time_step

local DEFAULT_FREQ_HZ = 124.000E6

local fr33_power = get_param_handle("FR33_POWER")
local fr33_freq_hz = get_param_handle("FR33_FREQ_HZ")
local fr33_freq_mhz = get_param_handle("FR33_ACTIVE_FREQ")

function dev:is_on()
    return fr33_power:get() > 0.5
end

innerNoise          = getInnerNoise(2.5E-6, 10.0)
frequency_accuracy  = 500.0
band_width          = 12E3
power               = 10.0
goniometer = {
    isLagElement = true,
    T1 = 0.3,
    bias = {
        { valmin = math.rad(0), valmax = math.rad(360), bias = math.rad(1) }
    }
}

agr = {
    input_signal_deviation = rangeUtoDb(4E-6, 0.5),
    output_signal_deviation = 5 - (-4),
    input_signal_linear_zone = 10.0,
    regulation_time = 0.25,
}

GUI = {
    range = {min = 118.0E6, max = 136.975E6, step = 25E3},
    displayName = _('FR33 Radio'),
    AM = true,
    FM = false,
}

local function set_fr33_frequency(freq_hz)
    dev:set_frequency(freq_hz)
    dev:set_modulation(MODULATION_AM)
    fr33_freq_hz:set(freq_hz)
    fr33_freq_mhz:set(freq_hz / 1.0E6)
end

function post_initialize()
    fr33_power:set(1.0)
    set_fr33_frequency(DEFAULT_FREQ_HZ)
end

function update()
    fr33_power:set(1.0)
end

need_to_be_closed = false
