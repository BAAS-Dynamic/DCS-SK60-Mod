dofile(LockOn_Options.script_path.."NS430/NS430_def.lua")

SHOW_MASKS = true -- enable debug

-- This operation can align the newly created cropping block to the three connectors
-- Must use FOV mode
local half_width   = GetScale()
local half_height  = GetAspect() * half_width

local aspect       = GetAspect()
--default_gps_y = 1000 * aspect

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

-- StartUP Logo
local ns430_startup_icon 				        = CreateElement "ceTexPoly"
ns430_startup_icon.vertices                     = GPS_vert_gen(1500,750)
ns430_startup_icon.indices                      = {0,1,2,2,3,0}
ns430_startup_icon.tex_coords                   = tex_coord_gen(1024,0,512,256,2048,2048)
ns430_startup_icon.material                     = basic_ns430_material
ns430_startup_icon.name 			            = create_guid_string()
ns430_startup_icon.init_pos                     = {0, 0, 0}
ns430_startup_icon.init_rot		                = {0, 0, 0}
ns430_startup_icon.collimated	                = true
ns430_startup_icon.element_params               = {"NAVU_PAGE1_ENABLE"}              -- Initialize the main display control
ns430_startup_icon.controllers                  = {{"opacity_using_parameter",0}}
ns430_startup_icon.use_mipfilter                = true
ns430_startup_icon.additive_alpha               = true
ns430_startup_icon.h_clip_relation              = h_clip_relations.COMPARE
ns430_startup_icon.level                        = NS430_DEFAULT_NOCLIP_LEVEL
ns430_startup_icon.parent_element	            = "ns430_base_clip"
Add(ns430_startup_icon)

-- StartUp acknology
local ns430_startup_info 				        = CreateElement "ceTexPoly"
ns430_startup_info.vertices                     = GPS_vert_gen(2000,2000*aspect)
ns430_startup_info.indices                      = {0,1,2,2,3,0}
ns430_startup_info.tex_coords                   = tex_coord_gen(1024,256,512,256,2048,2048)
ns430_startup_info.material                     = basic_ns430_material
ns430_startup_info.name 			            = create_guid_string()
ns430_startup_info.init_pos                     = {0, 0, 0}
ns430_startup_info.init_rot		                = {0, 0, 0}
ns430_startup_info.collimated	                = true
ns430_startup_info.element_params               = {"NAVU_PAGE2_ENABLE"}              -- Initialize the main display control
ns430_startup_info.controllers                  = {{"opacity_using_parameter",0}}
ns430_startup_info.use_mipfilter                = true
ns430_startup_info.additive_alpha               = true
ns430_startup_info.h_clip_relation              = h_clip_relations.COMPARE
ns430_startup_info.level                        = NS430_DEFAULT_NOCLIP_LEVEL
ns430_startup_info.parent_element	            = "ns430_base_clip"
Add(ns430_startup_info)

-- StartUp acknology
local ns430_startup_info 				        = CreateElement "ceTexPoly"
ns430_startup_info.vertices                     = GPS_vert_gen(2000,2000*aspect)
ns430_startup_info.indices                      = {0,1,2,2,3,0}
ns430_startup_info.tex_coords                   = tex_coord_gen(0,0,1024,512,2048,2048)
ns430_startup_info.material                     = basic_ns430_material
ns430_startup_info.name 			            = create_guid_string()
ns430_startup_info.init_pos                     = {0, 0, 0}
ns430_startup_info.init_rot		                = {0, 0, 0}
ns430_startup_info.collimated	                = true
ns430_startup_info.element_params               = {"NAVU_BASE_ENABLE"}              -- Initialize the main display control
ns430_startup_info.controllers                  = {{"opacity_using_parameter",0}}
ns430_startup_info.use_mipfilter                = true
ns430_startup_info.additive_alpha               = true
ns430_startup_info.h_clip_relation              = h_clip_relations.COMPARE
ns430_startup_info.level                        = NS430_DEFAULT_NOCLIP_LEVEL
ns430_startup_info.parent_element	            = "ns430_base_clip"
Add(ns430_startup_info)