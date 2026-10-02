dofile(LockOn_Options.common_script_path.."devices_defs.lua") --,,
dofile(LockOn_Options.common_script_path.."ViewportHandling.lua") --hud()

indicator_type       = indicator_types.COLLIMATOR --hudCOLLIMATOR,COMMON,
purposes 	   = {render_purpose.GENERAL,render_purpose.HUD_ONLY_VIEW}

-- id
BASE    = 1

page_subsets  = {
	[BASE]    		= LockOn_Options.script_path.."GunSight/gunsight_base.lua",
}


pages = {
	{ BASE, },
}

init_pageID = 1 --TEST_NORMAL --

update_screenspace_diplacement(SelfWidth/SelfHeight,false)

--[[
	This operation is unusual. The call above resets two viewports:
	dedicated_viewport 		  = {default_x,default_y,default_width,default_height}
	dedicated_viewport_arcade = {default_x, 0	    ,default_width,default_height}
		The arcade viewport is then reset to the dedicated viewport; keep this under review.
]]
dedicated_viewport_arcade = dedicated_viewport