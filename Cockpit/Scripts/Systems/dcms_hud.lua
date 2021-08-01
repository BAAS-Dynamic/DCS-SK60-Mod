
dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")

local dev 	    = GetSelf()

local update_time_step = 0.02
make_default_activity(update_time_step)

local hud_warning = get_param_handle("WARNING_FLASH")
local hud_danger = get_param_handle("DANGER_FLASH")
local hud_denied = get_param_handle("WARNING_FLASH")
local hud_enable = get_param_handle("LEADI_DIS_ENABLE")
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

local eadi_lf1_display = get_param_handle("L_EADI_DISPLAY_TL1")
local eadi_rf1_display = get_param_handle("L_EADI_DISPLAY_TR1")
local eadi_lf2_display = get_param_handle("L_EADI_DISPLAY_TL2")
local eadi_rb1_display = get_param_handle("L_EADI_DISPLAY_BR1")

local ealt_enable = get_param_handle("EALT_DIS_ENABLE")
local ealt_unit_baro = get_param_handle("ALT_BARO_UNIT_DIGTAL")
local ealt_unit = get_param_handle("ALT_UNIT_DIGTAL")
local ealt_baro_correct = get_param_handle("ALT_BARO_DIGTAL")
local ealt_x1000_obj = get_param_handle("ALT_XK_DIGTAL")
local ealt_x100_obj = get_param_handle("ALT_XH_DIGTAL")

local erpm_ln2 = get_param_handle("LRPM_N2_DIGTAL")
local erpm_rn2 = get_param_handle("RRPM_N2_DIGTAL")

local gps_base = get_param_handle("NS430_POWER")

local hud_adi_movx = get_param_handle("HUD_ADI_MOVX")

local ehsi_enable = get_param_handle("EHSI_DIS_ENABLE")
local ehsi_full_compass_enable = get_param_handle("COMPASS_FULL_ENABLE")
local ehsi_compass = get_param_handle("COMPASS_ROLL")

local sensor_data = get_base_data()
local ias_conversion_to_knots = 1.9504132
local ias_conversion_to_kmh =  1.9504132 -- easily convert to knots -- 3.6 
local DEGREE_TO_RAD  = 0.0174532925199433
local RAD_TO_DEGREE  = 57.29577951308233
local METER_TO_INCH = 3.2808

local maxG_record = 1

function post_initialize()
    hud_FD_x:set(0)
    hud_FD_y:set(0)
    hud_adi_level_enable:set(1)
    hud_enable:set(1)
    hud_maxg_dis:set(1)
    gps_base:set(1)
end

function SetCommand(command,value)

end

function update()
    gps_base:set(1)
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
    eadi_lf1_display:set("VERSION 2")
    eadi_lf2_display:set("EADI OK")
    eadi_rf1_display:set(sensor_data.getMachNumber())
    eadi_rb1_display:set("ERECT")

    erpm_ln2:set(sensor_data.getEngineLeftRPM() * 100 / 1.2)
    erpm_rn2:set(sensor_data.getEngineRightRPM() * 100 / 1.2)

    -- altimeter calculator
    local baro_altitude = sensor_data.getBarometricAltitude() * 3.28084
    local baro_x1k = math.modf(baro_altitude/1000)
    local baro_x100 = math.fmod(baro_altitude,1000)

    ealt_enable:set(1)
    ealt_unit:set("FT")
    ealt_unit_baro:set("HPA")
    ealt_baro_correct:set(1013)
    ealt_x100_obj:set(baro_x100)
    if baro_x1k == 0 then
        if baro_x100 < 0 then
            baro_x1k = "-0"
        else
            baro_x1k = "0"
        end
    end
    ealt_x1000_obj:set(baro_x1k)

    ehsi_enable:set(1)
    ehsi_full_compass_enable:set(1)
    ehsi_compass:set(sensor_data.sensor_data.getMagneticHeading() * RAD_TO_DEGREE)
end