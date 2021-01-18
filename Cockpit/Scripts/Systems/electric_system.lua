dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")
 

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
-- electric_system:listen_command(Keys.BatteryPower)

electric_system:DC_Battery_on(true)

local genLeftSwitch = get_param_handle("GenLeftSwitch")
local genRightSwitch = get_param_handle("GenRightSwitch")
-- local BatterySwitch = get_param_handle("BatterySwitch") no battery switch, default open

function update_elec_state() --更新电力总线状态
    if (electric_system:get_AC_Bus_1_voltage() > 0 or electric_system:get_AC_Bus_2_voltage() > 0) then
        -- 主发电机状态正常（双备份）
        elec_primary_ac_ok:set(1)
    else
        elec_primary_ac_ok:set(0)
    end

    if electric_system:get_DC_Bus_1_voltage() > 0 and batteryStatus == 1 then 
        elec_primary_dc_ok:set(1)
    else
        elec_primary_dc_ok:set(0)
    end
end

function post_initialize() --默认初始化函数
    set_aircraft_draw_argument_value(114, 1) -- clear the default outer cockpit

    local dev = GetSelf()
    local birth = LockOn_Options.init_conditions.birth_place
    if birth=="GROUND_HOT" or birth=="AIR_HOT" then --"GROUND_COLD","GROUND_HOT","AIR_HOT"
        electric_system:AC_Generator_1_on(true)
        electric_system:AC_Generator_2_on(true) -- A-6A have 2 engine, so two generator
        electric_system:DC_Battery_on(true) -- A-6 have a battery
        genLeftStatus = 1
        genRightStatus = 1
        batteryStatus = 1
        genLeftSwitch:set(0)
        genRightSwitch:set(0)
        --BatterySwitch:set(0)
    elseif birth=="GROUND_COLD" then
        electric_system:AC_Generator_1_on(false) 
        electric_system:AC_Generator_2_on(false) -- A-6A have 2 engine, so two generator
        electric_system:DC_Battery_on(true) -- A-6 have a battery but default open
        genLeftStatus = 0
        genRightStatus = 0
        batteryStatus = 0
        genLeftSwitch:set(1)
        genRightSwitch:set(1)
        --BatterySwitch:set(1)
    end

    update_elec_state()
end

function SetCommand(command,value)
    -- 最基础的航电功能监听
    if command == Keys.PowerGeneratorLeftUP then
        if genLeftStatus < 0.5 then
            genLeftStatus = genLeftStatus + 1
        end
        if (genLeftStatus >= 1) then
            electric_system:AC_Generator_1_on(true)
        else
            --electric_system:AC_Generator_1_on(false)
        end
    elseif command == Keys.PowerGeneratorLeftDOWN then
        if genLeftStatus > -0.5 then
            genLeftStatus = genLeftStatus - 1
        end
        if (genLeftStatus >= 1) then
            electric_system:AC_Generator_1_on(true)
        else
            --electric_system:AC_Generator_1_on(false)
        end
    elseif command == Keys.PowerGeneratorRightUP then
        if genRightStatus < 0.5 then
            genRightStatus = genRightStatus + 1
        end
        if (genRightStatus >= 1) then
            electric_system:AC_Generator_2_on(true)
        else
            --electric_system:AC_Generator_2_on(false)
        end
    elseif command == Keys.PowerGeneratorRightDOWN then
        if genRightStatus > -0.5 then
            genRightStatus = genRightStatus - 1
        end
        if (genRightStatus >= 1) then
            electric_system:AC_Generator_2_on(true)
        else
            --electric_system:AC_Generator_2_on(false)
        end
    end
end

function update() --刷新状态

    update_elec_state()

    if (genLeftStatus > genLeftSwitch:get()) then
        genLeftSwitch:set(genLeftSwitch:get() + 0.2)
    elseif (genLeftStatus < genLeftSwitch:get()) then
        genLeftSwitch:set(genLeftSwitch:get() - 0.2)
    end

    if (genRightStatus > genRightSwitch:get()) then
        genRightSwitch:set(genRightSwitch:get() + 0.2)
    elseif (genRightStatus < genRightSwitch:get()) then
        genRightSwitch:set(genRightSwitch:get() - 0.2)
    end
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