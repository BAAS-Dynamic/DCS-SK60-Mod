dofile(LockOn_Options.script_path.."devices.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")

local avionics = require_avionics()

local dev = GetSelf()
local extended_dev = avionics.ExtendedRadio(devices.ELECTRIC_SYSTEM, devices.INTERCOM, devices.UHF_RADIO)

local update_time_step = 0.05
make_default_activity(update_time_step)

local UHF_MODE_OFF = 0
local UHF_MODE_TR = 1
local UHF_MODE_TR_G = 2
local UHF_MODE_ADF = 3
local UHF_MODE_MAX = UHF_MODE_ADF

local radio_mode = UHF_MODE_OFF
local radio_volume = 0.7
local radio_sql = 1

local mode_param = get_param_handle("PTN_556")
local volume_param = get_param_handle("PTN_554")
local sql_param = get_param_handle("PTN_555")

local iCommandPlaneIntercomUHFPress = 1172
local voice_ptt_0_icommand = 1731
local voice_ptt_1_icommand = 1732

dev:listen_command(Keys.UHF_Mode_Left)
dev:listen_command(Keys.UHF_Mode_Right)
dev:listen_command(Keys.UHF_Vol)
dev:listen_command(Keys.UHF_Vol_Up)
dev:listen_command(Keys.UHF_Vol_Down)
dev:listen_command(Keys.UHF_SQLACK_Up)
dev:listen_command(Keys.UHF_SQLACK_Down)
dev:listen_command(Keys.UHF_TAKE_Button_Press)
dev:listen_command(Keys.UHF_TAKE_Button_Release)
dev:listen_command(iCommandPlaneIntercomUHFPress)
dev:listen_command(voice_ptt_0_icommand)
dev:listen_command(voice_ptt_1_icommand)

local function clamp(value, min_value, max_value)
    return math.min(max_value, math.max(min_value, value))
end

local function apply_volume()
    volume_param:set(radio_volume)
    extended_dev:setVolume(math.pow(radio_volume, 3.0))
end

local function apply_mode()
    mode_param:set(radio_mode / UHF_MODE_MAX)
    extended_dev:setPower(radio_mode ~= UHF_MODE_OFF)
    extended_dev:setCurrentCommunicator()
end

local function apply_sql()
    sql_param:set(radio_sql)
end

function post_initialize()
    extended_dev:init()

    local birth = LockOn_Options.init_conditions.birth_place
    if birth == "GROUND_HOT" or birth == "AIR_HOT" then
        radio_mode = UHF_MODE_TR
    end

    apply_volume()
    apply_sql()
    apply_mode()
end

function SetCommand(command, value)
    if command == Keys.UHF_Mode_Left then
        radio_mode = clamp(radio_mode - 1, UHF_MODE_OFF, UHF_MODE_MAX)
        apply_mode()
    elseif command == Keys.UHF_Mode_Right then
        radio_mode = clamp(radio_mode + 1, UHF_MODE_OFF, UHF_MODE_MAX)
        apply_mode()
    elseif command == Keys.UHF_Vol then
        radio_volume = clamp(value, 0.0, 1.0)
        apply_volume()
    elseif command == Keys.UHF_Vol_Up then
        radio_volume = clamp(radio_volume + 0.05, 0.0, 1.0)
        apply_volume()
    elseif command == Keys.UHF_Vol_Down then
        radio_volume = clamp(radio_volume - 0.05, 0.0, 1.0)
        apply_volume()
    elseif command == Keys.UHF_SQLACK_Up or command == Keys.UHF_SQLACK_Down then
        radio_sql = 1.0 - radio_sql
        apply_sql()
    elseif command == Keys.UHF_TAKE_Button_Press or command == iCommandPlaneIntercomUHFPress then
        extended_dev:pushToTalk()
        extended_dev:pushToTalkVOIP(true, radio_mode == UHF_MODE_ADF)
    elseif command == Keys.UHF_TAKE_Button_Release then
        extended_dev:pushToTalkVOIP(false, radio_mode == UHF_MODE_ADF)
    elseif command == voice_ptt_0_icommand then
        extended_dev:pushToTalkVOIP(value == 1, radio_mode == UHF_MODE_ADF)
    elseif command == voice_ptt_1_icommand then
        extended_dev:pushToTalkVOIP(value == 1, false)
    end
end

function update()
    extended_dev:setPower(radio_mode ~= UHF_MODE_OFF)
end

need_to_be_closed = false