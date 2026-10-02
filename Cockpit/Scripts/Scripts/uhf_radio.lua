dofile(LockOn_Options.common_script_path..'Radio.lua')
dofile(LockOn_Options.script_path.."debug_util.lua")
dofile(LockOn_Options.common_script_path.."mission_prepare.lua")

dofile(LockOn_Options.script_path.."devices.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")

local gettext = require("i_18n")
_ = gettext.translate

local dev = GetSelf()
local iCommandPlaneIntercomUHFPress = 1172
local radio_power = get_param_handle("RADIO_POWER")
local function update_radio_power()
   -- Keep the native radio available to DCS/SRS like the old SK60 did.
   -- The FR31 display can still follow aircraft electrical power, but dropping
   -- RADIO_POWER when PTN_401 is off makes SRS lose the aircraft shortly after
   -- spawn.
    radio_power:set(1.0)
end

-- SRS compatibility
function dev:is_on()
    return radio_power:get() > 0.5
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
	range = {min = 104E6, max = 407.975E6, step = 25E3}, --Hz
	displayName = _('FR31 Radio'),
	AM = true,
	FM = false,
}
-- end of block

local current_freq = 124.8E6

dev:listen_command(Keys.RadioUpdate)
dev:listen_command(iCommandPlaneIntercomUHFPress)

function check_frequency_change()
	-- check if override by efm radio system
	local freq_efm_signal = get_param_handle("RADIO_EFM_CHANGED")
	local freq_uplink_signal = get_param_handle("RADIO_2EFM_CHANGED")
	local freqency_EFM_exchange = get_param_handle("RADIO_UHF_FREQ_EXC")
	-- dprintf(sprintf("current Freq: %d", dev:get_frequency()))
	-- check if override by simple radio system
	if (dev:get_frequency() ~= current_freq) then
		-- send to efm, change display
		dprintf("lua radio freq changed")
		current_freq = dev:get_frequency()
		-- this direction has higher prioity
		freq_efm_signal:set(0)
		freqency_EFM_exchange:set(current_freq/1e3)
		freq_uplink_signal:set(1)
	elseif freq_efm_signal:get() > 0 then
		dprintf("EFM freq changed")
		current_freq = freqency_EFM_exchange:get() * 1e3
		dev:set_frequency(current_freq)
		freq_uplink_signal:set(0)
		freq_efm_signal:set(0)
	end
end

function post_initialize()
	-- initialize the radio system
	local wake_radio = get_param_handle("RADIO_SYSTEM_AVAIL")
	wake_radio:set(0.0)
	dev:set_frequency(current_freq)
  	dev:set_modulation(MODULATION_AM)
  	local intercom = GetDevice(devices.INTERCOM)
  	intercom:set_communicator(devices.UHF_RADIO)
	intercom:make_setup_for_communicator()

	--set up the pointer for the radio system
  	str_ptr = string.sub(tostring(dev.link),10)
  	local set_radio_pointer = get_param_handle("RADIO_POINTER")
	set_radio_pointer:set(str_ptr)
	wake_radio:set(1.0)
	update_radio_power()

	local freq_efm_signal = get_param_handle("RADIO_EFM_CHANGED")
	local freq_uplink_signal = get_param_handle("RADIO_2EFM_CHANGED")
	freq_efm_signal:set(0)
	freq_uplink_signal:set(0)
end


function SetCommand(command,value)
	-- avUHF_ARC_164 handles iCommandPlaneIntercomUHFPress internally once this
	-- Lua side listens to it. Keep SetCommand lightweight so the native radio
	-- command can open the airborne communications menu.
	check_frequency_change()
end

function update()
	update_radio_power()
	check_frequency_change()
end


need_to_be_closed = false -- close lua state after initialization



