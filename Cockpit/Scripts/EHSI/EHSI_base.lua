
dofile(LockOn_Options.script_path.."EHSI/EHSI_def.lua")

SHOW_MASKS = true -- enable debug

-- This operation can align the newly created cropping block to the three connectors
-- Must use FOV mode
local half_width   = GetScale()
local half_height  = GetAspect() * half_width

local aspect       = GetAspect()

-- This is the top trim layer of the total instrument
local ehsi_base_clip 			 	= CreateElement "ceMeshPoly" --This is the clipping layer
ehsi_base_clip.name 			    = "ehsi_base_clip"
ehsi_base_clip.primitivetype   	    = "triangles"
ehsi_base_clip.vertices 		    = { {1, aspect}, { 1,-aspect}, { -1,-aspect}, {-1,aspect},} --四个边角
ehsi_base_clip.indices 		        = {0,1,2,0,2,3}
ehsi_base_clip.init_pos		        = {0, 0, 0}
ehsi_base_clip.init_rot		        = {0, 0, 0}
ehsi_base_clip.material		        = "DBG_GREY"
ehsi_base_clip.h_clip_relation      = h_clip_relations.REWRITE_LEVEL --INCREASE_IF_LEVEL--COMPARE --REWRITE_LEVEL
ehsi_base_clip.level			    = EHSI_DEFAULT_NOCLIP_LEVEL
ehsi_base_clip.isdraw		        = true
ehsi_base_clip.change_opacity       = false
ehsi_base_clip.element_params       = {"EHSI_DIS_ENABLE"}              -- Initialize the main display control
ehsi_base_clip.controllers          = {{"opacity_using_parameter",0}}
ehsi_base_clip.isvisible		    = SHOW_MASKS
Add(ehsi_base_clip)

-- Full view control element
local ehsi_compass_rot_ctrl                     = CreateElement "ceSimple"
ehsi_compass_rot_ctrl.name                      = "ehsi_compass_rot_ctrl"
ehsi_compass_rot_ctrl.init_pos                  = {0, 0, 0}
ehsi_compass_rot_ctrl.element_params            = {"COMPASS_ROLL","COMPASS_FULL_ENABLE",}
ehsi_compass_rot_ctrl.controllers               = {{"rotate_using_parameter", 0, 0.0174532925199433 * 180},{"opacity_using_parameter",1}}
ehsi_compass_rot_ctrl.collimated	            = true
ehsi_compass_rot_ctrl.use_mipfilter             = true
ehsi_compass_rot_ctrl.additive_alpha            = true
ehsi_compass_rot_ctrl.h_clip_relation           = h_clip_relations.COMPARE
ehsi_compass_rot_ctrl.level                     = EHSI_DEFAULT_NOCLIP_LEVEL
ehsi_compass_rot_ctrl.parent_element	        = "ehsi_base_clip"
ehsi_compass_rot_ctrl.isvisible                 = false
Add(ehsi_compass_rot_ctrl)

-- full view compass center distance
local hsi_compass_pattern 				       = CreateElement "ceTexPoly"
hsi_compass_pattern.vertices                   = EHSI_vert_gen(3500,3500)
hsi_compass_pattern.indices                    = {0,1,2,2,3,0}
hsi_compass_pattern.tex_coords                 = tex_coord_gen(256,1024,512,1536,2048,2048)
hsi_compass_pattern.material                   = basic_ehsi_material
hsi_compass_pattern.name 			           = create_guid_string()
hsi_compass_pattern.init_pos                   = {0, 0, 0}
hsi_compass_pattern.init_rot		           = {0, 0, 0}
hsi_compass_pattern.collimated	               = true
hsi_compass_pattern.element_params             = {"COMPASS_FULL_ENABLE"}              -- Initialize the main display control
hsi_compass_pattern.controllers                = {{"opacity_using_parameter",0}}
hsi_compass_pattern.use_mipfilter              = true
hsi_compass_pattern.additive_alpha             = true
hsi_compass_pattern.h_clip_relation            = h_clip_relations.COMPARE
hsi_compass_pattern.level                      = EHSI_DEFAULT_NOCLIP_LEVEL
hsi_compass_pattern.parent_element	           = "ehsi_base_clip"
Add(hsi_compass_pattern)

-- full view compass element
local hsi_compass_pattern 				       = CreateElement "ceTexPoly"
hsi_compass_pattern.vertices                   = EHSI_vert_gen(3500,3500)
hsi_compass_pattern.indices                    = {0,1,2,2,3,0}
hsi_compass_pattern.tex_coords                 = tex_coord_gen(0,0,1024,1024,2048,2048)
hsi_compass_pattern.material                   = basic_ehsi_material
hsi_compass_pattern.name 			           = create_guid_string()
hsi_compass_pattern.init_pos                   = {0, 0, 0}
hsi_compass_pattern.init_rot		           = {0, 0, 0}
hsi_compass_pattern.collimated	               = true
hsi_compass_pattern.element_params             = {"COMPASS_FULL_ENABLE"}              -- Initialize the main display control
hsi_compass_pattern.controllers                = {{"opacity_using_parameter",0}}
hsi_compass_pattern.use_mipfilter              = true
hsi_compass_pattern.additive_alpha             = true
hsi_compass_pattern.h_clip_relation            = h_clip_relations.COMPARE
hsi_compass_pattern.level                      = EHSI_DEFAULT_NOCLIP_LEVEL
hsi_compass_pattern.parent_element	           = "ehsi_compass_rot_ctrl"
Add(hsi_compass_pattern)

HEADING = {"N","E","S","W"}

for i = 0, 330, 30 do
    local compass_mark             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
    compass_mark.material          = EHSI_font_white    --FONT_             --Material type (note the font material created above)
    compass_mark.init_pos          = {(math.cos(math.rad(i)) * 1650)/default_ehsi_x, (math.sin(math.rad(i)) * 1650)/default_ehsi_y}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
    compass_mark.alignment         = "CenterCenter"       --Alignment settings：Left/Right/Center; Top/Down/Center
    compass_mark.stringdefs        = {0.8*0.004,0.8 * 0.004, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
    if (math.fmod(i, 90) == 0) then
        compass_mark.formats           = {HEADING[i/90+1], "%s"}
    else
        compass_mark.formats           = {tostring(i), "%s"}
    end
    -- The output is set here, similar to the printf model of C.% is the output type at the beginning, and the following %s is the input type
    compass_mark.element_params    = {"EHSI_COMPASS", "COMPASS_FULL_ENABLE", "COMPASS_ROLL"} -- top left first line display
    compass_mark.controllers       = {{"text_using_parameter",0},{"opacity_using_parameter",1},{"rotate_using_parameter", 2, -0.0174532925199433 * 180}}
    compass_mark.collimated        = true
    compass_mark.use_mipfilter     = true
    compass_mark.additive_alpha    = true
    compass_mark.isvisible		   = true
    compass_mark.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
    compass_mark.level			   = EHSI_DEFAULT_NOCLIP_LEVEL
    compass_mark.parent_element    = "ehsi_compass_rot_ctrl"  --Parent node name - can bind parent nodes that are not on the same layer
    Add(compass_mark)
end