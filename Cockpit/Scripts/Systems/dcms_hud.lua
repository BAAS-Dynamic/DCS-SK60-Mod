
dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")

local dev 	    = GetSelf()

local update_time_step = 0.02
make_default_activity(update_time_step)

local hud_warning = get_param_handle("WARNING_FLASH")
local hud_danger = get_param_handle("DANGER_FLASH")
local hud_denied = get_param_handle("WARNING_FLASH")
--local hud_enable = get_param_handle("LEADI_DIS_ENABLE")
local hud_adi_level_enable = get_param_handle("ADI_LINE_GROUP")
local hud_adi_rot = get_param_handle("HUD_ADI_ROT")
local hud_adi_pitch = get_param_handle("HUD_ADI_MOVY")
local hud_FD_x = get_param_handle("HUD_FD_X")
local hud_FD_y = get_param_handle("HUD_FD_Y")
local hud_speed_dis = get_param_handle("HUD_SPEED_DIS")
local hud_alt_dis = get_param_handle("HUD_ALT_DIS")
local hud_ralt_dis = get_param_handle("HUD_RALT_DIS")
local hud_g_dis = get_param_handle("HUD_G_DIS")
local hud_aoa_dis = get_param_handle("HUD_AOA_DIS")
local hud_mach_dis = get_param_handle("HUD_MACH_DIS")
local hud_ln2_dis = get_param_handle("HUD_LN2_DIS")
local hud_rn2_dis = get_param_handle("HUD_RN2_DIS")
local hud_maxg_dis = get_param_handle("HUD_GM_DIS")
local hud_hdg_dis = get_param_handle("HUD_HDG_DIS")
local hud_hdg_mov = get_param_handle("HUD_HDG_MOV")
local hud_nav_data_1 = get_param_handle("HUD_NAV_DATA_1_DIS")
local hud_nav_data_2 = get_param_handle("HUD_NAV_DATA_2_DIS")
local hud_nav_data_3 = get_param_handle("HUD_NAV_DATA_3_DIS")

--local eadi_lf1_display = get_param_handle("L_EADI_DISPLAY_TL1")
--local eadi_rf1_display = get_param_handle("L_EADI_DISPLAY_TR1")
--local eadi_lf2_display = get_param_handle("L_EADI_DISPLAY_TL2")
--local eadi_rb1_display = get_param_handle("L_EADI_DISPLAY_BR1")

local erpm_power = get_param_handle("ERPM_ENABLE")
local erpm_ln2 = get_param_handle("LRPM_N2_DIGTAL")
local erpm_rn2 = get_param_handle("RRPM_N2_DIGTAL")
local erpm_color = get_param_handle("RPM_COLOR")

--local gps_base = get_param_handle("NS430_POWER")

local hud_adi_movx = get_param_handle("HUD_ADI_MOVX")

local ehsi_enable = get_param_handle("EHSI_DIS_ENABLE")
local ehsi_full_compass_enable = get_param_handle("COMPASS_FULL_ENABLE")
local ehsi_compass = get_param_handle("COMPASS_ROLL")
-- local nav_mode = get_param_handle("ACTIVE_NAV_MOD")
local ehsi_mag_heading = get_param_handle("EHSI_HEADING")
local ehsi_course_heading = get_param_handle("EHSI_COURSE")

local gps_receiver_lat = get_param_handle("GPS_REC_LAT")
local gps_receiver_lon = get_param_handle("GPS_REC_LON")
local gps_receiver_alt = get_param_handle("GPS_REC_ALT")

--NS430 Page Test
--local ns430_logo_page = get_param_handle("NAVU_PAGE1_ENABLE")
--local ns430_info_page = get_param_handle("NAVU_PAGE2_ENABLE")
--local ns430_base_page = get_param_handle("NAVU_BASE_ENABLE")
local temp_dbg = get_param_handle("DBG_OUT_TMP")

local sensor_data = get_base_data()
local ias_conversion_to_knots = 1.9504132
local ias_conversion_to_kmh =  1.9504132 -- easily convert to knots -- 3.6 
local DEGREE_TO_RAD  = 0.0174532925199433
local RAD_TO_DEGREE  = 57.29577951308233
local METER_TO_INCH = 3.2808

local maxG_record = 1

dev:listen_command(Keys.COM_Freq_Swap)
dev:listen_command(Keys.LOC_Freq_Swap)
dev:listen_command(Keys.Freq_Degi)
dev:listen_command(Keys.Freq_Num)
dev:listen_command(Keys.Freq_Knob_Push)
dev:listen_command(Keys.Nav_Map_range_increse)
dev:listen_command(Keys.Nav_Map_range_decrease)
dev:listen_command(Keys.Nav_Direct_to)
dev:listen_command(Keys.Nav_Menu)
dev:listen_command(Keys.Nav_Clear)
dev:listen_command(Keys.Nav_Ent)
dev:listen_command(Keys.Nav_CDI)
dev:listen_command(Keys.Nav_OBS)
dev:listen_command(Keys.Nav_MSG)
dev:listen_command(Keys.Nav_FPL)
dev:listen_command(Keys.Nav_PROC)
dev:listen_command(Keys.L_STARTER_RELEASE)
dev:listen_command(Keys.L_STARTER_PRESS)
dev:listen_command(Keys.Nav_Right_Knob_Push)

-- iCommandPlaneViewVertical 2008
-- iCommandPlaneViewHorizontal 2007
dev:listen_command(2143)-- iService
dev:listen_command(2142)-- 2143
-- iCommandCockpitClickModeOnOff	363
dev:listen_command(Keys.Custom_Menu)
dev:listen_command(363)-- 2143

local pos_x_loc, pos_y_loc, alt, coord

function post_initialize()
    hud_FD_x:set(0)
    hud_FD_y:set(0)
    hud_adi_level_enable:set(1)
    --hud_enable:set(1)
    hud_maxg_dis:set(1)
    --gps_base:set(1)
    erpm_power:set(0)

end

NS430_Test_Status = 0;

cursor_v = 0
cursor_h = 0
viewang_v = 0
viewang_h = 0

local cursor_mode = get_param_handle("DEBUG_LINE3")

function SetCommand(command,value)
    -- print_message_to_user(command)
    --[[
    if (command == 9100) then
        cursor_h = value
        print_message_to_user("9100")
    elseif (command == 2037) then
        cursor_v = value
        print_message_to_user("received")
    elseif (command == 2142) then
        viewang_h = value
    elseif (command == 2143) then
        viewang_v = value
    end
    elseif (command == Keys.Custom_Menu) then
        -- ask the click mode to off
        print_message_to_user("menu triggered")
        if (debug_line3:get() < 1) then
            -- cursor mode is clickable
            dispatch_action(nil, 363)
        end
        -- close click mode [should be in transpose mode now]
        -- force close transpose mode
        dispatch_action(nil, 1594)
        -- dispatch_action(nil, iCommandMouseViewOn, 1)
    end
    -- 
    ]]--
end

local testParam = get_param_handle("TEST_TEXTURE_STATE")
local counter_test = 0

local is_get_mission_route = 0

function update()
    --gps_base:set(1)
    hud_adi_rot:set(sensor_data.getRoll())
    hud_adi_pitch:set(-sensor_data.getPitch())
    hud_speed_dis:set(sensor_data.getIndicatedAirSpeed()*ias_conversion_to_kmh)
    hud_alt_dis:set(sensor_data.getBarometricAltitude())
    hud_aoa_dis:set(sensor_data.getAngleOfAttack() * RAD_TO_DEGREE)
    hud_g_dis:set(sensor_data.getVerticalAcceleration())
    local temp_G = sensor_data.getVerticalAcceleration()
    hud_ralt_dis:set(sensor_data.getRadarAltitude)
    if (temp_G > maxG_record) then
        maxG_record = temp_G
        hud_maxg_dis:set(maxG_record)
    end
    hud_mach_dis:set(sensor_data.getMachNumber())
    hud_hdg_dis:set(sensor_data.getMagneticHeading() * RAD_TO_DEGREE)
    hud_ln2_dis:set(sensor_data.getEngineLeftRPM() / 1.2)
    hud_rn2_dis:set(sensor_data.getEngineRightRPM() / 1.2)
    -- getMagneticHeading

    hud_nav_data_1:set("NAV UNSET")
    hud_nav_data_2:set("ETE: 00:00")
    hud_nav_data_3:set("MODE: TEST")
    
    local temp_hdg = sensor_data.getMagneticHeading() * RAD_TO_DEGREE / 10
    if temp_hdg > 18 then
        temp_hdg = 36 - temp_hdg
        hud_hdg_mov:set(temp_hdg)
    elseif temp_hdg <= 18 then
        hud_hdg_mov:set(-temp_hdg)
    end

    -- Set the flight path vector cursor
    local current_aoa = sensor_data.getAngleOfAttack()
    local current_aos = sensor_data.getAngleOfSlide()
    hud_adi_movx:set(current_aos)
    hud_FD_y:set(current_aoa)
    --eadi_lf1_display:set("VERSION 2")
    --eadi_lf2_display:set("EADI OK")
    --eadi_rf1_display:set(sensor_data.getMachNumber())
    --eadi_rb1_display:set("ERECT")

    -- debug
    local roll_rate = sensor_data.getRateOfRoll()
    --temp_dbg:set(roll_rate * RAD_TO_DEGREE)

    if get_elec_dc_status() then
        erpm_power:set(1)
        erpm_ln2:set(sensor_data.getEngineLeftRPM() * 100 / 1.2)
        erpm_rn2:set(sensor_data.getEngineRightRPM() * 100 / 1.2)
        erpm_color:set(1)
    else
        erpm_power:set(0)
        erpm_ln2:set(0.0)
        erpm_rn2:set(0.0)
        erpm_color:set(1)
    end

    if get_elec_ac_status() then
        local deg_heading = sensor_data.getMagneticHeading() * RAD_TO_DEGREE
        if deg_heading < 0 then
            deg_heading = deg_heading + 360
        elseif deg_heading > 360 then
            deg_heading = deg_heading - 360
        end
        ehsi_mag_heading:set(deg_heading)
        ehsi_compass:set(deg_heading)
    end

    local temp_dbg1 = get_param_handle("AIRPORT_LON_0")
    local temp_dbg2 = get_param_handle("MAP_CENTER_Y")
    --print_message_to_user(temp_dbg:get())
    --print_message_to_user("maxI:"..temp_dbg1:get())
    --print_message_to_user("minI:"..temp_dbg2:get())
    --left_n1:set(sensor_data.getEngineLeftRPM())
    --print_message_to_user(left_n1:get())
    --ehsi_enable:set(1)
    --ehsi_full_compass_enable:set(1)
    --ehsi_course_heading:set(0 * RAD_TO_DEGREE)
    --nav_mode:set(1)
    --[[
    if (NS430_Test_Status == 0) then
        ns430_logo_page:set(1)
        ns430_info_page:set(0)
        ns430_base_page:set(0)
    elseif (NS430_Test_Status == 1) then
        ns430_logo_page:set(0)
        ns430_info_page:set(1)
        ns430_base_page:set(0)
    else
        ns430_logo_page:set(0)
        ns430_info_page:set(0)
        ns430_base_page:set(1)
    end
    ]]

end

need_to_be_closed = false