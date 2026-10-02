dofile(LockOn_Options.script_path.."ERPM/ERPM_def.lua")

SHOW_MASKS = false

local aspect = GetAspect()

local itt_r_base_clip = CreateElement "ceMeshPoly"
itt_r_base_clip.name = "itt_r_base_clip"
itt_r_base_clip.primitivetype = "triangles"
itt_r_base_clip.vertices = {{1.2, aspect}, {1.2, -aspect}, {-0.2, -aspect}, {-0.2, aspect}}
itt_r_base_clip.indices = {0, 1, 2, 0, 2, 3}
itt_r_base_clip.init_pos = {0, 0, 0}
itt_r_base_clip.init_rot = {0, 0, 0}
itt_r_base_clip.material = "DBG_GREY"
itt_r_base_clip.h_clip_relation = h_clip_relations.REWRITE_LEVEL
itt_r_base_clip.level = EADI_DEFAULT_NOCLIP_LEVEL
itt_r_base_clip.isdraw = true
itt_r_base_clip.change_opacity = false
itt_r_base_clip.element_params = {"ITT_ENABLE"}
itt_r_base_clip.controllers = {{"opacity_using_parameter", 0},}
itt_r_base_clip.isvisible = SHOW_MASKS
Add(itt_r_base_clip)

local right_text = CreateElement "ceStringPoly"
right_text.material = "LCD_font_white"
right_text.init_pos = {1, 0}
right_text.alignment = "RightCenter"
right_text.stringdefs = {0.8 * 0.0095, 0.8 * 0.0095, 0, 0}
right_text.formats = {"%.0f", "%s"}
right_text.element_params = {"R_ITT_DIGITAL", "ITT_COLOR", "ITT_ENABLE"}
right_text.controllers = {{"text_using_parameter", 0}, {"change_color_when_parameter_equal_to_number", 1, 1, 230 / 255, 120 / 255, 30 / 255}, {"opacity_using_parameter", 2},}
right_text.collimated = true
right_text.use_mipfilter = true
right_text.additive_alpha = true
right_text.isvisible = true
right_text.h_clip_relation = h_clip_relations.COMPARE
right_text.level = EADI_DEFAULT_NOCLIP_LEVEL
right_text.parent_element = "itt_r_base_clip"
Add(right_text)
