multiplier_suspen = 13000000000--24005000;
				--  16317400
multi2 = 12 -- 6-- fit 2.5G max overload when fully retract

multi2_damp_f = 32000--8000
multi2_damp_b = 26000

-- force = spring_force_factor * pow(reduce_length, amortizer_spring_force_factor_rate)

suspension_data = 
{
	{
		mass  			  = 30,
		-- pos   			  = { 4.226,  -2.661 - 0.225,   0},

		-- moment_of_inertia = {1000,1000,1000},
		--damage_element = 0, 
		self_attitude = false,
		-- wheel_axle_offset = 0,
		yaw_limit = math.rad(35.0),
		damper_coeff = 300.0, 
		allowable_hard_contact_length	= 0.2,				

		amortizer_min_length					= 0.0,
		amortizer_max_length					= 0.15,
		amortizer_basic_length					= 0.15, -- - 3.25 + 3.394,
		amortizer_spring_force_factor			= 3495463692326.1/500000, --10623.044,
		amortizer_spring_force_factor_rate		= 3,
		amortizer_static_force					= 1120,--4720,
		amortizer_reduce_length					= 0.15, -- - 3.25 + 3.394,
		amortizer_direct_damper_force_factor	= 3800,
		amortizer_back_damper_force_factor		= 2600,


		wheel_radius				  = 0.4 / 2,
		wheel_static_friction_factor  = 0.85 , --Static friction when wheel is not moving (fully braked)
		wheel_side_friction_factor    = 0.65 ,
		wheel_roll_friction_factor    = 0.06, -- Rolling friction factor when wheel moving
		wheel_glide_friction_factor   = 0.35 , -- Sliding aircraft
		wheel_damage_force_factor     = 1450.0, -- Tire is explosing due to hard landing
		wheel_damage_speed			  = 180.0, -- Tire burst due to excessive speed


		wheel_moment_of_inertia   = 0.15, --wheel moi as rotation body

		wheel_brake_moment_max = 0, -- maximum value of braking moment  , N*m no wheel break on nose wheel
		
		--[[
		args_post	  = {0,3,5};
		args_amortizer = {1,4,6};
		args_wheel	  = {76,77,77};
		args_wheel_yaw = {2,-1,-1};
		--]]

		wheel_kz_factor					= 0.3,
		noise_k							= 0.2,
		wheel_damage_speedX				= 97.5,
		wheel_damage_delta_speedX		= 11.5,

		arg_post             = 0,
		arg_amortizer        = 1,
		arg_wheel_rotation   = 76,
		arg_wheel_yaw        = 2,
		collision_shell_name = "WHEEL_F",
	},
	{
		mass  			  = 65,
		-- pos   			  = { -1.035,  -2.443 - 0.385,  -1.839},
		
		--damage_element	    = 3,
		-- wheel_axle_offset 	= 0 ,
		self_attitude	    = false,
		yaw_limit		    = math.rad(0.0),
		damper_coeff	    = 160.0,
		
		allowable_hard_contact_length			= 0.37,

		amortizer_min_length					= 0.0,
		amortizer_max_length					= 0.45,
		amortizer_basic_length					= 0.45,
		amortizer_spring_force_factor			= multiplier_suspen,
		amortizer_spring_force_factor_rate		= multi2,
		amortizer_static_force					= 2897,
		amortizer_reduce_length					= 0.14,
		amortizer_direct_damper_force_factor 	= multi2_damp_f,
		amortizer_back_damper_force_factor 		= multi2_damp_b,

		anti_skid_installed = true,

		wheel_radius				  = 0.572/2 ,
		wheel_static_friction_factor  = 0.85 ,
		wheel_side_friction_factor    = 0.65 ,
		wheel_roll_friction_factor    = 0.08,
		wheel_glide_friction_factor   = 0.35,
		wheel_damage_force_factor     = 1450.0,
		wheel_damage_speed			  = 180.0,
		wheel_moment_of_inertia   = 3.6, --wheel moi as rotation body

		wheel_brake_moment_max = 5000.0, -- maximum value of braking moment  , N*m 

		wheel_kz_factor					= 0.25,
		noise_k							= 0.4,
		wheel_damage_speedX				= 108,
		wheel_damage_delta_speedX		= 15,
		
		crossover_locked_wheel_protection = true,
		crossover_locked_wheel_protection_speed_min = 18.0,
		anti_skid_improved = true,
		anti_skid_gain = 200.0,
		--[[
		args_post	  = {0,3,5};
		args_amortizer = {1,4,6};
		args_wheel	  = {76,77,77};
		args_wheel_yaw = {2,-1,-1};
		--]]

		arg_post             = 5,
		arg_amortizer        = 6,
		arg_wheel_rotation   = 77,
		arg_wheel_yaw        = -1,
		collision_shell_name = "WHEEL_L",
	},
	{
		mass  			  = 65,
		-- pos   			  = { -1.035,  -2.443 - 0.385,  1.839},
		
		
		--damage_element	    = 5,
		-- wheel_axle_offset 	= 0 ,
		
		self_attitude	    = false,
		yaw_limit		    = math.rad(0.0),
		damper_coeff	    = 160.0,
		
		allowable_hard_contact_length			= 0.37,

		amortizer_min_length					= 0.0,
		amortizer_max_length					= 0.45,
		amortizer_basic_length					= 0.45,
		amortizer_spring_force_factor			= multiplier_suspen,
		amortizer_spring_force_factor_rate		= multi2,
		amortizer_static_force					= 2897,
		amortizer_reduce_length					= 0.14,
		amortizer_direct_damper_force_factor 	= multi2_damp_f,
		amortizer_back_damper_force_factor 		= multi2_damp_b,

		anti_skid_installed = true,

		wheel_radius				  = 0.572/2 ,
		wheel_static_friction_factor  = 0.85,
		wheel_side_friction_factor    = 0.65,
		wheel_roll_friction_factor    = 0.08,
		wheel_glide_friction_factor   = 0.35 ,
		wheel_damage_force_factor     = 1450.0,
		wheel_damage_speed			  = 180.0,
		wheel_moment_of_inertia   = 3.6, --wheel moi as rotation body

		wheel_brake_moment_max = 5000.0, -- maximum value of braking moment  , N*m 

		wheel_kz_factor					= 0.25,
		noise_k							= 0.4,
		wheel_damage_speedX				= 108,
		wheel_damage_delta_speedX		= 15,
		
		crossover_locked_wheel_protection = true,
		crossover_locked_wheel_protection_speed_min = 18.0,
		anti_skid_improved = true,
		anti_skid_gain = 200.0,
		--[[
		args_post	  = {0,3,5};
		args_amortizer = {1,4,6};
		args_wheel	  = {76,77,77};
		args_wheel_yaw = {2,-1,-1};
		--]]
		
		arg_post             = 3,
		arg_amortizer        = 4,
		arg_wheel_rotation   = 77,
		arg_wheel_yaw        = -1,
		collision_shell_name = "WHEEL_R",
	},
}