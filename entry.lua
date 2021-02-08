-- SAAB_SK60_FM
-- local FM_dll=nil
-- Test Collision only
local FM_dll= "SAAB_SK60_FM.dll" -- "A-6E_Intruder_FM" --

self_ID = "SK-60"
declare_plugin(self_ID,
{
image     	 = "FC3.bmp",
installed 	 = true, -- if false that will be place holder , or advertising
dirName	  	 = current_mod_path,
displayName  = _("SK-60B"),
developerName = _("Saab"),

fileMenuName = _("SK-60"),
update_id    = "SK-60",
version		 = "V1.2.0-alpha1",
state		 = "installed",
info		 = _("SK-60 or Saab-105 is a swedish twin seat high performance training jet."),
encyclopedia_path = current_mod_path..'/Encyclopedia',
binaries   =
{
    FM_dll
},

Skins	=
	{
		{
		    name	= _("SK-60"),
			dir		= "Theme"
		},
	},
Missions =
	{
		{
			name		    = _("SK-60"),
			dir			    = "Missions",
  		},
	},
LogBook =
	{
		{
			name		= _("SK-60"),
			type		= "SK-60",
		},
	},	
		
InputProfiles =
	{
		["SK-60"] = current_mod_path .. '/Input/SK-60',
	},	
	
--encyclopedia_path = current_mod_path..'/Encyclopedia'
	
})
----------------------------------------------------------------------------------------
mount_vfs_model_path	(current_mod_path.."/Shapes")
mount_vfs_liveries_path (current_mod_path.."/Liveries")
mount_vfs_texture_path  (current_mod_path.."/Textures")
mount_vfs_sound_path    (current_mod_path.."/Sounds")
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
local FM = nil

test_susp = {
	{
		wheel_radius         = 0.45,
		
			arg_post             = 0,
			arg_amortizer        = 1,
			arg_wheel_rotation   = 76,
			arg_wheel_yaw        = 2,
			collision_shell_name = "WHEEL_F",
		},
		{
			wheel_radius         = 0.77,
	
			arg_post             = 3,
			arg_amortizer        = 4,
			arg_wheel_rotation   = 77,
			arg_wheel_yaw        = -1,
			collision_shell_name = "WHEEL_R",
		},
		{
			wheel_radius         = 0.77,
	
			arg_post             = 5,
			arg_amortizer        = 6,
			arg_wheel_rotation   = 77,
			arg_wheel_yaw        = -1,
			collision_shell_name = "WHEEL_L",
		},
}

dofile(current_mod_path.."/suspension.lua")

if FM_dll then
	FM=
	{
		[1] = self_ID,
		[2] = FM_dll,
		center_of_mass = {0, 0, 0},--{5.8784 - 4.572, -0.7883, 0},
		-- the moment_of_inertia is following the data from nasa
		-- reverse the axis of y and z
		moment_of_inertia = {10000, 39500, 35000, 2000},
		suspension = suspension_data,
	}
else
    FM=nil
end


dofile(current_mod_path.."/Views.lua")
make_view_settings('SK-60', ViewSettings, SnapViews)
make_flyable('SK-60',current_mod_path..'/Cockpit/Scripts/', FM , current_mod_path..'/Comm.lua')
-------------------------------------------------------------------------------------
dofile(current_mod_path..'/SK-60.lua')
-------------------------------------------------------------------------------------
plugin_done()