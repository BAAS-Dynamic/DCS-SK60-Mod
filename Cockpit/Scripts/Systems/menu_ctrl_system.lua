dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")
dofile(LockOn_Options.script_path.."CustomMenu/menu_config.lua")

local dev 	    = GetSelf()

local update_time_step = 0.02
make_default_activity(update_time_step)

local sensor_data = get_base_data()
local ias_conversion_to_knots = 1.9504132
local ias_conversion_to_kmh =  1.9504132 -- easily convert to knots -- 3.6 
local DEGREE_TO_RAD  = 0.0174532925199433
local RAD_TO_DEGREE  = 57.29577951308233
local METER_TO_INCH = 3.2808

-- iCommandPlaneViewVertical 2008
-- iCommandPlaneViewHorizontal 2007
dev:listen_command(2142)-- iServicePilotAngleHorizontal
dev:listen_command(2143)-- iServicePilotAngleVertical
-- iCommandCockpitClickModeOnOff	363
dev:listen_command(Keys.Custom_Menu)
dev:listen_command(363)-- 2143

local cursor_mode = get_param_handle("DEBUG_LINE3")
local menu_disp_enable = get_param_handle("MENU_DISP_ENABLE")
local current_menu_hint = get_param_handle("MENU_CENTER_STR")
local general_menu_hint = get_param_handle("MENU_STR_TRI")

viewang_v = 0
viewang_h = 0
-- record the view angle when start trigger menu
viewangle_offset_v = 0
viewangle_offset_h = 0

menu_is_on = 0
last_cursor_mode = 0
on_close = 0
current_submenu_index = submenu_id.MAIN_MENU
last_submenu_index = submenu_id.MAIN_MENU
screen_height = LockOn_Options.screen.height * 0.5

function post_initialize()
    current_submenu_index = submenu_id.MAIN_MENU
    last_submenu_index = submenu_id.MAIN_MENU
    current_menu_hint:set(submenu[current_submenu_index][0][1])
    general_menu_hint:set(submenu[current_submenu_index][0][1])
end

function SetCommand(command,value)
    if (command == 2142) then
        viewang_h = value
    elseif (command == 2143) then
        viewang_v = value
    elseif (command == Keys.Custom_Menu) then
        if (menu_is_on == 0) then
            -- ask the click mode to off
            print_message_to_user("menu triggered")
            if (cursor_mode:get() < 1) then
                -- cursor mode is clickable
                dispatch_action(nil, 363)
                last_cursor_mode = 1
            end
            menu_is_on = 1
            -- force close transpose mode
            dispatch_action(nil, 1594) 
        else
            -- close menu
            print_message_to_user("exit menu")
            if (last_cursor_mode == 1) then
                -- trigger back to clickable
                dispatch_action(nil, 363)
                -- reset
                last_cursor_mode = 0
            end
            current_submenu_index = submenu_id.MAIN_MENU
            menu_is_on = 0
        end
    end
end

function menu_disp_ctrl()
    if menu_is_on == 1 then
        if on_close == 0 then
            menu_disp_enable:set(1)
            temp_param_handle = get_param_handle("MENU_CENTER_"..last_submenu_index.."_ICON")
            temp_param_handle:set(0)
            temp_param_handle = get_param_handle("MENU_CENTER_"..current_submenu_index.."_ICON")
            temp_param_handle:set(1)
            for i, subsect in pairs(submenu[last_submenu_index]) do
                temp_param_handle = get_param_handle("MENU_SUB_"..current_submenu_index.."_SEC_"..i)
                temp_param_handle:set(0)
            end
            for i, subsect in pairs(submenu[current_submenu_index]) do
                temp_str = "MENU_SUB_"..current_submenu_index.."_SEC_"..i
                angle = 360 / 8 * i
                local_x = 0.95 * screen_height * math.cos(math.rad(angle));
                local_y = 0.95 * screen_height * math.sin(math.rad(angle));
                temp_param_handle = get_param_handle(temp_str.."_X")
                temp_param_handle:set(local_x)
                temp_param_handle = get_param_handle(temp_str.."_Y")
                temp_param_handle:set(local_y)
                temp_param_handle = get_param_handle(temp_str)
                temp_param_handle:set(1)
            end
            on_close = 1
        end
    else
        -- close
        if on_close == 1 then
            menu_disp_enable:set(0)
            temp_param_handle = get_param_handle("MENU_CENTER_"..current_submenu_index.."_ICON")
            temp_param_handle:set(0)
            for i, subsect in pairs(submenu[current_submenu_index]) do
                temp_param_handle = get_param_handle("MENU_SUB_"..current_submenu_index.."_SEC_"..i)
                temp_param_handle:set(0)
            end 
            on_close = 0
        end
    end
end

function update()
    menu_disp_ctrl()
end

need_to_be_closed = 0