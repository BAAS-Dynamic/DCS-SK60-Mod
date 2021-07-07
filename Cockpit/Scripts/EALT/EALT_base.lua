dofile(LockOn_Options.script_path.."EALT/EALT_def.lua")

SHOW_MASKS = true -- enable debug

-- This operation can align the newly created cropping block to the three connectors
-- Must use FOV mode
local half_width   = GetScale()
local half_height  = GetAspect() * half_width

local aspect       = GetAspect()

-- This is the top trim layer of the total instrument
local eadi_base_clip 			 	= CreateElement "ceMeshPoly" --This is the clipping layer
eadi_base_clip.name 			    = "ealt_base_clip"
eadi_base_clip.primitivetype   	    = "triangles"
eadi_base_clip.vertices 		    = {{-0.92, 0.45*aspect},{-0.92, -0.25*aspect},{-1, -0.25*aspect},{-1, -aspect},{-0.2, -aspect},{-0.2, 0.45*aspect}--[[left unit]], {0.35, 0.5*aspect}, {0.35, 0.3*aspect}, {0.1, 0.3*aspect}, {0.1, -0.35*aspect}, {0.35, -0.35*aspect}, {0.35, -0.55*aspect}, {-0.1, -0.55*aspect}, {-0.1,-aspect},{1, -aspect}, {1,0.5 *aspect}, } --{ {1, aspect}, { 1,-aspect}, { -1,-aspect}, {-1,aspect},} --四个边角
eadi_base_clip.indices 		        = {1,2,3,1,3,4,1,4,5,0,1,5--[[left display unit]],7,8,9,7,9,10,11,12,13,11,13,14,10,11,14,10,14,15,6,10,15}
eadi_base_clip.init_pos		        = {0, 0, 0}
eadi_base_clip.init_rot		        = {0, 0, 0}
eadi_base_clip.material		        = "EALT_BG_COLOR"
eadi_base_clip.h_clip_relation      = h_clip_relations.REWRITE_LEVEL --INCREASE_IF_LEVEL--COMPARE --REWRITE_LEVEL
eadi_base_clip.level			    = EALT_DEFAULT_NOCLIP_LEVEL
eadi_base_clip.isdraw		        = true
eadi_base_clip.change_opacity       = false
eadi_base_clip.element_params       = {"EALT_DIS_ENABLE"}              -- Initialize the main display control
eadi_base_clip.controllers          = {{"opacity_using_parameter",0}}
eadi_base_clip.isvisible		    = SHOW_MASKS
Add(eadi_base_clip)

