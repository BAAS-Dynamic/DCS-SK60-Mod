dofile(LockOn_Options.script_path.."CustomMenu/menu_def.lua")
dofile(LockOn_Options.script_path.."version.lua")

SHOW_MASKS = true

local  screen_height =          LockOn_Options.screen.height * 0.5
local  screen_width  =          LockOn_Options.screen.width * 0.5

-- load config for easier change layout
dofile(LockOn_Options.script_path.."CustomMenu/menu_config.lua")

-- Base clip for the menu system
menu_base_clip 			 	        = CreateElement "ceMeshPoly" --This is the clipping layer
menu_base_clip.name 			    = "menu_base_clip"
menu_base_clip.primitivetype   	    = "triangles"
menu_base_clip.vertices 		    = { {screen_width, screen_height}, { screen_width,-screen_height}, { -screen_width,-screen_height}, {-screen_width,screen_height},} --四个边角 --四个边角
menu_base_clip.indices 		        = {0,1,2,0,2,3} -- Index, each group of three forms a triangle that will be displayed, and the number represents the previous vert coordinate
menu_base_clip.init_pos		        = {0, 0, 0}
menu_base_clip.init_rot		        = {0, 0, 0}
menu_base_clip.material		        = "DBG_GREEN"
menu_base_clip.element_params       = {"MENU_BASE_CLIP"}
menu_base_clip.controllers          = {{"opacity_using_parameter",0}}
menu_base_clip.h_clip_relation      = h_clip_relations.REWRITE_LEVEL --INCREASE_IF_LEVEL--COMPARE --REWRITE_LEVEL
menu_base_clip.level			    = MENU_DEFAULT_NOCLIP_LEVEL
menu_base_clip.isdraw		        = SHOW_MASKS
menu_base_clip.change_opacity       = false
menu_base_clip.isvisible		    = false
Add(menu_base_clip)

-- Center Circle clip
current_menu_center 	 	        = CreateElement "ceMeshPoly" --This is the clipping layer
menu_base_clip.name 			    = "menu_center_clip"
menu_base_clip.primitivetype   	    = "triangles"
menu_base_clip.vertices 		    = create_circle_pos(30, 0, 0, 0.4 * screen_height)
menu_base_clip.indices 		        = create_circle_index(30)
menu_base_clip.init_pos		        = {0, 0, 0}
menu_base_clip.init_rot		        = {0, 0, 0}
menu_base_clip.material		        = "DBG_GREY"
menu_base_clip.element_params       = {"MENU_BASE_CLIP"}
menu_base_clip.controllers          = {{"opacity_using_parameter",0}}
menu_base_clip.h_clip_relation      = h_clip_relations.INCREASE_IF_LEVEL
menu_base_clip.level			    = MENU_DEFAULT_LEVEL - 1
menu_base_clip.isdraw		        = SHOW_MASKS
menu_base_clip.change_opacity       = false
menu_base_clip.isvisible		    = false
Add(menu_base_clip)

-- Center Name Parameter "menu_center_clip"
local menu_enter_text             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
menu_enter_text.material          = "BS430_font_white"    --FONT_             --Material type (note the font material created above)
menu_enter_text.init_pos          = {0, - 0.1}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
menu_enter_text.alignment         = "CenterCenter"       --Alignment settings：Left/Right/Center; Top/Down/Center
menu_enter_text.stringdefs        = {60/screen_width/2, 30/screen_width/2, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
menu_enter_text.formats           = {"%s","%s"} -- The output is set here, similar to the printf model of C.% is the output type at the beginning, and the following %s is the input type
menu_enter_text.element_params    = {"MENU_CENTER_STR","MENU_BASE_CLIP"} -- top left first line display
menu_enter_text.controllers       = {{"text_using_parameter",0},{"opacity_using_parameter",1}}
menu_enter_text.collimated        = true
menu_enter_text.use_mipfilter     = true
menu_enter_text.additive_alpha    = true
menu_enter_text.isvisible		  = true
menu_enter_text.h_clip_relation   = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
menu_enter_text.level			  = MENU_DEFAULT_LEVEL
menu_enter_text.parent_element    = "menu_center_clip"  --Parent node name - can bind parent nodes that are not on the same layer
Add(menu_enter_text)

-- load icon of submenu
for i, v in ipairs(submenu_id) do
    temp_string = "MENU_CENTER_"..v
    texture_offset_x = math.fmod(submenu[v][0][2], 8)
    texture_offset_y = math.modf(submenu[v][0][2]/ 8)
    -- StartUP Logo -- test only
    menu_center_icon 				              = CreateElement "ceTexPoly"
    menu_center_icon.vertices                     = mesh_vert_gen(0.4 * screen_width, 0.4 * screen_height)
    menu_center_icon.indices                      = {0,1,2,2,3,0}
    menu_center_icon.tex_coords                   = tex_coord_gen(texture_offset_x,texture_offset_y,1,1,8,8)
    menu_center_icon.material                     = basic_ns430_material
    menu_center_icon.name 			              = create_guid_string()
    menu_center_icon.init_pos                     = {0, 0.05, 0}
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

for i, page_index in ipairs(submenu_id) do
    temp_string = "MENU_SUB_"..page_index
    for j, subsect_index in ipairs(submenu[page_index]) do
        -- icon 0 is for indicate the center display
        if j ~= 0 then
            temp_str_2 = temp_string.."_SEC_"..j
            texture_offset_x = math.fmod(subsect_index[2], 8)
            texture_offset_y = math.modf(subsect_index[2]/ 8)

            local menu_section                   = CreateElement "ceSimple"
            menu_section.name                    = temp_str_2.."_mov"
            menu_section.init_pos                = {0, 0, 0}
            menu_section.element_params          = {temp_str_2.."_Y", temp_str_2.."_X", temp_str_2}
            menu_section.controllers             = {{"move_up_down_using_parameter",0,0.075},{"move_left_right_using_parameter",1,0.075},{"opacity_using_parameter",2}}
            menu_section.collimated	             = true
            menu_section.use_mipfilter           = true
            menu_section.additive_alpha          = true
            menu_section.h_clip_relation         = h_clip_relations.COMPARE
            menu_section.level                   = MENU_DEFAULT_NOCLIP_LEVEL
            menu_section.parent_element	         = "menu_base_clip"
            menu_section.isvisible               = false
            Add(menu_section)

            menu_section_icon 				               = CreateElement "ceTexPoly"
            menu_section_icon.vertices                     = mesh_vert_gen(1500,750)
            menu_section_icon.indices                      = {0,1,2,2,3,0}
            menu_section_icon.tex_coords                   = tex_coord_gen(texture_offset_x,texture_offset_y,1,1,8,8)
            menu_section_icon.material                     = basic_ns430_material
            menu_section_icon.name 			               = create_guid_string()
            menu_section_icon.init_pos                     = {0, 0, 0}
            menu_section_icon.init_rot		               = {0, 0, 0}
            menu_section_icon.collimated	               = true
            menu_section_icon.element_params               = {temp_str_2}              -- Initialize the main display control
            menu_section_icon.controllers                  = {{"opacity_using_parameter",0}}
            menu_section_icon.use_mipfilter                = true
            menu_section_icon.additive_alpha               = true
            menu_section_icon.h_clip_relation              = h_clip_relations.COMPARE
            menu_section_icon.level                        = MENU_DEFAULT_NOCLIP_LEVEL
            menu_section_icon.parent_element	           = temp_str_2.."_mov"
            Add(menu_section_icon)

            local Debug_text_box_1             = CreateElement "ceStringPoly" --Create a character output element "ceTexPoly" means to create a texture model
            Debug_text_box_1.material          = "BS430_font_white"    --FONT_             --Material type (note the font material created above)
            Debug_text_box_1.init_pos          = {0, - 0.02}         -- This is the coordinates of the alignment point [this is the maximum limit of the current model (do not exceed when aligning the corners)]
            Debug_text_box_1.alignment         = "CenterCenter"       --Alignment settings：Left/Right/Center; Top/Down/Center
            Debug_text_box_1.stringdefs        = {60/screen_width/2, 30/screen_width/2, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} The first value controls the width, the second value controls the height
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