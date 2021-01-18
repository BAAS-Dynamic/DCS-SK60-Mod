dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")

local dev = GetSelf()

local update_time_step = 0.02  --每秒50次刷新
make_default_activity(update_time_step)

sensor_data = get_base_data()
local ias_conversion_to_knots = 1.9504132
local ias_conversion_to_kmh = 3.6 
local DEGREE_TO_RAD  = 0.0174532925199433
local RAD_TO_DEGREE  = 57.29577951308233
local METER_TO_INCH = 3.2808

local airspeed_ind = get_param_handle("AIR_SPEED")
local mach_ind = get_param_handle("MACH_IND")
local current_g_ind = get_param_handle("G_METER")
local aoa_ind = get_param_handle("AOA_IND")

function Airspeed_Gauge_AOA_G_Cal()
    local current_speed = 0
    local current_mach_covert = 0.36
    local current_mach = 0
    local vertical_acc = 1
    local aoa_num = -1
    local temp
    if (get_elec_primary_ac_ok() == true) then
        current_speed = sensor_data.getIndicatedAirSpeed() * ias_conversion_to_knots
        if (current_speed > 200) then
            current_mach = sensor_data.getMachNumber()
            temp = current_speed / 200
            current_mach_covert = 0.36 + (current_mach - temp)
        end
        vertical_acc = sensor_data.getVerticalAcceleration() / 9.81
        temp = sensor_data.getAngleOfAttack() * RAD_TO_DEGREE
        if (temp > 0) then
            aoa_num = 0.5 + 0.1 * math.log(temp)
        else
            aoa_num = 0.5 - 0.1 * math.log(-temp)
        end
    end
    airspeed_ind:set(current_speed/314)
    mach_ind:set(current_mach_covert)
    current_g_ind:set(vertical_acc)
    aoa_ind:set(aoa_num)
end

local radar_alt_ind = get_param_handle("RADAR_ALT_IND")
local Baro_alt_x100 = get_param_handle("BARO_ALT")
local Baro_alt_x1k = get_param_handle("BARO_x1K")
local Baro_alt_x1w = get_param_handle("BARO_x1W")
local QNH_set_x1k = get_param_handle("QNH_x1K")
local QNH_set_x100 = get_param_handle("QNH_x100")
local QNH_set_x10 = get_param_handle("QNH_x10")
local QNH_set_x1 = get_param_handle("QNH_x1")
local Baro_power = get_param_handle("BARO_POWER")

QNH_SET = 2992

function Altitude_Cal()
    local radar_altitude = -1
    local baro_altitude = 0

    local baro_x1k_target = 0
    local baro_x1w_target = 0

    local current_baro_x1k = Baro_alt_x1k:get()
    local current_baro_x1w = Baro_alt_x1w:get()

    local baro_power_status = 0

    if (get_elec_primary_ac_ok() == true) then
        radar_altitude = sensor_data.getRadarAltitude() * METER_TO_INCH
        -- print_message_to_user(radar_altitude)
        baro_altitude = sensor_data.getBarometricAltitude() * METER_TO_INCH

        baro_x1w_target = math.modf(baro_altitude/10000)
        baro_x1k_target = math.modf(math.fmod(baro_altitude,10000)/1000)
        baro_power_status = 1
    end

    Baro_alt_x100:set(math.fmod(baro_altitude,1000)/1000)

    if (radar_altitude < 100) then
        radar_alt_ind:set(radar_altitude / 450)
    elseif (radar_altitude < 200) then
        radar_alt_ind:set((radar_altitude - 100) * 0.0012 + 0.22)
    elseif (radar_altitude < 400) then
        radar_alt_ind:set((radar_altitude - 200) * 0.0007 + 0.34)
    elseif (radar_altitude < 500) then
        radar_alt_ind:set((radar_altitude - 400) * 0,0002 + 0.48)
    elseif (radar_altitude < 1000) then
        radar_alt_ind:set((radar_altitude - 500) * 0.0003 + 0.5) --0.65
    elseif (radar_altitude < 2000) then
        radar_alt_ind:set((radar_altitude - 1000) * 0.00015 + 0.65) --0.8
    elseif (radar_altitude < 5000) then
        radar_alt_ind:set((radar_altitude - 2000) * 0.0000667 + 0.8)
    end

    local baro_altitude_set_temp = QNH_SET

    if (baro_x1k_target > current_baro_x1k) then
        current_baro_x1k = current_baro_x1k + 0.1
    elseif (baro_x1k_target < current_baro_x1k) then
        current_baro_x1k = current_baro_x1k - 0.1
    end

    if (baro_x1w_target > current_baro_x1w) then
        current_baro_x1w = current_baro_x1w + 0.1
    elseif (baro_x1k_target < current_baro_x1k) then
        current_baro_x1w = current_baro_x1w - 0.1
    end

    Baro_alt_x1k:set(current_baro_x1k/10)
    Baro_alt_x1w:set(current_baro_x1w/10)

    Baro_power:set(baro_power_status)

    for i = 1, 4, 1 do
        QNH_set_x1k:set(math.modf(baro_altitude_set_temp/1000)/10)
        baro_altitude_set_temp = math.fmod(baro_altitude_set_temp,1000)
        QNH_set_x100:set(math.modf(baro_altitude_set_temp/100)/10)
        baro_altitude_set_temp = math.fmod(baro_altitude_set_temp,100)
        QNH_set_x10:set(math.modf(baro_altitude_set_temp/10)/10)
        baro_altitude_set_temp = math.fmod(baro_altitude_set_temp,10)
        QNH_set_x1:set(baro_altitude_set_temp/10)
    end
end

local gyro_roll = get_param_handle("GYRO_ROLL")
local gyro_pitch= get_param_handle("GYRO_PITCH")

function update_Gyro_Display()
    if (get_elec_primary_ac_ok() == true) then
        gyro_roll:set(-sensor_data.getRoll() * RAD_TO_DEGREE / 90 )
        gyro_pitch:set(sensor_data.getPitch() * RAD_TO_DEGREE / 90)
    else
        gyro_roll:set(-0.3)
        gyro_pitch:set(0.3)
    end
end

local climb_rate_ind = get_param_handle("CLIMB_RATE")
local slide_rate_ind = get_param_handle("SLIDE_IND")

function calculate_Climb_Slide()
    if (get_elec_primary_ac_ok() == true) then
        local climb_rate = sensor_data.getVerticalVelocity() / 40
        local slide_rate = sensor_data.getRateOfYaw() * RAD_TO_DEGREE / 90
        climb_rate_ind:set(climb_rate)
        slide_rate_ind:set(slide_rate)
        -- print_message_to_user(climb_rate..slide_rate)
    else
        climb_rate_ind:set(0)
        slide_rate_ind:set(0)
    end
end

local HSI_compass_ind = get_param_handle("HSI_COMPASS")

function update_HSI_Compass()
    local current_magnitude_heading = sensor_data.getMagneticHeading() * RAD_TO_DEGREE
    local temp = 0
    if (get_elec_primary_ac_ok() == true) then
        if (current_magnitude_heading > 180) then
            temp = 0.5 - (360 - current_magnitude_heading) / 180 / 2
        else
            temp = 0.5 +  current_magnitude_heading / 180 / 2
        end
    end
    HSI_compass_ind:set(temp)
end

function post_initialize()
    Baro_alt_x1k:set(0)
    Baro_alt_x1w:set(0)
end

function update()
    Altitude_Cal()
    Airspeed_Gauge_AOA_G_Cal()
    update_Gyro_Display()
    calculate_Climb_Slide()
    update_HSI_Compass()
end

need_to_be_closed = false