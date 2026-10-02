dofile(LockOn_Options.common_script_path..'Radio.lua')
dofile(LockOn_Options.script_path.."debug_util.lua")
dofile(LockOn_Options.common_script_path.."mission_prepare.lua")

dofile(LockOn_Options.script_path.."devices.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")

local gettext = require("i_18n")
_ = gettext.translate

local dev = GetSelf()
-- SRS/native radio compatibility
function dev:is_on()
   -- Match the FR31/UHF backing radio behavior: keep the native radio visible to
   -- SRS regardless of cockpit display/electrical state. The FR33 control head
   -- still publishes FR33_POWERED for cockpit/export state.
    return true
end

local update_time_step = 0.05 --update will be called once per second
device_timer_dt = update_time_step
-- make_default_activity(update_time_step)

-- the following are some functions for the radio to work
-- radio parameter setup
innerNoise 			= getInnerNoise(2.5E-6, 10.0)--V/m (dB S+N/N)
frequency_accuracy 	= 500.0				--Hz
band_width			= 12E3				--Hz (6 dB selectivity)
power 				= 10.0				--Watts
goniometer = {isLagElement = true, T1 = 0.3, bias = {{valmin = math.rad(0), valmax = math.rad(360), bias = math.rad(1)}}}

agr = {
	input_signal_deviation		= rangeUtoDb(4E-6, 0.5), --Db
	output_signal_deviation		= 5 - (-4),  --Db
	input_signal_linear_zone 	= 10.0, --Db
	regulation_time				= 0.25, --sec
}

GUI = {
	range = {min = 118E6, max = 135.975E6, step = 25E3}, --Hz
	displayName = _('FR33 Radio'),
	AM = true,
	FM = false,
}
-- end of block

local current_freq = 124.8E6

dev:listen_command(Keys.RadioUpdate)

function check_frequency_change()
	-- Keep this native backing radio local to FR33. The FR33 Lua control head is
	-- authoritative for dial animation and SRS/export params; avoid the shared
	-- RADIO_* exchange signals used by FR31.
	local radio_freq = dev:get_frequency()
	if radio_freq ~= current_freq then
		current_freq = radio_freq
		get_param_handle("FR33_FREQ_HZ"):set(current_freq)
		get_param_handle("FR33_ACTIVE_FREQ"):set(current_freq / 1e6)
	end
end
function post_initialize()
	-- initialize the radio system
	local wake_radio = get_param_handle("RADIO_SYSTEM_AVAIL")
	wake_radio:set(0.0)
	dev:set_frequency(current_freq)
  	dev:set_modulation(MODULATION_AM)
	--set up the pointer for the radio system
  	str_ptr = string.sub(tostring(dev.link),10)
	local set_radio_pointer = get_param_handle("VHF_RADIO_POINTER")
	set_radio_pointer:set(str_ptr)
	wake_radio:set(1.0)


end


function SetCommand(command,value)
	-- FR33 is SRS-only for now. Do not claim the DCS intercom/PTT command here;
	-- FR31/UHF remains the in-game ATC radio.
	check_frequency_change()
end

function update()
	check_frequency_change()
end


need_to_be_closed = false -- close lua state after initialization



