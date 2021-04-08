dofile(LockOn_Options.script_path.."HUD/Indicator/hud_def.lua")

SHOW_MASKS = true

-- This operation can align the newly created cropping block to the three connectors
-- Must use FOV mode
local half_width   = GetScale()
local half_height  = GetAspect() * half_width

local aspect       = GetAspect()

-- This is the top trim layer of the total instrument
HUD_base_clip 			 	    = CreateElement "ceMeshPoly" --This is the clipping layer
HUD_base_clip.name 			    = "hud_base_clip"
HUD_base_clip.primitivetype   	= "triangles"
HUD_base_clip.vertices 		    = { {6, aspect}, { 6,-aspect}, { -6,-aspect}, {-6,aspect}, } --四个边角
HUD_base_clip.indices 		    = {0,1,2,0,2,3} -- Index, each group of three forms a triangle that will be displayed, and the number represents the previous vert coordinate
HUD_base_clip.init_pos		    = {0, 0, 0}
HUD_base_clip.init_rot		    = {0, 0, 0}
HUD_base_clip.material		    = "DBG_GREY"
HUD_base_clip.element_params    = {"UNAUTHOPAC"}
HUD_base_clip.controllers       = {{"opacity_using_parameter",0}}
HUD_base_clip.h_clip_relation   = h_clip_relations.REWRITE_LEVEL --INCREASE_IF_LEVEL--COMPARE --REWRITE_LEVEL
HUD_base_clip.level			    = HUD_DEFAULT_NOCLIP_LEVEL
HUD_base_clip.isdraw		    = true
HUD_base_clip.change_opacity    = false
HUD_base_clip.isvisible		    = SHOW_MASKS
Add(HUD_base_clip)

-- Left engine N2 speed display
local LN2_dis_box             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
LN2_dis_box.material          = "hud_font_base"    --FONT_             --Material type (note the font material created above)
LN2_dis_box.init_pos          = {0, 0}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
LN2_dis_box.alignment         = "CenterCenter"       --Alignment settings：Left/Right/Center; Top/Down/Center
LN2_dis_box.stringdefs        = {4*0.010,4 * 0.010, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
LN2_dis_box.formats           = {"NOT AUTHED FOR THIS WIP MOD","%s"} -- The output is set here, similar to the printf model of C.% is the output type at the beginning, and the following %s is the input type
--LN2_dis_box.element_params    = {"UNAUTHOPAC"}
LN2_dis_box.element_params    = {"HUD_LN2_DIS", "UNAUTHOPAC"}
LN2_dis_box.controllers       = {{"text_using_parameter",0},{"opacity_using_parameter",1}}
LN2_dis_box.collimated        = true
LN2_dis_box.use_mipfilter     = true
LN2_dis_box.additive_alpha    = true
LN2_dis_box.isvisible		 = true
LN2_dis_box.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
LN2_dis_box.level			 = HUD_DEFAULT_NOCLIP_LEVEL
LN2_dis_box.parent_element    = "hud_base_clip"  --Parent node name - can bind parent nodes that are not on the same layer
Add(LN2_dis_box)