function declear_smoke_pod(_name, _color, _red, _green, _blue, _alpha, uuid)
	local data = {
		category		= CAT_PODS,
		CLSID			= "{"..uuid.."}",
		Picture	        = "smokePod.png",
		PictureBlendColor = _color,		
		displayName		= _("Team60 ".._name.." Smoke Pod"),
		
		attribute	=	{4,	15,	50,	WSTYPE_PLACEHOLDER},			
		Smoke  = {
			alpha = _alpha,
			r  = _red,
			g  = _green,
			b  = _blue,
			dx = -1.6,
			dy = -0.05
		},
		
		shape_table_data = 
		{
			{
				name 	= "TEAM60-SMOKE-POD",
				file	= "TEAM60-SMOKE-POD";
				life	= 1;
				fire	= {0, 1};
				username= "{"..uuid.."}";
				index	= WSTYPE_PLACEHOLDER;
			},
		},
		Weight			= 15.5,
		Count 			= 1,
		Cx_pil			= 0.0005,
		Elements		={{
							ShapeName	=	"TEAM60-SMOKE-POD", 
							Position	=	{0, 0, 0},
						}}
	}

    declare_loadout(data)
end

function declear_smoke_nozzle(_name, _color, _red, _green, _blue, _alpha, uuid)
	local data = {
		category		= CAT_PODS,
		CLSID			= "{"..uuid.."}",
		Picture	        = "Nozzlesmoke.png",
		PictureBlendColor = _color,		
		displayName		= _("Team60 ".._name.." Nozzle Smoke"),
		
		attribute	=	{4,	15,	50,	WSTYPE_PLACEHOLDER},			
		Smoke  = {
			alpha = _alpha,
			r  = _red,
			g  = _green,
			b  = _blue,
			dx = -1.6,
			dy = -0.05
		},
		
		shape_table_data = 
		{
			{
				name 	= "TEAM60",
				file	= "TEAM60";
				life	= 1;
				fire	= {0, 1};
				username= "{"..uuid.."}";
				index	= WSTYPE_PLACEHOLDER;
			},
		},
		Weight			= 1,
		Count 			= 1,
		Cx_pil			= 0,
		Elements		={{
                            ShapeName	=	"TEAM60-SMOKE", 
							Position	=	{0, 0, 0},
						}}
	}

    declare_loadout(data)
end

declear_smoke_pod('WHITE', '0xffffffff', 255, 255, 255, 200, '3d7bfa20-fefe-4642-ba1f-380d5ae4f9c1')
declear_smoke_pod('RED', '0xcb1b45ff', 255, 30, 60, 200, '3d7bfa20-fefe-4642-ba1f-380d5ae4f9c2')
declear_smoke_pod('YELLOW', '0xffc408ff', 255, 196, 8, 200, '3d7bfa20-fefe-4642-ba1f-380d5ae4f9c3')
declear_smoke_pod('ORANGE', '0xffb11bff', 255, 177, 27, 200, '3d7bfa20-fefe-4642-ba1f-380d5ae4f9c4')
declear_smoke_pod('GREEN', '0x1b813eff', 27, 130, 62, 200, '3d7bfa20-fefe-4642-ba1f-380d5ae4f9c5')
declear_smoke_pod('BLUE', '0x2ea9dfff', 46, 169, 233, 200, '3d7bfa20-fefe-4642-ba1f-380d5ae4f9c6')


declear_smoke_nozzle('WHITE', '0xffffffff', 255, 255, 255, 200, '3d7bfa20-fefe-4642-ba1f-380d5ae4f9d1')
declear_smoke_nozzle('RED', '0xcb1b45ff', 255, 30, 60, 200, '3d7bfa20-fefe-4642-ba1f-380d5ae4f9d2')
declear_smoke_nozzle('YELLOW', '0xffc408ff', 255, 196, 8, 200, '3d7bfa20-fefe-4642-ba1f-380d5ae4f9d3')
declear_smoke_nozzle('ORANGE', '0xffb11bff', 255, 177, 27, 200, '3d7bfa20-fefe-4642-ba1f-380d5ae4f9d4')
declear_smoke_nozzle('GREEN', '0x1b813eff', 27, 130, 62, 200, '3d7bfa20-fefe-4642-ba1f-380d5ae4f9d5')
declear_smoke_nozzle('BLUE', '0x2ea9dfff', 46, 169, 233, 200, '3d7bfa20-fefe-4642-ba1f-380d5ae4f9d6')

-- rockets and rocket pods 

-- 135mm M/56 ARAK Rockets (HE)
local M56_ARAK135HE = {
	category			= CAT_ROCKETS,
	CLSID				= "{3c4b6e88-49ed-4a7c-8131-4abb48b1e02a}",
	name				= "M56ARAK135HE",
	user_name			= _("M/56 13,5cm ARAK(HE)"),
	wsTypeOfWeapon		= {wsType_Weapon,wsType_NURS,wsType_Rocket, 1350},
	scheme 				= "nurs-standard",
	model 				= "SK60_135_srak",
		-- coped from 70mm rockets
        fm = 
        {
            mass        = 45,   -- start weight, kg
            caliber     = 0.135, -- Caliber, meters 
            cx_coeff    = {1,0.889005,0.67,0.3173064,2.08},  -- Cx
            L           = 2.105, --Length, meters
            I           = 39.00209, -- moment of inertia
            Ix          = 6, -- not used???
            Ma          = 0.50851, -- dependence moment coefficient of  by  AoA
            Mw          = 3.28844, --  dependence moment coefficient by angular speed
            shapeName   = "",
            
            wind_time   = 1.5, -- dispersion coefficient
            wind_sigma  = 4, -- dispersion coefficient
        },

        engine =
        {
            fuel_mass   = 16.5, -- Fuel mass, kg
            impulse     = 250, -- Specific impulse, sec
            boost_time  = 0, -- Time of booster action
            work_time   = 3.2, -- Time of mid-flight engine action
            boost_factor= 1, -- Booster to cruise trust ratio
            nozzle_position =  {{-0.858, 0, 0}}, -- meters
            tail_width  = 0.180, -- contrail thickness 
            boost_tail  = 1.5,
            work_tail   = 1.5,
			-- black smoke
            smoke_color = {0.7, 0.7, 0.7},
			smoke_transparency = 0.6,--0.8,
        },

	warhead	=
	{
		mass				= 4.2,
		-- 3.7kg TNT
		expl_mass 			= 3.7,
		other_factors 		= { 2.0, 2.5, 2.5},--{ 1.0, 0.5, 0.5},
		concrete_factors 	= { 0.8, 0.8, 0.8},--{ 1.0, 0.5, 0.1},
		concrete_obj_factor = 0.8,
		obj_factors 		= { 1.5, 1.5},--{ 1.0, 1.0},
		cumulative_factor	= 2.0,
		cumulative_thickness = 0.6,
		piercing_mass		= 20.0,
	},

	shape_table_data =
	{
		{
			file		= "SK60_135_srak",
			life		= 1,
			fire		= {0, 1},
			username 	= "SK60_135_srak",
			index 		= WSTYPE_PLACEHOLDER,
			position	= {0, 0.3, 0},
		},
	},

	properties =
	{
		dist_min = 500,
		dist_max = 7000,
	}
}

declare_weapon(M56_ARAK135HE)

-- 145mm M/49 PSRAK Rockets (HEAT)
local M49_PSRAK145HEAT = {
	category			= CAT_ROCKETS,
	CLSID				= "{d261ef35-faeb-4d7d-9c5f-45eb150c553a}",
	name				= "M49PSRAK145HEAT",
	user_name			= _("M/49 14,5cm PSRAK(HEAT)"),
	wsTypeOfWeapon		= {wsType_Weapon,wsType_NURS,wsType_Rocket, 1450},
	scheme 				= "nurs-standard",
	model 				= "SK60_145_psrak",
		-- coped from 70mm rockets
        fm = 
        {
            mass        = 45,   -- start weight, kg
            caliber     = 0.135, -- Caliber, meters 
            cx_coeff    = {1,0.889005,0.67,0.3173064,2.08},  -- Cx
            L           = 2.105, --Length, meters
            I           = 39.00209, -- moment of inertia
            Ix          = 6, -- not used???
            Ma          = 0.50851, -- dependence moment coefficient of  by  AoA
            Mw          = 3.28844, --  dependence moment coefficient by angular speed
            shapeName   = "",
            
            wind_time   = 1.5, -- dispersion coefficient
            wind_sigma  = 4, -- dispersion coefficient
        },

        engine =
        {
            fuel_mass   = 17.5, -- Fuel mass, kg
            impulse     = 220, -- Specific impulse, sec
            boost_time  = 0, -- Time of booster action
            work_time   = 3.2, -- Time of mid-flight engine action
            boost_factor= 1, -- Booster to cruise trust ratio
            nozzle_position =  {{-0.875, 0, 0}}, -- meters
            tail_width  = 0.150, -- contrail thickness 
            boost_tail  = 1.5,
            work_tail   = 1.5,

            smoke_color = {0.7, 0.7, 0.7},
			smoke_transparency = 0.6,--0.8,
        },

	warhead	=
	{
		mass				= 4.2,
		-- 3.7kg TNT
		expl_mass 			= 3.7,
		other_factors 		= { 2.0, 2.5, 2.5},--{ 1.0, 0.5, 0.5},
		concrete_factors 	= { 0.8, 0.8, 0.8},--{ 1.0, 0.5, 0.1},
		concrete_obj_factor = 0.8,
		obj_factors 		= { 1.5, 1.5},--{ 1.0, 1.0},
		cumulative_factor	= 2.0,
		cumulative_thickness = 0.6,
		piercing_mass		= 20.0,
	},

	shape_table_data =
	{
		{
			file		= "SK60_145_psrak",
			life		= 1,
			fire		= {0, 1},
			username 	= "SK60_145_psrak",
			index 		= WSTYPE_PLACEHOLDER,
			position	= {0, 0.3, 0},
		},
	},

	properties =
	{
		dist_min = 500,
		dist_max = 7000,
	}
}

declare_weapon(M49_PSRAK145HEAT)

--loadout declear function
function declear_rocket_pods(_uuid, _display_name, _display_icon, _rocket_num, _rocket_id, _rocket_shape)
	local data = {
		category 		= CAT_ROCKETS,
		CLSID 			= _uuid,
		attribute 		= {wsType_Weapon,wsType_NURS,wsType_Container, 145},
		--attribute 	= {wsType_Weapon,wsType_NURS,wsType_Container,WSTYPE_PLACEHOLDER},
		wsTypeOfWeapon	= {wsType_Weapon,wsType_NURS,wsType_Rocket, _rocket_id},	
		Picture 		= _display_icon,
		displayName		= _(_display_name),
		Weight 			= 45 * _rocket_num + 5, -- weight * num + pylon
		Count			= _rocket_num,
		Cx_pil			= 0.0001,
		kind_of_shipping = 1,

		Elements = {},
	}

	if _rocket_num > 1 then
		data.Elements = {
			{
				ShapeName = "", -- pod name
				IsAdapter = true,
			},
		
			{
				Position	= {0, -0.14, 0}, --1
				ShapeName	= _rocket_shape,
				Rotation 	= {0,0,0},
			},
		}
	else
		data.Elements = {
			{
				ShapeName = "", -- pod name
				IsAdapter = true,
			},
		
			{
				Position	= {0, -0.14, 0}, --2
				ShapeName	= _rocket_shape,
				Rotation 	= {0,0,0},
			},

			{
				Position	= {0, -0.25, 0}, --1
				ShapeName	= _rocket_shape,
				Rotation 	= {0,0,0},
			},
		}
	end

end

declare_loadout(declear_rocket_pods("{d694b359-e7a8-4909-88d4-7100b77afd10}", "2x 14,5cm HEAT rocket", "", 2, 1450, "SK60_145_psrak"))
declare_loadout(declear_rocket_pods("{d694b359-e7a8-4909-88d4-7100b77afd11}", "2x 13,5cm HE rocket", "", 2, 1350, "SK60_135_srak"))