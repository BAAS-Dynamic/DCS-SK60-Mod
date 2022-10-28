--初始化加载要用lua文件
dofile(LockOn_Options.common_script_path.."devices_defs.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")
dofile(LockOn_Options.script_path.."debug_util.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")

--设置循环次数
local update_rate = 0.1 -- 20次每秒
make_default_activity(update_rate)

local ic_ctrl = GetSelf()

--初始化DCS读取API
local sensor_data = get_base_data()

------Here Strat the general Switch Control

local SWITCH_OFF = 0
local SWITCH_ON = 1
local SWITCH_TEST = -1

local RAD_TO_DEGREE  = 57.29577951308233

switch_count = 0
function _switch_counter()
    switch_count = switch_count + 1
    return switch_count
end

local l_eng_fire    = _switch_counter()
local canopy        = _switch_counter()
local r_eng_fire    = _switch_counter()
local l_eng_fuel    = _switch_counter()
local thrust_rev    = _switch_counter()
local r_eng_fuel    = _switch_counter()
local l_eng_oil     = _switch_counter()
local brake         = _switch_counter()
local r_eng_oil     = _switch_counter()
local l_eng_hyd     = _switch_counter()
local inverterA    = _switch_counter()
local r_eng_hyd     = _switch_counter()
local l_eng_gen     = _switch_counter()
local inverterB    = _switch_counter()
local r_eng_gen     = _switch_counter()
local master_cau     = _switch_counter()

local element_name = {"FIRE_L_ENG", "CANOPY", "FIRE_R_ENG", "FUEL_L_ENG", "THRUST_REV", "FUEL_R_ENG", "OIL_L_ENG", "BRAKE", "OIL_R_ENG", "HYDRO_L", "CONVERT_A", "HYDRO_R", "GEN_L", "CONVERT_B", "GEN_R"}

target_status = {
    {l_eng_fire , SWITCH_OFF, get_param_handle(element_name[1]), element_name[1]},
    {canopy     , SWITCH_OFF, get_param_handle(element_name[2]), element_name[2]},
    {r_eng_fire , SWITCH_OFF, get_param_handle(element_name[3]), element_name[3]},
    {l_eng_fuel , SWITCH_OFF, get_param_handle(element_name[4]), element_name[4]},
    {thrust_rev , SWITCH_OFF, get_param_handle(element_name[5]), element_name[5]},
    {r_eng_fuel , SWITCH_OFF, get_param_handle(element_name[6]), element_name[6]},
    {l_eng_oil  , SWITCH_OFF, get_param_handle(element_name[7]), element_name[7]},
    {brake      , SWITCH_OFF, get_param_handle(element_name[8]), element_name[8]},
    {r_eng_oil  , SWITCH_OFF, get_param_handle(element_name[9]), element_name[9]},
    {l_eng_hyd  , SWITCH_OFF, get_param_handle(element_name[10]), element_name[10]},
    {inverterA  , SWITCH_OFF, get_param_handle(element_name[11]), element_name[11]},
    {r_eng_hyd  , SWITCH_OFF, get_param_handle(element_name[12]), element_name[12]},
    {l_eng_gen  , SWITCH_OFF, get_param_handle(element_name[13]), element_name[13]},
    {inverterB  , SWITCH_OFF, get_param_handle(element_name[14]), element_name[14]},
    {r_eng_gen  , SWITCH_OFF, get_param_handle(element_name[15]), element_name[15]},
    {master_cau , SWITCH_TEST, get_param_handle("MASTER_WARN"), "MASTER_WARN"},
}

current_status = {
    {l_eng_fire , SWITCH_OFF, SWITCH_OFF},
    {canopy     , SWITCH_OFF, SWITCH_OFF},
    {r_eng_fire , SWITCH_OFF, SWITCH_OFF},
    {l_eng_fuel , SWITCH_OFF, SWITCH_OFF},
    {thrust_rev , SWITCH_OFF, SWITCH_OFF},
    {r_eng_fuel , SWITCH_OFF, SWITCH_OFF},
    {l_eng_oil  , SWITCH_OFF, SWITCH_OFF},
    {brake      , SWITCH_OFF, SWITCH_OFF},
    {r_eng_oil  , SWITCH_OFF, SWITCH_OFF},
    {l_eng_hyd  , SWITCH_OFF, SWITCH_OFF},
    {inverterA  , SWITCH_OFF, SWITCH_OFF},
    {r_eng_hyd  , SWITCH_OFF, SWITCH_OFF},
    {l_eng_gen  , SWITCH_OFF, SWITCH_OFF},
    {inverterB  , SWITCH_OFF, SWITCH_OFF},
    {r_eng_gen  , SWITCH_OFF, SWITCH_OFF},
    {master_cau , SWITCH_TEST, SWITCH_TEST},
}

function post_initialize()
    local birth = LockOn_Options.init_conditions.birth_place
    if birth == "GROUND_HOT" then
        updateWarningSignal()
    elseif birth == "GROUND_COLD" then
        setWarnSystemPowerOff()
    elseif birth == "AIR_HOT" then
        updateWarningSignal()
    end
    for k,v in pairs(target_status) do
        current_status[k][2] = target_status[k][2]
        target_status[k][3]:set(current_status[k][2])
    end
    -- center panel
    sndhost_cockpit_warning          = create_sound_host("COCKPIT_WARN","3D",0.3,-0.3,0.3) 
    snd_stall_warning                = sndhost_cockpit_warning:create_sound("Aircrafts/SK-60/SK60_Warn_Stall")
end

ic_ctrl:listen_command()

function SetCommand(command, value)
    if command == Keys.WARN_MASTER_CANCEL then
        MasterCautionArmed = 0
        target_status[master_cau][2] = SWITCH_OFF
    end
end

function update_switch_status()
    local switch_moving_step = 0.25
    for k,v in pairs(target_status) do
        if math.abs(target_status[k][2] - current_status[k][2]) < switch_moving_step then
            current_status[k][2] = target_status[k][2]
        elseif target_status[k][2] > current_status[k][2] then
            current_status[k][2] = current_status[k][2] + switch_moving_step
        elseif target_status[k][2] < current_status[k][2] then
            current_status[k][2] = current_status[k][2] - switch_moving_step
        end
        target_status[k][3]:set(current_status[k][2])
        -- local temp_switch_ref = get_clickable_element_reference(target_status[k][4])
        -- temp_switch_ref:update()
        -- print_message_to_user(k)
    end
end

-- warning_display = get_param_handle("WARNING_DIS_ENABLE")

warn_tick = 0

-- set warning panel to off
function setWarnSystemPowerOff()
    -- set whole system to power off
    for k,v in pairs(target_status) do
        target_status[k][2] = 0
    end
    target_status[master_cau][2] = SWITCH_TEST
    MasterCautionArmed = 0
end

local parking_brake_status = get_param_handle("PARK_BRAKE")
local fuel_press_l = get_param_handle("OP_LEFT")
local fuel_press_r = get_param_handle("OP_RIGHT")

local MasterCautionArmed = 0

function switchTargetStatus(uid, target)
    current_status[uid][3] = target_status[uid][2]
    target_status[uid][2] = target
    if MasterCautionArmed == 0 and target_status[uid][2] == SWITCH_ON and current_status[uid][3] == SWITCH_OFF then
        MasterCautionArmed = 1
        target_status[master_cau][2] = 0.5
    end
end

function updateWarningSignal()
    -- canopy
    if get_aircraft_draw_argument_value(38) < 0.05 then
        switchTargetStatus(canopy, SWITCH_OFF)
    else
        switchTargetStatus(canopy, SWITCH_ON)
    end
    -- electric system
    if get_elec_inverterA_status() then
        switchTargetStatus(inverterA, SWITCH_OFF)
    else
        switchTargetStatus(inverterA, SWITCH_ON)
    end
    if get_elec_inverterB_status() then
        switchTargetStatus(inverterB, SWITCH_OFF)
    else
        switchTargetStatus(inverterB, SWITCH_ON)
    end
    -- engine part
    if sensor_data.getEngineLeftRPM() < 0.5 then
        switchTargetStatus(l_eng_gen, SWITCH_ON)
        switchTargetStatus(l_eng_hyd, SWITCH_ON)
    else
        switchTargetStatus(l_eng_gen, SWITCH_OFF)
        switchTargetStatus(l_eng_hyd, SWITCH_OFF)
    end
    if sensor_data.getEngineRightRPM() < 0.5 then
        switchTargetStatus(r_eng_gen, SWITCH_ON)
        switchTargetStatus(r_eng_hyd, SWITCH_ON)
    else
        switchTargetStatus(r_eng_gen, SWITCH_OFF)
        switchTargetStatus(r_eng_hyd, SWITCH_OFF)
    end
    if sensor_data.getEngineLeftRPM() < 0.04 then
        switchTargetStatus(l_eng_oil, SWITCH_ON)
    else
        switchTargetStatus(l_eng_oil, SWITCH_OFF)
    end
    if sensor_data.getEngineRightRPM() < 0.04 then
        switchTargetStatus(r_eng_oil, SWITCH_ON)
    else
        switchTargetStatus(r_eng_oil, SWITCH_OFF)
    end
    if fuel_press_l:get() > 0.001 then
        switchTargetStatus(l_eng_fuel, SWITCH_OFF)
    else
        switchTargetStatus(l_eng_fuel, SWITCH_ON)
    end
    if fuel_press_r:get() > 0.001 then
        switchTargetStatus(r_eng_fuel, SWITCH_OFF)
    else
        switchTargetStatus(r_eng_fuel, SWITCH_ON)
    end
end

function update()
    update_switch_status()
    if get_elec_dc_status() then
        -- here start the warning system
        updateWarningSignal()
        -- warning_display:set(1)
        if (sensor_data.getIndicatedAirSpeed() > 40 or sensor_data.getWOW_NoseLandingGear() < 0.01) then
            if (sensor_data.getAngleOfAttack()*RAD_TO_DEGREE > 13.5 and get_aircraft_draw_argument_value(9) < 0.3) then
                snd_stall_warning:play_continue()
            elseif (sensor_data.getAngleOfAttack()*RAD_TO_DEGREE > 9 and get_aircraft_draw_argument_value(9) >= 0.3) then
                snd_stall_warning:play_continue()
            elseif (sensor_data.getIndicatedAirSpeed() < 40) then
                snd_stall_warning:play_continue()
            else
                snd_stall_warning:stop()
            end
        else
            snd_stall_warning:stop()
        end
    else
        setWarnSystemPowerOff()
        snd_stall_warning:stop()
    end
end

need_to_be_closed = false