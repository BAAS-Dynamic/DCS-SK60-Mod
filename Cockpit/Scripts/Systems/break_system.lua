local Breaks = GetSelf()
dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")

-- ATTENTION: 空气刹车暂时不工作

local update_time_step = 0.02  --每秒50次刷新
make_default_activity(update_time_step)

local sensor_data = get_base_data()

local fmt = '%.2f'

local air_brake_state
local air_brake_pos = 0

local air_brake_pos_ind = get_param_handle("AIRBREAK_IND")

local parking_brake_handle = get_param_handle("PARKINGBREAK_HANDLE")

-- 减速伞工作情况
local drag_chute_target_state = 0 -- 0为关闭，1为打开，2为抛离
local drag_chute_pos

local Airbrake  = 73 -- 默认空气刹车的按键输入
local AirbrakeOn = 147
local AirbrakeOff = 148

local iCommandPlaneWheelBrakeOn = 74 --原装的机轮刹车
local iCommandPlaneWheelBrakeOff = 75

local parking_brake_state = 0
local parking_brake_target = 0

local parking_brake_applied = 0

function post_initialize()
    air_brake_state = 0
    local birth = LockOn_Options.init_conditions.birth_place
    if birth=="GROUND_HOT" then
        parking_brake_target = 1
    elseif birth=="AIR_HOT" then
        parking_brake_target = 0
    elseif birth=="GROUND_COLD" then
        parking_brake_target = 1
    end
    parking_brake_handle:set(parking_brake_target)
end

-- 监听轮子刹车
Breaks:listen_command(Keys.BrakesOn)
Breaks:listen_command(Keys.BrakesOff)
-- 监听空气刹车
Breaks:listen_command(Airbrake)
Breaks:listen_command(AirbrakeOn)
Breaks:listen_command(AirbrakeOff)
-- 监听停机刹车
Breaks:listen_command(Keys.ParkingBrakesOn)
Breaks:listen_command(Keys.ParkingBrakesOff)
Breaks:listen_command(Keys.ParkingBrakes)
Breaks:listen_command(72)
Breaks:listen_command(145)
Breaks:listen_command(146)

Flap_Target = 0
Flap_Current = 0

function SetCommand(command,value)
    if (command == Keys.BrakesOn) and (parking_brake_target == 0) then
        dispatch_action(nil,iCommandPlaneWheelBrakeOn)
    elseif (command == Keys.BrakesOff) and (parking_brake_target == 0) then
        dispatch_action(nil,iCommandPlaneWheelBrakeOff)
    elseif (command == Airbrake) then
        if (air_brake_state == 0) then
            air_brake_state =0 
        elseif (air_brake_state == 1) then
            air_brake_state = 0
        end
    elseif (command == AirbrakeOn) then
        air_brake_state = 1
    elseif (command == AirbrakeOff) then
        air_brake_state = 0
    elseif (command == Keys.ParkingBrakesOn) then
        print_message_to_user("pb on")
        dispatch_action(nil,iCommandPlaneWheelBrakeOn)
        parking_brake_target = 1
    elseif (command == Keys.ParkingBrakesOff) then
        dispatch_action(nil,iCommandPlaneWheelBrakeOff)
        parking_brake_target = 0
    elseif (command == Keys.ParkingBrakes) then
        parking_brake_target = 1 - parking_brake_target
        if (parking_brake_target == 1) then
            dispatch_action(nil,iCommandPlaneWheelBrakeOn)
        elseif (parking_brake_target == 0) then
            dispatch_action(nil,iCommandPlaneWheelBrakeOff)
        end
    elseif (command == 146) then
        Flap_Target = 0
    elseif (command == 145) then
        Flap_Target = 1
    elseif (command == 72) then
        Flap_Target = 1 - Flap_Target
    end
end

function update()
    air_brake_pos = tonumber(string.format(fmt, air_brake_pos))
    if (air_brake_pos < air_brake_state) then
        air_brake_pos = air_brake_pos + 0.02
        set_aircraft_draw_argument_value(21, air_brake_pos)
        air_brake_pos_ind:set(air_brake_pos)
    elseif (air_brake_pos > air_brake_state) then
        air_brake_pos = air_brake_pos - 0.02
        set_aircraft_draw_argument_value(21, air_brake_pos)
        air_brake_pos_ind:set(air_brake_pos)
    end
	--print_message_to_user("BREAKPOS")
	--print_message_to_user(air_brake_pos)
	--print_message_to_user("BREAKTAR")
    --print_message_to_user(air_brake_state)
    if (parking_brake_state < parking_brake_target) and (parking_brake_target == 1) then
        parking_brake_state = parking_brake_state + 0.1
    elseif (parking_brake_state > parking_brake_target) and (parking_brake_target == 0) then
        parking_brake_state = parking_brake_state - 0.1
    end

    parking_brake_handle:set(parking_brake_state)
    --print_message_to_user(parking_brake_state)
    local flap_moving_step = 0.02 / 5
    -- update flap status
    if math.abs(Flap_Target - Flap_Current) < flap_moving_step then
        Flap_Current = Flap_Target
    else
        if Flap_Target < Flap_Current then
            Flap_Current = Flap_Current - flap_moving_step
        elseif Flap_Current < Flap_Target then
            Flap_Current = Flap_Current + flap_moving_step
        end
    end
    set_aircraft_draw_argument_value(9,Flap_Current)
    set_aircraft_draw_argument_value(10,Flap_Current)
    set_aircraft_draw_argument_value(13,Flap_Current)
    set_aircraft_draw_argument_value(14,Flap_Current)

end

--不关闭该lua
need_to_be_closed = false
