self_ID = "SK-60"
declare_plugin(self_ID,
{
image     	 = "FC3.bmp",
installed 	 = true, -- if false that will be place holder , or advertising
dirName	  	 = current_mod_path,
displayName  = _("SK-60"),
developerName = _("Saab"),

fileMenuName = _("SK-60"),
update_id    = "SK-60",
version		 = "Development build",
state		 = "installed",
info		 = _("SK-60 or Saab-105 is a swedish twin seat high performance training jet."),
encyclopedia_path = current_mod_path..'/Encyclopedia',

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

dofile(current_mod_path.."/Views.lua")
make_view_settings('SK-60', ViewSettings, SnapViews)
make_flyable('SK-60',current_mod_path..'/Cockpit/Scripts/', FM , current_mod_path..'/Comm.lua')
-------------------------------------------------------------------------------------
dofile(current_mod_path..'/SK-60.lua')
-------------------------------------------------------------------------------------
plugin_done()