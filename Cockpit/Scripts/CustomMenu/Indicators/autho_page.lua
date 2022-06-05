dofile(LockOn_Options.script_path.."CustomMenu/menu_def.lua")
dofile(LockOn_Options.script_path.."version.lua")

local  screen_height =          LockOn_Options.screen.height * 0.5
local  screen_width  =          LockOn_Options.screen.width * 0.5

-- This is the top trim layer of the total instrument
HUD_base_clip 			 	    = CreateElement "ceMeshPoly" --This is the clipping layer
HUD_base_clip.name 			    = "auth_base_clip"
HUD_base_clip.primitivetype   	= "triangles"
HUD_base_clip.vertices 		    = { {screen_width, screen_height}, { screen_width,-screen_height}, { -screen_width,-screen_height}, {-screen_width,screen_height},} --四个边角 --四个边角
HUD_base_clip.indices 		    = {0,1,2,0,2,3} -- Index, each group of three forms a triangle that will be displayed, and the number represents the previous vert coordinate
HUD_base_clip.init_pos		    = {0, 0, 0}
HUD_base_clip.init_rot		    = {0, 0, 0}
HUD_base_clip.material		    = "DBG_GREEN"
HUD_base_clip.element_params    = {"UNAUTHOPAC"}
HUD_base_clip.controllers       = {{"opacity_using_parameter",0}}
HUD_base_clip.h_clip_relation   = h_clip_relations.REWRITE_LEVEL --INCREASE_IF_LEVEL--COMPARE --REWRITE_LEVEL
HUD_base_clip.level			    = MENU_DEFAULT_NOCLIP_LEVEL
HUD_base_clip.isdraw		    = true
HUD_base_clip.change_opacity    = false
HUD_base_clip.isvisible		    = true
Add(HUD_base_clip)

-- StartUP Logo -- test only
local ns430_startup_icon 				        = CreateElement "ceTexPoly"
ns430_startup_icon.vertices                     = mesh_vert_gen(1500,375)
ns430_startup_icon.indices                      = {0,1,2,2,3,0}
ns430_startup_icon.tex_coords                   = tex_coord_gen(1024,0,512,128,2048,2048)
ns430_startup_icon.material                     = basic_ns430_material
ns430_startup_icon.name 			            = create_guid_string()
ns430_startup_icon.init_pos                     = {0, 375/screen_height/2, 0}
ns430_startup_icon.init_rot		                = {0, 0, 0}
ns430_startup_icon.collimated	                = true
ns430_startup_icon.element_params               = {"UNAUTHOPAC"}              -- Initialize the main display control
ns430_startup_icon.controllers                  = {{"opacity_using_parameter",0}}
ns430_startup_icon.use_mipfilter                = true
ns430_startup_icon.additive_alpha               = true
ns430_startup_icon.h_clip_relation              = h_clip_relations.COMPARE
ns430_startup_icon.level                        = MENU_DEFAULT_NOCLIP_LEVEL
ns430_startup_icon.parent_element	            = "auth_base_clip"
Add(ns430_startup_icon)

-- Left engine N2 speed display
local LN2_dis_box             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
LN2_dis_box.material          = "BS430_font_purple"    --FONT_             --Material type (note the font material created above)
LN2_dis_box.init_pos          = {0, 0}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
LN2_dis_box.alignment         = "CenterCenter"       --Alignment settings：Left/Right/Center; Top/Down/Center
LN2_dis_box.stringdefs        = {100/screen_width/2, 50/screen_width/2, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
LN2_dis_box.formats           = {"CURRENT VERSON IS "..general_version, "%s"} -- The output is set here, similar to the printf model of C.% is the output type at the beginning, and the following %s is the input type
--LN2_dis_box.element_params    = {"UNAUTHOPAC"}
LN2_dis_box.element_params    = {"HUD_LN2_DIS", "UNAUTHOPAC"}
LN2_dis_box.controllers       = {{"text_using_parameter",0},{"opacity_using_parameter",1}}
LN2_dis_box.collimated        = true
LN2_dis_box.use_mipfilter     = true
LN2_dis_box.additive_alpha    = true
LN2_dis_box.isvisible		  = true
LN2_dis_box.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
LN2_dis_box.level			  = MENU_DEFAULT_NOCLIP_LEVEL
LN2_dis_box.parent_element    = "auth_base_clip"  --Parent node name - can bind parent nodes that are not on the same layer
Add(LN2_dis_box)

-- Left engine N2 speed display
local LN2_dis_box             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
LN2_dis_box.material          = "BS430_font_purple"    --FONT_             --Material type (note the font material created above)
LN2_dis_box.init_pos          = {0, -150/screen_width/2}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
LN2_dis_box.alignment         = "CenterCenter"       --Alignment settings：Left/Right/Center; Top/Down/Center
LN2_dis_box.stringdefs        = {100/screen_width/2, 50/screen_width/2, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
LN2_dis_box.formats           = {"INSIDE DEV LICENSE MISSING OR WRONG","%s"} -- The output is set here, similar to the printf model of C.% is the output type at the beginning, and the following %s is the input type
--LN2_dis_box.element_params    = {"UNAUTHOPAC"}
LN2_dis_box.element_params    = {"HUD_LN2_DIS", "UNAUTHOPAC"}
LN2_dis_box.controllers       = {{"text_using_parameter",0},{"opacity_using_parameter",1}}
LN2_dis_box.collimated        = true
LN2_dis_box.use_mipfilter     = true
LN2_dis_box.additive_alpha    = true
LN2_dis_box.isvisible		  = true
LN2_dis_box.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
LN2_dis_box.level			  = MENU_DEFAULT_NOCLIP_LEVEL
LN2_dis_box.parent_element    = "auth_base_clip"  --Parent node name - can bind parent nodes that are not on the same layer
Add(LN2_dis_box)