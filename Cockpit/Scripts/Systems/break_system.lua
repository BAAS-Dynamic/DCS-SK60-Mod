local Breaks = GetSelf()
dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")

-- ATTENTION: air brake is currently not working

local update_time_step = 0.02 --refreshes 50 times per second
make_default_activity(update_time_step)

local sensor_data = get_base_data()

local fmt = '%.2f'

local air_brake_state
local air_brake_pos = 0

local air_brake_pos_ind = get_param_handle("AIRBRAKE_IND")

local parking_brake_handle = get_param_handle("PARKINGBREAK_HANDLE")
local parking_brake_status = get_param_handle("PARK_BRAKE")

-- drag chute state
local drag_chute_target_state = 0 -- 0 closed, 1 deployed, 2 jettisoned
local drag_chute_pos

local Airbrake  = 73 -- default air-brake key input
local AirbrakeOn = 147
local AirbrakeOff = 148

local iCommandPlaneWheelBrakeOn = 74 --default wheel brake
local iCommandPlaneWheelBrakeOff = 75
local iCommandWheelBrake = 2101 -- combined wheel-brake axis
local iCommandLeftWheelBrake = 2112
local iCommandRightWheelBrake = 2113

local gear_state_share = get_param_handle("GEAR_SHARE")
local ejection_commanded = get_param_handle("EJECTION_COMMANDED")

local parking_brake_state = 0
local parking_brake_target = 0
local parking_brake_latch = get_param_handle("PARK_BRAKE_LATCH")
local wheel_brakes_pressed = false
local left_brake_pedal = 0
local right_brake_pedal = 0
local left_brake_pedal_handle = get_param_handle("BRAKE_PEDAL_LEFT")
local right_brake_pedal_handle = get_param_handle("BRAKE_PEDAL_RIGHT")

function post_initialize()
    air_brake_state = 0
    -- The parking brake is set manually as part of the startup checklist.
    parking_brake_target = 0
    parking_brake_latch:set(parking_brake_target)
    parking_brake_state = parking_brake_target
    parking_brake_handle:set(parking_brake_target)
end

-- listen for wheel-brake commands
Breaks:listen_command(Keys.BrakesOn)
Breaks:listen_command(Keys.BrakesOff)
Breaks:listen_command(iCommandPlaneWheelBrakeOn)
Breaks:listen_command(iCommandPlaneWheelBrakeOff)
Breaks:listen_command(iCommandWheelBrake)
Breaks:listen_command(iCommandLeftWheelBrake)
Breaks:listen_command(iCommandRightWheelBrake)
-- listen for air-brake commands
Breaks:listen_command(Airbrake)
Breaks:listen_command(AirbrakeOn)
Breaks:listen_command(AirbrakeOff)
-- listen for parking-brake commands
Breaks:listen_command(Keys.ParkingBrakesOn)
Breaks:listen_command(Keys.ParkingBrakesOff)
Breaks:listen_command(Keys.ParkingBrakes)
Breaks:listen_command(72)
Breaks:listen_command(145)
Breaks:listen_command(146)


-- listen to flap
Breaks:listen_command(Keys.Flap_Pos_Up)
Breaks:listen_command(Keys.Flap_Pos_Half)
Breaks:listen_command(Keys.Flap_Pos_Down)
Breaks:listen_command(Keys.FlapUp)
Breaks:listen_command(Keys.FlapDown)
Breaks:listen_command(Keys.Sync_Flaps)

------Here Strat the general Switch Control

local SWITCH_OFF = 0
local SWITCH_ON = 1
local SWITCH_TEST = -1
local SWITCH_HALF = 0.5

switch_count = 0
function _switch_counter()
    switch_count = switch_count + 1
    return switch_count
end

local flap_switch = _switch_counter()

target_status = {
    {flap_switch , SWITCH_ON, get_param_handle("FLAP_LEVEL"), "FLAP_LEVEL"},
}

current_status = {
    {flap_switch, SWITCH_ON, SWITCH_ON},
}

Flap_Target = 0
Flap_Current = 0

function SetCommand(command,value)
	if ejection_commanded:get() >= 0.5 then
		return
	end

	if command == Keys.Sync_Flaps then
	    local position = math.max(0, math.min(1, value))
	    Flap_Target = position
	    Flap_Current = position
	    if position < 0.25 then
	        target_status[flap_switch][2] = SWITCH_ON
	    elseif position < 0.75 then
	        target_status[flap_switch][2] = SWITCH_HALF
	    else
	        target_status[flap_switch][2] = SWITCH_OFF
	    end
	    current_status[flap_switch][2] = target_status[flap_switch][2]
	elseif (command == Keys.BrakesOn) or (command == iCommandPlaneWheelBrakeOn) then
        wheel_brakes_pressed = true
        left_brake_pedal = 1
        right_brake_pedal = 1
        -- Pressing the pedals unloads the pawls, allowing their springs to
        -- return the parking-brake lever to the open position.
        if parking_brake_target == 1 then
            parking_brake_target = 0
        end
        if command == Keys.BrakesOn then
            dispatch_action(nil,iCommandPlaneWheelBrakeOn)
        end
    elseif command == iCommandWheelBrake then
        -- Brake axes use the DCS -1 (released) to +1 (pressed) convention.
        -- Track the pedal crossing rather than treating every axis update as a
        -- new press, otherwise a held pedal would repeatedly release a latch.
        local pedal_position = math.max(0, math.min(1, (value + 1) * 0.5))
        local axis_pressed = pedal_position > 0.05
        if axis_pressed and not wheel_brakes_pressed and parking_brake_target == 1 then
            parking_brake_target = 0
        end
        left_brake_pedal = pedal_position
        right_brake_pedal = pedal_position
        wheel_brakes_pressed = axis_pressed
    elseif command == iCommandLeftWheelBrake or command == iCommandRightWheelBrake then
        local pedal_position = math.max(0, math.min(1, (value + 1) * 0.5))
        local was_pressed = wheel_brakes_pressed
        if command == iCommandLeftWheelBrake then
            left_brake_pedal = pedal_position
        else
            right_brake_pedal = pedal_position
        end
        wheel_brakes_pressed = left_brake_pedal > 0.05 or right_brake_pedal > 0.05
        if wheel_brakes_pressed and not was_pressed and parking_brake_target == 1 then
            parking_brake_target = 0
        end
    elseif (command == Keys.BrakesOff) or (command == iCommandPlaneWheelBrakeOff) then
        wheel_brakes_pressed = false
        left_brake_pedal = 0
        right_brake_pedal = 0
        if parking_brake_target == 0 and command == Keys.BrakesOff then
            dispatch_action(nil,iCommandPlaneWheelBrakeOff)
        end
   --elseif (command == Airbrake) then
   --    if (air_brake_state == 0) then
   --        air_brake_state =0
   --    elseif (air_brake_state == 1) then
   --        air_brake_state = 0
   --    end
   --elseif (command == AirbrakeOn) then
   --    air_brake_state = 1
   --elseif (command == AirbrakeOff) then
   --    air_brake_state = 0
    elseif (command == Keys.ParkingBrakesOn) then
        if wheel_brakes_pressed then
            parking_brake_target = 1
        end
    elseif (command == Keys.ParkingBrakesOff) then
        parking_brake_target = 0
    elseif (command == Keys.ParkingBrakes) then
        -- Pulling the lever only catches while pedal pressure is present.
        -- Otherwise its spring immediately leaves/returns it at argument 0.
        if parking_brake_target == 0 and wheel_brakes_pressed then
            parking_brake_target = 1
        else
            parking_brake_target = 0
        end
    elseif (command == 146) then
        dispatch_action(nil,Keys.FlapUp)
       --[[
        if (Flap_Target > 0.1 and Flap_Target <= 0.7) then
            Flap_Target = 0
        elseif Flap_Target >= 0.8 then
            Flap_Target = 0.5
        end
        ]]--
    elseif (command == 145) then
        dispatch_action(nil,Keys.FlapDown)
       --[[
        if (Flap_Target < 0.8 and Flap_Target > 0.3) then
            Flap_Target = 1
        elseif Flap_Target < 0.3 then
            Flap_Target = 0.5
        end
        ]]--
    elseif (command == 72) then
       -- this is warthunder like now
        if get_aircraft_draw_argument_value(0) > 0.5 then
            if Flap_Target > 0.3 then
                Flap_Target = 0
                target_status[flap_switch][2] = SWITCH_ON
                -- Flap status debug text disabled.
            else
                if (sensor_data.getWOW_NoseLandingGear() > 0.0001) then
                    Flap_Target = 0.5
                    target_status[flap_switch][2] = SWITCH_HALF
                    -- Flap status debug text disabled.
                else
                    Flap_Target = 1
                    target_status[flap_switch][2] = SWITCH_OFF
                    -- Flap status debug text disabled.
                end
            end
        else
            if Flap_Target > 0.3 then
                Flap_Target = 0
                target_status[flap_switch][2] = SWITCH_ON
                -- Flap status debug text disabled.
            else
                Flap_Target = 0.5
                target_status[flap_switch][2] = SWITCH_HALF
                -- Flap status debug text disabled.
            end
        end
    elseif (command == Keys.Flap_Pos_Up) then
        Flap_Target = 0
        target_status[flap_switch][2] = SWITCH_ON
    elseif (command == Keys.Flap_Pos_Half) then
        Flap_Target = 0.5
        target_status[flap_switch][2] = SWITCH_HALF
    elseif (command == Keys.Flap_Pos_Down) then
        Flap_Target = 1
        target_status[flap_switch][2] = SWITCH_OFF
    elseif (command == Keys.FlapUp) then
        if (Flap_Target < 0.2) then
            Flap_Target = 0.5
            target_status[flap_switch][2] = SWITCH_HALF
        elseif (Flap_Target < 0.7) then
            Flap_Target = 1
            target_status[flap_switch][2] = SWITCH_OFF
        end
    elseif (command == Keys.FlapDown) then
        if (Flap_Target > 0.7) then
            Flap_Target = 0.5
            target_status[flap_switch][2] = SWITCH_HALF
        elseif (Flap_Target > 0.3) then
            Flap_Target = 0
            target_status[flap_switch][2] = SWITCH_ON
        end
    end
end

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

function update()
   --[[
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
    ]]--
	--print_message_to_user("BREAKPOS")
	--print_message_to_user(air_brake_pos)
	--print_message_to_user("BREAKTAR")
   --print_message_to_user(air_brake_state)
    local parking_brake_step = 0.1
    if math.abs(parking_brake_state - parking_brake_target) <= parking_brake_step then
        parking_brake_state = parking_brake_target
    elseif parking_brake_state < parking_brake_target then
        parking_brake_state = parking_brake_state + parking_brake_step
    else
        parking_brake_state = parking_brake_state - parking_brake_step
    end

    parking_brake_handle:set(parking_brake_state)
    -- Unlike arbitrary dispatch_action command IDs, cockpit parameters are a
    -- supported Lua-to-EFM data path and are sampled by the EFM every frame.
    parking_brake_latch:set(parking_brake_target)
    left_brake_pedal_handle:set(left_brake_pedal)
    right_brake_pedal_handle:set(right_brake_pedal)
   --print_message_to_user(parking_brake_state)
    local flap_moving_step = 0.02 / 10
   -- update flap status
    if get_hydro_system_status() == true then
        if math.abs(Flap_Target - Flap_Current) < flap_moving_step then
            Flap_Current = Flap_Target
        else
            if Flap_Target < Flap_Current then
                Flap_Current = Flap_Current - flap_moving_step
            elseif Flap_Current < Flap_Target then
                Flap_Current = Flap_Current + flap_moving_step
            end
        end
    end
    set_aircraft_draw_argument_value(9,Flap_Current)
    set_aircraft_draw_argument_value(10,Flap_Current)
    set_aircraft_draw_argument_value(13,Flap_Current)
    set_aircraft_draw_argument_value(14,Flap_Current)
    air_brake_pos_ind:set(get_aircraft_draw_argument_value(21))
    parking_brake_status:set(parking_brake_state)
    update_switch_status()
end

--do not close this Lua device
need_to_be_closed = false

-- SK60 shared cockpit integration
dofile(LockOn_Options.script_path .. "Multicrew/runtime.lua").install(4)
