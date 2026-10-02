-- =========================
-- GLOBAL TUNING
-- =========================

local multiplier_suspen = 108000     -- progressive support near full main-gear compression
local multi2 = 1.15                   -- progressive spring exponent

local multi2_damp_f = 42000
local multi2_damp_b = 16000


-- =========================
-- SUSPENSION DATA
-- =========================

suspension_data = 
{

-- =========================
-- NOSE GEAR
-- =========================
{
    mass = 30,

    self_attitude = false,
    yaw_limit = math.rad(35.0),
    damper_coeff = 300.0,

    allowable_hard_contact_length = 0.2,

    amortizer_min_length = 0.0,
    amortizer_max_length = 0.15,
    amortizer_basic_length = 0.15,

    -- Low static support lets the nose settle; progression resists bottoming
    amortizer_spring_force_factor = 60000,
    amortizer_spring_force_factor_rate = 1.3,

    amortizer_static_force = 10000,

    amortizer_reduce_length = 0.05,

    amortizer_direct_damper_force_factor = 3800,
    amortizer_back_damper_force_factor   = 2600,

    wheel_radius = 0.413 / 2,

    wheel_static_friction_factor = 0.85,
    wheel_side_friction_factor   = 0.85,
    wheel_roll_friction_factor   = 0.015,
    wheel_glide_friction_factor  = 0.25,

    wheel_damage_force_factor = 1450.0,
    wheel_damage_speed = 180.0,

    wheel_moment_of_inertia = 0.15,

    wheel_brake_moment_max = 0, -- no braking on nose gear

    wheel_kz_factor = 0.3,
    noise_k = 0.2,

    wheel_damage_speedX = 97.5,
    wheel_damage_delta_speedX = 11.5,

    arg_post = 0,
    arg_amortizer = 1,
    arg_wheel_rotation = 76,
    arg_wheel_yaw = 2,

    collision_shell_name = "WHEEL_F",
},


-- =========================
-- LEFT MAIN GEAR
-- =========================
{
    mass = 65,

    self_attitude = false,
    yaw_limit = math.rad(0.0),
    damper_coeff = 300.0,

    allowable_hard_contact_length = 0.37,

    amortizer_min_length = 0.0,
    amortizer_max_length = 0.15,
    amortizer_basic_length = 0.15,

    amortizer_spring_force_factor = multiplier_suspen * 1.3,
    amortizer_spring_force_factor_rate = multi2,

    -- Damping handles the initial impact; low preload allows a deep static sag
    amortizer_static_force = 500,
    amortizer_reduce_length = 0.148,

    amortizer_direct_damper_force_factor = multi2_damp_f,
    amortizer_back_damper_force_factor   = multi2_damp_b,

    anti_skid_installed = true,

    wheel_radius = 0.579 / 2,

    wheel_static_friction_factor = 0.95,
    wheel_side_friction_factor   = 0.95,
    wheel_roll_friction_factor   = 0.03,
    wheel_glide_friction_factor  = 0.15,

    wheel_damage_force_factor = 1450.0,
    wheel_damage_speed = 180.0,

    wheel_moment_of_inertia = 3.6,

    wheel_brake_moment_max = 1944,

    wheel_kz_factor = 0.20,
    noise_k = 0.4,

    wheel_damage_speedX = 108,
    wheel_damage_delta_speedX = 15,

    crossover_locked_wheel_protection = true,
    crossover_locked_wheel_protection_speed_min = 18.0,

    anti_skid_improved = true,
    anti_skid_gain = 200.0,

    arg_post = 5,
    arg_amortizer = 6,
    arg_wheel_rotation = 77,
    arg_wheel_yaw = -1,

    collision_shell_name = "WHEEL_L",
},


-- =========================
-- RIGHT MAIN GEAR
-- =========================
{
    mass = 65,

    self_attitude = false,
    yaw_limit = math.rad(0.0),
    damper_coeff = 300.0,

    allowable_hard_contact_length = 0.37,

    amortizer_min_length = 0.0,
    amortizer_max_length = 0.15,
    amortizer_basic_length = 0.15,

    amortizer_spring_force_factor = multiplier_suspen * 1.3,
    amortizer_spring_force_factor_rate = multi2,

    -- Damping handles the initial impact; low preload allows a deep static sag
    amortizer_static_force = 500,
    amortizer_reduce_length = 0.148,

    amortizer_direct_damper_force_factor = multi2_damp_f,
    amortizer_back_damper_force_factor   = multi2_damp_b,

    anti_skid_installed = true,

    wheel_radius = 0.572 / 2,

    wheel_static_friction_factor = 0.95,
    wheel_side_friction_factor   = 0.95,
    wheel_roll_friction_factor   = 0.03,
    wheel_glide_friction_factor  = 0.15,

    wheel_damage_force_factor = 1450.0,
    wheel_damage_speed = 180.0,

    wheel_moment_of_inertia = 3.6,

    wheel_brake_moment_max = 1944,

    wheel_kz_factor = 0.20,
    noise_k = 0.4,

    wheel_damage_speedX = 108,
    wheel_damage_delta_speedX = 15,

    crossover_locked_wheel_protection = true,
    crossover_locked_wheel_protection_speed_min = 18.0,

    anti_skid_improved = true,
    anti_skid_gain = 200.0,

    arg_post = 3,
    arg_amortizer = 4,
    arg_wheel_rotation = 77,
    arg_wheel_yaw = -1,

    collision_shell_name = "WHEEL_R",
},

}
