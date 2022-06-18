dofile(LockOn_Options.script_path.."DBGiPad/ipad_def.lua")

SHOW_MASKS = true-- enable debug

-- This operation can align the newly created cropping block to the three connectors
-- Must use FOV mode
local half_width   = GetScale()
local half_height  = GetAspect() * half_width

local aspect       = GetAspect()

-- This is the top trim layer of the total instrument
local base_clip 			 	= CreateElement "ceMeshPoly" --This is the clipping layer
base_clip.name 			        = "base_clip"
base_clip.primitivetype   	    = "triangles"
base_clip.vertices 		        = { {1, aspect}, { 1,-aspect}, { -1,-aspect}, {-1,aspect},} --四个边角
base_clip.indices 		        = {0,1,2,0,2,3}
base_clip.init_pos		        = {0, 0, 0}
base_clip.init_rot		        = {0, 0, 0}
base_clip.material		        = "DBG_GREY"
base_clip.h_clip_relation       = h_clip_relations.REWRITE_LEVEL --INCREASE_IF_LEVEL--COMPARE --REWRITE_LEVEL
base_clip.level			        = IPAD_DEFAULT_NOCLIP_LEVEL
base_clip.isdraw		        = true
base_clip.change_opacity        = false
base_clip.element_params        = {"IPAD_DIS_ENABLE"}              -- Initialize the main display control
base_clip.controllers           = {{"opacity_using_parameter",0}}
base_clip.isvisible		        = SHOW_MASKS
Add(base_clip)

dofile(LockOn_Options.script_path.."DBGiPad/Indicators/ipad_mp3_page.lua")