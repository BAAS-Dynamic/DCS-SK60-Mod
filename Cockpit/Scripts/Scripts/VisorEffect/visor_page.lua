dofile(LockOn_Options.common_script_path .. "elements_defs.lua")

local texture_path = LockOn_Options.script_path .. "../Textures/Visor/SK60_VisorMask.dds"
local visor_material = MakeMaterial(texture_path, {255, 255, 255, 255})

-- Overscan the helmet projection so the texture covers both VR eyes and
-- remains outside the visible edge while the player turns their head.
local half_width = LockOn_Options.screen.width * 2.0
local half_height = GetAspect() * 2.0

local visor_mask = CreateElement "ceTexPoly"
visor_mask.name = "SK60_tinted_visor_mask"
visor_mask.vertices = {
	{-half_width, half_height},
	{half_width, half_height},
	{half_width, -half_height},
	{-half_width, -half_height},
}
visor_mask.indices = {0, 1, 2, 0, 2, 3}
visor_mask.tex_coords = {
	{0, 0},
	{1, 0},
	{1, 1},
	{0, 1},
}
visor_mask.material = visor_material
-- Start above the helmet projection and follow the physical tinted visor down.
-- Texture alpha controls the strength and shape of the tint.
local visor_travel = 3.0
visor_mask.init_pos = {0, visor_travel, 0}
visor_mask.element_params = {"COCKPIT_PILOT_TINTED_VISOR"}
visor_mask.controllers = {{"move_up_down_using_parameter", 0, -visor_travel}}
visor_mask.use_mipfilter = true
visor_mask.collimated = true
visor_mask.h_clip_relation = h_clip_relations.REWRITE_LEVEL
visor_mask.change_opacity = false
visor_mask.isvisible = true
Add(visor_mask)
