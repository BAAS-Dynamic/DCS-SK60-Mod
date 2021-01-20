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
eadi_base_clip.isvisible		    = SHOW_MASKS
Add(eadi_base_clip)

-- 250 * 16

local eadi_adi_clip 			    = CreateElement "ceMeshPoly" --create second clip
eadi_adi_clip.name 			        = "eadi_adi_clip"
eadi_adi_clip.vertices 		        = create_EADI_circle_pos(61, 0, 0, 1900)
eadi_adi_clip.indices 		        = create_EADI_circle_index(61)
eadi_adi_clip.init_pos		        = {0, 0, 0}
eadi_adi_clip.init_rot		        = {0, 0, 0}
eadi_adi_clip.material		        = "DBG_GREY"
eadi_adi_clip.h_clip_relation       = h_clip_relations.INCREASE_IF_LEVEL--COMPARE --REWRITE_LEVEL
eadi_adi_clip.level			        = EADI_DEFAULT_LEVEL - 1
eadi_adi_clip.change_opacity        = false
eadi_adi_clip.element_params        = {"LEADI_DIS_ENABLE"}              -- Initialize the main display control
eadi_adi_clip.controllers           = {{"opacity_using_parameter",0}}
eadi_adi_clip.isvisible		        = SHOW_MASKS
Add(eadi_adi_clip)

local center_tex 				      = CreateElement "ceTexPoly"
center_tex.vertices                 = EADI_vert_gen(1000,640)
center_tex.indices                  = {0,1,2,2,3,0}
center_tex.tex_coords               = tex_coord_gen(0,728,250,160,1024,1024)
center_tex.material                 = basic_eadi_material
center_tex.name 			        = create_guid_string()
center_tex.init_pos                 = {0, -0.1, 0}
center_tex.init_rot		            = {0, 0, 0}
center_tex.collimated	            = true
center_tex.element_params           = {"LEADI_DIS_ENABLE"}              -- Initialize the main display control
center_tex.controllers              = {{"opacity_using_parameter",0}}
center_tex.use_mipfilter            = true
center_tex.additive_alpha           = true
center_tex.h_clip_relation          = h_clip_relations.COMPARE
center_tex.level                    = EADI_DEFAULT_LEVEL
center_tex.parent_element	        = "eadi_adi_clip"
Add(center_tex)

local eadi_adi_rotate                   = CreateElement "ceSimple"
eadi_adi_rotate.name                    = "eadi_adi_rotate"
eadi_adi_rotate.init_pos                = {0, 0, 0}
eadi_adi_rotate.element_params          = {"GYRO_ROLL",}
eadi_adi_rotate.controllers             = {{"rotate_using_parameter", 0, 0.0174532925199433 * 180},}
eadi_adi_rotate.collimated	            = true
eadi_adi_rotate.use_mipfilter           = true
eadi_adi_rotate.additive_alpha          = true
eadi_adi_rotate.h_clip_relation         = h_clip_relations.COMPARE
eadi_adi_rotate.level                   = EADI_DEFAULT_LEVEL
eadi_adi_rotate.parent_element	        = "eadi_adi_clip"
eadi_adi_rotate.isvisible               = false
Add(eadi_adi_rotate)

-- 310 * 310 in display -> equal to 1900 * 1900  360 * 1024 
local gyro_tex 				      = CreateElement "ceTexPoly"
gyro_tex.vertices                 = EADI_vert_gen(2206*2,6276*2)
gyro_tex.indices                  = {0,1,2,2,3,0}
gyro_tex.tex_coords               = tex_coord_gen(664,0,360,1024,1024,1024)
gyro_tex.material                 = basic_eadi_material
gyro_tex.name 			          = create_guid_string()
gyro_tex.init_pos                 = {0, 0, 0}
gyro_tex.init_rot		          = {0, 0, 0}
gyro_tex.collimated	              = true
gyro_tex.element_params           = {"GYRO_PITCH",}
gyro_tex.controllers              = {{"move_up_down_using_parameter",0,0.075},}
gyro_tex.use_mipfilter            = true
gyro_tex.additive_alpha           = true
gyro_tex.h_clip_relation          = h_clip_relations.COMPARE
gyro_tex.level                    = EADI_DEFAULT_LEVEL
gyro_tex.parent_element	          = "eadi_adi_rotate"
Add(gyro_tex)