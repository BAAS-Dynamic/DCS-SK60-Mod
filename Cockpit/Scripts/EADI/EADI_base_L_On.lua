dofile(LockOn_Options.script_path.."EADI/EADI_def.lua")

SHOW_MASKS = true -- enable debug

-- This operation can align the newly created cropping block to the three connectors
-- Must use FOV mode
local half_width   = GetScale()
local half_height  = GetAspect() * half_width

local aspect       = GetAspect()

-- This is the top trim layer of the total instrument
local eadi_base_clip 			 	= CreateElement "ceMeshPoly" --This is the clipping layer
eadi_base_clip.name 			    = "eadi_base_clip"
eadi_base_clip.primitivetype   	    = "triangles"
eadi_base_clip.vertices 		    = { {1, aspect}, { 1,-aspect}, { -1,-aspect}, {-1,aspect},} --四个边角
eadi_base_clip.indices 		        = {0,1,2,0,2,3}
eadi_base_clip.init_pos		        = {0, 0, 0}
eadi_base_clip.init_rot		        = {0, 0, 0}
eadi_base_clip.material		        = "DBG_GREY"
eadi_base_clip.h_clip_relation      = h_clip_relations.REWRITE_LEVEL --INCREASE_IF_LEVEL--COMPARE --REWRITE_LEVEL
eadi_base_clip.level			    = EADI_DEFAULT_NOCLIP_LEVEL
eadi_base_clip.isdraw		        = true
eadi_base_clip.change_opacity       = false
eadi_base_clip.element_params       = {"LEADI_DIS_ENABLE"}              -- Initialize the main display control
eadi_base_clip.controllers          = {{"opacity_using_parameter",0}}
eadi_base_clip.isvisible		    = false--SHOW_MASKS
Add(eadi_base_clip)

local eadi_adi_clip 			    = CreateElement "ceMeshPoly" --create second clip
eadi_adi_clip.name 			        = "eadi_test_clip"
eadi_adi_clip.vertices 		        = EADI_vert_gen(2000,600)
eadi_adi_clip.indices 		        = {0,1,2,0,2,3}
eadi_adi_clip.init_pos		        = {0, 0, 10/2000}
eadi_adi_clip.init_rot		        = {0, 0, 0}
eadi_adi_clip.material		        = "DBG_RED"
eadi_adi_clip.h_clip_relation       = h_clip_relations.REWRITE_LEVEL--COMPARE --REWRITE_LEVEL
eadi_adi_clip.level			        = EADI_DEFAULT_NOCLIP_LEVEL
eadi_adi_clip.change_opacity        = false
eadi_adi_clip.element_params        = {"LEADI_DIS_ENABLE"}              -- Initialize the main display control
eadi_adi_clip.controllers           = {{"opacity_using_parameter",0}}
eadi_adi_clip.isvisible		        = false
Add(eadi_adi_clip)