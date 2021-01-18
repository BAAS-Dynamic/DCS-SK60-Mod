local Engine = GetSelf()

--初始化加载要用lua文件
dofile(LockOn_Options.common_script_path.."devices_defs.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")
 
dofile(LockOn_Options.script_path.."command_defs.lua")

--设置循环次数
local update_rate = 0.05 -- 20次每秒
make_default_activity(update_rate)

--初始化DCS读取API
local sensor_data = get_base_data()

--定义默认SFM模型发动机控制参数
local iCommandEnginesStart=309
local iCommandEnginesStop=310
local iCommandPlaneThrustCommon = 2004
local iCommandPlaneThrustLeft = 2005
local iCommandPlaneThrustRight = 2006

local iCommandLeftEngineStop = 313
local iCommandLeftEngineStart = 311
local iCommandRightEngineStop = 314
local iCommandRightEngineStart = 312

--设置引擎预定义状态
local ENGINE_OFF = 0
local ENGINE_RUNNING = 1
local ENGINE_STARTING = 2
local ENGINE_POST_STARTING = 3

local engine_state_left = ENGINE_OFF
local engine_state_right = ENGINE_OFF

local SWITCH_OFF = 0
local SWITCH_ON = 1
local SWITCH_TEST = -1

local LstartButtonFlag = 0
local LstartCounter = 0
local LstartIsDone = 0

local RPM_l = get_param_handle("RPM_L")
local RPM_r = get_param_handle("RPM_R")
local EGT_l = get_param_handle("EGT_L")
local EGT_r = get_param_handle("EGT_R")
local FF_l = get_param_handle("FF_L")
local FF_r = get_param_handle("FF_R")

local left_throttle = get_param_handle("LeftThrottor")
local right_throttle = get_param_handle("RightThrottor")

function update_Engine_Working_Status()
    RPM_l:set(sensor_data.getEngineLeftRPM()/100)
    RPM_r:set(sensor_data.getEngineRightRPM()/100)
    EGT_l:set(sensor_data.getEngineLeftTemperatureBeforeTurbine()/900)
    EGT_r:set(sensor_data.getEngineRightTemperatureBeforeTurbine()/900)
    FF_l:set(sensor_data.getEngineLeftFuelConsumption())
    FF_r:set(sensor_data.getEngineRightFuelConsumption())
end

-- local EngineSwitch = get_param_handle("EngineSwitch")

--监听引擎启动关闭和油门输入

Engine:listen_command(Keys.ThrottleAxisTest)
Engine:listen_command(Keys.LeftThrottleAxis)
Engine:listen_command(Keys.RightThrottleAxis)

Engine:listen_command(Keys.LeftEngineIDLE)
Engine:listen_command(Keys.RightEngineIDLE)

Engine:listen_command(Keys.RightSpeedDriveUP)
Engine:listen_command(Keys.RightSpeedDriveDOWN)
Engine:listen_command(Keys.LeftSpeedDriveUP)
Engine:listen_command(Keys.LeftSpeedDriveDOWN)

Engine:listen_command(Keys.FuelMasterLeft)
Engine:listen_command(Keys.FuelMasterRight)

Engine:listen_command(Keys.LeftEngineCrank)
Engine:listen_command(Keys.LeftEngineCrankUP)
Engine:listen_command(Keys.RightEngineCrank)
Engine:listen_command(Keys.RightEngineCrankUP)

Engine:listen_command(Keys.CSDSwitch)

switch_count = 0

function _switch_counter()
    switch_count = switch_count + 1
    return switch_count
end

local left_spd = _switch_counter()
local right_spd = _switch_counter()
local left_fuel_m = _switch_counter()
local right_fuel_m = _switch_counter()
local left_crank = _switch_counter()
local right_crank = _switch_counter()
local csd_status = _switch_counter()

local left_idle_status = SWITCH_OFF
local right_idle_status = SWITCH_OFF
local Externel_Bleed_Status = SWITCH_ON

target_status = {
    {left_spd , SWITCH_OFF, get_param_handle("PTN_109")},
    {right_spd , SWITCH_OFF, get_param_handle("PTN_110")},
    {left_fuel_m , SWITCH_OFF, get_param_handle("PTN_112")},
    {right_fuel_m , SWITCH_OFF, get_param_handle("PTN_113")},
    {left_crank, SWITCH_OFF, get_param_handle("PTN_118")},
    {right_crank, SWITCH_OFF, get_param_handle("PTN_119")},
    {csd_status, SWITCH_OFF, get_param_handle("PTN_115")},
}

current_status = {
    {left_spd , SWITCH_OFF},
    {right_spd , SWITCH_OFF},
    {left_fuel_m , SWITCH_OFF},
    {right_fuel_m , SWITCH_OFF},
    {left_crank, SWITCH_OFF},
    {right_crank, SWITCH_OFF},
    {csd_status, SWITCH_OFF},
}

function update_switch_status()
    for k,v in pairs(target_status) do
       if target_status[k][2] > current_status[k][2] then
            current_status[k][2] = current_status[k] + 0.2
            target_status[k][3]:set(current_status[k][2])
        elseif target_status[k][2] < current_status[k][2] then
            current_status[k][2] = current_status[k] - 0.2
            target_status[k][3]:set(current_status[k][2])
       end
    end
end

-- 初始化函数
function post_initialize()
	
	local dev = GetSelf()
    local sensor_data = get_base_data()
    local throttle = sensor_data.getThrottleLeftPosition()

    --初始化不同出生状况下发动机状态参数
    local birth = LockOn_Options.init_conditions.birth_place
    if birth=="GROUND_HOT" then
        engine_state = ENGINE_RUNNING
    elseif birth=="AIR_HOT" then
        engine_state = ENGINE_RUNNING
    elseif birth=="GROUND_COLD" then
        engine_state = ENGINE_OFF
    end
    if engine_state == ENGINE_RUNNING then
        target_status = {
            {left_spd , SWITCH_ON, get_param_handle("PTN_109")},
            {right_spd , SWITCH_ON, get_param_handle("PTN_110")},
            {left_fuel_m , SWITCH_ON, get_param_handle("PTN_112")},
            {right_fuel_m , SWITCH_ON, get_param_handle("PTN_113")},
            {left_crank, SWITCH_OFF, get_param_handle("PTN_118")},
            {right_crank, SWITCH_OFF, get_param_handle("PTN_119")},
            {csd_status, SWITCH_OFF, get_param_handle("PTN_115")},
        }
        
        current_status = {
            {left_spd , SWITCH_ON},
            {right_spd , SWITCH_ON},
            {left_fuel_m , SWITCH_ON},
            {right_fuel_m , SWITCH_ON},
            {left_crank, SWITCH_OFF},
            {right_crank, SWITCH_OFF},
            {csd_status, SWITCH_OFF},
        }

        left_idle_status = SWITCH_ON
        right_idle_status = SWITCH_ON
        Externel_Bleed_Status = SWITCH_OFF

        left_throttle:set(0.2)
        right_throttle:set(0.2)
    end

    for k,v in pairs(target_status) do
        target_status[k][3]:set(current_status[k][2])
    end

    --EngineSwitch:set(1)
end

start_count_time = 0
start_count_flag_l = 0
start_count_flag_r = 0

--监听函数
function SetCommand(command, value)
    if (get_elec_primary_dc_ok() or get_elec_primary_ac_ok()) then
        if (command == Keys.ThrottleAxisTest) and (engine_state == ENGINE_RUNNING) then 
            local throttle = value * 0.85 + 0.15
            if (engine_state == ENGINE_RUNNING and ENGINE_STARTING == 0) then
                dispatch_action(nil, iCommandPlaneThrustCommon, value)
                left_throttle:set(throttle)
                right_throttle:set(throttle)
            end
        elseif (command == Keys.LeftThrottleAxis) and (engine_state == ENGINE_RUNNING) then 
            local throttle = value * 0.85 + 0.15
            if (engine_state == ENGINE_RUNNING and ENGINE_STARTING == 0) then
                dispatch_action(nil, iCommandPlaneThrustLeft, value)
                left_throttle:set(throttle)
            end
        elseif (command == Keys.RightThrottleAxis) and (engine_state == ENGINE_RUNNING) then 
            local throttle = value * 0.85 + 0.15
            if (engine_state == ENGINE_RUNNING and ENGINE_STARTING == 0) then
                dispatch_action(nil, iCommandPlaneThrustRight, value)
                right_throttle:set(throttle)
            end
        elseif (command == Keys.RightSpeedDriveUP) then
            if (target_status[right_spd][2] < 0.5) then
                target_status[right_spd][2] = target_status[right_spd][2] + 1
            end
        elseif (command == Keys.RightSpeedDriveDOWN) then
            if (target_status[right_spd][2] > -0.5) then
                target_status[right_spd][2] = target_status[right_spd][2] - 1
            end
        elseif (command == Keys.LeftSpeedDriveUP) then
            if (target_status[left_spd][2] < 0.5) then
                target_status[left_spd][2] = target_status[left_spd][2] + 1
            end
        elseif (command == Keys.LefttSpeedDriveDOWN) then
            if (target_status[left_spd][2] > -0.5) then
                target_status[left_spd][2] = target_status[left_spd][2] - 1
            end
        elseif (command == Keys.FuelMasterLeft) then
            target_status[left_fuel_m][2] = 1 - target_status[left_fuel_m][2]
        elseif (command == Keys.FuelMasterLeft) then
            target_status[right_fuel_m][2] = 1 - target_status[right_fuel_m][2]
        elseif (command == Keys.LeftThrottleCrank) then
            target_status[left_crank][2] = SWITCH_ON
            start_count_flag_l = 1
            start_count_time = 0
        elseif (command == Keys.RightThrottleCrank) then
            target_status[right_crank][2] = SWITCH_ON
            start_count_flag_r = 1
            start_count_time = 0
        elseif (command == Keys.LeftThrottleCrankUP) then
            target_status[left_crank][2] = SWITCH_OFF
            start_count_flag_r = 1
            start_count_time = 0
        elseif (command == Keys.RightThrottleCrankUP) then
            target_status[right_crank][2] = SWITCH_OFF
            start_count_flag_r = 0
            start_count_time = 0
        elseif (command == Keys.LeftEngineIDLE) then
            if (engine_state_left == ENGINE_RUNNING and left_throttle:get() < 0.17) then
                left_idle_status = SWITCH_OFF
                left_throttle:set(left_idle_status)
                dispatch_action(iCommandLeftEngineStop, nil)
                -- engine_state_left = ENGINE_OFF
            elseif engine_state_left == ENGINE_STARTING then
                -- dispatch_action(iCommandLeftEngineStart, nil)
                engine_state_left = ENGINE_RUNNING
                Externel_Bleed_Status = SWITCH_OFF
            end
        elseif (command == Keys.LeftEngineIDLE) then
            if (engine_state_right == ENGINE_RUNNING and right_throttle:get() < 0.17) then
                right_idle_status = SWITCH_OFF
                right_throttle:set(right_idle_status)
                -- engine_state_right = ENGINE_OFF
                dispatch_action(iCommandRightEngineStop, nil)
            elseif engine_state_right == ENGINE_STARTING then
                -- dispatch_action(iCommandRightEngineStart, nil)
                engine_state_right = ENGINE_RUNNING
                Externel_Bleed_Status = SWITCH_OFF
            end
        elseif (command == Keys.CSDSwitch) then
            target_status[csd_status][2] = 1 - target_status[csd_status][2]
        end
    end
end

function update_Engine_Status()
    if (left_idle_status == SWITCH_OFF and sensor_data.getEngineLeftRPM <= 0) then
        engine_state_left = ENGINE_OFF
    elseif (left_idle_status == SWITCH_OFF and sensor_data.getEngineLeftRPM < 35) then
            engine_state_left = ENGINE_STARTING
    elseif (left_idle_status == SWITCH_OFF and sensor_data.getEngineLeftRPM >= 15) then
        dispatch_action(iCommandLeftEngineStop, nil)
    end
    if (right_idle_status == SWITCH_OFF and sensor_data.getEngineRightRPM <= 0) then
        engine_state_right = ENGINE_OFF
    elseif (right_idle_status == SWITCH_OFF and sensor_data.getEngineRightRPM < 35) then
        engine_state_right = ENGINE_STARTING
    elseif (right_idle_status == SWITCH_OFF and sensor_data.getEngineRightRPM >= 15) then
        dispatch_action(iCommandRightEngineStop, nil)
    end
end

function check_if_engine_starting()
    if (target_status[left_spd][2] == SWITCH_ON and target_status[left_fuel_m][2] == SWITCH_ON and (Externel_Bleed_Status == SWITCH_ON or (target_status[csd_status][2] == SWITCH_ON and sensor_data.getEngineRightRPM >= 40))) then
        if start_count_flag_l == 1 then
            start_count_time = start_count_time + 1
            if start_count_time > 75 then
                dispatch_action(iCommandLeftEngineStart, nil)
                start_count_flag_l = 0
            end
        end
    end
    if (target_status[right_spd][2] == SWITCH_ON and target_status[right_fuel_m][2] == SWITCH_ON and (Externel_Bleed_Status == SWITCH_ON or (target_status[csd_status][2] == SWITCH_ON and sensor_data.getEngineLeftRPM >= 40))) then
        if start_count_flag_r == 1 then
            start_count_time = start_count_time + 1
            if start_count_time > 75 then
                dispatch_action(iCommandRightEngineStart, nil)
                start_count_flag_r = 0
            end
        end
    end
end

function update()
    -- update engine working status
    check_if_engine_starting()
    update_Engine_Status()
    update_switch_status()
    update_Engine_Working_Status()
end

--不关闭该lua
need_to_be_closed = false