dofile(LockOn_Options.script_path.."ERPM/ERPM_def.lua")

SHOW_MASKS = false

local aspect = GetAspect()

local n1rpm_r_base_clip = CreateElement "ceMeshPoly"
n1rpm_r_base_clip.name = "n1rpm_r_base_clip"
n1rpm_r_base_clip.primitivetype = "triangles"
n1rpm_r_base_clip.vertices = {{1.2, aspect}, {1.2, -aspect}, {-0.2, -aspect}, {-0.2, aspect}}
n1rpm_r_base_clip.indices = {0, 1, 2, 0, 2, 3}
n1rpm_r_base_clip.init_pos = {0, 0, 0}
n1rpm_r_base_clip.init_rot = {0, 0, 0}
n1rpm_r_base_clip.material = "DBG_GREY"
n1rpm_r_base_clip.h_clip_relation = h_clip_relations.REWRITE_LEVEL
n1rpm_r_base_clip.level = EADI_DEFAULT_NOCLIP_LEVEL
n1rpm_r_base_clip.isdraw = true
n1rpm_r_base_clip.change_opacity = false
n1rpm_r_base_clip.element_params = {"N1RPM_ENABLE"}
n1rpm_r_base_clip.controllers = {{"opacity_using_parameter", 0},}
n1rpm_r_base_clip.isvisible = SHOW_MASKS
Add(n1rpm_r_base_clip)

local right_text = CreateElement "ceStringPoly"
right_text.material = "LCD_font_white"
right_text.init_pos = {1, 0}
right_text.alignment = "RightCenter"
right_text.stringdefs = {0.8 * 0.0095, 0.8 * 0.0095, 0, 0}
right_text.formats = {"%.1f", "%s"}
right_text.element_params = {"RN1_RPM_DIGITAL", "N1RPM_COLOR", "N1RPM_ENABLE"}
right_text.controllers = {{"text_using_parameter", 0}, {"change_color_when_parameter_equal_to_number", 1, 1, 230 / 255, 120 / 255, 30 / 255}, {"opacity_using_parameter", 2},}
right_text.collimated = true
right_text.use_mipfilter = true
right_text.additive_alpha = true
right_text.isvisible = true
right_text.h_clip_relation = h_clip_relations.COMPARE
right_text.level = EADI_DEFAULT_NOCLIP_LEVEL
right_text.parent_element = "n1rpm_r_base_clip"
Add(right_text)
