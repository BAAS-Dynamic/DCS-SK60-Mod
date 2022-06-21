-- layer base for flight plan
-- 790 * 475 // 1024 * 512
local Flight_Plan_Clip                      = CreateElement "ceMeshPoly" --This is the clipping layer
Flight_Plan_Clip.name 			            = "flight_plan_clip"
Flight_Plan_Clip.vertices 		            = { {0.7715, aspect * 0.92773}, {0.7715,-aspect * 0.92773}, {-0.7715,-aspect * 0.92773}, {-0.7715,aspect * 0.92773},} --四个边角
Flight_Plan_Clip.indices 		            = {0,1,2,0,2,3}
Flight_Plan_Clip.init_pos		            = {0.2285, 0.0722344, 0}
Flight_Plan_Clip.init_rot		            = {0, 0, 0}
Flight_Plan_Clip.material		            = "DBG_BLUE" -- "EALT_BG_COLOR"
Flight_Plan_Clip.h_clip_relation            = h_clip_relations.INCREASE_IF_LEVEL --INCREASE_IF_LEVEL--COMPARE --REWRITE_LEVEL
Flight_Plan_Clip.level			            = NS430_DEFAULT_LEVEL - 1
Flight_Plan_Clip.isdraw		                = true
Flight_Plan_Clip.change_opacity             = false
Flight_Plan_Clip.element_params             = {"NS430_FPL_ACT_DISPLAY"}              -- Initialize the main display control
Flight_Plan_Clip.controllers                = {{"opacity_using_parameter",0}}
Flight_Plan_Clip.parent_element	            = "base_disp_clip"
Flight_Plan_Clip.isvisible		            = SHOW_MASKS
Add(Flight_Plan_Clip)

-- background color
local Flight_Plan_Clip                      = CreateElement "ceTexPoly" --This is the clipping layer
Flight_Plan_Clip.name 			            = "flight_plan_bg_tex"
Flight_Plan_Clip.vertices 		            = { {0.7715, aspect * 0.92773}, {0.7715,-aspect * 0.92773}, {-0.7715,-aspect * 0.92773}, {-0.7715,aspect * 0.92773},} --四个边角
Flight_Plan_Clip.indices 		            = {0,1,2,0,2,3}
Flight_Plan_Clip.init_pos		            = {0, 0, 0}  --{0.2285, 0.0722344, 0}
Flight_Plan_Clip.init_rot		            = {0, 0, 0}
Flight_Plan_Clip.material		            = "EALT_BG_COLOR"
Flight_Plan_Clip.h_clip_relation            = h_clip_relations.COMPARE --INCREASE_IF_LEVEL--COMPARE --REWRITE_LEVEL
Flight_Plan_Clip.level			            = NS430_DEFAULT_LEVEL
Flight_Plan_Clip.isdraw		                = true
Flight_Plan_Clip.change_opacity             = false
Flight_Plan_Clip.element_params             = {"NS430_FPL_ACT_DISPLAY"}              -- Initialize the main display control
Flight_Plan_Clip.controllers                = {{"opacity_using_parameter",0}}
Flight_Plan_Clip.parent_element	            = "flight_plan_clip"
Flight_Plan_Clip.isvisible		            = true
Add(Flight_Plan_Clip)

-- line height 110 px, distance 20px
-- "BS430_font_white"
local BS430_FPL_TITLE             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
BS430_FPL_TITLE.material          = "BS430_font_white"    --FONT_             --Material type (note the font material created above)
BS430_FPL_TITLE.init_pos          = {0, 770 * aspect / default_gps_x}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
BS430_FPL_TITLE.alignment         = "CenterTop"       --Alignment settings：Left/Right/Center; Top/Down/Center
BS430_FPL_TITLE.stringdefs        = {0.85 *0.004, 1 * 0.004, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
BS430_FPL_TITLE.formats           = {"ACTIVE FLIGHT PLAN", "%s"}
BS430_FPL_TITLE.element_params    = {"NS430_FPL_ACT_DISPLAY", "NS430_FPL_ACT_DISPLAY"} -- top left first line display
BS430_FPL_TITLE.controllers       = {{"text_using_parameter",0},{"opacity_using_parameter",1}}
BS430_FPL_TITLE.collimated        = true
BS430_FPL_TITLE.use_mipfilter     = true
BS430_FPL_TITLE.additive_alpha    = true
BS430_FPL_TITLE.isvisible		  = true
BS430_FPL_TITLE.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
BS430_FPL_TITLE.level			  = NS430_DEFAULT_LEVEL
BS430_FPL_TITLE.parent_element    = "flight_plan_clip"  --Parent node name - can bind parent nodes that are not on the same layer
Add(BS430_FPL_TITLE)

-- waypoint mark
local BS430_FPL_TITLE_WPT             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
BS430_FPL_TITLE_WPT.material          = "BS430_font_blue"    --FONT_             --Material type (note the font material created above)
BS430_FPL_TITLE_WPT.init_pos          = {-260*2/default_gps_x, 330 * aspect / default_gps_x}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
BS430_FPL_TITLE_WPT.alignment         = "CenterTop"       --Alignment settings：Left/Right/Center; Top/Down/Center
BS430_FPL_TITLE_WPT.stringdefs        = {0.85 *0.004, 1 * 0.004, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
BS430_FPL_TITLE_WPT.formats           = {"WAYPOINT", "%s"}
BS430_FPL_TITLE_WPT.element_params    = {"NS430_FPL_ACT_DISPLAY", "NS430_FPL_ACT_DISPLAY"} -- top left first line display
BS430_FPL_TITLE_WPT.controllers       = {{"text_using_parameter",0},{"opacity_using_parameter",1}}
BS430_FPL_TITLE_WPT.collimated        = true
BS430_FPL_TITLE_WPT.use_mipfilter     = true
BS430_FPL_TITLE_WPT.additive_alpha    = true
BS430_FPL_TITLE_WPT.isvisible		  = true
BS430_FPL_TITLE_WPT.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
BS430_FPL_TITLE_WPT.level			  = NS430_DEFAULT_LEVEL
BS430_FPL_TITLE_WPT.parent_element    = "flight_plan_clip"  --Parent node name - can bind parent nodes that are not on the same layer
Add(BS430_FPL_TITLE_WPT)

-- dtk mark
local BS430_FPL_TITLE_DTK             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
BS430_FPL_TITLE_DTK.material          = "BS430_font_blue"    --FONT_             --Material type (note the font material created above)
BS430_FPL_TITLE_DTK.init_pos          = {23.35*2/default_gps_x, 330 * aspect / default_gps_x}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
BS430_FPL_TITLE_DTK.alignment         = "CenterTop"       --Alignment settings：Left/Right/Center; Top/Down/Center
BS430_FPL_TITLE_DTK.stringdefs        = {0.85 *0.004, 1 * 0.004, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
BS430_FPL_TITLE_DTK.formats           = {"DTK", "%s"}
BS430_FPL_TITLE_DTK.element_params    = {"NS430_FPL_ACT_DISPLAY", "NS430_FPL_ACT_DISPLAY"} -- top left first line display
BS430_FPL_TITLE_DTK.controllers       = {{"text_using_parameter",0},{"opacity_using_parameter",1}}
BS430_FPL_TITLE_DTK.collimated        = true
BS430_FPL_TITLE_DTK.use_mipfilter     = true
BS430_FPL_TITLE_DTK.additive_alpha    = true
BS430_FPL_TITLE_DTK.isvisible		  = true
BS430_FPL_TITLE_DTK.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
BS430_FPL_TITLE_DTK.level			  = NS430_DEFAULT_LEVEL
BS430_FPL_TITLE_DTK.parent_element    = "flight_plan_clip"  --Parent node name - can bind parent nodes that are not on the same layer
Add(BS430_FPL_TITLE_DTK)

-- dis mark
local BS430_FPL_TITLE_DIS             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
BS430_FPL_TITLE_DIS.material          = "BS430_font_blue"    --FONT_             --Material type (note the font material created above)
BS430_FPL_TITLE_DIS.init_pos          = {259.25*2/default_gps_x, 330 * aspect / default_gps_x}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
BS430_FPL_TITLE_DIS.alignment         = "CenterTop"       --Alignment settings：Left/Right/Center; Top/Down/Center
BS430_FPL_TITLE_DIS.stringdefs        = {0.85 *0.004, 1 * 0.004, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
BS430_FPL_TITLE_DIS.formats           = {"DIS", "%s"}
BS430_FPL_TITLE_DIS.element_params    = {"NS430_FPL_ACT_DISPLAY", "NS430_FPL_ACT_DISPLAY"} -- top left first line display
BS430_FPL_TITLE_DIS.controllers       = {{"text_using_parameter",0},{"opacity_using_parameter",1}}
BS430_FPL_TITLE_DIS.collimated        = true
BS430_FPL_TITLE_DIS.use_mipfilter     = true
BS430_FPL_TITLE_DIS.additive_alpha    = true
BS430_FPL_TITLE_DIS.isvisible		  = true
BS430_FPL_TITLE_DIS.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
BS430_FPL_TITLE_DIS.level			  = NS430_DEFAULT_LEVEL
BS430_FPL_TITLE_DIS.parent_element    = "flight_plan_clip"  --Parent node name - can bind parent nodes that are not on the same layer
Add(BS430_FPL_TITLE_DIS)

local Flight_Plan_Clip                      = CreateElement "ceTexPoly" --This is the clipping layer
Flight_Plan_Clip.name 			            = "flight_plan_clip_black"
Flight_Plan_Clip.vertices 		            = GPS_vert_gen(748*2, 2*517.16*aspect)
Flight_Plan_Clip.indices 		            = {0,1,2,0,2,3}
Flight_Plan_Clip.init_pos		            = {0, - 2*108.6*aspect/default_gps_x - 0.0722344, 0}
Flight_Plan_Clip.init_rot		            = {0, 0, 0}
Flight_Plan_Clip.material		            = "DBG_GREY"
Flight_Plan_Clip.h_clip_relation            = h_clip_relations.COMPARE --INCREASE_IF_LEVEL--COMPARE --REWRITE_LEVEL
Flight_Plan_Clip.level			            = NS430_DEFAULT_LEVEL
Flight_Plan_Clip.isdraw		                = true
Flight_Plan_Clip.change_opacity             = false
Flight_Plan_Clip.element_params             = {"NS430_FPL_ACT_DISPLAY"}              -- Initialize the main display control
Flight_Plan_Clip.controllers                = {{"opacity_using_parameter",0}}
Flight_Plan_Clip.parent_element	            = "flight_plan_clip"
Flight_Plan_Clip.isvisible		            = true
Add(Flight_Plan_Clip)

local active_waypoint 				     = CreateElement "ceTexPoly"
active_waypoint.vertices                 = GPS_vert_gen(31.22,62.44)
active_waypoint.indices                  = {0,1,2,2,3,0}
active_waypoint.tex_coords               = tex_coord_gen(1536,256,128,128,2048,2048)
active_waypoint.material                 = "HUD_DAY_COLOR" -- basic_ns430_material --"DBG_GREEN"--blue_ns430_material
active_waypoint.name 			         = create_guid_string()
active_waypoint.init_pos                 = {(-260*2-150)/default_gps_x, (110-40) * aspect / default_gps_x}
active_waypoint.init_rot		         = {0, 0, 0}
active_waypoint.collimated	             = true
active_waypoint.element_params           = {"BS430_FPL_ACTWPT_SYMB", "BS430_FPL_ACTWPT_SYMB_POS"}
active_waypoint.controllers              = {{"opacity_using_parameter",0},{"move_up_down_using_parameter", 1, -220*aspect/default_gps_x*0.045},}
active_waypoint.use_mipfilter            = true
active_waypoint.additive_alpha           = true
active_waypoint.h_clip_relation          = h_clip_relations.COMPARE
active_waypoint.level                    = NS430_DEFAULT_LEVEL
active_waypoint.parent_element	         = "flight_plan_clip"
Add(active_waypoint)

local active_waypoint 				     = CreateElement "ceTexPoly"
active_waypoint.vertices                 = GPS_vert_gen(300,125)
active_waypoint.indices                  = {0,1,2,2,3,0}
active_waypoint.tex_coords               = tex_coord_gen(1536,256,128,128,2048,2048)
active_waypoint.material                 = "HUD_DAY_COLOR"      --blue_ns430_material
active_waypoint.name 			         = create_guid_string()
active_waypoint.init_pos                 = {-260*2/default_gps_x, (110-40) * aspect / default_gps_x}
active_waypoint.init_rot		         = {0, 0, 0}
active_waypoint.collimated	             = true
active_waypoint.element_params           = {"BS430_FPL_SEL_WPT", "BS430_FPL_SEL_WPT_POS"}
active_waypoint.controllers              = {{"opacity_using_parameter",0},{"move_up_down_using_parameter", 1, -220*aspect/default_gps_x*0.045},}
active_waypoint.use_mipfilter            = true
active_waypoint.additive_alpha           = true
active_waypoint.h_clip_relation          = h_clip_relations.COMPARE
active_waypoint.level                    = NS430_DEFAULT_LEVEL
active_waypoint.parent_element	         = "flight_plan_clip"
Add(active_waypoint)

-- line field
for i=0,3,1 do
    -- waypoint mark
    local BS430_FPL_TITLE_WPT             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
    BS430_FPL_TITLE_WPT.material          = "BS430_font_green"    --FONT_             --Material type (note the font material created above)
    BS430_FPL_TITLE_WPT.init_pos          = {-260*2/default_gps_x, (110 - 220*i) * aspect / default_gps_x}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
    BS430_FPL_TITLE_WPT.alignment         = "CenterTop"       --Alignment settings：Left/Right/Center; Top/Down/Center
    BS430_FPL_TITLE_WPT.stringdefs        = {0.85 *0.004, 1 * 0.004, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
    BS430_FPL_TITLE_WPT.formats           = {"%s", "%s"}
    BS430_FPL_TITLE_WPT.element_params    = {"NS430_FPL_ACT_WPT_"..i, "NS430_FPL_ACT_DISPLAY", "BS430_FPL_SEL_WPT_POS"} -- top left first line display
    BS430_FPL_TITLE_WPT.controllers       = {{"text_using_parameter",0},{"opacity_using_parameter",1},{"change_color_when_parameter_equal_to_number", 2, i, 255/255,255/255,255/255}}
    BS430_FPL_TITLE_WPT.collimated        = true
    BS430_FPL_TITLE_WPT.use_mipfilter     = true
    BS430_FPL_TITLE_WPT.additive_alpha    = true
    BS430_FPL_TITLE_WPT.isvisible		  = true
    BS430_FPL_TITLE_WPT.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
    BS430_FPL_TITLE_WPT.level			  = NS430_DEFAULT_LEVEL
    BS430_FPL_TITLE_WPT.parent_element    = "flight_plan_clip"  --Parent node name - can bind parent nodes that are not on the same layer
    Add(BS430_FPL_TITLE_WPT)

    -- dtk mark
    local BS430_FPL_TITLE_DTK             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
    BS430_FPL_TITLE_DTK.material          = "BS430_font_green"    --FONT_             --Material type (note the font material created above)
    BS430_FPL_TITLE_DTK.init_pos          = {23.35*2/default_gps_x, (110 - 220*i) * aspect / default_gps_x}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
    BS430_FPL_TITLE_DTK.alignment         = "CenterTop"       --Alignment settings：Left/Right/Center; Top/Down/Center
    BS430_FPL_TITLE_DTK.stringdefs        = {0.85 *0.004, 1 * 0.004, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
    BS430_FPL_TITLE_DTK.formats           = {"%s", "%s"}
    BS430_FPL_TITLE_DTK.element_params    = {"NS430_FPL_ACT_DTK_"..i, "NS430_FPL_ACT_DISPLAY"} -- top left first line display
    BS430_FPL_TITLE_DTK.controllers       = {{"text_using_parameter",0},{"opacity_using_parameter",1}}
    BS430_FPL_TITLE_DTK.collimated        = true
    BS430_FPL_TITLE_DTK.use_mipfilter     = true
    BS430_FPL_TITLE_DTK.additive_alpha    = true
    BS430_FPL_TITLE_DTK.isvisible		  = true
    BS430_FPL_TITLE_DTK.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
    BS430_FPL_TITLE_DTK.level			  = NS430_DEFAULT_LEVEL
    BS430_FPL_TITLE_DTK.parent_element    = "flight_plan_clip"  --Parent node name - can bind parent nodes that are not on the same layer
    Add(BS430_FPL_TITLE_DTK)

    -- dis mark
    local BS430_FPL_TITLE_DIS             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
    BS430_FPL_TITLE_DIS.material          = "BS430_font_green"    --FONT_             --Material type (note the font material created above)
    BS430_FPL_TITLE_DIS.init_pos          = {259.25*2/default_gps_x, (110 - 220*i) * aspect / default_gps_x}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
    BS430_FPL_TITLE_DIS.alignment         = "CenterTop"       --Alignment settings：Left/Right/Center; Top/Down/Center
    BS430_FPL_TITLE_DIS.stringdefs        = {0.85 *0.004, 1 * 0.004, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
    BS430_FPL_TITLE_DIS.formats           = {"%s", "%s"}
    BS430_FPL_TITLE_DIS.element_params    = {"NS430_FPL_ACT_DIS_"..i, "NS430_FPL_ACT_DISPLAY"} -- top left first line display
    BS430_FPL_TITLE_DIS.controllers       = {{"text_using_parameter",0},{"opacity_using_parameter",1}}
    BS430_FPL_TITLE_DIS.collimated        = true
    BS430_FPL_TITLE_DIS.use_mipfilter     = true
    BS430_FPL_TITLE_DIS.additive_alpha    = true
    BS430_FPL_TITLE_DIS.isvisible		  = true
    BS430_FPL_TITLE_DIS.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
    BS430_FPL_TITLE_DIS.level			  = NS430_DEFAULT_LEVEL
    BS430_FPL_TITLE_DIS.parent_element    = "flight_plan_clip"  --Parent node name - can bind parent nodes that are not on the same layer
    Add(BS430_FPL_TITLE_DIS)
end