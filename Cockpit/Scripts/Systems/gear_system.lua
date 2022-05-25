dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")
dofile(LockOn_Options.script_path.."debug_util.lua")
dofile(LockOn_Options.script_path.."devices.lua")

local gear_system = GetSelf()

local update_time_step = 0.02  --50 refreshes per second
make_default_activity(update_time_step)

local sensor_data = get_base_data()

--local iCommandPlaneGear
local gear_switch = 68  --Define landing gear buttons
local gear_up = 430
local gear_down = 431

local nose_gear_status = 1   --Landing gear status 0 retracted, 1 lowered
local l_main_gear_status = 1
local r_main_gear_status = 1

local nose_gear_broken = 0   --Landing gear condition 0 normal, 1 malfunction
local l_main_gear_broken = 0
local r_main_gear_broken = 0

local gear_level_init = 0 --The landing gear handle is not set by default

local gear_level = get_param_handle("PTN_083")

-- set indicator
local ngear_pos_ind = get_param_handle("NoseWPOS_IND")
local mlgear_pos_ind = get_param_handle("MainLWPOS_IND")
local mrgear_pos_ind = get_param_handle("MainRWPOS_IND")

local gear_state_share = get_param_handle("GEAR_SHARE")

gear_system:listen_command(gear_switch)
gear_system:listen_command(gear_up)
gear_system:listen_command(gear_down)
gear_system:listen_command(click_cmd.GearLevel)
gear_system:listen_command(120)

local n_gear_status
local l_gear_status
local r_gear_status

function post_initialize()
    local birth = LockOn_Options.init_conditions.birth_place
    if birth=="GROUND_HOT" then
        nose_gear_status = 1   --Landing gear status 0 retracted, 1 lowered
        l_main_gear_status = 1
        r_main_gear_status = 1
    elseif birth=="AIR_HOT" then
        nose_gear_status = 0   --Landing gear status 0 retracted, 1 lowered
        l_main_gear_status = 0
        r_main_gear_status = 0
    elseif birth=="GROUND_COLD" then
        nose_gear_status = 1   --Landing gear status 0 retracted, 1 lowered
        l_main_gear_status = 1
        r_main_gear_status = 1
    end

    n_gear_status = nose_gear_status
    l_gear_status = l_main_gear_status
    r_gear_status = r_main_gear_status

    if (gear_level_init == 0) then
        --gear_system:performClickableAction(click_cmd.GearLevel, 1, false)
    end

    set_aircraft_draw_argument_value(0, nose_gear_status)
    set_aircraft_draw_argument_value(3, r_main_gear_status)
    set_aircraft_draw_argument_value(5, l_main_gear_status)
    gear_level:set(1 - nose_gear_status)
    gear_state_share:set(nose_gear_status)
    gear_level_pos = 1 - nose_gear_status
end

local move_ability = 1;
function SetCommand(command,value)
    if (command == click_cmd.GearLevel) then
        dispatch_action(nil, 68) --Reset command to default landing gear command
    elseif (command == gear_switch) then
        nose_gear_status = 1 - nose_gear_status
        l_main_gear_status = 1 - l_main_gear_status
        r_main_gear_status = 1 - r_main_gear_status
        if (nose_gear_status == 1) then
            dprintf("Gear Down")
        else
            dprintf("Gear Up")
        end
    elseif (command == gear_down) then
        nose_gear_status = 1
        l_main_gear_status = 1
        r_main_gear_status = 1
    elseif (command == gear_up) then
        nose_gear_status = 0
        l_main_gear_status = 0
        r_main_gear_status = 0       
    elseif (command == 120) then
        dispatch_action(nil, THROTTLEAXIS, -1)
	end
end

local moving_starts = 0

function update()
    local gear_handle_click_ref = get_clickable_element_reference("PNT_083")

        --takes 7 seconds to full extended
        -- set globle time count
        local time_increse_step = 0.02 / 7
        if (sensor_data.getWOW_LeftMainLandingGear() > 0.001 or sensor_data.getWOW_NoseLandingGear() > 0.001 or sensor_data.getWOW_RightMainLandingGear() > 0.001) then
            move_ability = 0;
            --dprintf("L:"..sensor_data.getWOW_LeftMainLandingGear());
            --dprintf("R:"..sensor_data.getWOW_RightMainLandingGear());
        else
            move_ability = 1;
        end
        --dprintf("N:"..sensor_data.getWOW_NoseLandingGear());
        
        
        if (nose_gear_status == 0 and n_gear_status > 0) then
            -- in increments of time_increse_step (50x per second)
            n_gear_status = n_gear_status - time_increse_step * move_ability
            set_aircraft_draw_argument_value(0, n_gear_status)
            if moving_starts == 0 and move_ability == 1 then
                dispatch_action(devices.SOUND_SYSTEM, Keys.SND_GEAR, 1)
                moving_starts = 1
            end
        elseif (nose_gear_status == 1 and n_gear_status < 1) then
            -- in increments of time_increse_step (50x per second)
            n_gear_status = n_gear_status + time_increse_step
            set_aircraft_draw_argument_value(0, n_gear_status)
            if moving_starts == 0 and move_ability == 1 then
                dispatch_action(devices.SOUND_SYSTEM, Keys.SND_GEAR, 1)
                moving_starts = 1
            end
        else
            moving_starts = 0
        end

        if (nose_gear_status == 0 and n_gear_status <= 0) then
            n_gear_status = 0
        elseif (nose_gear_status == 1 and n_gear_status >= 1)then
            n_gear_status = 1
        end

        if (l_main_gear_status == 0 and l_gear_status > 0) then
            l_gear_status = l_gear_status - time_increse_step * move_ability
            set_aircraft_draw_argument_value(5, l_gear_status)
        elseif (l_main_gear_status == 1 and l_gear_status < 1) then
            l_gear_status = l_gear_status + time_increse_step
            set_aircraft_draw_argument_value(5, l_gear_status)
        end

        if (r_main_gear_status == 0 and r_gear_status > 0) then
            -- lower canopy in increments of time_increse_step (50x per second)
            r_gear_status = r_gear_status - time_increse_step * move_ability
            set_aircraft_draw_argument_value(3, r_gear_status)
        elseif (r_main_gear_status == 1 and r_gear_status < 1) then
            -- lower canopy in increments of time_increse_step (50x per second)
            r_gear_status = r_gear_status + time_increse_step
            set_aircraft_draw_argument_value(3, r_gear_status)
        end
        
        -- level step slower
        if (nose_gear_status == 0 and gear_level_pos < 1) then
            -- lower canopy in increments of time_increse_step (50x per second)
            gear_level_pos = gear_level_pos + 0.1
            gear_level:set(gear_level_pos)
            gear_handle_click_ref:update()
        elseif (nose_gear_status == 1 and gear_level_pos > 0) then
            -- lower canopy in increments of time_increse_step (50x per second)
            gear_level_pos = gear_level_pos - 0.1
            gear_level:set(gear_level_pos)
            gear_handle_click_ref:update()
        end

        -- the gear indication system  wont work without the dc power
        if get_elec_dc_status() then
            ngear_pos_ind:set(n_gear_status)
            mlgear_pos_ind:set(l_gear_status)
            mrgear_pos_ind:set(r_gear_status)
        else
            ngear_pos_ind:set(0)
            mlgear_pos_ind:set(0)
            mrgear_pos_ind:set(0)
        end
        gear_state_share:set(nose_gear_status)
end

need_to_be_closed = false