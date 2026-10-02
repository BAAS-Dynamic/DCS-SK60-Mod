dofile(LockOn_Options.script_path.."RNAV/RNAV_def.lua")

SHOW_MASKS = false
local aspect = GetAspect()

local rnav_base_clip = CreateElement "ceMeshPoly"
rnav_base_clip.name = "rnav_base_clip"
rnav_base_clip.primitivetype = "triangles"
rnav_base_clip.vertices = {{1.0, aspect}, {1.0, -aspect}, {-1.0, -aspect}, {-1.0, aspect}}
rnav_base_clip.indices = {0, 1, 2, 0, 2, 3}
rnav_base_clip.init_pos = {0, 0, 0}
rnav_base_clip.init_rot = {0, 0, 0}
rnav_base_clip.material = "DBG_GREY"
rnav_base_clip.h_clip_relation = h_clip_relations.REWRITE_LEVEL
rnav_base_clip.level = RNAV_DEFAULT_NOCLIP_LEVEL
rnav_base_clip.isdraw = true
rnav_base_clip.change_opacity = false
rnav_base_clip.element_params = {"RNAV_DISPLAY_ENABLE"}
rnav_base_clip.controllers = {{"opacity_using_parameter", 0},}
rnav_base_clip.isvisible = SHOW_MASKS
Add(rnav_base_clip)

local function create_rnav_text(name, x_pos, data_param, data_format)
    local text = CreateElement "ceStringPoly"
    text.name = name
    text.material = "LCD_font_white"
    text.init_pos = {x_pos, 0}
    text.alignment = "CenterCenter"
    text.stringdefs = {0.8 * 0.0095, 0.8 * 0.0095, 0, 0}
    text.formats = {data_format}
    text.element_params = {data_param, "RNAV_DISPLAY_ENABLE"}
    text.controllers = {
        {"text_using_parameter", 0},
        {"change_color_when_parameter_equal_to_number", 1, 1, 230 / 255, 40 / 255, 40 / 255},
        {"opacity_using_parameter", 1},
    }
    text.collimated = true
    text.use_mipfilter = true
    text.additive_alpha = true
    text.isvisible = true
    text.h_clip_relation = h_clip_relations.COMPARE
    text.level = RNAV_DEFAULT_NOCLIP_LEVEL
    text.parent_element = "rnav_base_clip"
    Add(text)
end

local function create_rnav_blinking_text(name, x_pos, data_param, data_format, visible_param, blink_param)
    local text = CreateElement "ceStringPoly"
    text.name = name
    text.material = "LCD_font_white"
    text.init_pos = {x_pos, 0}
    text.alignment = "CenterCenter"
    text.stringdefs = {0.8 * 0.0095, 0.8 * 0.0095, 0, 0}
    text.formats = {data_format}
    text.element_params = {data_param, visible_param, blink_param, "RNAV_DISPLAY_ENABLE"}
    text.controllers = {
        {"text_using_parameter", 0},
        {"change_color_when_parameter_equal_to_number", 3, 1, 230 / 255, 40 / 255, 40 / 255},
        {"opacity_using_parameter", 3},
        {"parameter_in_range", 1, 0.5, 1.5},
        {"parameter_in_range", 2, 0.5, 1.5},
    }
    text.collimated = true
    text.use_mipfilter = true
    text.additive_alpha = true
    text.isvisible = true
    text.h_clip_relation = h_clip_relations.COMPARE
    text.level = RNAV_DEFAULT_NOCLIP_LEVEL
    text.parent_element = "rnav_base_clip"
    Add(text)
end

create_rnav_text("rnav_frequency_digits", -0.06, "RNAV_DISPLAY_FRQ", "%.2f")
create_rnav_text("rnav_bearing_digits",    0.33, "RNAV_DISPLAY_RAD", "%03.0f")
create_rnav_text("rnav_distance_digits",   0.72, "RNAV_DISPLAY_DST", "%05.1f")
create_rnav_blinking_text("rnav_waypoint_active_digits",  -0.72, "RNAV_DISPLAY_WPT", "%1.0f", "RNAV_WPT_ACTIVE", "RNAV_DISPLAY_ENABLE")
create_rnav_blinking_text("rnav_waypoint_pending_digits", -0.72, "RNAV_DISPLAY_WPT", "%1.0f", "RNAV_WPT_PENDING", "RNAV_SEL_BLINK")
