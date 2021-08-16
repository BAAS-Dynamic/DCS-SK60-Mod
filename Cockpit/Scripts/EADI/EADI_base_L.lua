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

-- 612 * 606 move down center for 3
local adi_surround_tex 				        = CreateElement "ceTexPoly"
adi_surround_tex.vertices                   = EADI_vert_gen(4000,3961)
adi_surround_tex.indices                    = {0,1,2,2,3,0}
adi_surround_tex.tex_coords                 = tex_coord_gen(0,0,612,606,1024,1024)
adi_surround_tex.material                   = basic_eadi_material
adi_surround_tex.name 			            = create_guid_string()
adi_surround_tex.init_pos                   = {0, -80/2000, 0}
adi_surround_tex.init_rot		            = {0, 0, 0}
adi_surround_tex.collimated	                = true
adi_surround_tex.element_params             = {"LEADI_DIS_ENABLE"}              -- Initialize the main display control
adi_surround_tex.controllers                = {{"opacity_using_parameter",0}}
adi_surround_tex.use_mipfilter              = true
adi_surround_tex.additive_alpha             = true
adi_surround_tex.h_clip_relation            = h_clip_relations.COMPARE
adi_surround_tex.level                      = EADI_DEFAULT_NOCLIP_LEVEL
adi_surround_tex.parent_element	            = "eadi_base_clip"
Add(adi_surround_tex)

local RBOT_text_box             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
RBOT_text_box.material          = "EADI_font"    --FONT_             --Material type (note the font material created above)
RBOT_text_box.init_pos          = {-1950/2000, 2050/2000}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
RBOT_text_box.alignment         = "LeftTop"       --Alignment settings：Left/Right/Center; Top/Down/Center
RBOT_text_box.stringdefs        = {0.8*0.004,0.8 * 0.004, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
RBOT_text_box.formats           = {"%s","%s"} -- The output is set here, similar to the printf model of C.% is the output type at the beginning, and the following %s is the input type
RBOT_text_box.element_params    = {"L_EADI_DISPLAY_TL1","LEADI_DIS_ENABLE"} -- top left first line display
RBOT_text_box.controllers       = {{"text_using_parameter",0},{"opacity_using_parameter",1}}
RBOT_text_box.collimated        = true
RBOT_text_box.use_mipfilter     = true
RBOT_text_box.additive_alpha    = true
RBOT_text_box.isvisible		    = true
RBOT_text_box.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
RBOT_text_box.level			    = EADI_DEFAULT_NOCLIP_LEVEL
RBOT_text_box.parent_element    = "eadi_base_clip"  --Parent node name - can bind parent nodes that are not on the same layer
Add(RBOT_text_box)

local RTOP_text_box             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
RTOP_text_box.material          = "EADI_font"    --FONT_             --Material type (note the font material created above)
RTOP_text_box.init_pos          = {1950/2000, 2050/2000}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
RTOP_text_box.alignment         = "RightTop"       --Alignment settings：Left/Right/Center; Top/Down/Center
RTOP_text_box.stringdefs        = {0.8*0.006,0.8 * 0.006, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
RTOP_text_box.formats           = {"%0.1f","%s"} -- The output is set here, similar to the printf model of C.% is the output type at the beginning, and the following %s is the input type
RTOP_text_box.element_params    = {"DBG_OUT","LEADI_DIS_ENABLE"}--{"L_EADI_DISPLAY_TR1"} -- top left first line display
RTOP_text_box.controllers       = {{"text_using_parameter",0},{"opacity_using_parameter",1}}
RTOP_text_box.collimated        = true
RTOP_text_box.use_mipfilter     = true
RTOP_text_box.additive_alpha    = true
RTOP_text_box.isvisible		    = true
RTOP_text_box.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
RTOP_text_box.level			    = EADI_DEFAULT_NOCLIP_LEVEL
RTOP_text_box.parent_element    = "eadi_base_clip"  --Parent node name - can bind parent nodes that are not on the same layer
Add(RTOP_text_box)

local RBOT_text_box             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
RBOT_text_box.material          = "EADI_font"    --FONT_             --Material type (note the font material created above)
RBOT_text_box.init_pos          = {1950/2000, -1850/2000}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
RBOT_text_box.alignment         = "RightTop"       --Alignment settings：Left/Right/Center; Top/Down/Center
RBOT_text_box.stringdefs        = {0.8*0.004,0.8 * 0.004, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
RBOT_text_box.formats           = {"%s","%s"} -- The output is set here, similar to the printf model of C.% is the output type at the beginning, and the following %s is the input type
RBOT_text_box.element_params    = {"L_EADI_DISPLAY_BR1","LEADI_DIS_ENABLE"} -- top left first line display
RBOT_text_box.controllers       = {{"text_using_parameter",0},{"opacity_using_parameter",1}}
RBOT_text_box.collimated        = true
RBOT_text_box.use_mipfilter     = true
RBOT_text_box.additive_alpha    = true
RBOT_text_box.isvisible		    = true
RBOT_text_box.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
RBOT_text_box.level			    = EADI_DEFAULT_NOCLIP_LEVEL
RBOT_text_box.parent_element    = "eadi_base_clip"  --Parent node name - can bind parent nodes that are not on the same layer
Add(RBOT_text_box)

local RBOT_text_box             = CreateElement "ceStringPoly"
RBOT_text_box.material          = "EADI_font"    
RBOT_text_box.init_pos          = {-1950/2000, 1850/2000}         
RBOT_text_box.alignment         = "LeftTop"
RBOT_text_box.stringdefs        = {0.8*0.004,0.8 * 0.004, 0, 0} 
RBOT_text_box.formats           = {"%s","%s"}
RBOT_text_box.element_params    = {"L_EADI_DISPLAY_TL2","LEADI_DIS_ENABLE"}
RBOT_text_box.controllers       = {{"text_using_parameter",0},{"opacity_using_parameter",1}}
RBOT_text_box.collimated        = true
RBOT_text_box.use_mipfilter     = true
RBOT_text_box.additive_alpha    = true
RBOT_text_box.isvisible		    = true
RBOT_text_box.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
RBOT_text_box.level			    = EADI_DEFAULT_NOCLIP_LEVEL
RBOT_text_box.parent_element    = "eadi_base_clip"  --Parent node name - can bind parent nodes that are not on the same layer
Add(RBOT_text_box)

-- 250 * 16

local eadi_adi_clip 			    = CreateElement "ceMeshPoly" --create second clip
eadi_adi_clip.name 			        = "eadi_adi_clip"
eadi_adi_clip.vertices 		        = create_EADI_circle_pos(61, 0, 0, 1800)
eadi_adi_clip.indices 		        = create_EADI_circle_index(61)
eadi_adi_clip.init_pos		        = {0, 0, 0}
eadi_adi_clip.init_rot		        = {0, 0, 0}
eadi_adi_clip.material		        = "DBG_GREY"
eadi_adi_clip.h_clip_relation       = h_clip_relations.INCREASE_IF_LEVEL--COMPARE --REWRITE_LEVEL
eadi_adi_clip.level			        = EADI_DEFAULT_LEVEL - 1
eadi_adi_clip.change_opacity        = false
eadi_adi_clip.element_params        = {"LEADI_DIS_ENABLE",}              -- Initialize the main display control
eadi_adi_clip.controllers           = {{"opacity_using_parameter",0}}
eadi_adi_clip.isvisible		        = SHOW_MASKS
Add(eadi_adi_clip)

local center_tex 				      = CreateElement "ceTexPoly"
center_tex.vertices                 = EADI_vert_gen(1000,640)
center_tex.indices                  = {0,1,2,2,3,0}
center_tex.tex_coords               = tex_coord_gen(0,728,250,160,1024,1024)
center_tex.material                 = basic_eadi_material
center_tex.name 			        = create_guid_string()
center_tex.init_pos                 = {0, -0.01, 0}
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
gyro_tex.element_params           = {"GYRO_PITCH","LEADI_GYRO_ENABLE"}
gyro_tex.controllers              = {{"move_up_down_using_parameter",0,0.075},{"opacity_using_parameter",1}}
gyro_tex.use_mipfilter            = true
gyro_tex.additive_alpha           = true
gyro_tex.h_clip_relation          = h_clip_relations.COMPARE
gyro_tex.level                    = EADI_DEFAULT_LEVEL
gyro_tex.parent_element	          = "eadi_adi_rotate"
Add(gyro_tex)

local gyro_tex 				      = CreateElement "ceTexPoly"
gyro_tex.vertices                 = EADI_vert_gen(2206*2,6276)
gyro_tex.indices                  = {0,1,2,2,3,0}
gyro_tex.tex_coords               = tex_coord_gen(664,0,360,1024,1024,1024)
gyro_tex.material                 = "SKY_BLUE"
gyro_tex.name 			          = create_guid_string()
gyro_tex.init_pos                 = {0, 6276/4000, 0}
gyro_tex.init_rot		          = {0, 0, 0}
gyro_tex.collimated	              = true
gyro_tex.element_params           = {"GYRO_PITCH","LEADI_GYRO_ENABLE"}
gyro_tex.controllers              = {{"move_up_down_using_parameter",0,0.075},{"opacity_using_parameter",1}}
gyro_tex.use_mipfilter            = true
gyro_tex.additive_alpha           = true
gyro_tex.h_clip_relation          = h_clip_relations.COMPARE
gyro_tex.level                    = EADI_DEFAULT_LEVEL
gyro_tex.parent_element	          = "eadi_adi_rotate"
Add(gyro_tex)

local gyro_tex 				      = CreateElement "ceTexPoly"
gyro_tex.vertices                 = EADI_vert_gen(2206*2,6276)
gyro_tex.indices                  = {0,1,2,2,3,0}
gyro_tex.tex_coords               = tex_coord_gen(664,0,360,1024,1024,1024)
gyro_tex.material                 = "GROUND_YELLOW"
gyro_tex.name 			          = create_guid_string()
gyro_tex.init_pos                 = {0, -6276/4000, 0}
gyro_tex.init_rot		          = {0, 0, 0}
gyro_tex.collimated	              = true
gyro_tex.element_params           = {"GYRO_PITCH","LEADI_GYRO_ENABLE"}
gyro_tex.controllers              = {{"move_up_down_using_parameter",0,0.075},{"opacity_using_parameter",1}}
gyro_tex.use_mipfilter            = true
gyro_tex.additive_alpha           = true
gyro_tex.h_clip_relation          = h_clip_relations.COMPARE
gyro_tex.level                    = EADI_DEFAULT_LEVEL
gyro_tex.parent_element	          = "eadi_adi_rotate"
Add(gyro_tex)