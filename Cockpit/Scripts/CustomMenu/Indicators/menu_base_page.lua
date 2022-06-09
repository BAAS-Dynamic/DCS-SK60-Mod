dofile(LockOn_Options.script_path.."CustomMenu/menu_def.lua")

SHOW_MASKS = false -- enable debug

-- This operation can align the newly created cropping block to the three connectors
-- Must use FOV mode
local half_width   = GetScale()
local half_height  = GetAspect() * half_width

local  screen_height =          LockOn_Options.screen.height * 0.5
local  screen_width  =          LockOn_Options.screen.width * 0.5

-- local aspect                = 1 --GetAspect()
-- local screen_width          = 4 --GetAspect()

-- This is the top trim layer of the total instrument
local base_clip 			 	= CreateElement "ceMeshPoly" --This is the clipping layer
base_clip.name 			        = "base_clip"
base_clip.primitivetype   	    = "triangles"
base_clip.vertices 		        = { {screen_width, screen_height}, { screen_width,-screen_height}, { -screen_width,-screen_height}, {-screen_width,screen_height},} --四个边角
base_clip.indices 		        = {0,1,2,0,2,3}
base_clip.init_pos		        = {0, 0, 0}
base_clip.init_rot		        = {0, 0, 0}
base_clip.material		        = "DBG_GREEN"
base_clip.h_clip_relation       = h_clip_relations.REWRITE_LEVEL --INCREASE_IF_LEVEL--COMPARE --REWRITE_LEVEL
base_clip.level			        = MENU_DEFAULT_NOCLIP_LEVEL 
base_clip.isdraw		        = true
base_clip.change_opacity        = false
base_clip.element_params        = {"IPAD_DIS_ENABLE"}              -- Initialize the main display control
base_clip.controllers           = {{"opacity_using_parameter",0}}
base_clip.isvisible		        = SHOW_MASKS
Add(base_clip)

-- dofile(LockOn_Options.script_path.."DBGiPad/Indicators/ipad_mp3_page.lua")

-- StartUP Logo -- test only
local ns430_startup_icon 				        = CreateElement "ceTexPoly"
ns430_startup_icon.vertices                     = mesh_vert_gen(1500,750)
ns430_startup_icon.indices                      = {0,1,2,2,3,0}
ns430_startup_icon.tex_coords                   = tex_coord_gen(1024,0,512,256,2048,2048)
ns430_startup_icon.material                     = basic_ns430_material
ns430_startup_icon.name 			            = create_guid_string()
ns430_startup_icon.init_pos                     = {0, 0, 0}
ns430_startup_icon.init_rot		                = {0, 0, 0}
ns430_startup_icon.collimated	                = true
ns430_startup_icon.element_params               = {"IPAD_DIS_ENABLE"}              -- Initialize the main display control
ns430_startup_icon.controllers                  = {{"opacity_using_parameter",0}}
ns430_startup_icon.use_mipfilter                = true
ns430_startup_icon.additive_alpha               = true
ns430_startup_icon.h_clip_relation              = h_clip_relations.COMPARE
ns430_startup_icon.level                        = MENU_DEFAULT_NOCLIP_LEVEL
ns430_startup_icon.parent_element	            = "base_clip"
-- Add(ns430_startup_icon)

-- Text test
local Debug_text_box             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
Debug_text_box.material          = "EADI_font"    --FONT_             --Material type (note the font material created above)
Debug_text_box.init_pos          = {0, 0}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
Debug_text_box.alignment         = "LeftTop"       --Alignment settings：Left/Right/Center; Top/Down/Center
Debug_text_box.stringdefs        = {40/screen_width/2, 20/screen_width/2, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
Debug_text_box.formats           = {"%s","%s"} -- The output is set here, similar to the printf model of C.% is the output type at the beginning, and the following %s is the input type
Debug_text_box.element_params    = {"DEBUG_LINE1","IPAD_DIS_ENABLE"} -- top left first line display
Debug_text_box.controllers       = {{"text_using_parameter",0},{"opacity_using_parameter",1}}
Debug_text_box.collimated        = true
Debug_text_box.use_mipfilter     = true
Debug_text_box.additive_alpha    = true
Debug_text_box.isvisible		 = true
Debug_text_box.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
Debug_text_box.level			 = MENU_DEFAULT_NOCLIP_LEVEL
Debug_text_box.parent_element    = "base_clip"  --Parent node name - can bind parent nodes that are not on the same layer
Add(Debug_text_box)

local Debug_text_box_1             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
Debug_text_box_1.material          = "EADI_font"    --FONT_             --Material type (note the font material created above)
Debug_text_box_1.init_pos          = {0, -30/screen_height/2}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
Debug_text_box_1.alignment         = "LeftTop"       --Alignment settings：Left/Right/Center; Top/Down/Center
Debug_text_box_1.stringdefs        = {40/screen_width/2, 20/screen_width/2, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
Debug_text_box_1.formats           = {"%s","%s"} -- The output is set here, similar to the printf model of C.% is the output type at the beginning, and the following %s is the input type
Debug_text_box_1.element_params    = {"DEBUG_LINE2","IPAD_DIS_ENABLE"} -- top left first line display
Debug_text_box_1.controllers       = {{"text_using_parameter",0},{"opacity_using_parameter",1}}
Debug_text_box_1.collimated        = true
Debug_text_box_1.use_mipfilter     = true
Debug_text_box_1.additive_alpha    = true
Debug_text_box_1.isvisible		   = true
Debug_text_box_1.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
Debug_text_box_1.level			   = MENU_DEFAULT_NOCLIP_LEVEL
Debug_text_box_1.parent_element    = "base_clip"  --Parent node name - can bind parent nodes that are not on the same layer
Add(Debug_text_box_1)

local Debug_text_box_1             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
Debug_text_box_1.material          = "EADI_font"    --FONT_             --Material type (note the font material created above)
Debug_text_box_1.init_pos          = {0, -60/screen_height/2}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
Debug_text_box_1.alignment         = "LeftTop"       --Alignment settings：Left/Right/Center; Top/Down/Center
Debug_text_box_1.stringdefs        = {40/screen_width/2, 20/screen_width/2, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
Debug_text_box_1.formats           = {"%.2f","%s"} -- The output is set here, similar to the printf model of C.% is the output type at the beginning, and the following %s is the input type
Debug_text_box_1.element_params    = {"DEBUG_LINE3","IPAD_DIS_ENABLE"} -- top left first line display
Debug_text_box_1.controllers       = {{"text_using_parameter",0},{"opacity_using_parameter",1}}
Debug_text_box_1.collimated        = true
Debug_text_box_1.use_mipfilter     = true
Debug_text_box_1.additive_alpha    = true
Debug_text_box_1.isvisible		   = true
Debug_text_box_1.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
Debug_text_box_1.level			   = MENU_DEFAULT_NOCLIP_LEVEL
Debug_text_box_1.parent_element    = "base_clip"  --Parent node name - can bind parent nodes that are not on the same layer
Add(Debug_text_box_1)

dofile(LockOn_Options.script_path.."CustomMenu/Indicators/autho_page.lua")
dofile(LockOn_Options.script_path.."CustomMenu/Indicators/menu_page.lua")