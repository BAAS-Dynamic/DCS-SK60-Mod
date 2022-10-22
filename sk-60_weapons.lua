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
            smoke_color = {0.15, 0.15, 0.15},
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
			position	= {0, 0, 0},
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

            smoke_color = {0.1, 0.1, 0.1},
			smoke_transparency = 0.8,--0.8,
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
			position	= {0, 0, 0},
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
function declear_rocket_pods(_uuid, _display_name, _display_icon, _rocket_num, _rocket_id, _rocket_shape, _distance, _diameter, _forwarding)
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

	if _rocket_num < 1 then
		data.Elements = {
			{
				ShapeName = "", -- pod name
				IsAdapter = true,
			},
		
			{
				Position	= {_forwarding + 0.01, - 0.065 - _diameter/2 * 3 - _distance, 0}, --2 0.25
				ShapeName	= _rocket_shape,
				Rotation 	= {0,0,-1.5},
			},
		}
	else
		data.Elements = {
			{
				ShapeName = "placeholder", -- pod name
				position = {0, 0, 0},
				IsAdapter = true,
			},

			{
				Position	= {_forwarding, - 0.065 - _diameter/2, 0}, --1 
				ShapeName	= _rocket_shape,
				Rotation 	= {0,0,-1.5},
			},
		
			{
				Position	= {_forwarding + 0.01, - 0.065 - _diameter/2 * 3 - _distance, 0}, --2 0.25
				ShapeName	= _rocket_shape,
				Rotation 	= {0,0,-1.5},
			},
		}
	end
	return data
end

declare_loadout(declear_rocket_pods("{d694b359-e7a8-4909-88d4-7100b77afd11}", "2x 13,5cm HE rocket", "M56_Rocket_135_HE.png", 2, 1350, "SK60_135_srak", 0.025, 0.135, 0.38))
declare_loadout(declear_rocket_pods("{d694b359-e7a8-4909-88d4-7100b77afd13}", "1x 13,5cm HE rocket", "M56_Rocket_135_HE.png", 1, 1350, "SK60_135_srak", 0.025, 0.135, 0.38))
declare_loadout(declear_rocket_pods("{d694b359-e7a8-4909-88d4-7100b77afd12}", "1x 14,5cm HEAT rocket", "M49_Rocket_145_HEAT.png", 1, 1450, "SK60_145_psrak", 0.025, 0.145, 0.43))
declare_loadout(declear_rocket_pods("{d694b359-e7a8-4909-88d4-7100b77afd10}", "2x 14,5cm HEAT rocket", "M49_Rocket_145_HEAT.png", 2, 1450, "SK60_145_psrak", 0.025, 0.145, 0.43))

-- here is the new gun pods
-- 30 mm akan m/55
function akan_m55_gun(tbl)
	tbl.category = CAT_GUN_MOUNT
	tbl.name     = "Akan M/55 30mm"
	tbl.supply   =
	{
		-- use temp 20mm here
		shells = { "20x110mm HE-I", "20x110mm AP-I", "20x110mm AP-T" },
		mixes  = { { 1, 2, 1, 3 } }, -- 50% HE-i, 25% AP-I, 25% AP-T
		count  = 600,
	}
	if tbl.mixes then
		tbl.supply.mixes = tbl.mixes
		tbl.mixes        = nil
	end
	tbl.gun =
	{
		max_burst_length = 2,
		rates            = { 1700 },
		recoil_coeff     = 0.6 * 1.3,
		barrels_count    = 2,
	}
	if tbl.rates then
		tbl.gun.rates = tbl.rates
		tbl.rates     = nil
	end
	tbl.ejector_pos             = tbl.ejector_pos or { 0, 0, 0 }
	tbl.ejector_pos_connector   = tbl.ejector_pos_connector or "Gun_point"
	tbl.ejector_dir             = { -1, -6, 0 } -- left/right; back/front;?/?
	tbl.supply_position         = tbl.supply_position or { 0, 0.3, -0.3 }
	tbl.aft_gun_mount           = false
	tbl.effective_fire_distance = 1400
	tbl.drop_cartridge          = 204
	tbl.muzzle_pos              = tbl.muzzle_pos or { 2.5, -0.4, 0 } -- all position from connector
	tbl.muzzle_pos_connector    = tbl.muzzle_pos_connector or "Gun_point" -- all position from connector
	tbl.azimuth_initial         = tbl.azimuth_initial or 0
	tbl.elevation_initial       = tbl.elevation_initial or 0
	if tbl.effects == nil then
		tbl.effects = { { name = "FireEffect", arg = tbl.effect_arg_number or 436 },
			{ name = "HeatEffectExt", shot_heat = 7, barrel_k = 0.4 * 2.5, body_k = 0.4 * 15 },
			{ name = "SmokeEffect" } }
	end
	return declare_weapon(tbl)
end

AKAN_GUNPOD = {
    category        = CAT_PODS,
    CLSID           = "{5d5aa063-a002-4de8-8a89-6eda1e80ee7b}",
    attribute       = {wsType_Weapon,wsType_GContainer,wsType_Cannon_Cont,WSTYPE_PLACEHOLDER},
    wsTypeOfWeapon  = {wsType_Weapon,wsType_Shell,wsType_Shell,WSTYPE_PLACEHOLDER},
    Picture         = "SPPU22.png",
    displayName     = _("AKAN m/55 Gunpod"),
    Weight          = 196,
    Cx_pil          = 0.001220703125,
    Elements        = {{ShapeName = "SK60_AKAN"}},
    kind_of_shipping = 2,   -- SOLID_MUNITION
    gun_mounts      = {
        akan_m55_gun({
            muzzle_pos_connector = "AKAN_muzzle",
            rates = {1700}, mixes = {{1,2,1,3}},
            effect_arg_number = 1050,
            azimuth_initial = 0,
            elevation_initial = 0,
            supply_position = {2, -0.3, -0.4}})
    },
    shape_table_data = {{file = 'SK60_AKAN'; username = 'SK60_AKAN'; index = WSTYPE_PLACEHOLDER;}}
}

declare_loadout(AKAN_GUNPOD)