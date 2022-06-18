dofile(LockOn_Options.common_script_path.."devices_defs.lua") 
dofile(LockOn_Options.common_script_path.."ViewportHandling.lua") 

indicator_type       = indicator_types.COMMON --COLLIMATOR
purposes       		 = {100, render_purpose.SCREENSPACE_INSIDE_COCKPIT}
-- purposes 	   		 = {render_purpose.SCREENSPACE_INSIDE_COCKPIT}

BASE    = 1 

-- cant apply multi page
page_subsets  = {
	[BASE]    		= LockOn_Options.script_path.."CustomMenu/Indicators/menu_base_page.lua",
}

pages = {
	{ BASE, }, 
}

init_pageID = 1

local  default_height = LockOn_Options.screen.height
local  default_width  = LockOn_Options.screen.width

dedicated_viewport 	      = {10,10,default_width,default_height}
dedicated_viewport_arcade = dedicated_viewport

-- update_screenspace_diplacement(SelfWidth/SelfHeight,false)
-- dedicated_viewport_arcade = dedicated_viewport