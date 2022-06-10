dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")
dofile(LockOn_Options.script_path.."debug_util.lua")
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


local cursor_mode = get_param_handle("DEBUG_LINE3")
local menu_disp_enable = get_param_handle("MENU_DISP_ENABLE")
local current_menu_hint = get_param_handle("MENU_CENTER_STR")
local general_menu_hint = get_param_handle("MENU_STR_TRI")

local debug_line1 = get_param_handle("DEBUG_LINE1")
local debug_line2 = get_param_handle("DEBUG_LINE2")

local cursor_disp = get_param_handle("MENU_CURSOR")
local cursor_disp_x = get_param_handle("MENU_CURSOR_X")
local cursor_disp_y = get_param_handle("MENU_CURSOR_Y")

viewang_v = 0
viewang_h = 0
-- record the view angle when start trigger menu
viewangle_offset_v = 0
viewangle_offset_h = 0

angle_v = 0
angle_h = 0

menu_is_on = 0
last_cursor_mode = 0
on_close = 0

locate_input_target = -1
last_target_seletion = -1

current_submenu_index = submenu_id.MAIN_MENU
last_submenu_index = submenu_id.MAIN_MENU
screen_height = LockOn_Options.screen.height * 0.5
--            1, 2, 3, 4, 5, 6, 7
disp_table = {0, 1, 7, 2, 6, 3, 5}
--              0, 1, 2, 3, 4, 5, 6, 7
disp_reverse = {1, 2, 4, 6, 8, 7, 5, 3}
disp_reverse_available = {0, 0, 0, 0, 0, 0, 0, 0}
parent_menu_id = {}

dev:listen_command(2142)-- iServiceInformAboutUserHAngle
dev:listen_command(2143)-- iServiceInformAboutUserVAngle
-- iCommandCockpitClickModeOnOff	363
dev:listen_command(Keys.Custom_Menu)
dev:listen_command(363)-- 2143
dev:listen_command(Keys.Custom_Menu_Enter)

function post_initialize()
    current_submenu_index = submenu_id.MAIN_MENU
    last_submenu_index = submenu_id.MAIN_MENU
    current_menu_hint:set(submenu[current_submenu_index][0][1])
    general_menu_hint:set(submenu[current_submenu_index][0][1])
    for i = 1,8,1 do
        temp_str = "MENU_ON_SEL_"..i
        angle = 360 / 8 * (i-1)
        local_x = 0.7 * screen_height * math.cos(math.rad(angle));
        local_y = 0.7 * screen_height * math.sin(math.rad(angle));
        temp_handle = get_param_handle(temp_str.."_X")
        temp_handle:set(local_x)
        temp_handle = get_param_handle(temp_str.."_Y")
        temp_handle:set(local_y)
    end
    -- temp_handle:set(1)
end

function SetCommand(command,value)
    if (command == 2142) then
        viewang_h = value
    elseif (command == 2143) then
        viewang_v = value
    elseif (command == Keys.Custom_Menu) then
        if (menu_is_on == 0) then
            -- ask the click mode to off
            dprintf("menu triggered")
            if (cursor_mode:get() < 1) then
                -- cursor mode is clickable
                dispatch_action(nil, 363)
                last_cursor_mode = 1
            end
            viewangle_offset_v = viewang_v
            viewangle_offset_h = viewang_h
            current_submenu_index = submenu_id.MAIN_MENU
            menu_is_on = 1
            -- force close transpose mode
            dispatch_action(nil, 1594) 
        else
            -- close menu
            dprintf("exit menu")
            if (last_cursor_mode == 1) then
                -- trigger back to clickable
                dispatch_action(nil, 363)
                -- reset
                last_cursor_mode = 0
            end
            menu_is_on = 0
            menu_disp_ctrl()
            current_submenu_index = submenu_id.MAIN_MENU
        end
    elseif (command == Keys.Custom_Menu_Enter) then
        if menu_is_on == 1 then
            activate_selection()
        end
    end
end

function menu_disp_ctrl()
    if menu_is_on == 1 then
        cursor_disp_x:set(-angle_h / 30 * screen_height)
        cursor_disp_y:set(angle_v / 30 * screen_height)
        if on_close == 0 then
            cursor_disp:set(1)
            menu_disp_enable:set(1)
            temp_param_handle = get_param_handle("MENU_CENTER_"..last_submenu_index.."_ICON")
            temp_param_handle:set(0)
            temp_param_handle = get_param_handle("MENU_CENTER_"..current_submenu_index.."_ICON")
            temp_param_handle:set(1)
            for i, subsect in pairs(submenu[last_submenu_index]) do
                temp_param_handle = get_param_handle("MENU_SUB_"..last_submenu_index.."_SEC_"..i)
                temp_param_handle:set(0)
            end
            disp_reverse_available = {0, 0, 0, 0, 0, 0, 0, 0}
            for i, subsect in pairs(submenu[current_submenu_index]) do
                if (i > 0 and i < 8) then
                    temp_str = "MENU_SUB_"..current_submenu_index.."_SEC_"..i
                    disp_reverse_available[disp_table[i]+1] = 1
                    angle = 360 / 8 * disp_table[i]
                    local_x = 0.95 * screen_height * math.cos(math.rad(angle));
                    local_y = 0.95 * screen_height * math.sin(math.rad(angle));
                    temp_param_handle = get_param_handle(temp_str.."_X")
                    temp_param_handle:set(local_x)
                    temp_param_handle = get_param_handle(temp_str.."_Y")
                    temp_param_handle:set(local_y)
                    temp_param_handle = get_param_handle(temp_str)
                    temp_param_handle:set(1)
                end
            end
            local_x = - 0.95 * screen_height
            local_y = 0;
            temp_param_handle = get_param_handle("MENU_SEC_RETURN_X")
            temp_param_handle:set(local_x)
            temp_param_handle = get_param_handle("MENU_SEC_RETURN_Y")
            temp_param_handle:set(local_y)
            if (current_submenu_index ~= submenu_id.MAIN_MENU) then
                temp_param_handle = get_param_handle("MENU_SEC_RETURN")
                disp_reverse_available[5] = 1
                temp_param_handle:set(1)
            else
                temp_param_handle = get_param_handle("MENU_SEC_RETURN")
                temp_param_handle:set(0)
            end
            -- high light the selection
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
            temp_param_handle = get_param_handle("MENU_SEC_RETURN")
            temp_param_handle:set(0)
            temp_str = "MENU_ON_SEL_"
            temp_handle = get_param_handle(temp_str..locate_input_target)
            temp_handle:set(0)
            locate_input_target = -1
            last_target_seletion = -1
            on_close = 0
            cursor_disp:set(0)
        end
    end
end

function check_input_target()
    if menu_is_on == 1 then
        -- locate the position when is enabled
        angle_v = viewang_v - viewangle_offset_v
        angle_h = viewang_h - viewangle_offset_h
        if (math.abs(angle_v) > 2 or math.abs(angle_h) > 2) then
            -- out of dead zone
            local temp_current_sel = locate_input_target
            local target_deg = math.deg(math.atan2(angle_h, angle_v)) + 90
            -- debug_line2:set("X: "..angle_h..", Y: "..angle_v.."; ANG: "..target_deg)
            if target_deg < -180 then
                target_deg = target_deg + 360
            elseif target_deg > 180 then
                target_deg = target_deg - 360
            end
            if (target_deg < -157.5) then
                locate_input_target = 4
            elseif (target_deg < -112.5) then
                locate_input_target = 5
            elseif (target_deg < -67.5) then
                locate_input_target = 6
            elseif (target_deg < -22.5) then
                locate_input_target = 7
            elseif (target_deg < 22.5) then
                locate_input_target = 0
            elseif (target_deg < 67.5) then
                locate_input_target = 1
            elseif (target_deg < 112.5) then
                locate_input_target = 2
            elseif (target_deg < 157.5) then
                locate_input_target = 3
            else
                locate_input_target = 4
            end
            locate_input_target = locate_input_target + 1
            if disp_reverse_available[locate_input_target] == 0 then
                locate_input_target = -1
                temp_str = "MENU_ON_SEL_"
                temp_handle = get_param_handle(temp_str..tostring(temp_current_sel))
                temp_handle:set(0)
            elseif locate_input_target ~= temp_current_sel then
                temp_str = "MENU_ON_SEL_"
                temp_handle = get_param_handle(temp_str..tostring(temp_current_sel))
                temp_handle:set(0)
                temp_handle = get_param_handle(temp_str..tostring(locate_input_target))
                temp_handle:set(1)
                last_target_seletion = temp_current_sel
            end
            -- print_message_to_user("current target is "..tostring(locate_input_target))
        else
            locate_input_target = -1
        end
    end
end

function activate_selection()
    local target_menu_id
    local target_action_id
    if (locate_input_target ~= -1 and  locate_input_target > 0 and locate_input_target < 9) then
        -- has seleted an result
        target_id = disp_reverse[locate_input_target]
        if locate_input_target == 5 then
            -- this is the exit to pervious menu
            if current_submenu_index == submenu_id.MAIN_MENU then
                -- do nothing
            else
                -- go back to pervious
                last_submenu_index = current_submenu_index
                current_submenu_index = parent_menu_id[last_submenu_index]
                -- reset render symbol
                on_close = 0
            end
        elseif submenu[current_submenu_index][target_id] == nil then
            -- do nothing
        elseif submenu[current_submenu_index][target_id][3] == MENU_ENTRY then
            -- this is a menu entry
            -- print_message_to_user("active to entry: "..submenu[current_submenu_index][target_id][4])
            last_submenu_index = current_submenu_index
            current_submenu_index = submenu[current_submenu_index][target_id][4]
            parent_menu_id[current_submenu_index] = last_submenu_index
            -- reset render symbol
            on_close = 0
        elseif submenu[current_submenu_index][target_id][3] > 0 then
            -- this is a command
            dispatch_action(nil, submenu[current_submenu_index][target_id][3], submenu[current_submenu_index][target_id][5])
            if submenu[current_submenu_index][target_id][4] == EXIT_AFTER_ACT then
                -- close the menu
                dispatch_action(nil, Keys.Custom_Menu, nil)
            end
        end
    end
end

function update()
    debug_line1:set("HORI HEAD: " ..string.format("%.2f", viewang_h).. "; VERT HEAD: "..string.format("%.2f", viewang_v))
    -- debug_line1:set("")
    debug_line2:set("")
    menu_disp_ctrl()
    check_input_target()
end

need_to_be_closed = 0