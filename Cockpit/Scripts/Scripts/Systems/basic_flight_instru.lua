dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")
local HeadingUtils = dofile(LockOn_Options.script_path.."Systems/heading_utils.lua")
dofile(LockOn_Options.script_path.."debug_util.lua")

local dev = GetSelf()

local update_time_step = 0.02 --refreshes 50 times per second
make_default_activity(update_time_step)

sensor_data = get_base_data()
local ias_conversion_to_knots = 1  --1.9504132
local ias_conversion_to_kmh = 3.6
local DEGREE_TO_RAD  = 0.0174532925199433
local RAD_TO_DEGREE  = 57.29577951308233
local MAX_TURN_RATE_DEG_PER_SEC = 6
local AIRSPEED_NEEDLE_CALIBRATION = {
    { speed = 100, arg = 0.0 },
    { speed = 150, arg = 0.081280 }, -- measured 150 km/h dial at 164 km/h IAS
    { speed = 200, arg = 0.171450 }, -- measured 200 km/h dial at 235 km/h IAS
    { speed = 250, arg = 0.217170 }, -- measured 250 km/h dial at 271 km/h IAS
    { speed = 300, arg = 0.250190 }, -- measured 300 km/h dial at 297 km/h IAS
    { speed = 350, arg = 0.298450 }, -- measured 350 km/h dial at 335 km/h IAS
    { speed = 400, arg = 0.330200 }, -- measured 400 km/h dial at 360 km/h IAS
    { speed = 450, arg = 0.379730 }, -- measured 450 km/h dial at 399 km/h IAS
    { speed = 500, arg = 0.420370 }, -- measured 500 km/h dial at 431 km/h IAS
    { speed = 550, arg = 0.461010 }, -- measured 550 km/h dial at 463 km/h IAS
    { speed = 600, arg = 0.501650 }, -- measured 600 km/h dial at 495 km/h IAS
    { speed = 650, arg = 0.537210 }, -- measured 650 km/h dial at 523 km/h IAS
    { speed = 700, arg = 0.580390 }, -- measured 700 km/h dial at 557 km/h IAS
    { speed = 1200, arg = 0.95 },
}
local METER_TO_INCH = 1 --3.2808

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
local gyro_roll = _gauge_counter()
local gyro_pitch= _gauge_counter()
local climb_rate_ind = _gauge_counter()
local slide_rate_ind = _gauge_counter()
local HSI_compass_ind = _gauge_counter()
local turn_rate_ind = _gauge_counter()

Gauge_display_state = { -- last parameter define if it is unneed from 9 to zero
    {airspeed_ind, 0, 0, get_param_handle("AIR_SPEED"), 1, 0.04},
    {mach_ind, 0, 0, get_param_handle("MACH_IND"), 1, 0.04},
    {current_g_ind, 0, 0, get_param_handle("G_METER"), 1, 0.04},
    {aoa_ind, 0, 0, get_param_handle("AOA_IND"), 1, 0.04},
    {radar_alt_ind, 0, 0, get_param_handle("RADAR_ALT_IND"), 1, 0.04},
    {gyro_roll, 0, 0, get_param_handle("GYRO_ROLL"), 2, 0.04},
    {gyro_pitch, 0, 0, get_param_handle("GYRO_PITCH"), 2, 0.04},
    {climb_rate_ind, 0, 0, get_param_handle("CLIMB_RATE"), 1, 0.04},
    {slide_rate_ind, 0, 0, get_param_handle("SLIDE_IND"), 1, 0.04},
    {HSI_compass_ind, 0, 0, get_param_handle("HSI_COMPASS"), 2, 0.04},
    {turn_rate_ind, 0, 0, get_param_handle("TURN_RATE_IND"), 1, 0.04},
}

local function get_airspeed_needle_arg(speed_kmh)
    if speed_kmh <= AIRSPEED_NEEDLE_CALIBRATION[1].speed then
        return AIRSPEED_NEEDLE_CALIBRATION[1].arg
    end

    for i = 2, #AIRSPEED_NEEDLE_CALIBRATION do
        local current_point = AIRSPEED_NEEDLE_CALIBRATION[i]
        if speed_kmh <= current_point.speed then
            local previous_point = AIRSPEED_NEEDLE_CALIBRATION[i - 1]
            local speed_fraction = (speed_kmh - previous_point.speed) / (current_point.speed - previous_point.speed)
            return previous_point.arg + speed_fraction * (current_point.arg - previous_point.arg)
        end
    end

    return AIRSPEED_NEEDLE_CALIBRATION[#AIRSPEED_NEEDLE_CALIBRATION].arg
end

function Airspeed_Gauge_AOA_G_Cal()
    local current_speed = 0
    local vertical_acc = 1
    if (get_elec_dc_status() == true) then
        current_speed = sensor_data.getIndicatedAirSpeed() * ias_conversion_to_kmh
        vertical_acc = sensor_data.getVerticalAcceleration()
    end
    Gauge_display_state[airspeed_ind][2] = get_airspeed_needle_arg(current_speed)
   --[[
    if vertical_acc > 0 then
        Gauge_display_state[current_g_ind][2] = vertical_acc/8*0.889
    else
        Gauge_display_state[current_g_ind][2] = vertical_acc/3*0.749
    end
    ]]--
end

function Mach_Disc_Cal()
    local mach = 0

    if get_elec_dc_status() == true then
        mach = sensor_data.getMachNumber()
    end

    if mach < 0 then mach = 0 end
    if mach > 1 then mach = 1 end

    Gauge_display_state[mach_ind][2] = mach
end


function update_Gyro_Display()
    if (get_elec_dc_status() == true) then
        Gauge_display_state[gyro_roll][2] = sensor_data.getRoll() * RAD_TO_DEGREE / 90 / 2
        Gauge_display_state[gyro_pitch][2] = - sensor_data.getPitch() * RAD_TO_DEGREE / 90
    else
        Gauge_display_state[gyro_roll][2] = -0.3
        Gauge_display_state[gyro_pitch][2] = 0.3
    end
end

--[[function update_Backup_ADI()
    local standby_off_target = 0
    if get_elec_ac_status() ~= true then
        standby_off_target = 1
    end

    attgyro_stby_off:set(standby_off_target)
    attgyro_stby_horiz:set(standby_adi_horizon)

   -- Freeze the backup ADI when AC power is unavailable.
    if standby_off_target == 1 then
        return
    end

    local pitch = sensor_data.getPitch() * RAD_TO_DEGREE
    local roll = sensor_data.getRoll() * RAD_TO_DEGREE

    if pitch > 90 then
        pitch = 90
    elseif pitch < -90 then
        pitch = -90
    end

    if roll > 180 then
        roll = 180
    elseif roll < -180 then
        roll = -180
    end

    attgyro_stby_pitch:set(-pitch)
    attgyro_stby_roll:set(roll)
end ]]--


function calculate_Climb_Slide()
    if (get_elec_dc_status() == true) then
        local climb_rate = sensor_data.getVerticalVelocity() / 40
        local yaw_rate_degrees = sensor_data.getRateOfYaw() * RAD_TO_DEGREE
        local slide_rate = yaw_rate_degrees / 90
       -- DCS yaw rate is positive opposite the cockpit turn-rate needle convention.
        local turn_rate = -yaw_rate_degrees / MAX_TURN_RATE_DEG_PER_SEC
        if turn_rate > 1 then
            turn_rate = 1
        elseif turn_rate < -1 then
            turn_rate = -1
        end
        Gauge_display_state[climb_rate_ind][2] = climb_rate
        Gauge_display_state[slide_rate_ind][2] = slide_rate
        Gauge_display_state[turn_rate_ind][2] = turn_rate
    else
        Gauge_display_state[climb_rate_ind][2] = 0
        Gauge_display_state[slide_rate_ind][2] = 0
        Gauge_display_state[turn_rate_ind][2] = 0
    end
end

function update_HSI_Compass()
    local current_magnitude_heading = HeadingUtils.get_magnetic_heading(sensor_data)
    local temp = 0
    if (get_elec_ac_status() == true) then
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

local baro_altitude_efm = get_param_handle("ALT_XH_ANALOG")
local backup_adi_pitch = get_param_handle("BACKUP_ADI_PITCH")
local backup_adi_bank = get_param_handle("BACKUP_ADI_BANK")

function update_Backup_ADI()
    local pitch = 0
    local bank = 0

    if get_elec_dc_status() == true then
        pitch = sensor_data.getPitch() * RAD_TO_DEGREE / 90
        bank = sensor_data.getRoll() * RAD_TO_DEGREE / 180
    end

    if pitch > 1 then
        pitch = 1
    elseif pitch < -1 then
        pitch = -1
    end

    if bank > 1 then
        bank = 1
    elseif bank < -1 then
        bank = -1
    end

    backup_adi_pitch:set(pitch)
    backup_adi_bank:set(bank)
end

function update()
    Airspeed_Gauge_AOA_G_Cal()
	Mach_Disc_Cal()        -- Mach disc update
    update_Gyro_Display()
    calculate_Climb_Slide()
    update_HSI_Compass()
	update_Backup_ADI()
    update_Gauge_Display()
   --print_message_to_user(baro_altitude_efm)
end

need_to_be_closed = false

-- SK60 shared cockpit integration
dofile(LockOn_Options.script_path .. "Multicrew/runtime.lua").install(10)
