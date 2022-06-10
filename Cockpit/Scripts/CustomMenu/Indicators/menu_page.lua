dofile(LockOn_Options.script_path.."CustomMenu/menu_def.lua")
dofile(LockOn_Options.script_path.."version.lua")
dofile(LockOn_Options.script_path.."CustomMenu/menu_config.lua")

local  screen_height =          LockOn_Options.screen.height * 0.5
local  screen_width  =          LockOn_Options.screen.width * 0.5

-- This is the top trim layer of the total instrument
HUD_base_clip 			 	    = CreateElement "ceMeshPoly" --This is the clipping layer
HUD_base_clip.name 			    = "menu_base_clip"
HUD_base_clip.primitivetype   	= "triangles"
HUD_base_clip.vertices 		    = { {screen_width, screen_height}, { screen_width,-screen_height}, { -screen_width,-screen_height}, {-screen_width,screen_height},} --四个边角 --四个边角
HUD_base_clip.indices 		    = {0,1,2,0,2,3} -- Index, each group of three forms a triangle that will be displayed, and the number represents the previous vert coordinate
HUD_base_clip.init_pos		    = {0, 0, 0}
HUD_base_clip.init_rot		    = {0, 0, 0}
HUD_base_clip.material		    = "DBG_GREEN"
HUD_base_clip.element_params    = {"MENU_DISP_ENABLE"}
HUD_base_clip.controllers       = {{"opacity_using_parameter",0}}
HUD_base_clip.h_clip_relation   = h_clip_relations.REWRITE_LEVEL --INCREASE_IF_LEVEL--COMPARE --REWRITE_LEVEL
HUD_base_clip.level			    = MENU_DEFAULT_NOCLIP_LEVEL
HUD_base_clip.isdraw		    = true
HUD_base_clip.change_opacity    = false
HUD_base_clip.isvisible		    = false
Add(HUD_base_clip)

-- The cursor 
temp_str_2 = "MENU_CURSOR"
texture_offset_x = math.fmod((8-1), 8)
texture_offset_y = math.modf((8-1)/ 8)

local menu_center_icon 				          = CreateElement "ceTexPoly"
menu_center_icon.vertices                     = mesh_vert_gen(0.3*screen_height, 0.3*screen_height)
menu_center_icon.indices                      = {0,1,2,2,3,0}
menu_center_icon.tex_coords                   = tex_coord_gen(texture_offset_x*256,texture_offset_y*256,256,256,2048,2048)
menu_center_icon.material                     = basic_menu_material
menu_center_icon.name 			              = create_guid_string()
menu_center_icon.init_pos                     = {0, 0, 0}
menu_center_icon.init_rot		              = {0, 0, 0}
menu_center_icon.collimated	                  = true
menu_center_icon.element_params               = {temp_str_2, temp_str_2.."_Y", temp_str_2.."_X"}              -- Initialize the main display control
menu_center_icon.controllers                  = {{"opacity_using_parameter",0},{"move_up_down_using_parameter",1, 0.5/screen_height},{"move_left_right_using_parameter",2, 0.5/screen_width}}
menu_center_icon.use_mipfilter                = true
menu_center_icon.additive_alpha               = true
menu_center_icon.h_clip_relation              = h_clip_relations.COMPARE
menu_center_icon.level                        = MENU_DEFAULT_NOCLIP_LEVEL
menu_center_icon.parent_element	              = temp_str_2.."_mov"
Add(menu_center_icon)


-- Center Circle clip
local current_menu_center 	 	            = CreateElement "ceMeshPoly" --This is the clipping layer
current_menu_center.name 			        = "menu_center_clip"
current_menu_center.primitivetype   	    = "triangles"
current_menu_center.vertices 		        = create_circle_pos(60, 0, 0, 0.8*screen_height)
current_menu_center.indices 		        = create_circle_index(60)
current_menu_center.init_pos		        = {0, 0, 0}
current_menu_center.init_rot		        = {0, 0, 0}
current_menu_center.material		        = "MENU_GREY"
current_menu_center.element_params          = {"MENU_DISP_ENABLE"}
current_menu_center.controllers             = {{"opacity_using_parameter",0}}
current_menu_center.h_clip_relation         = h_clip_relations.INCREASE_IF_LEVEL
current_menu_center.level			        = MENU_DEFAULT_LEVEL - 1
current_menu_center.isdraw		            = true
current_menu_center.change_opacity          = false
current_menu_center.isvisible		        = true
Add(current_menu_center)

-- Text test
local Debug_text_box             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
Debug_text_box.material          = "BS430_font_white"    --FONT_             --Material type (note the font material created above)
Debug_text_box.init_pos          = {0, -0.2}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
Debug_text_box.alignment         = "CenterCenter"       --Alignment settings：Left/Right/Center; Top/Down/Center
Debug_text_box.stringdefs        = {80/1920, 40/1920, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
Debug_text_box.formats           = {"%s","%s"} -- The output is set here, similar to the printf model of C.% is the output type at the beginning, and the following %s is the input type
Debug_text_box.element_params    = {"MENU_CENTER_STR","MENU_DISP_ENABLE"} -- top left first line display
Debug_text_box.controllers       = {{"text_using_parameter",0},{"opacity_using_parameter",1}}
Debug_text_box.collimated        = true
Debug_text_box.use_mipfilter     = true
Debug_text_box.additive_alpha    = true
Debug_text_box.isvisible		 = true
Debug_text_box.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
Debug_text_box.level			 = MENU_DEFAULT_LEVEL
Debug_text_box.parent_element    = "menu_center_clip"  --Parent node name - can bind parent nodes that are not on the same layer
Add(Debug_text_box)

-- load icon of submenu
for i, v in pairs(submenu_id) do
    temp_string = "MENU_CENTER_"..tostring(v)
    texture_offset_x = math.fmod(submenu[v][0][2] - 1, 8)
    texture_offset_y = math.modf((submenu[v][0][2] - 1)/8)
    -- StartUP Logo -- test only
    local menu_center_icon 				          = CreateElement "ceTexPoly"
    menu_center_icon.vertices                     = mesh_vert_gen(0.8*screen_height, 0.8*screen_height)
    menu_center_icon.indices                      = {0,1,2,2,3,0}
    menu_center_icon.tex_coords                   = tex_coord_gen(texture_offset_x*256,texture_offset_y*256,256,256,2048,2048)
    menu_center_icon.material                     = basic_menu_material
    menu_center_icon.name 			              = create_guid_string()
    menu_center_icon.init_pos                     = {0, 0.08, 0}
    menu_center_icon.init_rot		              = {0, 0, 0}
    menu_center_icon.collimated	                  = true
    menu_center_icon.element_params               = {temp_string.."_ICON"}              -- Initialize the main display control
    menu_center_icon.controllers                  = {{"opacity_using_parameter",0}}
    menu_center_icon.use_mipfilter                = true
    menu_center_icon.additive_alpha               = true
    menu_center_icon.h_clip_relation              = h_clip_relations.COMPARE
    menu_center_icon.level                        = MENU_DEFAULT_LEVEL
    menu_center_icon.parent_element	              = "menu_center_clip"
    Add(menu_center_icon)
end

for i, page_index in pairs(submenu_id) do
    temp_string = "MENU_SUB_"..tostring(page_index)
    for j, subsect_index in pairs(submenu[page_index]) do
        -- icon 0 is for indicate the center display
        if (j > 0 and j < 8) then
            temp_str_2 = temp_string.."_SEC_"..j
            texture_offset_x = math.fmod((subsect_index[2]-1), 8)
            texture_offset_y = math.modf((subsect_index[2]-1)/ 8)

            local menu_section                   = CreateElement "ceSimple"
            menu_section.name                    = temp_str_2.."_mov"
            menu_section.init_pos                = {0, 0, 0}
            menu_section.element_params          = {temp_str_2.."_Y", temp_str_2.."_X"}
            menu_section.controllers             = {{"move_up_down_using_parameter",0, 0.5/screen_height},{"move_left_right_using_parameter",1, 0.5/screen_width}}
            menu_section.collimated	             = true
            menu_section.use_mipfilter           = true
            menu_section.additive_alpha          = true
            menu_section.h_clip_relation         = h_clip_relations.COMPARE
            menu_section.level                   = MENU_DEFAULT_NOCLIP_LEVEL
            menu_section.parent_element	         = "menu_base_clip"
            menu_section.isvisible               = false
            Add(menu_section)

            -- StartUP Logo -- test only
            local menu_center_icon 				          = CreateElement "ceTexPoly"
            menu_center_icon.vertices                     = mesh_vert_gen(0.6*screen_height, 0.6*screen_height)
            menu_center_icon.indices                      = {0,1,2,2,3,0}
            menu_center_icon.tex_coords                   = tex_coord_gen(texture_offset_x*256,texture_offset_y*256,256,256,2048,2048)
            menu_center_icon.material                     = basic_menu_material
            menu_center_icon.name 			              = create_guid_string()
            menu_center_icon.init_pos                     = {0, 0, 0}
            menu_center_icon.init_rot		              = {0, 0, 0}
            menu_center_icon.collimated	                  = true
            menu_center_icon.element_params               = {temp_str_2}              -- Initialize the main display control
            menu_center_icon.controllers                  = {{"opacity_using_parameter",0}}
            menu_center_icon.use_mipfilter                = true
            menu_center_icon.additive_alpha               = true
            menu_center_icon.h_clip_relation              = h_clip_relations.COMPARE
            menu_center_icon.level                        = MENU_DEFAULT_NOCLIP_LEVEL
            menu_center_icon.parent_element	              = temp_str_2.."_mov"
            Add(menu_center_icon)

            local Debug_text_box_1             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
            Debug_text_box_1.material          = "BS430_font_white"    --FONT_             --Material type (note the font material created above)
            Debug_text_box_1.init_pos          = {0, - 0.2}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
            Debug_text_box_1.alignment         = "CenterCenter"       --Alignment settings：Left/Right/Center; Top/Down/Center
            Debug_text_box_1.stringdefs        = {60/1920, 30/1920, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
            Debug_text_box_1.formats           = {subsect_index[1],"%s"} -- The output is set here, similar to the printf model of C.% is the output type at the beginning, and the following %s is the input type
            Debug_text_box_1.element_params    = {"MENU_STR_TRI", temp_str_2} -- top left first line display
            Debug_text_box_1.controllers       = {{"text_using_parameter",0},{"opacity_using_parameter",1}}
            Debug_text_box_1.collimated        = true
            Debug_text_box_1.use_mipfilter     = true
            Debug_text_box_1.additive_alpha    = true
            Debug_text_box_1.isvisible		   = true
            Debug_text_box_1.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
            Debug_text_box_1.level			   = MENU_DEFAULT_NOCLIP_LEVEL
            Debug_text_box_1.parent_element    = temp_str_2.."_mov"  --Parent node name - can bind parent nodes that are not on the same layer
            Add(Debug_text_box_1)
        end
    end
end

texture_offset_x = math.fmod((5-1), 8)
texture_offset_y = math.modf((5-1)/ 8)
for i = 1,8,1 do
    temp_str = "MENU_ON_SEL_"..i

    local menu_section                   = CreateElement "ceSimple"
    menu_section.name                    = temp_str.."_mov"
    menu_section.init_pos                = {0, 0, 0}
    menu_section.element_params          = {temp_str.."_Y", temp_str.."_X"}
    menu_section.controllers             = {{"move_up_down_using_parameter",0, 0.5/screen_height},{"move_left_right_using_parameter",1, 0.5/screen_width}}
    menu_section.collimated	             = true
    menu_section.use_mipfilter           = true
    menu_section.additive_alpha          = true
    menu_section.h_clip_relation         = h_clip_relations.COMPARE
    menu_section.level                   = MENU_DEFAULT_NOCLIP_LEVEL
    menu_section.parent_element	         = "menu_base_clip"
    menu_section.isvisible               = false
    Add(menu_section)

    -- StartUP Logo -- test only
    local menu_center_icon 				          = CreateElement "ceTexPoly"
    menu_center_icon.vertices                     = mesh_vert_gen(0.3*screen_height, 0.3*screen_height)
    menu_center_icon.indices                      = {0,1,2,2,3,0}
    menu_center_icon.tex_coords                   = tex_coord_gen(texture_offset_x*256,texture_offset_y*256,256,256,2048,2048)
    menu_center_icon.material                     = basic_menu_material
    menu_center_icon.name 			              = create_guid_string()
    menu_center_icon.init_pos                     = {0, 0, 0}
    menu_center_icon.init_rot		              = {0, 0, 0}
    menu_center_icon.collimated	                  = true
    menu_center_icon.element_params               = {temp_str}              -- Initialize the main display control
    menu_center_icon.controllers                  = {{"opacity_using_parameter",0}}
    menu_center_icon.use_mipfilter                = true
    menu_center_icon.additive_alpha               = true
    menu_center_icon.h_clip_relation              = h_clip_relations.COMPARE
    menu_center_icon.level                        = MENU_DEFAULT_NOCLIP_LEVEL
    menu_center_icon.parent_element	              = temp_str.."_mov"
    Add(menu_center_icon)
end

-- this is return button
temp_str_2 = "MENU_SEC_RETURN"
texture_offset_x = math.fmod((4-1), 8)
texture_offset_y = math.modf((4-1)/ 8)

local menu_section                   = CreateElement "ceSimple"
menu_section.name                    = temp_str_2.."_mov"
menu_section.init_pos                = {0, 0, 0}
menu_section.element_params          = {temp_str_2.."_Y", temp_str_2.."_X"}
menu_section.controllers             = {{"move_up_down_using_parameter",0, 0.5/screen_height},{"move_left_right_using_parameter",1, 0.5/screen_width}}
menu_section.collimated	             = true
menu_section.use_mipfilter           = true
menu_section.additive_alpha          = true
menu_section.h_clip_relation         = h_clip_relations.COMPARE
menu_section.level                   = MENU_DEFAULT_NOCLIP_LEVEL
menu_section.parent_element	         = "menu_base_clip"
menu_section.isvisible               = false
Add(menu_section)

-- StartUP Logo -- test only
local menu_center_icon 				          = CreateElement "ceTexPoly"
menu_center_icon.vertices                     = mesh_vert_gen(0.6*screen_height, 0.6*screen_height)
menu_center_icon.indices                      = {0,1,2,2,3,0}
menu_center_icon.tex_coords                   = tex_coord_gen(texture_offset_x*256,texture_offset_y*256,256,256,2048,2048)
menu_center_icon.material                     = basic_menu_material
menu_center_icon.name 			              = create_guid_string()
menu_center_icon.init_pos                     = {0, 0, 0}
menu_center_icon.init_rot		              = {0, 0, 0}
menu_center_icon.collimated	                  = true
menu_center_icon.element_params               = {temp_str_2}              -- Initialize the main display control
menu_center_icon.controllers                  = {{"opacity_using_parameter",0}}
menu_center_icon.use_mipfilter                = true
menu_center_icon.additive_alpha               = true
menu_center_icon.h_clip_relation              = h_clip_relations.COMPARE
menu_center_icon.level                        = MENU_DEFAULT_NOCLIP_LEVEL
menu_center_icon.parent_element	              = temp_str_2.."_mov"
Add(menu_center_icon)

local Debug_text_box_1             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
Debug_text_box_1.material          = "BS430_font_white"    --FONT_             --Material type (note the font material created above)
Debug_text_box_1.init_pos          = {0, - 0.2}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
Debug_text_box_1.alignment         = "CenterCenter"       --Alignment settings：Left/Right/Center; Top/Down/Center
Debug_text_box_1.stringdefs        = {60/1920, 30/1920, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
Debug_text_box_1.formats           = {"return","%s"} -- The output is set here, similar to the printf model of C.% is the output type at the beginning, and the following %s is the input type
Debug_text_box_1.element_params    = {"MENU_STR_TRI", temp_str_2} -- top left first line display
Debug_text_box_1.controllers       = {{"text_using_parameter",0},{"opacity_using_parameter",1}}
Debug_text_box_1.collimated        = true
Debug_text_box_1.use_mipfilter     = true
Debug_text_box_1.additive_alpha    = true
Debug_text_box_1.isvisible		   = true
Debug_text_box_1.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
Debug_text_box_1.level			   = MENU_DEFAULT_NOCLIP_LEVEL
Debug_text_box_1.parent_element    = temp_str_2.."_mov"  --Parent node name - can bind parent nodes that are not on the same layer
Add(Debug_text_box_1)

