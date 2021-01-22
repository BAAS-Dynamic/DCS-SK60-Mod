dofile(LockOn_Options.script_path.."EADI/EADI_def.lua")

SHOW_MASKS = true -- enable debug

-- This operation can align the newly created cropping block to the three connectors
-- Must use FOV mode
local half_width   = GetScale()
local half_height  = GetAspect() * half_width

local aspect       = GetAspect()

-- This is the top trim layer of the total instrument
local erpm_base_clip 			 	= CreateElement "ceMeshPoly" --This is the clipping layer
erpm_base_clip.name 			    = "erpm_base_clip"
erpm_base_clip.primitivetype   	    = "triangles"
erpm_base_clip.vertices 		    = { {3.3, aspect}, { 3.3,-aspect}, { -1,-aspect}, {-1,aspect},} --四个边角
erpm_base_clip.indices 		        = {0,1,2,0,2,3}
erpm_base_clip.init_pos		        = {0, 0, 0}
erpm_base_clip.init_rot		        = {0, 0, 0}
erpm_base_clip.material		        = "DBG_GREY"
erpm_base_clip.h_clip_relation      = h_clip_relations.REWRITE_LEVEL --INCREASE_IF_LEVEL--COMPARE --REWRITE_LEVEL
erpm_base_clip.level			    = EADI_DEFAULT_NOCLIP_LEVEL
erpm_base_clip.isdraw		        = true
erpm_base_clip.change_opacity       = false
erpm_base_clip.element_params       = {"LEADI_DIS_ENABLE"}              -- Initialize the main display control
erpm_base_clip.controllers          = {{"opacity_using_parameter",0}}
erpm_base_clip.isvisible		    = SHOW_MASKS
Add(erpm_base_clip)

local RTOP_text_box             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
RTOP_text_box.material          = "EADI_font"    --FONT_             --Material type (note the font material created above)
RTOP_text_box.init_pos          = {1 , 0}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
RTOP_text_box.alignment         = "RightCenter"       --Alignment settings：Left/Right/Center; Top/Down/Center
RTOP_text_box.stringdefs        = {0.8*0.0095,0.8 * 0.0095, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
RTOP_text_box.formats           = {"%.1f","%s"} -- The output is set here, similar to the printf model of C.% is the output type at the beginning, and the following %s is the input type
RTOP_text_box.element_params    = {"LRPM_N2_DIGTAL"} -- top left first line display
RTOP_text_box.controllers       = {{"text_using_parameter",0},}
RTOP_text_box.collimated        = true
RTOP_text_box.use_mipfilter     = true
RTOP_text_box.additive_alpha    = true
RTOP_text_box.isvisible		    = true
RTOP_text_box.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
RTOP_text_box.level			    = EADI_DEFAULT_NOCLIP_LEVEL
RTOP_text_box.parent_element    = "erpm_base_clip"  --Parent node name - can bind parent nodes that are not on the same layer
Add(RTOP_text_box)

local RTOP_text_box             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
RTOP_text_box.material          = "EADI_font"    --FONT_             --Material type (note the font material created above)
RTOP_text_box.init_pos          = { 3.2 , 0}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
RTOP_text_box.alignment         = "RightCenter"       --Alignment settings：Left/Right/Center; Top/Down/Center
RTOP_text_box.stringdefs        = {0.8*0.0095,0.8 * 0.0095, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
RTOP_text_box.formats           = {"%.1f","%s"} -- The output is set here, similar to the printf model of C.% is the output type at the beginning, and the following %s is the input type
RTOP_text_box.element_params    = {"RRPM_N2_DIGTAL"} -- top left first line display
RTOP_text_box.controllers       = {{"text_using_parameter",0},}
RTOP_text_box.collimated        = true
RTOP_text_box.use_mipfilter     = true
RTOP_text_box.additive_alpha    = true
RTOP_text_box.isvisible		    = true
RTOP_text_box.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
RTOP_text_box.level			    = EADI_DEFAULT_NOCLIP_LEVEL
RTOP_text_box.parent_element    = "erpm_base_clip"  --Parent node name - can bind parent nodes that are not on the same layer
Add(RTOP_text_box)