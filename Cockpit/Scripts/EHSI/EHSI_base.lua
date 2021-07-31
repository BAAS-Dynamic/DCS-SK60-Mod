
dofile(LockOn_Options.script_path.."EHSI/EHSI_def.lua")

SHOW_MASKS = true -- enable debug

-- This operation can align the newly created cropping block to the three connectors
-- Must use FOV mode
local half_width   = GetScale()
local half_height  = GetAspect() * half_width

local aspect       = GetAspect()

-- This is the top trim layer of the total instrument
local ehsi_base_clip 			 	= CreateElement "ceMeshPoly" --This is the clipping layer
ehsi_base_clip.name 			    = "ehsi_base_clip"
ehsi_base_clip.primitivetype   	    = "triangles"
ehsi_base_clip.vertices 		    = { {1, aspect}, { 1,-aspect}, { -1,-aspect}, {-1,aspect},} --四个边角
ehsi_base_clip.indices 		        = {0,1,2,0,2,3}
ehsi_base_clip.init_pos		        = {0, 0, 0}
ehsi_base_clip.init_rot		        = {0, 0, 0}
ehsi_base_clip.material		        = "DBG_GREY"
ehsi_base_clip.h_clip_relation      = h_clip_relations.REWRITE_LEVEL --INCREASE_IF_LEVEL--COMPARE --REWRITE_LEVEL
ehsi_base_clip.level			    = EADI_DEFAULT_NOCLIP_LEVEL
ehsi_base_clip.isdraw		        = true
ehsi_base_clip.change_opacity       = false
ehsi_base_clip.element_params       = {"LEADI_DIS_ENABLE"}              -- Initialize the main display control
ehsi_base_clip.controllers          = {{"opacity_using_parameter",0}}
ehsi_base_clip.isvisible		    = SHOW_MASKS
Add(ehsi_base_clip)