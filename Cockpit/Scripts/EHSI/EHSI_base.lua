
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
ehsi_base_clip.level			    = EHSI_DEFAULT_NOCLIP_LEVEL
ehsi_base_clip.isdraw		        = true
ehsi_base_clip.change_opacity       = false
ehsi_base_clip.element_params       = {"LEADI_DIS_ENABLE"}              -- Initialize the main display control
ehsi_base_clip.controllers          = {{"opacity_using_parameter",0}}
ehsi_base_clip.isvisible		    = SHOW_MASKS
Add(ehsi_base_clip)

local adi_surround_tex 				        = CreateElement "ceTexPoly"
adi_surround_tex.vertices                   = EHSI_vert_gen(3500,3500)
adi_surround_tex.indices                    = {0,1,2,2,3,0}
adi_surround_tex.tex_coords                 = tex_coord_gen(0,0,1024,1024,2048,2048)
adi_surround_tex.material                   = basic_ehsi_material
adi_surround_tex.name 			            = create_guid_string()
adi_surround_tex.init_pos                   = {0, 0, 0}
adi_surround_tex.init_rot		            = {0, 0, 0}
adi_surround_tex.collimated	                = true
adi_surround_tex.element_params             = {"LEADI_DIS_ENABLE"}              -- Initialize the main display control
adi_surround_tex.controllers                = {{"opacity_using_parameter",0}}
adi_surround_tex.use_mipfilter              = true
adi_surround_tex.additive_alpha             = true
adi_surround_tex.h_clip_relation            = h_clip_relations.COMPARE
adi_surround_tex.level                      = EHSI_DEFAULT_NOCLIP_LEVEL
adi_surround_tex.parent_element	            = "ehsi_base_clip"
Add(adi_surround_tex)