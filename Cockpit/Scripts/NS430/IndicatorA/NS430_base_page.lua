dofile(LockOn_Options.script_path.."NS430/IndicatorA/NS430_layer_A_def.lua")

SHOW_MASKS = true -- enable debug

-- This operation can align the newly created cropping block to the three connectors
-- Must use FOV mode
local half_width   = GetScale()
local half_height  = GetAspect() * half_width

aspect       = GetAspect()
--default_gps_y = 1000 * aspect
map_scaler    = 0.02

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

-- Base Enable as a whole group
-- including the Left and Down surround and display
-- only disable when some setting page take whole screen

-- Base Screen background
-- only contain the lines
local bs430_base_surround 				            = CreateElement "ceTexPoly"
bs430_base_surround.vertices                        = GPS_vert_gen(2000,2000*aspect)
bs430_base_surround.indices                         = {0,1,2,2,3,0}
bs430_base_surround.tex_coords                      = tex_coord_gen(0,0,1024,512,2048,2048)
bs430_base_surround.material                        = blue_ns430_material
bs430_base_surround.name 			                = create_guid_string()
bs430_base_surround.init_pos                        = {0, 0, 0}
bs430_base_surround.init_rot		                = {0, 0, 0}
bs430_base_surround.collimated	                    = true
bs430_base_surround.element_params                  = {"NAVU_BASE_ENABLE"}              -- Initialize the main display control
bs430_base_surround.controllers                     = {{"opacity_using_parameter",0}}
bs430_base_surround.use_mipfilter                   = true
bs430_base_surround.additive_alpha                  = true
bs430_base_surround.h_clip_relation                 = h_clip_relations.COMPARE
bs430_base_surround.level                           = NS430_DEFAULT_NOCLIP_LEVEL
bs430_base_surround.parent_element	                = "ns430_base_clip"
Add(bs430_base_surround)

-- 225 * 156 line width = 41 2 55 2 55 2 100  
-- = 440 * 304.7

local bs430_base_surround 				            = CreateElement "ceTexPoly"
bs430_base_surround.vertices                        = GPS_vert_gen(440, 390.625*aspect)
bs430_base_surround.indices                         = {0,1,2,2,3,0}
bs430_base_surround.tex_coords                      = tex_coord_gen(0,0,1024,512,2048,2048)
bs430_base_surround.material                        = "EALT_BG_COLOR" -- blue_ns430_material
bs430_base_surround.name 			                = create_guid_string()
bs430_base_surround.init_pos                        = {-1 + 231.72/default_gps_x, 1*aspect - 218.7525*aspect/default_gps_x, 0}
bs430_base_surround.init_rot		                = {0, 0, 0}
bs430_base_surround.collimated	                    = true
bs430_base_surround.element_params                  = {"NAVU_BASE_ENABLE"}              -- Initialize the main display control
bs430_base_surround.controllers                     = {{"opacity_using_parameter",0}}
bs430_base_surround.use_mipfilter                   = true
bs430_base_surround.additive_alpha                  = true
bs430_base_surround.h_clip_relation                 = h_clip_relations.COMPARE
bs430_base_surround.level                           = NS430_DEFAULT_NOCLIP_LEVEL
bs430_base_surround.parent_element	                = "ns430_base_clip"
Add(bs430_base_surround)

local bs430_base_surround 				            = CreateElement "ceTexPoly"
bs430_base_surround.vertices                        = GPS_vert_gen(440, 218.775*aspect)
bs430_base_surround.indices                         = {0,1,2,2,3,0}
bs430_base_surround.tex_coords                      = tex_coord_gen(0,0,1024,512,2048,2048)
bs430_base_surround.material                        = "EALT_BG_COLOR" -- blue_ns430_material
bs430_base_surround.name 			                = create_guid_string()
bs430_base_surround.init_pos                        = {-1 + 231.72/default_gps_x, 1*aspect - 520*aspect/default_gps_x, 0}
bs430_base_surround.init_rot		                = {0, 0, 0}
bs430_base_surround.collimated	                    = true
bs430_base_surround.element_params                  = {"NAVU_BASE_ENABLE", "FREQ_FOCUS_COM"}              -- Initialize the main display control {0,50,255,255}
bs430_base_surround.controllers                     = {{"opacity_using_parameter",0}, {"change_color_when_parameter_equal_to_number", 1, 1, 30/255,100/255,140/255}}
bs430_base_surround.use_mipfilter                   = true
bs430_base_surround.additive_alpha                  = true
bs430_base_surround.h_clip_relation                 = h_clip_relations.COMPARE
bs430_base_surround.level                           = NS430_DEFAULT_NOCLIP_LEVEL
bs430_base_surround.parent_element	                = "ns430_base_clip"
Add(bs430_base_surround)

local BS430_COM_FREQ             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
BS430_COM_FREQ.material          = "BS430_font_white"    --FONT_             --Material type (note the font material created above)
BS430_COM_FREQ.init_pos          = {-1 + 30.72/default_gps_x, 1*aspect - 440*aspect/default_gps_x}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
BS430_COM_FREQ.alignment         = "LeftDown"       --Alignment settings：Left/Right/Center; Top/Down/Center
BS430_COM_FREQ.stringdefs        = {1.5*0.004,1.5 * 0.004, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
BS430_COM_FREQ.formats           = {"%03.0f.", "%s"}
BS430_COM_FREQ.element_params    = {"COM_FREQ_ACT_1", "NAVU_BASE_ENABLE"} -- top left first line display
BS430_COM_FREQ.controllers       = {{"text_using_parameter",0},{"opacity_using_parameter",1}}
BS430_COM_FREQ.collimated        = true
BS430_COM_FREQ.use_mipfilter     = true
BS430_COM_FREQ.additive_alpha    = true
BS430_COM_FREQ.isvisible		  = true
BS430_COM_FREQ.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
BS430_COM_FREQ.level			  = NS430_DEFAULT_NOCLIP_LEVEL
BS430_COM_FREQ.parent_element    = "ns430_base_clip"  --Parent node name - can bind parent nodes that are not on the same layer
Add(BS430_COM_FREQ)

local BS430_COM_FREQ             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
BS430_COM_FREQ.material          = "BS430_font_white"    --FONT_             --Material type (note the font material created above)
BS430_COM_FREQ.init_pos          = {-1 + 281.72/default_gps_x, 1*aspect - 420*aspect/default_gps_x}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
BS430_COM_FREQ.alignment         = "RightDown"       --Alignment settings：Left/Right/Center; Top/Down/Center
BS430_COM_FREQ.stringdefs        = {1.1*0.004,1.1 * 0.004, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
BS430_COM_FREQ.formats           = {"%03.0f", "%s"}
BS430_COM_FREQ.element_params    = {"COM_FREQ_ACT_2", "NAVU_BASE_ENABLE"} -- top left first line display
BS430_COM_FREQ.controllers       = {{"text_using_parameter",0},{"opacity_using_parameter",1}}
BS430_COM_FREQ.collimated        = true
BS430_COM_FREQ.use_mipfilter     = true
BS430_COM_FREQ.additive_alpha    = true
BS430_COM_FREQ.isvisible		 = true
BS430_COM_FREQ.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
BS430_COM_FREQ.level			 = NS430_DEFAULT_NOCLIP_LEVEL
BS430_COM_FREQ.parent_element    = "ns430_base_clip"  --Parent node name - can bind parent nodes that are not on the same layer
Add(BS430_COM_FREQ)

local line2_offset = 220

local BS430_COM_FREQ             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
BS430_COM_FREQ.material          = "BS430_font_white"    --FONT_             --Material type (note the font material created above)
BS430_COM_FREQ.init_pos          = {-1 + 30.72/default_gps_x, 1*aspect - (440 + line2_offset)*aspect/default_gps_x}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
BS430_COM_FREQ.alignment         = "LeftDown"       --Alignment settings：Left/Right/Center; Top/Down/Center
BS430_COM_FREQ.stringdefs        = {1.5*0.004,1.5 * 0.004, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
BS430_COM_FREQ.formats           = {"%03.0f.", "%s"}
BS430_COM_FREQ.element_params    = {"COM_FREQ_STB_1", "NAVU_BASE_ENABLE", "FREQ_FOCUS_COM"} -- top left first line display
BS430_COM_FREQ.controllers       = {{"text_using_parameter",0},{"opacity_using_parameter",1},{"change_color_when_parameter_equal_to_number", 2, 1, 255/255,255/255,255/255}}
BS430_COM_FREQ.collimated        = true
BS430_COM_FREQ.use_mipfilter     = true
BS430_COM_FREQ.additive_alpha    = true
BS430_COM_FREQ.isvisible		  = true
BS430_COM_FREQ.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
BS430_COM_FREQ.level			  = NS430_DEFAULT_NOCLIP_LEVEL
BS430_COM_FREQ.parent_element    = "ns430_base_clip"  --Parent node name - can bind parent nodes that are not on the same layer
Add(BS430_COM_FREQ)

local BS430_COM_FREQ             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
BS430_COM_FREQ.material          = "BS430_font_white"    --FONT_             --Material type (note the font material created above)
BS430_COM_FREQ.init_pos          = {-1 + 281.72/default_gps_x, 1*aspect - (420 + line2_offset)*aspect/default_gps_x}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
BS430_COM_FREQ.alignment         = "RightDown"       --Alignment settings：Left/Right/Center; Top/Down/Center
BS430_COM_FREQ.stringdefs        = {1.1*0.004,1.1 * 0.004, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
BS430_COM_FREQ.formats           = {"%03.0f", "%s"}
BS430_COM_FREQ.element_params    = {"COM_FREQ_STB_2", "NAVU_BASE_ENABLE", "FREQ_FOCUS_COM"} -- top left first line display
BS430_COM_FREQ.controllers       = {{"text_using_parameter",0},{"opacity_using_parameter",1},{"change_color_when_parameter_equal_to_number", 2, 1, 255/255,255/255,255/255}}
BS430_COM_FREQ.collimated        = true
BS430_COM_FREQ.use_mipfilter     = true
BS430_COM_FREQ.additive_alpha    = true
BS430_COM_FREQ.isvisible		 = true
BS430_COM_FREQ.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
BS430_COM_FREQ.level			 = NS430_DEFAULT_NOCLIP_LEVEL
BS430_COM_FREQ.parent_element    = "ns430_base_clip"  --Parent node name - can bind parent nodes that are not on the same layer
Add(BS430_COM_FREQ)

local temp_move_y = 670 * aspect / default_gps_x
-- VLOC part
local bs430_base_surround 				            = CreateElement "ceTexPoly"
bs430_base_surround.vertices                        = GPS_vert_gen(440, 390.625*aspect)
bs430_base_surround.indices                         = {0,1,2,2,3,0}
bs430_base_surround.tex_coords                      = tex_coord_gen(0,0,1024,512,2048,2048)
bs430_base_surround.material                        = "EALT_BG_COLOR" -- blue_ns430_material
bs430_base_surround.name 			                = create_guid_string()
bs430_base_surround.init_pos                        = {-1 + 231.72/default_gps_x, 1*aspect - 218.7525*aspect/default_gps_x - temp_move_y, 0}
bs430_base_surround.init_rot		                = {0, 0, 0}
bs430_base_surround.collimated	                    = true
bs430_base_surround.element_params                  = {"NAVU_BASE_ENABLE"}              -- Initialize the main display control
bs430_base_surround.controllers                     = {{"opacity_using_parameter",0}}
bs430_base_surround.use_mipfilter                   = true
bs430_base_surround.additive_alpha                  = true
bs430_base_surround.h_clip_relation                 = h_clip_relations.COMPARE
bs430_base_surround.level                           = NS430_DEFAULT_NOCLIP_LEVEL
bs430_base_surround.parent_element	                = "ns430_base_clip"
Add(bs430_base_surround)

local bs430_base_surround 				            = CreateElement "ceTexPoly"
bs430_base_surround.vertices                        = GPS_vert_gen(440, 218.775*aspect)
bs430_base_surround.indices                         = {0,1,2,2,3,0}
bs430_base_surround.tex_coords                      = tex_coord_gen(0,0,1024,512,2048,2048)
bs430_base_surround.material                        = "EALT_BG_COLOR" -- blue_ns430_material
bs430_base_surround.name 			                = create_guid_string()
bs430_base_surround.init_pos                        = {-1 + 231.72/default_gps_x, 1*aspect - 520*aspect/default_gps_x - temp_move_y, 0}
bs430_base_surround.init_rot		                = {0, 0, 0}
bs430_base_surround.collimated	                    = true
bs430_base_surround.element_params                  = {"NAVU_BASE_ENABLE", "FREQ_FOCUS_LOC"}              -- Initialize the main display control {0,50,255,255}
bs430_base_surround.controllers                     = {{"opacity_using_parameter",0}, {"change_color_when_parameter_equal_to_number", 1, 1, 30/255,100/255,140/255}}
bs430_base_surround.use_mipfilter                   = true
bs430_base_surround.additive_alpha                  = true
bs430_base_surround.h_clip_relation                 = h_clip_relations.COMPARE
bs430_base_surround.level                           = NS430_DEFAULT_NOCLIP_LEVEL
bs430_base_surround.parent_element	                = "ns430_base_clip"
Add(bs430_base_surround)

local BS430_COM_FREQ             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
BS430_COM_FREQ.material          = "BS430_font_white"    --FONT_             --Material type (note the font material created above)
BS430_COM_FREQ.init_pos          = {-1 + 30.72/default_gps_x, 1*aspect - 440*aspect/default_gps_x - temp_move_y}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
BS430_COM_FREQ.alignment         = "LeftDown"       --Alignment settings：Left/Right/Center; Top/Down/Center
BS430_COM_FREQ.stringdefs        = {1.5*0.004,1.5 * 0.004, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
BS430_COM_FREQ.formats           = {"%03.0f.", "%s"}
BS430_COM_FREQ.element_params    = {"LOC_FREQ_ACT_1", "NAVU_BASE_ENABLE"} -- top left first line display
BS430_COM_FREQ.controllers       = {{"text_using_parameter",0},{"opacity_using_parameter",1}}
BS430_COM_FREQ.collimated        = true
BS430_COM_FREQ.use_mipfilter     = true
BS430_COM_FREQ.additive_alpha    = true
BS430_COM_FREQ.isvisible		  = true
BS430_COM_FREQ.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
BS430_COM_FREQ.level			  = NS430_DEFAULT_NOCLIP_LEVEL
BS430_COM_FREQ.parent_element    = "ns430_base_clip"  --Parent node name - can bind parent nodes that are not on the same layer
Add(BS430_COM_FREQ)

local BS430_COM_FREQ             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
BS430_COM_FREQ.material          = "BS430_font_white"    --FONT_             --Material type (note the font material created above)
BS430_COM_FREQ.init_pos          = {-1 + 281.72/default_gps_x, 1*aspect - 420*aspect/default_gps_x - temp_move_y}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
BS430_COM_FREQ.alignment         = "RightDown"       --Alignment settings：Left/Right/Center; Top/Down/Center
BS430_COM_FREQ.stringdefs        = {1.1*0.004,1.1 * 0.004, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
BS430_COM_FREQ.formats           = {"%02.0f", "%s"}
BS430_COM_FREQ.element_params    = {"LOC_FREQ_ACT_2", "NAVU_BASE_ENABLE"} -- top left first line display
BS430_COM_FREQ.controllers       = {{"text_using_parameter",0},{"opacity_using_parameter",1}}
BS430_COM_FREQ.collimated        = true
BS430_COM_FREQ.use_mipfilter     = true
BS430_COM_FREQ.additive_alpha    = true
BS430_COM_FREQ.isvisible		 = true
BS430_COM_FREQ.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
BS430_COM_FREQ.level			 = NS430_DEFAULT_NOCLIP_LEVEL
BS430_COM_FREQ.parent_element    = "ns430_base_clip"  --Parent node name - can bind parent nodes that are not on the same layer
Add(BS430_COM_FREQ)

local line2_offset = 220

local BS430_COM_FREQ             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
BS430_COM_FREQ.material          = "BS430_font_white"    --FONT_             --Material type (note the font material created above)
BS430_COM_FREQ.init_pos          = {-1 + 30.72/default_gps_x, 1*aspect - (440 + line2_offset)*aspect/default_gps_x - temp_move_y}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
BS430_COM_FREQ.alignment         = "LeftDown"       --Alignment settings：Left/Right/Center; Top/Down/Center
BS430_COM_FREQ.stringdefs        = {1.5*0.004,1.5 * 0.004, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
BS430_COM_FREQ.formats           = {"%03.0f.", "%s"}
BS430_COM_FREQ.element_params    = {"LOC_FREQ_STB_1", "NAVU_BASE_ENABLE", "FREQ_FOCUS_LOC"} -- top left first line display
BS430_COM_FREQ.controllers       = {{"text_using_parameter",0},{"opacity_using_parameter",1},{"change_color_when_parameter_equal_to_number", 2, 1, 255/255,255/255,255/255}}
BS430_COM_FREQ.collimated        = true
BS430_COM_FREQ.use_mipfilter     = true
BS430_COM_FREQ.additive_alpha    = true
BS430_COM_FREQ.isvisible		  = true
BS430_COM_FREQ.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
BS430_COM_FREQ.level			  = NS430_DEFAULT_NOCLIP_LEVEL
BS430_COM_FREQ.parent_element    = "ns430_base_clip"  --Parent node name - can bind parent nodes that are not on the same layer
Add(BS430_COM_FREQ)

local BS430_COM_FREQ             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
BS430_COM_FREQ.material          = "BS430_font_white"    --FONT_             --Material type (note the font material created above)
BS430_COM_FREQ.init_pos          = {-1 + 281.72/default_gps_x, 1*aspect - (420 + line2_offset)*aspect/default_gps_x - temp_move_y}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
BS430_COM_FREQ.alignment         = "RightDown"       --Alignment settings：Left/Right/Center; Top/Down/Center
BS430_COM_FREQ.stringdefs        = {1.1*0.004,1.1 * 0.004, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
BS430_COM_FREQ.formats           = {"%02.0f", "%s"}
BS430_COM_FREQ.element_params    = {"LOC_FREQ_STB_2", "NAVU_BASE_ENABLE", "FREQ_FOCUS_LOC"} -- top left first line display
BS430_COM_FREQ.controllers       = {{"text_using_parameter",0},{"opacity_using_parameter",1},{"change_color_when_parameter_equal_to_number", 2, 1, 255/255,255/255,255/255}}
BS430_COM_FREQ.collimated        = true
BS430_COM_FREQ.use_mipfilter     = true
BS430_COM_FREQ.additive_alpha    = true
BS430_COM_FREQ.isvisible		 = true
BS430_COM_FREQ.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
BS430_COM_FREQ.level			 = NS430_DEFAULT_NOCLIP_LEVEL
BS430_COM_FREQ.parent_element    = "ns430_base_clip"  --Parent node name - can bind parent nodes that are not on the same layer
Add(BS430_COM_FREQ)

-- "BS430_font_white"
-- Texts Test
local BS430_MSG             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
BS430_MSG.material          = "BS430_font_white"    --FONT_             --Material type (note the font material created above)
BS430_MSG.init_pos          = {0, -1020 * aspect / default_gps_x}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
BS430_MSG.alignment         = "RightDown"       --Alignment settings：Left/Right/Center; Top/Down/Center
BS430_MSG.stringdefs        = {0.85 *0.004, 1 * 0.004, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
BS430_MSG.formats           = {"MSG", "%s"}
BS430_MSG.element_params    = {"MSG_SIGN", "NAVU_BASE_ENABLE","MSG_MODE"} -- top left first line display
BS430_MSG.controllers       = {{"text_using_parameter",0},{"opacity_using_parameter",1},{"change_color_when_parameter_equal_to_number", 2, 1, 200/255,200/255,50/255}}
BS430_MSG.collimated        = true
BS430_MSG.use_mipfilter     = true
BS430_MSG.additive_alpha    = true
BS430_MSG.isvisible		    = true
BS430_MSG.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
BS430_MSG.level			    = NS430_DEFAULT_NOCLIP_LEVEL
BS430_MSG.parent_element    = "ns430_base_clip"  --Parent node name - can bind parent nodes that are not on the same layer
Add(BS430_MSG)

local BS430_NAV_MODE             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
BS430_NAV_MODE.material          = "BS430_font_purple"    --FONT_             --Material type (note the font material created above)
BS430_NAV_MODE.init_pos          = {-1 + 30.72/default_gps_x , -1020 * aspect / default_gps_x}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
BS430_NAV_MODE.alignment         = "LeftDown"       --Alignment settings：Left/Right/Center; Top/Down/Center
BS430_NAV_MODE.stringdefs        = {0.85 *0.004, 1 * 0.004, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
BS430_NAV_MODE.formats           = {"%s", "%s"}
BS430_NAV_MODE.element_params    = {"NAV_MODE_NAME", "NAVU_BASE_ENABLE","ACTIVE_NAV_MOD"} -- top left first line display
BS430_NAV_MODE.controllers       = {{"text_using_parameter",0},{"opacity_using_parameter",1},{"change_color_when_parameter_equal_to_number", 2, 1, 4/255,239/255,40/255}}
BS430_NAV_MODE.collimated        = true
BS430_NAV_MODE.use_mipfilter     = true
BS430_NAV_MODE.additive_alpha    = true
BS430_NAV_MODE.isvisible		 = true
BS430_NAV_MODE.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
BS430_NAV_MODE.level			 = NS430_DEFAULT_NOCLIP_LEVEL
BS430_NAV_MODE.parent_element    = "ns430_base_clip"  --Parent node name - can bind parent nodes that are not on the same layer
Add(BS430_NAV_MODE)

-- load of the over layer
-- dofile(LockOn_Options.script_path.."NS430/IndicatorA/NS430_overlayer.lua")

-- Here start the load of the nav group
-- Load of the NAV - Movingmap
dofile(LockOn_Options.script_path.."NS430/IndicatorA/NS430_nav_map_page.lua")