dofile(LockOn_Options.script_path.."ADF/ADF_def.lua")

SHOW_MASKS = false
local aspect = GetAspect()

local adf_base_clip = CreateElement "ceMeshPoly"
adf_base_clip.name = "adf_base_clip"
adf_base_clip.primitivetype = "triangles"
adf_base_clip.vertices = {{1.0, aspect}, {1.0, -aspect}, {-1.0, -aspect}, {-1.0, aspect}}
adf_base_clip.indices = {0, 1, 2, 0, 2, 3}
adf_base_clip.init_pos = {0, 0, 0}
adf_base_clip.init_rot = {0, 0, 0}
adf_base_clip.material = "DBG_GREY"
adf_base_clip.h_clip_relation = h_clip_relations.REWRITE_LEVEL
adf_base_clip.level = ADF_DEFAULT_NOCLIP_LEVEL
adf_base_clip.isdraw = true
adf_base_clip.change_opacity = false
adf_base_clip.element_params = {"ADF_DISPLAY_ENABLE"}
adf_base_clip.controllers = {{"opacity_using_parameter", 0},}
adf_base_clip.isvisible = SHOW_MASKS
Add(adf_base_clip)

local adf_freq_digits = CreateElement "ceStringPoly"
adf_freq_digits.name = "adf_frequency_digits"
adf_freq_digits.material = "LCD_font_white"
adf_freq_digits.init_pos = {0.0, 0}
adf_freq_digits.alignment = "CenterCenter"
adf_freq_digits.stringdefs = {0.8 * 0.0095, 0.8 * 0.0095, 0, 0}
adf_freq_digits.formats = {"%06.2f"}
adf_freq_digits.element_params = {"ADF_DISPLAY_FREQ", "ADF_DISPLAY_ENABLE"}
adf_freq_digits.controllers = {
    {"text_using_parameter", 0},
    {"change_color_when_parameter_equal_to_number", 1, 1, 230 / 255, 40 / 255, 40 / 255},
    {"opacity_using_parameter", 1},
}
adf_freq_digits.collimated = true
adf_freq_digits.use_mipfilter = true
adf_freq_digits.additive_alpha = true
adf_freq_digits.isvisible = true
adf_freq_digits.h_clip_relation = h_clip_relations.COMPARE
adf_freq_digits.level = ADF_DEFAULT_NOCLIP_LEVEL
adf_freq_digits.parent_element = "adf_base_clip"
Add(adf_freq_digits)
