dofile(LockOn_Options.script_path.."NS430/NS430_def.lua")

SHOW_MASKS = true -- enable debug

-- This operation can align the newly created cropping block to the three connectors
-- Must use FOV mode
local half_width   = GetScale()
local half_height  = GetAspect() * half_width

local aspect       = GetAspect()

-- This is the top trim layer of the total instrument
local ns430_base_clip 			 	    = CreateElement "ceMeshPoly" --This is the clipping layer
ns430_base_clip.name 			        = "ns430_base_clip"
ns430_base_clip.primitivetype   	    = "triangles"
ns430_base_clip.vertices 		        = { {1, aspect}, { 1,-aspect}, { -1,-aspect}, {-1,aspect},} --四个边角
ns430_base_clip.indices 		        = {0,1,2,0,2,3}
ns430_base_clip.init_pos		        = {0, 0, 0}
ns430_base_clip.init_rot		        = {0, 0, 0}
ns430_base_clip.material		        = "DBG_GREY"
ns430_base_clip.h_clip_relation         = h_clip_relations.REWRITE_LEVEL --INCREASE_IF_LEVEL--COMPARE --REWRITE_LEVEL
ns430_base_clip.level			        = NS430_DEFAULT_NOCLIP_LEVEL
ns430_base_clip.isdraw		            = true
ns430_base_clip.change_opacity          = false
ns430_base_clip.element_params          = {"NS430_POWER"}              -- Initialize the main display control
ns430_base_clip.controllers             = {{"opacity_using_parameter",0}}
ns430_base_clip.isvisible		        = SHOW_MASKS
Add(ns430_base_clip)