dofile(LockOn_Options.common_script_path.."devices_defs.lua") --Load the default, don’t know the reason, no valid function is found in it
dofile(LockOn_Options.common_script_path.."ViewportHandling.lua") --Most non-hud displays load this file (it seems to be a viewing angle control function)

indicator_type       = indicator_types.COLLIMATOR	--Most huds use COLLIMATOR, and the main display uses COMMON. There is a doubt here.
purposes 	   = {render_purpose.GENERAL,render_purpose.HUD_ONLY_VIEW} --Rendering model

--Subpage id
BASE    = 1    --This is the top cropping frame
--BASIC_PAGE = 2 --This is the basic instrument page

--Subpage
page_subsets  = {
	[BASE]    		= LockOn_Options.script_path.."HUD/Indicator/hud_base_page.lua",    --Bottom page
	--[BASIC_PAGE]    = LockOn_Options.script_path.."MFD/Indicator/basic_page.lua",	--Basic flight data page
}
--It is currently not possible to control the display of the page set, so only one page is used to control
--Page set
pages = {
	{ BASE, }, --There is only one page set. In the case of multiple page sets, add this array
}

-- Note: Regarding the control of multiple screens, a function can be loaded here to distinguish different screen initializations, and three basepages

init_pageID = 1 --TEST_NORMAL --The first page set is loaded by default

-- mat_tbl = {
-- jf17 has a lot of material definitions here, it seems to call this macro definition directly later
-- }

--This is some material definition, I don’t understand it temporarily
-- brightness_sensitive_materials = mat_tbl
-- opacity_sensitive_materials    = mat_tbl
-- color_sensitive_materials      = mat_tbl

--Some color descriptions are marked here, the principle is unknown
-- is_colored   = true
-- day_color    = {0, 1.0, 0}
-- night_color  = {0, 0.5, 0}

-- The material.lua referenced by jf17 here also defines part of the display characters

----The part above the xxxx dividing line is the implementation of JF-17
-- The MFD of JF-17 shields the default update_screenspace function
-- The following two are to obtain the width and height of the screen, which seems to be obtained after the three helper coordinates are defined in device_init.lua
--local w = LockOn_Options.screen.width;
--local h = LockOn_Options.screen.height;
--[[
	This part mainly converts these two global parameters: [non-HUD display]
JF-17 uses this best_fit_rect function to find a synchronization value
This function comes from his own util file, and it is looking for perspective calibration (it seems)
	local hud_only_view_position = best_fit_rect(0, h * (1 - 50/120), w/3 , h * 50/120, Viewport_Align.left, Viewport_Align.vcenter, MFCD_aspect)
	dedicated_viewport
	dedicated_viewport_arcade
]]--

----XXXXXXXXXXXXXXXXXXXXXXXXXXXXX----------
-- A4 uses this function to redefine the perspective (the label is perspective shift), and the function comes from viewerhandling
-- The description of this function in the common folder is positioning on screen in HUD Only view
-- The function has three parameters: the first is the screen ratio, the second is is_left, and the third is the zoom value (A4 has no third value here)
-- I don’t know where the selfwidth and hight come from. This parameter does not appear in all scripts.
-- At present, JF-17 defines the same control function in this function, but this function has not been used, and all the places used are commented out

-- At present, these two are not necessary


update_screenspace_diplacement(SelfWidth/SelfHeight,false)

--[[
	The operation of this line is very strange, the result of the above operation is to reset the two perspectives，
	dedicated_viewport 		  = {default_x,default_y,default_width,default_height}
	dedicated_viewport_arcade = {default_x, 0	    ,default_width,default_height}
	But A4 redefines the arcade value to the viewport value at the end? Doubtful
]] 
dedicated_viewport_arcade = dedicated_viewport