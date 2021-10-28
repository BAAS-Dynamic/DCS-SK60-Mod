local LightSystem = GetSelf()

--初始化加载要用lua文件
dofile(LockOn_Options.common_script_path.."devices_defs.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")

--设置循环次数
local update_rate = 0.01 -- 50次每秒
make_default_activity(update_rate)

--初始化DCS读取API
local sensor_data = get_base_data()

------Here Strat the general Switch Control

local SWITCH_OFF = 0
local SWITCH_ON = 1
local SWITCH_TEST = -1

switch_count = 0
function _switch_counter()
    switch_count = switch_count + 1
    return switch_count
end

local strobe_light_switch = _switch_counter()
local taxi_light_switch = _switch_counter()
local wing_navi_switch = _switch_counter()
local formation_switch = _switch_counter()
local flood_light_switch = _switch_counter()
local instrument_light_switch = _switch_counter()
local console_light_switch = _switch_counter()
local approach_index_switch = _switch_counter()

local gear_state_share = get_param_handle("GEAR_SHARE")

target_status = {
    {strobe_light_switch , SWITCH_OFF, get_param_handle("PTN_429"), "PTN_429"},
    {taxi_light_switch , 0.5, get_param_handle("PTN_436"), "PTN_436"},
    {wing_navi_switch , SWITCH_OFF, get_param_handle("PTN_424"), "PTN_424"},
    {formation_switch , SWITCH_OFF, get_param_handle("PTN_130"), "PTN_130"},
    {flood_light_switch , SWITCH_OFF, get_param_handle("PTN_133"), "PTN_133"},
    {instrument_light_switch , SWITCH_OFF, get_param_handle("PTN_132"), "PTN_132"},
    {console_light_switch , SWITCH_OFF, get_param_handle("PTN_131"), "PTN_131"},
    {approach_index_switch , SWITCH_OFF, get_param_handle("PTN_134"), "PTN_134"},
}

current_status = {
    {strobe_light_switch , SWITCH_OFF, SWITCH_OFF},
    {taxi_light_switch, SWITCH_OFF, SWITCH_OFF},
    {wing_navi_switch, SWITCH_OFF, SWITCH_OFF},
    {formation_switch, SWITCH_OFF, SWITCH_OFF},
    {flood_light_switch, SWITCH_OFF, SWITCH_OFF},
    {instrument_light_switch, SWITCH_OFF, SWITCH_OFF},
    {console_light_switch, SWITCH_OFF, SWITCH_OFF},
    {approach_index_switch, SWITCH_OFF, SWITCH_OFF},
}

function post_initialize()
    local birth = LockOn_Options.init_conditions.birth_place
    if birth == "GROUND_HOT" then
        target_status = {
            {strobe_light_switch , SWITCH_ON, get_param_handle("PTN_429"), "PTN_429"},
            {taxi_light_switch , 0, get_param_handle("PTN_436"), "PTN_436"},
            {wing_navi_switch , SWITCH_ON, get_param_handle("PTN_424"), "PTN_424"},
            {formation_switch , SWITCH_OFF, get_param_handle("PTN_130"), "PTN_130"},
            {flood_light_switch , SWITCH_OFF, get_param_handle("PTN_133"), "PTN_133"},
            {instrument_light_switch , SWITCH_ON, get_param_handle("PTN_132"), "PTN_132"},
            {console_light_switch , 0.3, get_param_handle("PTN_131"), "PTN_131"},
            {approach_index_switch , SWITCH_OFF, get_param_handle("PTN_134"), "PTN_134"},
        }
    elseif birth == "AIR_HOT" then
        target_status = {
            {strobe_light_switch , SWITCH_OFF, get_param_handle("PTN_429"), "PTN_429"},
            {taxi_light_switch , 0.5, get_param_handle("PTN_436"), "PTN_436"},
            {wing_navi_switch , SWITCH_ON, get_param_handle("PTN_424"), "PTN_424"},
            {formation_switch , SWITCH_OFF, get_param_handle("PTN_130"), "PTN_130"},
            {flood_light_switch , SWITCH_OFF, get_param_handle("PTN_133"), "PTN_133"},
            {instrument_light_switch , SWITCH_OFF, get_param_handle("PTN_132"), "PTN_132"},
            {console_light_switch , 0.3, get_param_handle("PTN_131"), "PTN_131"},
            {approach_index_switch , SWITCH_OFF, get_param_handle("PTN_134"), "PTN_134"},
        }
    end
end

LightSystem:listen_command(Keys.LightStrobeUP)
LightSystem:listen_command(Keys.LightStrobeDOWN)
LightSystem:listen_command(Keys.LightTaxiUP)
LightSystem:listen_command(Keys.LightTaxiDOWN)
LightSystem:listen_command(Keys.LightNaviWingUP)
LightSystem:listen_command(Keys.LightNaviWingDOWN)
LightSystem:listen_command(Keys.LightNaviTailUP)
LightSystem:listen_command(Keys.LightNaviTailDOWN)
LightSystem:listen_command(Keys.LightFormationUP)
LightSystem:listen_command(Keys.LightFormationDOWN)
LightSystem:listen_command(Keys.LightFloodDOWN)
LightSystem:listen_command(Keys.LightFloodUP)
LightSystem:listen_command(Keys.LightInstruBRT)
LightSystem:listen_command(Keys.LightConsoleBRT)
LightSystem:listen_command(Keys.LightApproIndexBRT)
LightSystem:listen_command(Keys.SpecialSence)

local special_display_status = 0;
local special_display_current = 0;

function SetCommand(command, value)
    local new_value
    if command == Keys.LightStrobeUP then
        if target_status[strobe_light_switch][2] < 0.5 then
            target_status[strobe_light_switch][2] = target_status[strobe_light_switch][2] + 1
        end
    elseif command == Keys.LightStrobeDOWN then
        if target_status[strobe_light_switch][2] > - 0.5 then
            target_status[strobe_light_switch][2] = target_status[strobe_light_switch][2] - 1
        end    
    elseif command == Keys.LightTaxiUP then
        -- print_message_to_user(target_status[taxi_light_switch][2])
        if target_status[taxi_light_switch][2] < 0.8 then
            target_status[taxi_light_switch][2] = target_status[taxi_light_switch][2] + 0.5
        end
    elseif command == Keys.LightTaxiDOWN then
        if target_status[taxi_light_switch][2] > 0.3 then
            target_status[taxi_light_switch][2] = target_status[taxi_light_switch][2] - 0.5
        end
    -- fit new
    elseif command == Keys.LightNaviWingUP then
        if target_status[wing_navi_switch][2] < 0.8 and target_status[wing_navi_switch][2] > -0.5 then
            target_status[wing_navi_switch][2] = target_status[wing_navi_switch][2] + 0.5
        elseif target_status[wing_navi_switch][2] < 0.1 then
            target_status[wing_navi_switch][2] = target_status[wing_navi_switch][2] + 1
        end
    elseif command == Keys.LightNaviWingDOWN then
        if target_status[wing_navi_switch][2] > 0.1 then
            target_status[wing_navi_switch][2] = target_status[wing_navi_switch][2] - 0.5
        elseif target_status[wing_navi_switch][2] > -0.5 then
            target_status[wing_navi_switch][2] = target_status[wing_navi_switch][2] - 1
        end

    elseif command == Keys.LightFormationUP then
        if target_status[formation_switch][2] < 0.5 then
            target_status[formation_switch][2] = target_status[formation_switch][2] + 1
        end
    elseif command == Keys.LightFormationDOWN then
        if target_status[formation_switch][2] > -0.5 then
            target_status[formation_switch][2] = target_status[formation_switch][2] - 1
        end
    elseif command == Keys.LightFloodUP then
        if target_status[flood_light_switch][2] < 0.5 then
            target_status[flood_light_switch][2] = target_status[flood_light_switch][2] + 1
        end
    elseif command == Keys.LightFloodDOWN then
        if target_status[flood_light_switch][2] > -0.5 then
            target_status[flood_light_switch][2] = target_status[flood_light_switch][2] - 1
        end
    elseif command == Keys.LightInstruBRT then
        if value < 0.5 then
            new_value = - 0.1
        else
            new_value = 0.1
        end
        if target_status[instrument_light_switch][2] <= 1 and target_status[instrument_light_switch][2] >= 0 then
            --print_message_to_user(new_value)
            target_status[instrument_light_switch][2] = target_status[instrument_light_switch][2] + new_value
        elseif target_status[instrument_light_switch][2] < 0 then
            target_status[instrument_light_switch][2] = 0
        elseif target_status[instrument_light_switch][2] > 1 then
            target_status[instrument_light_switch][2] = 1
        end
        --print_message_to_user(value)
        --print_message_to_user(target_status[instrument_light_switch][2])
    elseif command == Keys.LightConsoleBRT then
        if value < 0.5 then
            new_value = - 0.1
        else
            new_value = 0.1
        end
        if target_status[console_light_switch][2] <= 1 and target_status[console_light_switch][2] >= 0 then
            target_status[console_light_switch][2] = target_status[console_light_switch][2] + new_value
        elseif target_status[console_light_switch][2] < 0 then
            target_status[console_light_switch][2] = 0
        elseif target_status[console_light_switch][2] > 1 then
            target_status[console_light_switch][2] = 1
        end
        print_message_to_user(value)
        print_message_to_user(target_status[console_light_switch][2])
    elseif command == Keys.LightApproIndexBRT then
        if value < 0.5 then
            new_value = - 0.1
        else
            new_value = 0.1
        end
        if target_status[approach_index_switch][2] <= 1 and target_status[approach_index_switch][2] >= 0 then
            target_status[approach_index_switch][2] = target_status[approach_index_switch][2] + new_value
        elseif target_status[approach_index_switch][2] < 0 then
            target_status[approach_index_switch][2] = 0
        elseif target_status[approach_index_switch][2] > 1 then
            target_status[approach_index_switch][2] = 1
        end
    elseif command == Keys.SpecialSence then
        --print_message_to_user("start")
        special_display_current = 0
        special_display_status = 1
    end
end

NAV_FLASH_COUNT = 0
STROBE_ROTATION = 0

function update_externel_light_status()
    local anticolmulti = 1;
    if get_elec_ac_status() == true then
        set_aircraft_draw_argument_value(51, current_status[taxi_light_switch][2]) -- taxi light 51

        -- rotation mode
        if math.abs(current_status[strobe_light_switch][2]) > 0.5 then
            if (current_status[strobe_light_switch][2] < -0.5) then
                anticolmulti = 0.5
            else
                anticolmulti = 1
            end
            set_aircraft_draw_argument_value(192, anticolmulti)
            STROBE_ROTATION = STROBE_ROTATION + 0.004
            if (STROBE_ROTATION > 1) then
                STROBE_ROTATION = STROBE_ROTATION - 1
            end
            set_aircraft_draw_argument_value(193, STROBE_ROTATION)
        else
            anticolmulti = 0
            set_aircraft_draw_argument_value(192, anticolmulti)
        end

        -- Nav light flash mode
        if target_status[wing_navi_switch][2] > 0.25 and target_status[wing_navi_switch][2] < 0.75 then
            NAV_FLASH_COUNT = NAV_FLASH_COUNT + 0.02
            if NAV_FLASH_COUNT > 2 then
                NAV_FLASH_COUNT = 0
            end
            if NAV_FLASH_COUNT <= 1 then
                set_aircraft_draw_argument_value(190, NAV_FLASH_COUNT)
                set_aircraft_draw_argument_value(191, NAV_FLASH_COUNT)
            else
                set_aircraft_draw_argument_value(190, 2 - NAV_FLASH_COUNT)
                set_aircraft_draw_argument_value(191, 2 - NAV_FLASH_COUNT)
            end
        elseif target_status[wing_navi_switch][2] < -0.25 then
            NAV_FLASH_COUNT = 0
            set_aircraft_draw_argument_value(190, 0)
            set_aircraft_draw_argument_value(191, 0)
        elseif target_status[wing_navi_switch][2] > -0.25 and target_status[wing_navi_switch][2] < 0.25 then
            NAV_FLASH_COUNT = 0
            set_aircraft_draw_argument_value(190, 0.5)
            set_aircraft_draw_argument_value(191, 0.5)
        elseif target_status[wing_navi_switch][2] > 0.75 then
            NAV_FLASH_COUNT = 0
            set_aircraft_draw_argument_value(190, 1)
            set_aircraft_draw_argument_value(191, 1)
        end

        -- taxi/landing lights
        if get_aircraft_draw_argument_value(0) > 0.8 then
            -- when gear is out
            if target_status[taxi_light_switch][2] == 0 then
                set_aircraft_draw_argument_value(194, 0.5)
            elseif target_status[taxi_light_switch][2] == 1 then
                set_aircraft_draw_argument_value(194, 1)
            elseif target_status[taxi_light_switch][2] == 0.5 then
                set_aircraft_draw_argument_value(194, 0)
            end
        else
            -- cloase taxi/landing light
            set_aircraft_draw_argument_value(194, 0)
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

function updateSpecialAnimation()
    if special_display_status == 1 then
        if special_display_current < 1 then
            special_display_current = special_display_current + update_rate / 4
        else
            special_display_current = 0
            special_display_status = 0
        end
        set_aircraft_draw_argument_value(999, special_display_current)
        --print_message_to_user(special_display_current)
    end
end

function update()
    update_switch_status()
    update_externel_light_status()
    updateSpecialAnimation()
end

need_to_be_closed = false