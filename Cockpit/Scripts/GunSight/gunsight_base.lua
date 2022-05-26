dofile(LockOn_Options.script_path.."GunSight/gunsight_def.lua")

SHOW_MASKS = false

-- 这个操作可以将新建的裁剪块对齐到三个标记
local half_width   = GetScale()
local half_height  = GetAspect() * half_width

local aspect       = GetAspect()

-- 这个是最上面的总仪表裁剪层
HUD_base_clip 			 	    = CreateElement "ceMeshPoly" --这是裁剪层
HUD_base_clip.name 			    = "hud_base_data_clip"
HUD_base_clip.primitivetype   	= "triangles"
HUD_base_clip.vertices 		    = { {1, 0.5 * aspect}, { 1,-aspect}, { -1,-aspect}, {-1,aspect*0.5}, {-0.76,aspect}, {0.76,aspect}}
HUD_base_clip.indices 		    = {0,1,2,0,2,3,0,3,4,0,4,5}
HUD_base_clip.init_pos		    = {0, 0, 0}
HUD_base_clip.init_rot		    = {0, 0, 0}
HUD_base_clip.material		    = "DBG_GREY"
HUD_base_clip.h_clip_relation   = h_clip_relations.REWRITE_LEVEL --INCREASE_IF_LEVEL--COMPARE --REWRITE_LEVEL
HUD_base_clip.level			    = GUNSIGHT_DEFAULT_NOCLIP_LEVEL
HUD_base_clip.isdraw		    = true
HUD_base_clip.change_opacity    = false
HUD_base_clip.element_params    = {"GUNSIGHT_ENABLE"}              -- 初始化主显示控制
HUD_base_clip.controllers       = {{"opacity_using_parameter",0}}
HUD_base_clip.isvisible		    = SHOW_MASKS
Add(HUD_base_clip)

-- virtual projection plane of the hud display
local gunsight_proj_clip 			    = CreateElement "ceMeshPoly" --create second clip
gunsight_proj_clip.name 			    = "gunsight_projection_clip"
gunsight_proj_clip.vertices 		    = create_circle_pos(120, 0, 0, 3000 * default_hud_size_scaler)
gunsight_proj_clip.indices 		        = create_circle_index(120)
gunsight_proj_clip.init_pos		        = {0, default_hud_y_offset, default_hud_z_offset}
gunsight_proj_clip.init_rot		        = {0, 0, default_hud_rot_offset}
gunsight_proj_clip.material		        = "DBG_GREEN"
gunsight_proj_clip.h_clip_relation      = h_clip_relations.INCREASE_IF_LEVEL--COMPARE --REWRITE_LEVEL
gunsight_proj_clip.level			    = GUNSIGHT_DEFAULT_LEVEL - 1
gunsight_proj_clip.change_opacity       = false
gunsight_proj_clip.element_params       = {"GUNSIGHT_ENABLE",}              -- Initialize the main display control
gunsight_proj_clip.controllers          = {{"opacity_using_parameter",0}}
gunsight_proj_clip.isvisible		    = SHOW_MASKS
Add(gunsight_proj_clip)

-- gunsight
local flight_dire_ind 				     = CreateElement "ceTexPoly"
flight_dire_ind.vertices                 = hud_vert_gen(539.5*default_hud_size_scaler,364*default_hud_size_scaler) -- hud_vert_gen(539.5,364)
flight_dire_ind.indices                  = {0,1,2,2,3,0}
flight_dire_ind.tex_coords               = tex_coord_gen(385,680,415,280,2000,2000)
flight_dire_ind.material                 = basic_HUD_material
flight_dire_ind.name 			         = create_guid_string()
flight_dire_ind.init_pos                 = {0, 0, 0}
flight_dire_ind.init_rot		         = {0, 0, 0}
flight_dire_ind.collimated	             = true
flight_dire_ind.element_params           = {"GUNSIGHT_ENABLE","GUNSIGHT_X","GUNSIGHT_Y"}
flight_dire_ind.controllers              = {{"opacity_using_parameter",0},{"move_left_right_using_parameter",1,0.1},{"move_up_down_using_parameter",2,0.1},}
flight_dire_ind.use_mipfilter            = true
flight_dire_ind.additive_alpha           = true
flight_dire_ind.h_clip_relation          = h_clip_relations.COMPARE
flight_dire_ind.level                    = GUNSIGHT_DEFAULT_LEVEL
flight_dire_ind.parent_element	         = "gunsight_projection_clip"
Add(flight_dire_ind)