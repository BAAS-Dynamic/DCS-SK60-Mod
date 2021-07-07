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

local LLINEA_TEXT             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
LLINEA_TEXT.material          = "LCD_font_white" --"EADI_font"    --FONT_             --Material type (note the font material created above)
LLINEA_TEXT.init_pos          = {-0.2 , 0.45*aspect}        -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
LLINEA_TEXT.alignment         = "RightTop"       --Alignment settings：Left/Right/Center; Top/Down/Center
LLINEA_TEXT.stringdefs        = {0.8*0.02,0.8 * 0.02, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
LLINEA_TEXT.formats           = {"%.0f","%s"} -- The output is set here, similar to the printf model of C.% is the output type at the beginning, and the following %s is the input type
LLINEA_TEXT.element_params    = {"ALT_XK_DIGTAL"} -- top left first line display
LLINEA_TEXT.controllers       = {{"text_using_parameter",0},}
LLINEA_TEXT.collimated        = true
LLINEA_TEXT.use_mipfilter     = true
LLINEA_TEXT.additive_alpha    = true
LLINEA_TEXT.isvisible		  = true
LLINEA_TEXT.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
LLINEA_TEXT.level			  = EALT_DEFAULT_NOCLIP_LEVEL
LLINEA_TEXT.parent_element    = "ealt_base_clip"  --Parent node name - can bind parent nodes that are not on the same layer
Add(LLINEA_TEXT)

local LLINEB_TEXT             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
LLINEB_TEXT.material          = "LCD_font_white" --"EADI_font"    --FONT_             --Material type (note the font material created above)
LLINEB_TEXT.init_pos          = {-0.2 , -0.55*aspect}        -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
LLINEB_TEXT.alignment         = "RightTop"       --Alignment settings：Left/Right/Center; Top/Down/Center
LLINEB_TEXT.stringdefs        = {0.8*0.012,0.8 * 0.012, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
LLINEB_TEXT.formats           = {"%.0f","%s"} -- The output is set here, similar to the printf model of C.% is the output type at the beginning, and the following %s is the input type
LLINEB_TEXT.element_params    = {"ALT_BARO_DIGTAL"} -- top left first line display
LLINEB_TEXT.controllers       = {{"text_using_parameter",0},}
LLINEB_TEXT.collimated        = true
LLINEB_TEXT.use_mipfilter     = true
LLINEB_TEXT.additive_alpha    = true
LLINEB_TEXT.isvisible		  = true
LLINEB_TEXT.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
LLINEB_TEXT.level			  = EALT_DEFAULT_NOCLIP_LEVEL
LLINEB_TEXT.parent_element    = "ealt_base_clip"  --Parent node name - can bind parent nodes that are not on the same layer
Add(LLINEB_TEXT)

local LLINECMARK_TEXT             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
LLINECMARK_TEXT.material          = "LCD_font_white" --"EADI_font"    --FONT_             --Material type (note the font material created above)
LLINECMARK_TEXT.init_pos          = {-1, -0.25*aspect}        -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
LLINECMARK_TEXT.alignment         = "LeftTop"       --Alignment settings：Left/Right/Center; Top/Down/Center
LLINECMARK_TEXT.stringdefs        = {0.8*0.009,0.8 * 0.009, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
LLINECMARK_TEXT.formats           = {"%s","%s"} -- The output is set here, similar to the printf model of C.% is the output type at the beginning, and the following %s is the input type
LLINECMARK_TEXT.element_params    = {"ALT_BARO_UNIT_DIGTAL"} -- top left first line display
LLINECMARK_TEXT.controllers       = {{"text_using_parameter",0},}
LLINECMARK_TEXT.collimated        = true
LLINECMARK_TEXT.use_mipfilter     = true
LLINECMARK_TEXT.additive_alpha    = true
LLINECMARK_TEXT.isvisible		  = true
LLINECMARK_TEXT.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
LLINECMARK_TEXT.level			  = EALT_DEFAULT_NOCLIP_LEVEL
LLINECMARK_TEXT.parent_element    = "ealt_base_clip"  --Parent node name - can bind parent nodes that are not on the same layer
Add(LLINECMARK_TEXT)

local RLINEAMARK_TEXT             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
RLINEAMARK_TEXT.material          = "LCD_font_white" --"EADI_font"    --FONT_             --Material type (note the font material created above)
RLINEAMARK_TEXT.init_pos          = {0.95 , 0.5*aspect}        -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
RLINEAMARK_TEXT.alignment         = "RightTop"       --Alignment settings：Left/Right/Center; Top/Down/Center
RLINEAMARK_TEXT.stringdefs        = {0.8*0.0075,0.8 * 0.0075, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
RLINEAMARK_TEXT.formats           = {"%s","%s"} -- The output is set here, similar to the printf model of C.% is the output type at the beginning, and the following %s is the input type
RLINEAMARK_TEXT.element_params    = {"ALT_UNIT_DIGTAL"} -- top left first line display
RLINEAMARK_TEXT.controllers       = {{"text_using_parameter",0},}
RLINEAMARK_TEXT.collimated        = true
RLINEAMARK_TEXT.use_mipfilter     = true
RLINEAMARK_TEXT.additive_alpha    = true
RLINEAMARK_TEXT.isvisible		  = true
RLINEAMARK_TEXT.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
RLINEAMARK_TEXT.level			  = EALT_DEFAULT_NOCLIP_LEVEL
RLINEAMARK_TEXT.parent_element    = "ealt_base_clip"  --Parent node name - can bind parent nodes that are not on the same layer
Add(RLINEAMARK_TEXT)

local RLINEA_TEXT             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
RLINEA_TEXT.material          = "LCD_font_white" --"EADI_font"    --FONT_             --Material type (note the font material created above)
RLINEA_TEXT.init_pos          = {0.1 , 0.35*aspect}        -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
RLINEA_TEXT.alignment         = "LeftTop"       --Alignment settings：Left/Right/Center; Top/Down/Center
RLINEA_TEXT.stringdefs        = {0.8*0.018,0.8 * 0.018, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
RLINEA_TEXT.formats           = {"%03.0f","%s"} -- The output is set here, similar to the printf model of C.% is the output type at the beginning, and the following %s is the input type
RLINEA_TEXT.element_params    = {"ALT_XH_DIGTAL"} -- top left first line display
RLINEA_TEXT.controllers       = {{"text_using_parameter",0},}
RLINEA_TEXT.collimated        = true
RLINEA_TEXT.use_mipfilter     = true
RLINEA_TEXT.additive_alpha    = true
RLINEA_TEXT.isvisible		  = true
RLINEA_TEXT.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
RLINEA_TEXT.level			  = EALT_DEFAULT_NOCLIP_LEVEL
RLINEA_TEXT.parent_element    = "ealt_base_clip"  --Parent node name - can bind parent nodes that are not on the same layer
Add(RLINEA_TEXT)
