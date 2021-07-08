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

gauge_count = 0
function _gauge_counter()
    gauge_count = gauge_count + 1
    return gauge_count
end

local airspeed_ind = _gauge_counter()
local mach_ind = _gauge_counter()
local current_g_ind = _gauge_counter()
local aoa_ind = _gauge_counter()
local radar_alt_ind = _gauge_counter()
local Baro_alt_x10 = _gauge_counter()
local Baro_alt_x100 = _gauge_counter()
local Baro_alt_x1k = _gauge_counter()
local Baro_alt_x1w = _gauge_counter()
local QNH_set_x1k = _gauge_counter()
local QNH_set_x100 = _gauge_counter()
local QNH_set_x10 = _gauge_counter()
local QNH_set_x1 = _gauge_counter()
local Baro_power = _gauge_counter()
local gyro_roll = _gauge_counter()
local gyro_pitch= _gauge_counter()
local climb_rate_ind = _gauge_counter()
local slide_rate_ind = _gauge_counter()
local HSI_compass_ind = _gauge_counter()

Gauge_display_state = { -- last parameter define if it is unneed from 9 to zero
    {airspeed_ind, 0, 0, get_param_handle("AIR_SPEED"), 1, 0.04},
    {mach_ind, 0, 0, get_param_handle("MACH_IND"), 1, 0.04},
    {current_g_ind, 0, 0, get_param_handle("G_METER"), 1, 0.04},
    {aoa_ind, 0, 0, get_param_handle("AOA_IND"), 1, 0.04},
    {radar_alt_ind, 0, 0, get_param_handle("RADAR_ALT_IND"), 1, 0.04},
    {Baro_alt_x10, 0, 0, get_param_handle("BARO_ALT"), 0, 0.04},
    {Baro_alt_x100, 0, 0, get_param_handle("BARO_x1H"), 0, 0.04},
    {Baro_alt_x1k, 0, 0, get_param_handle("BARO_x1K"), 0, 0.005},
    {Baro_alt_x1w, 0, 0, get_param_handle("BARO_x1W"), 0, 0.005},
    {QNH_set_x1k, 0, 0, get_param_handle("QNH_x1K"), 0, 0.005},
    {QNH_set_x100, 0, 0, get_param_handle("QNH_x100"), 0, 0.005},
    {QNH_set_x10, 0, 0, get_param_handle("QNH_x10"), 0, 0.005},
    {QNH_set_x1, 0, 0, get_param_handle("QNH_x1"), 0, 0.005},
    {Baro_power, 0, 0, get_param_handle("BARO_POWER"), 1, 0.005},
    {gyro_roll, 0, 0, get_param_handle("GYRO_ROLL"), 2, 0.04},
    {gyro_pitch, 0, 0, get_param_handle("GYRO_PITCH"), 2, 0.04},
    {climb_rate_ind, 0, 0, get_param_handle("CLIMB_RATE"), 1, 0.04},
    {slide_rate_ind, 0, 0, get_param_handle("SLIDE_IND"), 1, 0.04},
    {HSI_compass_ind, 0, 0, get_param_handle("HSI_COMPASS"), 2, 0.04},
}

function Airspeed_Gauge_AOA_G_Cal()
    local current_speed = 0
    local vertical_acc = 1
    if (get_elec_primary_ac_ok() == true) then
        current_speed = sensor_data.getIndicatedAirSpeed() * ias_conversion_to_kmh
        vertical_acc = sensor_data.getVerticalAcceleration()
    end
    if current_speed < 600 then
        Gauge_display_state[airspeed_ind][2] = (current_speed / 600) * 0.635
    elseif current_speed < 1200 then
        Gauge_display_state[airspeed_ind][2] = ((current_speed - 600) / 600) * 0.315 + 0.635
    else
        Gauge_display_state[airspeed_ind][2] = 0.95
    end
    if vertical_acc > 0 then
        Gauge_display_state[current_g_ind][2] = vertical_acc/8
    else
        Gauge_display_state[current_g_ind][2] = vertical_acc/3
    end
end

function Altitude_Cal()
    local baro_altitude = 0

    local baro_x1k_target = 0
    local baro_x1w_target = 0

    local baro_x100_target = 0

    if (get_elec_primary_ac_ok() == true) then
        -- print_message_to_user(radar_altitude)
        baro_altitude = sensor_data.getBarometricAltitude() * METER_TO_INCH

        baro_x1w_target = math.modf(baro_altitude/10000)
        baro_x1k_target = math.modf(math.fmod(baro_altitude,10000)/1000)
        -- baro_x100_target = math.modf(math.fmod(baro_altitude, 1000)/100)
    end

    Gauge_display_state[Baro_alt_x1k][2] = baro_x1k_target/10
    Gauge_display_state[Baro_alt_x1w][2] = baro_x1w_target/10
    Gauge_display_state[Baro_alt_x100][2] = math.fmod(baro_altitude, 1000)/100 / 10-- baro_x100_target/10
    Gauge_display_state[Baro_alt_x10][2] = math.fmod(baro_altitude, 1000)/100 / 10-- math.fmod(baro_altitude,100)/100
end

function update_Gyro_Display()
    if (get_elec_primary_ac_ok() == true) then
        Gauge_display_state[gyro_roll][2] = sensor_data.getRoll() * RAD_TO_DEGREE / 90 / 2
        Gauge_display_state[gyro_pitch][2] = - sensor_data.getPitch() * RAD_TO_DEGREE / 90
    else
        Gauge_display_state[gyro_roll][2] = -0.3
        Gauge_display_state[gyro_pitch][2] = 0.3
    end
end

function calculate_Climb_Slide()
    if (get_elec_primary_ac_ok() == true) then
        local climb_rate = sensor_data.getVerticalVelocity() / 40
        local slide_rate = sensor_data.getRateOfYaw() * RAD_TO_DEGREE / 90
        Gauge_display_state[climb_rate_ind][2] = climb_rate
        Gauge_display_state[slide_rate_ind][2] = slide_rate
    else
        Gauge_display_state[climb_rate_ind][2] = 0
        Gauge_display_state[slide_rate_ind][2] = 0
    end
end

function update_HSI_Compass()
    local current_magnitude_heading = sensor_data.getMagneticHeading() * RAD_TO_DEGREE
    local temp = 0
    if (get_elec_primary_ac_ok() == true) then
        if (current_magnitude_heading > 180) then
            temp = - (360 - current_magnitude_heading) / 180
        else
            temp = current_magnitude_heading / 180
        end
    end
    Gauge_display_state[HSI_compass_ind][2] = - temp
end

function post_initialize()

end

function update_Gauge_Display()
    for k_G,v_G in pairs(Gauge_display_state) do
        if math.abs(Gauge_display_state[k_G][2] - Gauge_display_state[k_G][3]) < Gauge_display_state[k_G][6] then
            Gauge_display_state[k_G][3] = Gauge_display_state[k_G][2]
        elseif Gauge_display_state[k_G][5] == 1 then
            if Gauge_display_state[k_G][2] < Gauge_display_state[k_G][3] then
                Gauge_display_state[k_G][3] = Gauge_display_state[k_G][3] - Gauge_display_state[k_G][6]
            elseif Gauge_display_state[k_G][2] > Gauge_display_state[k_G][3] then
                Gauge_display_state[k_G][3] = Gauge_display_state[k_G][3] + Gauge_display_state[k_G][6]
            end
        elseif Gauge_display_state[k_G][5] == 2 then
            if Gauge_display_state[k_G][3] > 0.85 and Gauge_display_state[k_G][2] < - 0.85 then
                Gauge_display_state[k_G][3] = Gauge_display_state[k_G][3] + Gauge_display_state[k_G][6]
                if Gauge_display_state[k_G][3] > 1 then
                    Gauge_display_state[k_G][3] = Gauge_display_state[k_G][3] - 2
                end
            elseif Gauge_display_state[k_G][3] < -0.85 and Gauge_display_state[k_G][2] > 0.85 then
                Gauge_display_state[k_G][3] = Gauge_display_state[k_G][3] - Gauge_display_state[k_G][6]
                if Gauge_display_state[k_G][3] < 0 then
                    Gauge_display_state[k_G][3] = Gauge_display_state[k_G][3] + 2
                end
            else
                if Gauge_display_state[k_G][2] < Gauge_display_state[k_G][3] then
                    Gauge_display_state[k_G][3] = Gauge_display_state[k_G][3] - Gauge_display_state[k_G][6]
                elseif Gauge_display_state[k_G][2] > Gauge_display_state[k_G][3] then
                    Gauge_display_state[k_G][3] = Gauge_display_state[k_G][3] + Gauge_display_state[k_G][6]
                end
            end
        elseif Gauge_display_state[k_G][3] > 0.85 and Gauge_display_state[k_G][2] < 0.15 then
            Gauge_display_state[k_G][3] = Gauge_display_state[k_G][3] + Gauge_display_state[k_G][6]
            if Gauge_display_state[k_G][3] > 1 then
                Gauge_display_state[k_G][3] = Gauge_display_state[k_G][3] - 1
            end
        elseif Gauge_display_state[k_G][3] < 0.15 and Gauge_display_state[k_G][2] > 0.85 then
            Gauge_display_state[k_G][3] = Gauge_display_state[k_G][3] - Gauge_display_state[k_G][6]
            if Gauge_display_state[k_G][3] < 0 then
                Gauge_display_state[k_G][3] = Gauge_display_state[k_G][3] + 1
            end
        else
            if Gauge_display_state[k_G][2] < Gauge_display_state[k_G][3] then
                Gauge_display_state[k_G][3] = Gauge_display_state[k_G][3] - Gauge_display_state[k_G][6]
            elseif Gauge_display_state[k_G][2] > Gauge_display_state[k_G][3] then
                Gauge_display_state[k_G][3] = Gauge_display_state[k_G][3] + Gauge_display_state[k_G][6]
            end
        end
        Gauge_display_state[k_G][4]:set(Gauge_display_state[k_G][3])
    end
end

function update()
    Altitude_Cal()
    Airspeed_Gauge_AOA_G_Cal()
    update_Gyro_Display()
    calculate_Climb_Slide()
    update_HSI_Compass()
    update_Gauge_Display()
end

need_to_be_closed = false