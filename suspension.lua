multiplier_suspen = 17;

suspension_data = 
{
	{
		mass  			  = 30,
		-- pos   			  = { 4.226,  -2.661 - 0.225,   0},

		-- moment_of_inertia = {1000,1000,1000},
		--damage_element = 0, 
		self_attitude = false,
		-- wheel_axle_offset = 0,
		yaw_limit = math.rad(63.0),
		damper_coeff = 300.0, 
		allowable_hard_contact_length	= 0.289,				

		amortizer_min_length					= 0.0,
		amortizer_max_length					= 0.284,
		amortizer_basic_length					= 0.284, -- - 3.25 + 3.394,
		amortizer_spring_force_factor			= 349546369232614, --10623.044,
		amortizer_spring_force_factor_rate		= 13,
		amortizer_static_force					= 21720,--4720,
		amortizer_reduce_length					= 0.284, -- - 3.25 + 3.394,
		amortizer_direct_damper_force_factor	= 13800,
		amortizer_back_damper_force_factor		= 16000,


		wheel_radius				  = 0.45 / 2,
		wheel_static_friction_factor  = 1.0 , --Static friction when wheel is not moving (fully braked)
		wheel_side_friction_factor    = 0.75 ,
		wheel_roll_friction_factor    = 0.1, -- Rolling friction factor when wheel moving
		wheel_glide_friction_factor   = 0.4 , -- Sliding aircraft
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
		
		allowable_hard_contact_length			= - 2.791 + 3.226 + 0.05,

		amortizer_min_length					= 0.0,
		amortizer_max_length					= - 2.791 + 3.226,
		amortizer_basic_length					= - 2.791 + 3.226,
		amortizer_spring_force_factor			= 1631740 * multiplier_suspen,
		amortizer_spring_force_factor_rate		= 4.5,
		amortizer_static_force					= 41897,
		amortizer_reduce_length					= - 2.791 + 3.226,
		amortizer_direct_damper_force_factor 	= 44000,
		amortizer_back_damper_force_factor 		= 35000,

		anti_skid_installed = true,

		wheel_radius				  = 0.385 ,
		wheel_static_friction_factor  = 1.0 ,
		wheel_side_friction_factor    = 0.75 ,
		wheel_roll_friction_factor    = 0.1,
		wheel_glide_friction_factor   = 0.4 ,
		wheel_damage_force_factor     = 1450.0,
		wheel_damage_speed			  = 180.0,
		wheel_moment_of_inertia   = 3.6, --wheel moi as rotation body

		wheel_brake_moment_max = 9000.0, -- maximum value of braking moment  , N*m 

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
		
		allowable_hard_contact_length			= - 2.791 + 3.226 + 0.05,

		amortizer_min_length					= 0.0,
		amortizer_max_length					= - 2.791 + 3.226,
		amortizer_basic_length					= - 2.791 + 3.226,
		amortizer_spring_force_factor			= 1631740 * multiplier_suspen,
		amortizer_spring_force_factor_rate		= 4.5,
		amortizer_static_force					= 41897,
		amortizer_reduce_length					= - 2.791 + 3.226,
		amortizer_direct_damper_force_factor 	= 44000,
		amortizer_back_damper_force_factor 		= 35000,

		anti_skid_installed = true,

		wheel_radius				  = 0.385 ,
		wheel_static_friction_factor  = 1.0 ,
		wheel_side_friction_factor    = 0.75 ,
		wheel_roll_friction_factor    = 0.1,
		wheel_glide_friction_factor   = 0.4 ,
		wheel_damage_force_factor     = 1450.0,
		wheel_damage_speed			  = 180.0,
		wheel_moment_of_inertia   = 3.6, --wheel moi as rotation body

		wheel_brake_moment_max = 9000.0, -- maximum value of braking moment  , N*m 
		
		--[[
		args_post	  = {0,3,5};
		args_amortizer = {1,4,6};
		args_wheel	  = {101,102,103};
		args_wheel_yaw = {2,-1,-1};
		--]]

		wheel_kz_factor					= 0.25,
		noise_k							= 0.4,
		wheel_damage_speedX				= 108,
		wheel_damage_delta_speedX		= 15,

		crossover_locked_wheel_protection = true,
		crossover_locked_wheel_protection_speed_min = 18.0,
		anti_skid_improved = true,
		anti_skid_gain = 200.0,
		
		arg_post             = 3,
		arg_amortizer        = 4,
		arg_wheel_rotation   = 77,
		arg_wheel_yaw        = -1,
		collision_shell_name = "WHEEL_R",
	},
}