
dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")
local HeadingUtils = dofile(LockOn_Options.script_path.."Systems/heading_utils.lua")

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
local n1rpm_power = get_param_handle("N1RPM_ENABLE")
local n1rpm_ln1 = get_param_handle("LN1_RPM_DIGITAL")
local n1rpm_rn1 = get_param_handle("RN1_RPM_DIGITAL")
local n1rpm_color = get_param_handle("N1RPM_COLOR")
local itt_power = get_param_handle("ITT_ENABLE")
local itt_l = get_param_handle("L_ITT_DIGITAL")
local itt_r = get_param_handle("R_ITT_DIGITAL")
local itt_color = get_param_handle("ITT_COLOR")

local hud_adi_movx = get_param_handle("HUD_ADI_MOVX")
local ehsi_compass = get_param_handle("COMPASS_ROLL")
local ehsi_mag_heading = get_param_handle("EHSI_HEADING")

local gps_receiver_lat = get_param_handle("GPS_REC_LAT")
local gps_receiver_lon = get_param_handle("GPS_REC_LON")
local gps_receiver_alt = get_param_handle("GPS_REC_ALT")

local temp_dbg = get_param_handle("DBG_OUT_TMP")

local sensor_data = get_base_data()
local ias_conversion_to_knots = 1.9504132
local ias_conversion_to_kmh =  1.9504132 -- easily convert to knots -- 3.6
local DEGREE_TO_RAD  = 0.0174532925199433
local RAD_TO_DEGREE  = 57.29577951308233
local METER_TO_INCH = 3.2808

local maxG_record = 1

local n1_needle_left = get_param_handle("N1_NEEDLE_LEFT")
local n1_needle_right = get_param_handle("N1_NEEDLE_RIGHT")
local N1_NEEDLE_MAX_PERCENT = 120.0

local function set_n1_needle_param(param_handle, n1_percent)
    local normalized = n1_percent / N1_NEEDLE_MAX_PERCENT
    if normalized < 0 then
        normalized = 0
    elseif normalized > 1 then
        normalized = 1
    end

    param_handle:set(normalized)
end

-- Calibrated display targets provided by user
local engine_display_calibration = {
    {speed = 0,   elev = 0,    n2 = 0, 		n1 = 0, 		itt = 0},
    {speed = 0,   elev = 0,    n2 = 20, 	n1 = 2, 		itt = 0},
    {speed = 0,   elev = 0,    n2 = 32.2, 	n1 = 12.8, 		itt = 530},
    {speed = 0,   elev = 0,    n2 = 43.5, 	n1 = 20.0, 		itt = 536},
    {speed = 0,   elev = 0,    n2 = 47.8, 	n1 = 25.2, 		itt = 388},
    {speed = 0,   elev = 0,    n2 = 67.1, 	n1 = 46.9, 		itt = 450},
    {speed = 0,   elev = 0,    n2 = 91.0, 	n1 = 96.0, 		itt = 680},
	{speed = 0,   elev = 0,    n2 = 100.0, 	n1 = 100.0, 	itt = 680},
    {speed = 210, elev = 30,   n2 = 94.3, 	n1 = 99.1, 		itt = 760},
    {speed = 400, elev = 1000, n2 = 84.0, 	n1 = 78.0, 		itt = 530},
    {speed = 520, elev = 3000, n2 = 82.0, 	n1 = 77.0, 		itt = 608},
    {speed = 465, elev = 6000, n2 = 85.0, 	n1 = 85.0, 		itt = 577},
}

local N2_SCALE = 100.0
local SPEED_SCALE = 600.0
local ELEV_SCALE = 6000.0

local function calibrated_n1(n2_value, speed_kmh, elev_m)
    local weighted_n1 = 0.0
    local weighted_total = 0.0

    for _, row in ipairs(engine_display_calibration) do
        local dn2 = (n2_value - row.n2) / N2_SCALE
        local dspd = (speed_kmh - row.speed) / SPEED_SCALE
        local delev = (elev_m - row.elev) / ELEV_SCALE
        local dist2 = dn2 * dn2 + dspd * dspd + delev * delev
        local w = 1.0 / (dist2 + 0.0001)

        weighted_n1 = weighted_n1 + row.n1 * w
        weighted_total = weighted_total + w
    end

    if weighted_total <= 0.0 then
        return n2_value
    end

    return weighted_n1 / weighted_total
end

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
dev:listen_command(Keys.R_STARTER_RELEASE)
dev:listen_command(Keys.R_STARTER_PRESS)
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
    erpm_power:set(0)
    n1rpm_power:set(0)
    itt_power:set(0)

end

cursor_v = 0
cursor_h = 0
viewang_v = 0
viewang_h = 0

local cursor_mode = get_param_handle("DEBUG_LINE3")

function SetCommand(command,value)
    if command == Keys.L_STARTER_PRESS or command == Keys.R_STARTER_PRESS then
        -- Forward the physical starter engagement to the cockpit sound device;
        -- waiting for an RPM rise makes the starter sample audibly late.
        dispatch_action(devices.SOUND_SYSTEM, command, value)
    elseif (command == 2142) then
        viewang_h = value
       -- print_message_to_user("headx:"..value)
    elseif (command == 2143) then
       -- print_message_to_user("heady:"..value)
    end
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
local show_ias = get_param_handle("IAS_TEXT")
local counter_test = 0

local is_get_mission_route = 0

function update()
    hud_adi_rot:set(sensor_data.getRoll())
    show_ias:set(1)
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
    hud_hdg_dis:set(HeadingUtils.get_corrected_magnetic_heading(sensor_data))
    hud_ln2_dis:set(sensor_data.getEngineLeftRPM() / 1.2)
    hud_rn2_dis:set(sensor_data.getEngineRightRPM() / 1.2)
   -- getMagneticHeading

    hud_nav_data_1:set("NAV UNSET")
    hud_nav_data_2:set("ETE: 00:00")
    hud_nav_data_3:set("MODE: TEST")

    local temp_hdg = HeadingUtils.get_corrected_magnetic_heading(sensor_data) / 10
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
        local speed_kmh = sensor_data.getIndicatedAirSpeed()*ias_conversion_to_kmh
        local elev_m = sensor_data.getBarometricAltitude()
        local n2_left = get_aircraft_draw_argument_value(303) * 100
        local n2_right = get_aircraft_draw_argument_value(304) * 100
        local n1_left = calibrated_n1(n2_left, speed_kmh, elev_m)
        local n1_right = calibrated_n1(n2_right, speed_kmh, elev_m)
        local itt_left = get_aircraft_draw_argument_value(305) * 1100
        local itt_right = get_aircraft_draw_argument_value(306) * 1100

        erpm_power:set(1)
        erpm_ln2:set(n2_left)
        erpm_rn2:set(n2_right)
        erpm_color:set(1)

        n1rpm_power:set(1)
        n1rpm_ln1:set(n1_left)
        n1rpm_rn1:set(n1_right)
        n1rpm_color:set(0)
        set_n1_needle_param(n1_needle_left, n1_left)
        set_n1_needle_param(n1_needle_right, n1_right)

        itt_power:set(1)
        itt_l:set(itt_left)
        itt_r:set(itt_right)
        itt_color:set(0)
    else
        erpm_power:set(0)
        erpm_ln2:set(0.0)
        erpm_rn2:set(0.0)
        erpm_color:set(1)

        n1rpm_power:set(0)
        n1rpm_ln1:set(0.0)
        n1rpm_rn1:set(0.0)
        n1rpm_color:set(0)
        set_n1_needle_param(n1_needle_left, 0.0)
        set_n1_needle_param(n1_needle_right, 0.0)

        itt_power:set(0)
        itt_l:set(0.0)
        itt_r:set(0.0)
        itt_color:set(0)
    end

    if get_elec_ac_status() then
        local deg_heading = HeadingUtils.get_corrected_magnetic_heading(sensor_data)
        ehsi_mag_heading:set(deg_heading)
        ehsi_compass:set(deg_heading)
    end

    local temp_dbg1 = get_param_handle("DBG_OUTPUT")
    local temp_dbg2 = get_param_handle("MAP_CENTER_Y")
   --print_message_to_user("maxI:"..temp_dbg1:get())
   --print_message_to_user("minI:"..temp_dbg2:get())
   --left_n1:set(sensor_data.getEngineLeftRPM())
   --print_message_to_user(left_n1:get())
   -- print_message_to_user(line1_lat:get())
   -- print_message_to_user(line1_lon:get())
end

need_to_be_closed = false

-- SK60 shared cockpit integration
dofile(LockOn_Options.script_path .. "Multicrew/runtime.lua").install(9)
