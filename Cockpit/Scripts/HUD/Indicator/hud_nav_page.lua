-- The basic navigation instructions are placed here
-- basic_HUD_material

-- 425 145； 75 1900 1260

local fd_move_multi = 0.1

-- Left engine N2 speed display
local LN2_dis_box             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
LN2_dis_box.material          = "hud_font_base"    --FONT_             --Material type (note the font material created above)
LN2_dis_box.init_pos          = {-2000/2000, -1500/2000}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
LN2_dis_box.alignment         = "RightCenter"       --Alignment settings：Left/Right/Center; Top/Down/Center
LN2_dis_box.stringdefs        = {0.8*0.010,0.8 * 0.010, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
LN2_dis_box.formats           = {"LN2 %.0f","%s"} -- The output is set here, similar to the printf model of C.% is the output type at the beginning, and the following %s is the input type
LN2_dis_box.element_params    = {"HUD_LN2_DIS"}
LN2_dis_box.controllers       = {{"text_using_parameter",0},}
LN2_dis_box.collimated        = true
LN2_dis_box.use_mipfilter     = true
LN2_dis_box.additive_alpha    = true
LN2_dis_box.isvisible		 = true
LN2_dis_box.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
LN2_dis_box.level			 = HUD_DEFAULT_NOCLIP_LEVEL
LN2_dis_box.parent_element    = "hud_base_clip"  --Parent node name - can bind parent nodes that are not on the same layer
Add(LN2_dis_box)

-- Right engine N2 speed display
local RN2_dis_box             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
RN2_dis_box.material          = "hud_font_base"    --FONT_             --Material type (note the font material created above)
RN2_dis_box.init_pos          = {-2000/2000, -1640/2000}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
RN2_dis_box.alignment         = "LeftCenter"        --Alignment settings：Left/Right/Center; Top/Down/Center
RN2_dis_box.stringdefs        = {0.8*0.010,0.8 * 0.010, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
RN2_dis_box.formats           = {"RN2 %.0f","%s"} -- The output is set here, similar to the printf model of C.% is the output type at the beginning, and the following %s is the input type
RN2_dis_box.element_params    = {"HUD_RN2_DIS"}
RN2_dis_box.controllers       = {{"text_using_parameter",0},}
RN2_dis_box.collimated        = true
RN2_dis_box.use_mipfilter     = true
RN2_dis_box.additive_alpha    = true
RN2_dis_box.isvisible		 = true
RN2_dis_box.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
RN2_dis_box.level			 = HUD_DEFAULT_NOCLIP_LEVEL
RN2_dis_box.parent_element    = "hud_base_clip"  --Parent node name - can bind parent nodes that are not on the same layer
Add(RN2_dis_box)