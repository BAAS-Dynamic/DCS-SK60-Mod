dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")
dofile(LockOn_Options.script_path.."sounds_defs.lua")
-- snd_device:performClickableAction(command,value,false)
 

local electric_system = GetSelf()
local dev = electric_system

local update_time_step = 0.02 --每秒50次调用update()函数
make_default_activity(update_time_step)

local sensor_data = get_base_data()

local genLeftStatus = 0
local genRightStatus = 0
local batteryStatus = 0

electric_system:listen_command(Keys.PowerGeneratorLeft)
electric_system:listen_command(Keys.PowerGeneratorRight)
electric_system:listen_command(Keys.BatteryPower)

electric_system:DC_Battery_on(true)

local SWITCH_OFF = 0
local SWITCH_ON = 1
local SWITCH_TEST = -1

switch_count = 0
function _switch_counter()
    switch_count = switch_count + 1
    return switch_count
end

local main_power_switch = _switch_counter()
local left_gen_switch = _switch_counter()
local right_gen_switch = _switch_counter()

target_status = {
    {main_power_switch , SWITCH_OFF, get_param_handle("PTN_401"), "PTN_401"},
    {left_gen_switch , SWITCH_OFF, get_param_handle("PTN_402"), "PTN_402"},
    {right_gen_switch , SWITCH_OFF, get_param_handle("PTN_404"), "PTN_404"},
}

current_status = {
    {main_power_switch , SWITCH_OFF, SWITCH_OFF},
    {left_gen_switch , SWITCH_OFF, SWITCH_OFF},
    {right_gen_switch , SWITCH_OFF, SWITCH_OFF},
}

function update_switch_status()
    local switch_moving_step = 0.15
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

function update_elec_state() --更新电力总线状态
    if (electric_system:get_AC_Bus_1_voltage() > 0 or electric_system:get_AC_Bus_2_voltage() > 0) then
        -- 主发电机状态正常（双备份）
        elec_charging_status:set(1)
    else
        elec_charging_status:set(0)
    end

    if electric_system:get_DC_Bus_1_voltage() > 0 or electric_system:get_DC_Bus_2_voltage() > 0 then
        if elec_battery_status:get() == 0 then
            -- elec_dc_status:set(0)
            -- problem here, when bus has power, dc electric should be on
            elec_dc_status:set(1)
        else
            elec_dc_status:set(1)
        end
    else
        elec_dc_status:set(0)
    end

    if (electric_system:get_DC_Bus_1_voltage() > 0 or electric_system:get_DC_Bus_2_voltage() > 0) and (target_status[left_gen_switch][2] == 1 or target_status[right_gen_switch][2] == 1) then
        elec_ac_status:set(1)
    else
        elec_ac_status:set(0)
    end

    if (elec_dc_status:get() == 1 and elec_charging_status:get() == 0) then    
        if (elec_ac_status:get() == 1) then
            elec_battery_status:set(elec_battery_status:get()-2)
        else
            elec_battery_status:set(elec_battery_status:get()-1)
        end
    elseif (elec_charging_status:get() == 1) then
        elec_battery_status:set(elec_battery_status:get()+5)
    end

    if elec_battery_status:get() < 0 then
        elec_battery_status:set(0)
    elseif elec_battery_status:get() > 3000000 then
        elec_battery_status:set(3000000)
    end
end

function post_initialize() --默认初始化函数
    --local dev = GetSelf()
    -- initial the elec system pointer for the radio
    str_ptr = string.sub(tostring(electric_system.link),10)
    local set_elec_pointer = get_param_handle("ELEC_POINTER")
    set_elec_pointer:set(str_ptr)
    -- end of block
    elec_battery_status:set(3000000)
    local birth = LockOn_Options.init_conditions.birth_place
    if birth=="GROUND_HOT" or birth=="AIR_HOT" then --"GROUND_COLD","GROUND_HOT","AIR_HOT"
        electric_system:AC_Generator_1_on(true)
        electric_system:AC_Generator_2_on(true)
        electric_system:DC_Battery_on(true)
        target_status[main_power_switch][2] = SWITCH_ON
        target_status[left_gen_switch][2] = SWITCH_ON
        target_status[right_gen_switch][2] = SWITCH_ON
        current_status[main_power_switch][2] = SWITCH_ON
        current_status[left_gen_switch][2] = SWITCH_ON
        current_status[right_gen_switch][2] = SWITCH_ON
    elseif birth=="GROUND_COLD" then
        electric_system:AC_Generator_1_on(true) 
        electric_system:AC_Generator_2_on(true)
        electric_system:DC_Battery_on(false)
        target_status[main_power_switch][2] = SWITCH_OFF
        target_status[left_gen_switch][2] = SWITCH_OFF
        target_status[right_gen_switch][2] = SWITCH_OFF
        current_status[main_power_switch][2] = SWITCH_OFF
        current_status[left_gen_switch][2] = SWITCH_OFF
        current_status[right_gen_switch][2] = SWITCH_OFF
    end
    update_switch_status()
    update_elec_state()
end

function SetCommand(command,value)
    -- 最基础的航电功能监听
    local status = 0
    if command == Keys.PowerGeneratorLeft then
        target_status[left_gen_switch][2] = 1 - target_status[left_gen_switch][2]
        dispatch_action(devices.SOUND_SYSTEM, Keys.SND_LEFT_PANEL, cockpit_sound.basic_switch)
    elseif command == Keys.PowerGeneratorRight then
        target_status[right_gen_switch][2] = 1 - target_status[right_gen_switch][2]
        dispatch_action(devices.SOUND_SYSTEM, Keys.SND_LEFT_PANEL, cockpit_sound.basic_switch)
    elseif command == Keys.BatteryPower then
        target_status[main_power_switch][2] = 1 - target_status[main_power_switch][2]
        dispatch_action(devices.SOUND_SYSTEM, Keys.SND_LEFT_PANEL, cockpit_sound.basic_switch)
        if target_status[main_power_switch][2] < 0.5 then
            electric_system:DC_Battery_on(false)
        else
            electric_system:DC_Battery_on(true)
        end
    end
    --[[
    if target_status[left_gen_switch][2] < 0.5 then
        -- electric_system:AC_Generator_1_on(false)
        -- electric_system:AC_Generator_2_on(false)
        status = status + 1
    else
        electric_system:AC_Generator_1_on(true)
        electric_system:AC_Generator_2_on(true)
    end
    if target_status[right_gen_switch][2] < 0.5 then
        -- electric_system:AC_Generator_2_on(false)
        -- electric_system:AC_Generator_1_on(false)
        status = status + 1
    else
        electric_system:AC_Generator_2_on(true)
        electric_system:AC_Generator_1_on(true)
    end
    
    if status == 2 then
        electric_system:AC_Generator_2_on(false)
        electric_system:AC_Generator_1_on(false)
    end
    ]]--
end

function update() --刷新状态
    update_switch_status()
    update_elec_state()
end

--[[
From DLL exports inspection, these are the methods support by avSimpleElectricSystem:
AC_Generator_1_on   <- pass true or false to this to enable or disable
AC_Generator_2_on   <- pass true or false to this to enable or disable
DC_Battery_on       <- pass true or false to this to enable or disable
get_AC_Bus_1_voltage  <- returns 115 if enabled (and left engine running), otherwise 0
get_AC_Bus_2_voltage  <- returns 115 if enabled (and right engine running), otherwise 0
get_DC_Bus_1_voltage  <- returns 28 if either AC bus has 115V, otherwise 0
get_DC_Bus_2_voltage  <- returns 28 if battery enabled, otherwise 0


potentially relevant standard base input commands:
iCommandPowerOnOff	315   -- the command dispatched by rshift-L in FC modules

iCommandGroundPowerDC	704
iCommandGroundPowerDC_Cover	705
iCommandPowerBattery1	706
iCommandPowerBattery1_Cover	707
iCommandPowerBattery2	708
iCommandPowerBattery2_Cover	709
iCommandGroundPowerAC	710
iCommandPowerGeneratorLeft	711
iCommandPowerGeneratorRight	712
iCommandElectricalPowerInverter	713

iCommandAPUGeneratorPower	1071
iCommandBatteryPower	1073
iCommandElectricalPowerInverterSTBY	1074
iCommandElectricalPowerInverterOFF	1075
iCommandElectricalPowerInverterTEST	1076
--]]
need_to_be_closed = false 