-- Condensation/humidity estimator for debug display and future vent smoke logic.
-- DCS does not expose relative humidity directly, so this module combines the
-- EFM atmosphere callback values with mission weather data and conservative
-- heuristics to produce stable, inspectable cockpit parameters.

local CondensationModel = {}

local STANDARD_PRESSURE_HPA = 1013.25
local KELVIN_TO_CELSIUS = -273.15
local SMOKE_ANIMATION_ARG = 5000
local SMOKE_LOOP_ANIMATION_ARG = 5001
local GLASS_FOG_ANIMATION_ARG = 5002
local SMOKE_LOOP_PERIOD_SECONDS = 2.0
local SMOKE_LOOP_FRAME_COUNT = 60
local SMOKE_LOOP_FRAME_DURATION_SECONDS = SMOKE_LOOP_PERIOD_SECONDS / SMOKE_LOOP_FRAME_COUNT
local SMOKE_LOOP_MAX_VALUE = 0.6
local SMOKE_LOOP_FRAME_VALUE_STEP = SMOKE_LOOP_MAX_VALUE / SMOKE_LOOP_FRAME_COUNT
local HUMIDITY_SMOKE_THRESHOLD = 50
local HUMIDITY_FULL_EFFECT_PERCENT = 80
local AMBIENT_MOISTURE_FLOOR_SCALE = 0.12
local SMOKE_MOISTURE_CLEAR_THRESHOLD = 0.035
local SMOKE_MOISTURE_FULL_EFFECT = 0.16
local AIRFLOW_SMOKE_VISIBILITY_BOOST = 17.0
local AIRFLOW_SMOKE_PUSH_GAIN = 0.70
local AIRFLOW_SMOKE_PUSH_DECAY_RATE = 1.20
local AIRFLOW_EQUALIZATION_DECAY_RATE = 2.40
local AIRFLOW_COCKPIT_DRYING_RATE = 0.120
local AIRFLOW_WET_AIRCRAFT_DRYING_RATE = 0.100
local GLASS_FOG_BUILD_RESPONSE_RATE = 0.45
local GLASS_FOG_CLEAR_RESPONSE_RATE = 0.65
local DEW_POINT_FULL_EFFECT_SPREAD_C = 2
local DEW_POINT_NO_EFFECT_SPREAD_C = 12
local PRESSURE_TRANSIENT_THRESHOLD_PA_PER_SEC = 450
local TEMPERATURE_TRANSIENT_THRESHOLD_C_PER_SEC = 0.75

local humidity_param = get_param_handle("CURRENT_HUMIDITY")
local smoke_param = get_param_handle("CONDENSATION_SMOKE_PERCENT")
local smoke_animation_param = get_param_handle("CONDENSATION_SMOKE")
local smoke_loop_animation_param = get_param_handle("CONDENSATION_SMOKE_LOOP")
local glass_fog_animation_param = get_param_handle("CONDENSATION_GLASS_FOG")
local dew_point_param = get_param_handle("CONDENSATION_DEW_POINT_C")
local cockpit_moisture_param = get_param_handle("CONDENSATION_COCKPIT_MOISTURE")
local temperature_param = get_param_handle("ATMOSPHERE_TEMPERATURE_K")
local pressure_param = get_param_handle("ATMOSPHERE_PRESSURE_PA")
local left_throttle_param = get_param_handle("EFM_LEFT_THRUST_A")
local right_throttle_param = get_param_handle("EFM_RIGHT_THRUST_A")
local canopy_param = get_param_handle("Inside_Canopy")

local mission_weather = nil
local mission_weather_loaded = false
local smoke_loop_time = 0
local smoke_loop_frame_index = 0
local smoke_loop_frame_elapsed = 0
local cockpit_moisture = 0
local wet_aircraft_factor = 0
local airflow_smoke_push = 0
local previous_airflow_factor = 0
local glass_fog_level = 0
local previous_pressure_pa = nil
local previous_temperature_c = nil

local function clamp(value, min_value, max_value)
    if value < min_value then
        return min_value
    elseif value > max_value then
        return max_value
    end

    return value
end

local function get_table_value(root, ...)
    local current = root
    for i = 1, select("#", ...) do
        if type(current) ~= "table" then
            return nil
        end
        current = current[select(i, ...)]
    end

    return current
end

local function load_mission_weather()
    if mission_weather_loaded then
        return mission_weather
    end

    mission_weather_loaded = true

    if do_mission_file ~= nil then
        do_mission_file("mission")
        if type(mission) == "table" then
            mission_weather = mission.weather
        end
    end

    return mission_weather
end

local function weather_preset_humidity(weather)
    local clouds = get_table_value(weather, "clouds") or {}
    local fog = get_table_value(weather, "fog") or {}
    local preset = string.lower(tostring(clouds.preset or clouds.name or ""))
    local density = tonumber(clouds.density) or 0
    local thickness = tonumber(clouds.thickness) or 0
    local precipitation = tonumber(clouds.iprecptns or clouds.precipitation) or 0

    -- Base estimate from mission cloud cover. DCS cloud density is normally 0..10.
    local relative_humidity = 35 + clamp(density, 0, 10) * 4.5

    if thickness > 1000 then
        relative_humidity = relative_humidity + 5
    end

    if precipitation > 0 then
        relative_humidity = relative_humidity + 18
    end

    if fog.enable == true or fog.enabled == true or (tonumber(fog.visibility) or 0) > 0 then
        relative_humidity = relative_humidity + 20
    end

    -- Weather preset names vary between DCS versions, so match broad tokens.
    if preset:find("thunder") or preset:find("storm") then
        relative_humidity = relative_humidity + 25
    elseif preset:find("rain") or preset:find("shower") then
        relative_humidity = relative_humidity + 22
    elseif preset:find("fog") or preset:find("mist") then
        relative_humidity = relative_humidity + 20
    elseif preset:find("overcast") then
        relative_humidity = relative_humidity + 15
    elseif preset:find("broken") then
        relative_humidity = relative_humidity + 8
    elseif preset:find("scattered") then
        relative_humidity = relative_humidity + 3
    elseif preset:find("clear") then
        relative_humidity = relative_humidity - 8
    end

    return clamp(relative_humidity, 25, 100)
end

local function get_weather_factors(weather, altitude_m)
    local clouds = get_table_value(weather, "clouds") or {}
    local fog = get_table_value(weather, "fog") or {}
    local preset = string.lower(tostring(clouds.preset or clouds.name or ""))
    local density = clamp(tonumber(clouds.density) or 0, 0, 10) / 10
    local thickness = tonumber(clouds.thickness) or 0
    local precipitation = tonumber(clouds.iprecptns or clouds.precipitation) or 0
    local cloud_base = tonumber(clouds.base) or tonumber(clouds.baseHeight) or nil

    local rain_factor = precipitation > 0 and 1 or 0
    if preset:find("rain") or preset:find("shower") or preset:find("storm") or preset:find("thunder") then
        rain_factor = 1
    end

    local fog_factor = 0
    if fog.enable == true or fog.enabled == true or (tonumber(fog.visibility) or 0) > 0 then
        fog_factor = 1
    elseif preset:find("fog") or preset:find("mist") then
        fog_factor = 0.8
    end

    local cloud_factor = 0
    if cloud_base ~= nil and thickness > 0 then
        local cloud_top = cloud_base + thickness
        if altitude_m >= cloud_base and altitude_m <= cloud_top then
            cloud_factor = density
        end
    elseif preset:find("overcast") then
        cloud_factor = 0.7
    end

    return rain_factor, fog_factor, clamp(cloud_factor, 0, 1)
end

local function update_wet_aircraft_factor(delta_time, rain_factor, fog_factor, cloud_factor, airflow_factor)
    local wetting = (rain_factor * 0.120) + (cloud_factor * 0.050) + (fog_factor * 0.040)
    local drying = (airflow_factor * AIRFLOW_WET_AIRCRAFT_DRYING_RATE) + ((1 - rain_factor) * 0.006)

    wet_aircraft_factor = wet_aircraft_factor + (wetting - drying) * delta_time
    wet_aircraft_factor = clamp(wet_aircraft_factor, 0, 1)

    return wet_aircraft_factor
end

local function get_transient_condensation_factor(temperature_c, pressure_pa, delta_time)
    if delta_time <= 0 or previous_pressure_pa == nil or previous_temperature_c == nil then
        previous_pressure_pa = pressure_pa
        previous_temperature_c = temperature_c
        return 0
    end

    local pressure_rate = math.abs(pressure_pa - previous_pressure_pa) / delta_time
    local temperature_rate = math.abs(temperature_c - previous_temperature_c) / delta_time

    previous_pressure_pa = pressure_pa
    previous_temperature_c = temperature_c

    local pressure_factor = clamp((pressure_rate - PRESSURE_TRANSIENT_THRESHOLD_PA_PER_SEC) / 2000, 0, 1)
    local temperature_factor = clamp((temperature_rate - TEMPERATURE_TRANSIENT_THRESHOLD_C_PER_SEC) / 3, 0, 1)

    return clamp(math.max(pressure_factor, temperature_factor), 0, 1)
end

local function get_canopy_open_factor()
    -- Canopy argument 38 uses 0.9 for fully open; 1.0 means removed in DCS.
    return clamp((canopy_param:get() or 0) / 0.9, 0, 1)
end

local function get_heat_factor(temperature_c)
    -- Placeholder for a later ECS/defog heat control. Outside warm air still helps
    -- normalize moisture slowly; cold air contributes no heat drying.
    return clamp((temperature_c - 5) / 25, 0, 1)
end

local function update_cockpit_moisture(delta_time, humidity_factor, rain_factor, fog_factor, cloud_factor, airflow_factor, heat_factor, canopy_open_factor, transient_factor)
    local wet_factor = update_wet_aircraft_factor(delta_time, rain_factor, fog_factor, cloud_factor, airflow_factor)
    local canopy_open_in_rain_factor = canopy_open_factor * math.max(rain_factor, cloud_factor)
    local moisture_in =
        (rain_factor * 0.080) +
        (fog_factor * 0.035) +
        (cloud_factor * 0.050) +
        (wet_factor * 0.030) +
        (canopy_open_in_rain_factor * 0.120) +
        (humidity_factor * 0.006) +
        (transient_factor * 0.060)

    local moisture_out =
        (airflow_factor * AIRFLOW_COCKPIT_DRYING_RATE) +
        (heat_factor * 0.018) +
        ((1 - humidity_factor) * 0.015)

    local active_wetness_floor = clamp(
        (rain_factor * 0.15) +
        (fog_factor * 0.10) +
        (cloud_factor * 0.12) +
        (wet_factor * 0.18) +
        (canopy_open_in_rain_factor * 0.15) +
        (transient_factor * 0.12),
        0,
        1
    )
    local airflow_floor_reduction = 1 - (airflow_factor * 0.85)
    local ambient_moisture_floor = humidity_factor * AMBIENT_MOISTURE_FLOOR_SCALE * active_wetness_floor * airflow_floor_reduction

    cockpit_moisture = cockpit_moisture + (moisture_in - moisture_out) * delta_time
    cockpit_moisture = math.max(cockpit_moisture, ambient_moisture_floor)
    cockpit_moisture = clamp(cockpit_moisture, 0, 1)

    return cockpit_moisture, wet_factor
end

local function calculate_visible_moisture_factor(moisture_factor, airflow_push_factor)
    local raw_visible_moisture = clamp(moisture_factor + airflow_push_factor, 0, 1)
    return clamp((raw_visible_moisture - SMOKE_MOISTURE_CLEAR_THRESHOLD) / (SMOKE_MOISTURE_FULL_EFFECT - SMOKE_MOISTURE_CLEAR_THRESHOLD), 0, 1)
end

local function update_airflow_smoke_push(delta_time, airflow_factor, moisture_factor)
    local airflow_increase = math.max(airflow_factor - previous_airflow_factor, 0)
    local pushed_moisture = airflow_increase * moisture_factor * AIRFLOW_SMOKE_PUSH_GAIN
    local equalization_decay = (AIRFLOW_SMOKE_PUSH_DECAY_RATE + (airflow_factor * AIRFLOW_EQUALIZATION_DECAY_RATE)) * delta_time

    airflow_smoke_push = clamp(airflow_smoke_push + pushed_moisture - equalization_decay, 0, 1)
    previous_airflow_factor = airflow_factor

    return airflow_smoke_push
end

local function update_glass_fog(delta_time, moisture_factor, canopy_open_factor)
    local canopy_closed_factor = 1 - canopy_open_factor
    local target_fog_level = moisture_factor * canopy_closed_factor
    local response_rate = GLASS_FOG_CLEAR_RESPONSE_RATE
    if target_fog_level > glass_fog_level then
        response_rate = GLASS_FOG_BUILD_RESPONSE_RATE
    end

    local response = clamp(response_rate * delta_time, 0, 1)
    glass_fog_level = clamp(glass_fog_level + ((target_fog_level - glass_fog_level) * response), 0, 1)
    glass_fog_animation_param:set(glass_fog_level)
    set_aircraft_draw_argument_value(GLASS_FOG_ANIMATION_ARG, glass_fog_level)

    return glass_fog_level
end

local function calculate_humidity_factor(humidity)
    return clamp((humidity - HUMIDITY_SMOKE_THRESHOLD) / (HUMIDITY_FULL_EFFECT_PERCENT - HUMIDITY_SMOKE_THRESHOLD), 0, 1)
end

local function calculate_dewpoint_factor(temperature_c, dew_point_c)
    local spread = temperature_c - dew_point_c
    return clamp((DEW_POINT_NO_EFFECT_SPREAD_C - spread) / (DEW_POINT_NO_EFFECT_SPREAD_C - DEW_POINT_FULL_EFFECT_SPREAD_C), 0, 1)
end

local function saturation_vapor_pressure_hpa(temperature_c)
    return 6.112 * math.exp((17.67 * temperature_c) / (temperature_c + 243.5))
end

local function calculate_dew_point_c(temperature_c, relative_humidity)
    local safe_humidity = clamp(relative_humidity, 1, 100)
    local gamma = math.log(safe_humidity / 100) + ((17.67 * temperature_c) / (243.5 + temperature_c))
    return (243.5 * gamma) / (17.67 - gamma)
end

local function estimate_relative_humidity(temperature_c, pressure_pa)
    local weather = load_mission_weather()
    local relative_humidity = weather_preset_humidity(weather)
    local pressure_hpa = pressure_pa / 100

    -- Keep preset humidity independent from altitude-driven temperature changes.
    -- Rapid climb/descent effects are handled separately as transient condensation.
    if temperature_c > 30 then
        relative_humidity = relative_humidity - (temperature_c - 30) * 0.2
    end

    -- Pressure is only a small bias for this relative-humidity estimate, but it
    -- keeps the value responsive to the current atmosphere passed from the EFM.
    relative_humidity = relative_humidity + clamp((pressure_hpa - STANDARD_PRESSURE_HPA) * 0.015, -5, 5)

    -- Keep the estimate physically plausible by checking the derived vapor pressure.
    local actual_vapor_pressure = saturation_vapor_pressure_hpa(temperature_c) * relative_humidity / 100
    if actual_vapor_pressure > saturation_vapor_pressure_hpa(temperature_c) then
        relative_humidity = 100
    end

    return clamp(relative_humidity, 0, 100)
end

local function get_temperature_c(sensor_data)
    local temperature_k = temperature_param:get()
    if temperature_k ~= nil and temperature_k > 0 then
        return temperature_k + KELVIN_TO_CELSIUS
    end

    -- Fallback ISA approximation if the EFM atmosphere parameter has not arrived yet.
    local altitude_m = 0
    if sensor_data ~= nil and sensor_data.getBarometricAltitude ~= nil then
        altitude_m = sensor_data.getBarometricAltitude()
    end

    return 15 - (0.0065 * altitude_m)
end

local function get_pressure_pa(sensor_data)
    local pressure_pa = pressure_param:get()
    if pressure_pa ~= nil and pressure_pa > 0 then
        return pressure_pa
    end

    -- Fallback ISA pressure if the EFM atmosphere parameter has not arrived yet.
    local altitude_m = 0
    if sensor_data ~= nil and sensor_data.getBarometricAltitude ~= nil then
        altitude_m = sensor_data.getBarometricAltitude()
    end

    return 101325 * (1 - 2.25577e-5 * altitude_m) ^ 5.25588
end

local function normalize_engine_rpm(value)
    if value == nil then
        return 0
    end

    -- DCS/EFM RPM sources can be exposed either as 0..1 related RPM or
    -- as 0..100 percent. Normalize both to the smoke 0..1 control range.
    if value > 1.5 then
        return clamp(value / 100, 0, 1)
    end

    return clamp(value, 0, 1)
end

local function get_engine_power_factor(sensor_data)
    -- Smoke strength follows engine RPM directly: 0% RPM = 0% smoke,
    -- 100% RPM = 100% smoke. Prefer the EFM-driven N2 draw args because
    -- those are the same values used by the RPM displays.
    local left_rpm = normalize_engine_rpm(get_aircraft_draw_argument_value(303) or 0)
    local right_rpm = normalize_engine_rpm(get_aircraft_draw_argument_value(304) or 0)

    if left_rpm > 0 or right_rpm > 0 then
        return clamp((left_rpm + right_rpm) * 0.5, 0, 1)
    end

    if sensor_data ~= nil and sensor_data.getEngineLeftRPM ~= nil and sensor_data.getEngineRightRPM ~= nil then
        local left_sensor_rpm = normalize_engine_rpm(sensor_data.getEngineLeftRPM())
        local right_sensor_rpm = normalize_engine_rpm(sensor_data.getEngineRightRPM())

        if left_sensor_rpm > 0 or right_sensor_rpm > 0 then
            return clamp((left_sensor_rpm + right_sensor_rpm) * 0.5, 0, 1)
        end
    end

    local left = left_throttle_param:get() or 0
    local right = right_throttle_param:get() or 0
    return clamp((left + right) * 0.5, 0, 1)
end

local function update_smoke_loop(smoke_animation_value, delta_time)
    local smoke_loop_value = 0

    if smoke_animation_value > 0 then
        smoke_loop_value = math.floor((smoke_loop_frame_index * SMOKE_LOOP_FRAME_VALUE_STEP) * 100 + 0.5) / 100
        smoke_loop_frame_elapsed = smoke_loop_frame_elapsed + delta_time

        while smoke_loop_frame_elapsed >= SMOKE_LOOP_FRAME_DURATION_SECONDS do
            smoke_loop_frame_elapsed = smoke_loop_frame_elapsed - SMOKE_LOOP_FRAME_DURATION_SECONDS
            smoke_loop_frame_index = (smoke_loop_frame_index + 1) % SMOKE_LOOP_FRAME_COUNT
        end

        smoke_loop_time = smoke_loop_frame_index * SMOKE_LOOP_FRAME_DURATION_SECONDS
    else
        smoke_loop_time = 0
        smoke_loop_frame_index = 0
        smoke_loop_frame_elapsed = 0
    end

    smoke_loop_animation_param:set(smoke_loop_value)
    set_aircraft_draw_argument_value(SMOKE_LOOP_ANIMATION_ARG, smoke_loop_value)

    return smoke_loop_value
end

function CondensationModel.update(sensor_data, delta_time)
    local dt = delta_time or 0
    local temperature_c = get_temperature_c(sensor_data)
    local pressure_pa = get_pressure_pa(sensor_data)
    local altitude_m = 0
    if sensor_data ~= nil and sensor_data.getBarometricAltitude ~= nil then
        altitude_m = sensor_data.getBarometricAltitude()
    end

    local weather = load_mission_weather()
    local humidity = estimate_relative_humidity(temperature_c, pressure_pa)
    local dew_point_c = calculate_dew_point_c(temperature_c, humidity)
    local humidity_factor = calculate_humidity_factor(humidity)
    local dewpoint_factor = calculate_dewpoint_factor(temperature_c, dew_point_c)
    local airflow_factor = get_engine_power_factor(sensor_data)
    local rain_factor, fog_factor, cloud_factor = get_weather_factors(weather, altitude_m)
    local heat_factor = get_heat_factor(temperature_c)
    local canopy_open_factor = get_canopy_open_factor()
    local transient_factor = get_transient_condensation_factor(temperature_c, pressure_pa, dt)
    local moisture_factor = update_cockpit_moisture(
        dt,
        humidity_factor,
        rain_factor,
        fog_factor,
        cloud_factor,
        airflow_factor,
        heat_factor,
        canopy_open_factor,
        transient_factor
    )
    local airflow_push_factor = update_airflow_smoke_push(dt, airflow_factor, moisture_factor)
    local visible_moisture_factor = calculate_visible_moisture_factor(moisture_factor, airflow_push_factor)
    local glass_fog = update_glass_fog(dt, moisture_factor, canopy_open_factor)
    local vapor_pulse = 0.75 + 0.15 * math.sin(smoke_loop_time * 1.7) + 0.10 * math.sin(smoke_loop_time * 4.3)
    local smoke_animation_value = clamp(humidity_factor * airflow_factor * AIRFLOW_SMOKE_VISIBILITY_BOOST * visible_moisture_factor * dewpoint_factor * vapor_pulse, 0, 1)
    local smoke_percent = smoke_animation_value * 100
    local smoke_loop_value = update_smoke_loop(smoke_animation_value, dt)

    humidity_param:set(humidity)
    smoke_param:set(smoke_percent)
    smoke_animation_param:set(smoke_animation_value)
    cockpit_moisture_param:set(moisture_factor)
    dew_point_param:set(dew_point_c)
    set_aircraft_draw_argument_value(SMOKE_ANIMATION_ARG, smoke_animation_value)

    return {
        humidity = humidity,
        smoke_percent = smoke_percent,
        smoke_loop_value = smoke_loop_value,
        cockpit_moisture = moisture_factor,
        airflow_factor = airflow_factor,
        airflow_push_factor = airflow_push_factor,
        glass_fog = glass_fog,
        rain_factor = rain_factor,
        fog_factor = fog_factor,
        cloud_factor = cloud_factor,
        canopy_open_factor = canopy_open_factor,
        dew_point_c = dew_point_c,
        temperature_c = temperature_c,
        pressure_pa = pressure_pa,
    }
end

return CondensationModel
