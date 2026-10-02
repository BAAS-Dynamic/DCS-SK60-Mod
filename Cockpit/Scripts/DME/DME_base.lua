dofile(LockOn_Options.script_path.."DME/DME_def.lua")

SHOW_MASKS = false
local aspect = GetAspect()

local dme_base_clip = CreateElement "ceMeshPoly"
dme_base_clip.name = "dme_base_clip"
dme_base_clip.primitivetype = "triangles"
dme_base_clip.vertices = {{1.0, aspect}, {1.0, -aspect}, {-1.0, -aspect}, {-1.0, aspect}}
dme_base_clip.indices = {0, 1, 2, 0, 2, 3}
dme_base_clip.init_pos = {0, 0, 0}
dme_base_clip.init_rot = {0, 0, 0}
dme_base_clip.material = "DBG_GREY"
dme_base_clip.h_clip_relation = h_clip_relations.REWRITE_LEVEL
dme_base_clip.level = DME_DEFAULT_NOCLIP_LEVEL
dme_base_clip.isdraw = true
dme_base_clip.change_opacity = false
dme_base_clip.element_params = {"DME_DISPLAY_ENABLE"}
dme_base_clip.controllers = {{"opacity_using_parameter", 0},}
dme_base_clip.isvisible = SHOW_MASKS
Add(dme_base_clip)

local function create_dme_numeric_text(name, x_pos, data_param, data_format)
    local text = CreateElement "ceStringPoly"
    text.name = name
    text.material = "LCD_font_white"
    text.init_pos = {x_pos, 0}
    text.alignment = "CenterCenter"
    text.stringdefs = {0.8 * 0.0095, 0.8 * 0.0095, 0, 0}
    text.formats = {data_format}
    text.element_params = {data_param, "DME_DISPLAY_ENABLE", "DME_DATA_VALID"}
    text.controllers = {
        {"text_using_parameter", 0},
        {"change_color_when_parameter_equal_to_number", 1, 1, 230 / 255, 40 / 255, 40 / 255},
        {"opacity_using_parameter", 1},
        {"parameter_in_range", 2, 0.5, 1.5},
    }
    text.collimated = true
    text.use_mipfilter = true
    text.additive_alpha = true
    text.isvisible = true
    text.h_clip_relation = h_clip_relations.COMPARE
    text.level = DME_DEFAULT_NOCLIP_LEVEL
    text.parent_element = "dme_base_clip"
    Add(text)
end

local function create_dme_dash_text(name, x_pos, dash_text)
    local text = CreateElement "ceStringPoly"
    text.name = name
    text.material = "LCD_font_white"
    text.value = dash_text
    text.init_pos = {x_pos, 0}
    text.alignment = "CenterCenter"
    text.stringdefs = {0.8 * 0.0095, 0.8 * 0.0095, 0, 0}
    text.element_params = {"DME_DISPLAY_ENABLE", "DME_DATA_VALID"}
    text.controllers = {
        {"change_color_when_parameter_equal_to_number", 0, 1, 230 / 255, 40 / 255, 40 / 255},
        {"opacity_using_parameter", 0},
        {"parameter_in_range", 1, -0.5, 0.5},
    }
    text.collimated = true
    text.use_mipfilter = true
    text.additive_alpha = true
    text.isvisible = true
    text.h_clip_relation = h_clip_relations.COMPARE
    text.level = DME_DEFAULT_NOCLIP_LEVEL
    text.parent_element = "dme_base_clip"
    Add(text)
end

create_dme_numeric_text("dme_distance_digits", -0.66, "DME_DISPLAY_DIST", "%05.1f")
create_dme_numeric_text("dme_speed_digits",    0.00, "DME_DISPLAY_GS",   "%03.0f")
create_dme_numeric_text("dme_time_digits",     0.66, "DME_DISPLAY_TIME", "%02.0f")

create_dme_dash_text("dme_distance_dash", -0.66, "---.-")
create_dme_dash_text("dme_speed_dash",     0.00, "---")
create_dme_dash_text("dme_time_dash",      0.66, "--")
