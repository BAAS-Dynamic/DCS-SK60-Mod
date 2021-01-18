dofile(LockOn_Options.script_path.."HUD/Indicator/hud_def.lua")

SHOW_MASKS = false

-- This operation can align the newly created cropping block to the three connectors
-- Must use FOV mode
local half_width   = GetScale()
local half_height  = GetAspect() * half_width

local aspect       = GetAspect()

-- This is the top trim layer of the total instrument
HUD_base_clip 			 	    = CreateElement "ceMeshPoly" --This is the clipping layer
HUD_base_clip.name 			    = "hud_base_clip"
HUD_base_clip.primitivetype   	= "triangles"
HUD_base_clip.vertices 		    = { {1, aspect}, { 1,-aspect}, { -1,-aspect}, {-1,aspect}, { -0.8, 1.35 * aspect} , { 0.8, 1.35 * aspect} , {0.95, aspect} , {-0.95, aspect} , {0, 1.4 * aspect}, {1.3, 0} , {-1.3 , 0} , } --四个边角
HUD_base_clip.indices 		    = {0,1,2,0,2,3,4,5,6,4,6,7,4,5,8,0,1,9,2,3,10} -- Index, each group of three forms a triangle that will be displayed, and the number represents the previous vert coordinate
HUD_base_clip.init_pos		    = {0, 0, 0}
HUD_base_clip.init_rot		    = {0, 0, 0}
HUD_base_clip.material		    = "DBG_GREY"
HUD_base_clip.h_clip_relation   = h_clip_relations.REWRITE_LEVEL --INCREASE_IF_LEVEL--COMPARE --REWRITE_LEVEL
HUD_base_clip.level			    = HUD_DEFAULT_NOCLIP_LEVEL
HUD_base_clip.isdraw		    = true
HUD_base_clip.change_opacity    = false
HUD_base_clip.element_params    = {"HUD_DIS_ENABLE"}              -- Initialize the main display control
HUD_base_clip.controllers       = {{"opacity_using_parameter",0}}
HUD_base_clip.isvisible		    = SHOW_MASKS
Add(HUD_base_clip)

-- Speed ​​moving bar clipping layer
speed_move_clip 			            = CreateElement "ceMeshPoly" --这是创建一个裁剪框
speed_move_clip.name 			        = "speed_move_clip"
speed_move_clip.vertices 		        = hud_duo_vert_gen(680, 2600, 232)
speed_move_clip.indices 		        = {0,1,2,0,3,2,4,5,6,5,6,7}
speed_move_clip.init_pos		        = { - 1 , 0.2 , default_hud_z_offset}
speed_move_clip.init_rot		        = {0, 0, default_hud_rot_offset}
speed_move_clip.material		        = "DBG_GREEN"
speed_move_clip.h_clip_relation         = h_clip_relations.INCREASE_IF_LEVEL--COMPARE --REWRITE_LEVEL
speed_move_clip.level			        = HUD_DEFAULT_LEVEL - 1
speed_move_clip.change_opacity          = false
speed_move_clip.element_params          = {"HUD_DIS_ENABLE"}              -- Initialize the main display control
speed_move_clip.controllers             = {{"opacity_using_parameter",0}}
speed_move_clip.isvisible		        = SHOW_MASKS
Add(speed_move_clip)

-- Clipping layer of heading movement bar
heading_move_clip 			            = CreateElement "ceMeshPoly" 
heading_move_clip.name 			        = "heading_move_clip"
heading_move_clip.vertices 		        = hud_vert_gen(3200, 300) --四个边角
heading_move_clip.indices 		        = {0,1,2,0,3,2}
heading_move_clip.init_pos		        = {0 , 2080 / 2000 , default_hud_z_offset}
heading_move_clip.init_rot		        = {0, 0, default_hud_rot_offset}
heading_move_clip.material		        = "DBG_GREEN"
heading_move_clip.h_clip_relation       = h_clip_relations.INCREASE_IF_LEVEL--COMPARE --REWRITE_LEVEL
heading_move_clip.level			        = HUD_DEFAULT_LEVEL - 1
heading_move_clip.change_opacity        = false
heading_move_clip.element_params        = {"HUD_DIS_ENABLE"}              -- Initialize the main display control
heading_move_clip.controllers           = {{"opacity_using_parameter",0}}
heading_move_clip.isvisible		        = SHOW_MASKS
Add(heading_move_clip)

-- Speed ​​moving bar clipping layer
altitude_move_clip 			                = CreateElement "ceMeshPoly" 
altitude_move_clip.name 			        = "altitude_move_clip"
altitude_move_clip.vertices 		        = hud_duo_vert_gen(680, 2600, 232)
altitude_move_clip.indices 		            = {0,1,2,0,3,2,4,5,6,5,6,7}
altitude_move_clip.init_pos		            = { 1 , 0.2 , default_hud_z_offset}
altitude_move_clip.init_rot		            = {0, 0, default_hud_rot_offset}
altitude_move_clip.material		            = "DBG_GREEN"
altitude_move_clip.h_clip_relation          = h_clip_relations.INCREASE_IF_LEVEL--COMPARE --REWRITE_LEVEL
altitude_move_clip.level			        = HUD_DEFAULT_LEVEL - 1
altitude_move_clip.change_opacity           = false
altitude_move_clip.element_params           = {"HUD_DIS_ENABLE"}              -- Initialize the main display control
altitude_move_clip.controllers              = {{"opacity_using_parameter",0}}
altitude_move_clip.isvisible		        = SHOW_MASKS
Add(altitude_move_clip)

-- 加载警告标记
dofile(LockOn_Options.script_path.."HUD/Indicator/hud_warning_sign.lua")
-- 加载导航标记
dofile(LockOn_Options.script_path.."HUD/Indicator/hud_nav_page.lua")