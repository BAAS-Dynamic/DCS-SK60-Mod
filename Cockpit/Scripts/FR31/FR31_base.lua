dofile(LockOn_Options.script_path.."FR31/FR31_def.lua")
SHOW_MASKS = false
local aspect = GetAspect()
local clip = CreateElement "ceMeshPoly"
clip.name = "fr31_base_clip"
clip.primitivetype = "triangles"
clip.vertices = {{1.0, aspect}, {1.0, -aspect}, {-1.0, -aspect}, {-1.0, aspect}}
clip.indices = {0,1,2,0,2,3}
clip.material = "DBG_GREY"
clip.h_clip_relation = h_clip_relations.REWRITE_LEVEL
clip.level = RNAV_DEFAULT_NOCLIP_LEVEL
clip.isdraw = true
clip.element_params = {"FR31_DSP_ENABLE"}
clip.controllers = {{"opacity_using_parameter",0}}
clip.isvisible = SHOW_MASKS
Add(clip)

local digit_positions = {-0.78, -0.39, 0.0, 0.39, 0.78}
local FR31_FONT_SIZE = 1.55 * 0.0095

local function add_digit(index, x_pos)
    local digit = CreateElement "ceStringPoly"
    digit.name = "fr31_digit_" .. index
    digit.material = "FR31_radio_font"
    digit.init_pos = {x_pos, 0.0}
    digit.alignment = "CenterCenter"
    digit.stringdefs = {FR31_FONT_SIZE, FR31_FONT_SIZE, 0, 0}
    digit.formats = {"%.0f"}
    digit.element_params = {"FR31_DIGIT_" .. index, "FR31_DIGIT_" .. index .. "_ENABLE", "FR31_DSP_ENABLE"}
    digit.controllers = {
        {"text_using_parameter", 0},
        {"parameter_in_range", 1, 0.5, 1.5},
        {"opacity_using_parameter", 2},
    }
    digit.collimated = true
    digit.use_mipfilter = true
    digit.additive_alpha = true
    digit.h_clip_relation = h_clip_relations.COMPARE
    digit.level = RNAV_DEFAULT_NOCLIP_LEVEL
    digit.parent_element = "fr31_base_clip"
    Add(digit)
end

for index,x_pos in ipairs(digit_positions) do
    add_digit(index, x_pos)
end

local function add_bas_character(name, character, x_pos, enable_parameter)
    local text = CreateElement "ceStringPoly"
    text.name = name
    text.material = "FR31_radio_font"
    text.init_pos = {x_pos, 0.0}
    text.alignment = "CenterCenter"
    text.stringdefs = {FR31_FONT_SIZE, FR31_FONT_SIZE, 0, 0}
    text.value = character
    text.element_params = {enable_parameter, "FR31_DSP_ENABLE"}
    text.controllers = {
        {"parameter_in_range", 0, 0.5, 1.5},
        {"opacity_using_parameter", 1},
    }
    text.collimated = true
    text.use_mipfilter = true
    text.additive_alpha = true
    text.h_clip_relation = h_clip_relations.COMPARE
    text.level = RNAV_DEFAULT_NOCLIP_LEVEL
    text.parent_element = "fr31_base_clip"
    Add(text)
end

-- BAS suffixes occupy the fourth character, with C2 using the fifth as well.
-- Separate static glyphs avoid encoding letters into the numeric digit params.
add_bas_character("fr31_bas_suffix_a", "A", digit_positions[4], "FR31_BAS_SUFFIX_A_ENABLE")
add_bas_character("fr31_bas_suffix_b", "B", digit_positions[4], "FR31_BAS_SUFFIX_B_ENABLE")
add_bas_character("fr31_bas_suffix_c", "C", digit_positions[4], "FR31_BAS_SUFFIX_C_ENABLE")
add_bas_character("fr31_bas_suffix_d", "D", digit_positions[4], "FR31_BAS_SUFFIX_D_ENABLE")
add_bas_character("fr31_bas_suffix_2", "2", digit_positions[5], "FR31_BAS_SUFFIX_2_ENABLE")
