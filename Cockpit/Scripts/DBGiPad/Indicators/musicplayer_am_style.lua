dofile(LockOn_Options.script_path.."DBGiPad/ipad_def.lua")

SHOW_MASKS = true-- enable debug

-- This operation can align the newly created cropping block to the three connectors
-- Must use FOV mode
local half_width   = GetScale()
local half_height  = GetAspect() * half_width

local aspect       = GetAspect()

-- define the materials used by apple music style version
basic_am_symbol_material = MakeMaterial(IPAD_IND_TEX_PATH.."MP3_AM_SYM_IND.dds", EADI_DAY_COLOR)
basic_am_bg_material = MakeMaterial(IPAD_IND_TEX_PATH.."MP3_AM_BG_IND.dds", EADI_DAY_COLOR)

-- pos_x define which symbol on 8*8 symbol 
function symb_coord_gen(pos_x,pos_line,width,height)
    return tex_coord_gen((pos_x-1)*128,(pos_line-1)*128, width*128, height*128, 1024, 1024)
end

function symb_coord_scale_gen(pos_x,pos_line,width,height,scale_end,scale_start,frame)
    tex_state = {}
    scale_step = (scale_start - scale_end)/frame
    current_scale = scale_end
    for i = 1,frame,1 do
        tex_state[#tex_state+1] = tex_center_coord_gen((pos_x-1)*128+width*64,(pos_line-1)*128+height*64,width*128*current_scale,height*128*current_scale,1024,1024)
        current_scale = current_scale - scale_step
    end
    return tex_state
end

-- ipad default size: 2388 * 1667/ 1194 * 833

-- background, keep lowest
-- Cover photo size: 328*2(small) 425*2(large) ^2; 268 vertical up
local mp3_bg_pic 				    = CreateElement "ceTexPoly"
mp3_bg_pic.vertices                 = {{1, aspect}, { 1,-aspect}, { -1,-aspect}, {-1,aspect},} --四个边角
mp3_bg_pic.indices                  = {0,1,2,2,3,0}
mp3_bg_pic.tex_coords               = symb_coord_gen(2,2,6,6)
mp3_bg_pic.material                 = basic_am_bg_material
mp3_bg_pic.name 			        = create_guid_string()
mp3_bg_pic.init_pos                 = {0, 0}
mp3_bg_pic.init_rot		            = {0, 0, 0}
mp3_bg_pic.collimated	            = true
mp3_bg_pic.element_params           = {"MP3_SCR_ENABLE", "MP3_COVER_SWITCH"} --, "D_GUNSIGHT_VISIBLE"
mp3_bg_pic.controllers              = {{"opacity_using_parameter",0}, {"change_texture_state_using_parameter",1}}
mp3_bg_pic.use_mipfilter            = true
mp3_bg_pic.additive_alpha           = true
mp3_bg_pic.h_clip_relation          = h_clip_relations.COMPARE
mp3_bg_pic.level                    = IPAD_DEFAULT_NOCLIP_LEVEL
mp3_bg_pic.parent_element	        = "base_clip"
Add(mp3_bg_pic)

-- setup a ceSimple for easy locate the position -660 to left when trigger the lyric or play list
local minimal_mp3_pos_ctrl                  = CreateElement "ceSimple"
minimal_mp3_pos_ctrl.name                   = "minimal_mp3_pos_ctrl"
minimal_mp3_pos_ctrl.init_pos               = {0, 0}            --为屏幕的正中位置
minimal_mp3_pos_ctrl.element_params         = {"MP3_MIN_SEC_MOV_X"}
minimal_mp3_pos_ctrl.controllers            = {{"move_left_right_using_parameter",0,0.552764},}
minimal_mp3_pos_ctrl.collimated	            = true
minimal_mp3_pos_ctrl.use_mipfilter          = true
minimal_mp3_pos_ctrl.additive_alpha         = true
minimal_mp3_pos_ctrl.h_clip_relation        = h_clip_relations.COMPARE
minimal_mp3_pos_ctrl.level                  = IPAD_DEFAULT_NOCLIP_LEVEL
minimal_mp3_pos_ctrl.parent_element	        = "base_clip"       --父对象为主屏幕裁剪层
minimal_mp3_pos_ctrl.isvisible              = false
Add(minimal_mp3_pos_ctrl)

-- Cover photo size: 328*2(small) 425*2(large) ^2; 268 vertical up
local mp3_play_cover_pic 				    = CreateElement "ceTexPoly"
mp3_play_cover_pic.vertices                 = mesh_vert_gen(950, 950)
mp3_play_cover_pic.indices                  = {0,1,2,2,3,0}
mp3_play_cover_pic.state_tex_coords         = symb_coord_scale_gen(1,6,2,2,0.95,1.2,60)
mp3_play_cover_pic.material                 = basic_am_symbol_material
mp3_play_cover_pic.name 			        = create_guid_string()
mp3_play_cover_pic.init_pos                 = {0, 0.3217*aspect}
mp3_play_cover_pic.init_rot		            = {0, 0, 0}
mp3_play_cover_pic.collimated	            = true
mp3_play_cover_pic.element_params           = {"MP3_SCR_ENABLE", "MP3_COVER_SWITCH"} --, "D_GUNSIGHT_VISIBLE"
mp3_play_cover_pic.controllers              = {{"opacity_using_parameter",0}, {"change_texture_state_using_parameter",1}}
mp3_play_cover_pic.use_mipfilter            = true
mp3_play_cover_pic.additive_alpha           = true
mp3_play_cover_pic.h_clip_relation          = h_clip_relations.COMPARE
mp3_play_cover_pic.level                    = IPAD_DEFAULT_NOCLIP_LEVEL
mp3_play_cover_pic.parent_element	        = "minimal_mp3_pos_ctrl"
Add(mp3_play_cover_pic)

-- current music name
local current_play_music_name                 = CreateElement "ceStringPoly" 
current_play_music_name.name                  = create_guid_string()
current_play_music_name.material              = "unicode_cn_white" --FONT_
current_play_music_name.init_pos              = {-0.36265, -0.288*aspect} 
current_play_music_name.alignment             = "LeftTop"       --对齐方式设置：Left/Right/Center; Top/Down/Center
current_play_music_name.stringdefs            = {0.003685, 0.003685}   
current_play_music_name.formats               = {"%s","%s"} 
current_play_music_name.element_params        = {"MP3_CURR_MUSIC_NAME", "MP3_SCR_ENABLE"} --This is music name so use name equal to the screen enable
current_play_music_name.controllers           = {{"text_using_parameter",0,0},{"opacity_using_parameter",1}}
current_play_music_name.collimated            = true
current_play_music_name.use_mipfilter         = true
current_play_music_name.additive_alpha        = true
current_play_music_name.isvisible		      = true
current_play_music_name.h_clip_relation 	  = h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
current_play_music_name.level			      = IPAD_DEFAULT_NOCLIP_LEVEL
current_play_music_name.parent_element        = "minimal_mp3_pos_ctrl"  --父节点名字 --可以绑定不在同一层的父节点
Add(current_play_music_name)

-- current artist name
local current_play_artist_name                 = CreateElement "ceStringPoly"
current_play_artist_name.name                  = create_guid_string()
current_play_artist_name.material              = "unicode_cn_white"
current_play_artist_name.init_pos              = {-0.36265, -0.348*aspect} 
current_play_artist_name.alignment             = "LeftTop"       --对齐方式设置：Left/Right/Center; Top/Down/Center
current_play_artist_name.stringdefs            = {0.003685, 0.003685}
current_play_artist_name.formats               = {"%s","%s"}
current_play_artist_name.element_params        = {"MP3_CURR_ARTIST_NAME", "MP3_HALF_OPC_ENABLE"} --This is music name so use name equal to the screen enable
current_play_artist_name.controllers           = {{"text_using_parameter",0,0},{"opacity_using_parameter",1}}
current_play_artist_name.collimated            = true
current_play_artist_name.use_mipfilter         = true
current_play_artist_name.additive_alpha        = true
current_play_artist_name.isvisible		       = true
current_play_artist_name.h_clip_relation 	   = h_clip_relations.COMPARE 
current_play_artist_name.level			       = IPAD_DEFAULT_NOCLIP_LEVEL
current_play_artist_name.parent_element        = "minimal_mp3_pos_ctrl"  --父节点名字
Add(current_play_artist_name)

-- the playing progress bar 880 width, -360 from center 0.8958333
local mp3_play_bar_base 				   = CreateElement "ceTexPoly"
mp3_play_bar_base.vertices                 = mesh_vert_gen(982.36, 327.41)
mp3_play_bar_base.indices                  = {0,1,2,2,3,0}
mp3_play_bar_base.tex_coords               = symb_coord_gen(2,5,3,1)
mp3_play_bar_base.material                 = basic_am_symbol_material
mp3_play_bar_base.name 			           = create_guid_string()
mp3_play_bar_base.init_pos                 = {0, -0.4322*aspect}
mp3_play_bar_base.init_rot		           = {0, 0, 0}
mp3_play_bar_base.collimated	           = true
mp3_play_bar_base.element_params           = {"MP3_LOW_OPC_ENABLE"} --, "D_GUNSIGHT_VISIBLE"
mp3_play_bar_base.controllers              = {{"opacity_using_parameter",0},}
mp3_play_bar_base.use_mipfilter            = true
mp3_play_bar_base.additive_alpha           = true
mp3_play_bar_base.h_clip_relation          = h_clip_relations.COMPARE
mp3_play_bar_base.level                    = IPAD_DEFAULT_NOCLIP_LEVEL
mp3_play_bar_base.parent_element	       = "minimal_mp3_pos_ctrl"
Add(mp3_play_bar_base)

-- the playing progress dot (start at 0 point)
local mp3_play_prog_icon 				    = CreateElement "ceTexPoly"
mp3_play_prog_icon.vertices                 = mesh_vert_gen(70, 70)
mp3_play_prog_icon.indices                  = {0,1,2,2,3,0}
mp3_play_prog_icon.tex_coords               = symb_coord_gen(1,5,1,1)
mp3_play_prog_icon.material                 = basic_am_symbol_material
mp3_play_prog_icon.name 			        = create_guid_string()
mp3_play_prog_icon.init_pos                 = {-0.36851, -0.4322*aspect}
mp3_play_prog_icon.init_rot		            = {0, 0, 0}
mp3_play_prog_icon.collimated	            = true
mp3_play_prog_icon.element_params           = {"MP3_HALF_OPC_ENABLE", "MP3_PLAY_PROG_STATUS"} --, "D_GUNSIGHT_VISIBLE"
mp3_play_prog_icon.controllers              = {{"opacity_using_parameter",0}, {"move_left_right_using_parameter",1,0.737}}
mp3_play_prog_icon.use_mipfilter            = true
mp3_play_prog_icon.additive_alpha           = true
mp3_play_prog_icon.h_clip_relation          = h_clip_relations.COMPARE
mp3_play_prog_icon.level                    = IPAD_DEFAULT_NOCLIP_LEVEL
mp3_play_prog_icon.parent_element	        = "minimal_mp3_pos_ctrl"
Add(mp3_play_prog_icon)

-- current time -390
local current_time_stamp                    = CreateElement "ceStringPoly"
current_time_stamp.name                     = create_guid_string()
current_time_stamp.material                 = "unicode_cn_white"
current_time_stamp.init_pos                 = {-0.36265, -0.46819*aspect} 
current_time_stamp.alignment                = "LeftTop"       --对齐方式设置：Left/Right/Center; Top/Down/Center
current_time_stamp.stringdefs               = {0.002094, 0.002094}
current_time_stamp.formats                  = {"%s","%s"}
current_time_stamp.element_params           = {"MP3_CURR_PLAY_TIME", "MP3_LOW_OPC_ENABLE"} --This is music name so use name equal to the screen enable
current_time_stamp.controllers              = {{"text_using_parameter",0,0},{"opacity_using_parameter",1}}
current_time_stamp.collimated               = true
current_time_stamp.use_mipfilter            = true
current_time_stamp.additive_alpha           = true
current_time_stamp.isvisible		        = true
current_time_stamp.h_clip_relation 	        = h_clip_relations.COMPARE 
current_time_stamp.level			        = IPAD_DEFAULT_NOCLIP_LEVEL
current_time_stamp.parent_element           = "minimal_mp3_pos_ctrl"  --父节点名字
Add(current_time_stamp)

-- reset play time -390
local rest_time_stamp                       = CreateElement "ceStringPoly"
rest_time_stamp.name                        = create_guid_string()
rest_time_stamp.material                    = "unicode_cn_white"
rest_time_stamp.init_pos                    = {0.36265, -0.46819*aspect} 
rest_time_stamp.alignment                   = "RightTop"       --对齐方式设置：Left/Right/Center; Top/Down/Center
rest_time_stamp.stringdefs                  = {0.002094, 0.002094}
rest_time_stamp.formats                     = {"-%s","%s"}
rest_time_stamp.element_params              = {"MP3_REST_PLAY_TIME", "MP3_LOW_OPC_ENABLE"} --This is music name so use name equal to the screen enable
rest_time_stamp.controllers                 = {{"text_using_parameter",0,0},{"opacity_using_parameter",1}}
rest_time_stamp.collimated                  = true
rest_time_stamp.use_mipfilter               = true
rest_time_stamp.additive_alpha              = true
rest_time_stamp.isvisible		            = true
rest_time_stamp.h_clip_relation 	        = h_clip_relations.COMPARE 
rest_time_stamp.level			            = IPAD_DEFAULT_NOCLIP_LEVEL
rest_time_stamp.parent_element              = "minimal_mp3_pos_ctrl"  --父节点名字
Add(rest_time_stamp)

-- play and pause button
local mp3_play_pause_button 				   = CreateElement "ceTexPoly"
mp3_play_pause_button.vertices                 = mesh_vert_gen(120, 120)
mp3_play_pause_button.indices                  = {0,1,2,2,3,0}
mp3_play_pause_button.state_tex_coords         = {symb_coord_gen(2,1,1,1),symb_coord_gen(1,1,1,1)}
mp3_play_pause_button.material                 = basic_am_symbol_material
mp3_play_pause_button.name 			           = create_guid_string()
mp3_play_pause_button.init_pos                 = {0, -0.60624*aspect}
mp3_play_pause_button.init_rot		           = {0, 0, 0}
mp3_play_pause_button.collimated	           = true
mp3_play_pause_button.element_params           = {"MP3_SCR_ENABLE", "MP3_PLAY_PAUSE_SWITCH"} --, "D_GUNSIGHT_VISIBLE"
mp3_play_pause_button.controllers              = {{"opacity_using_parameter",0}, {"change_texture_state_using_parameter",1}}
mp3_play_pause_button.use_mipfilter            = true
mp3_play_pause_button.additive_alpha           = true
mp3_play_pause_button.h_clip_relation          = h_clip_relations.COMPARE
mp3_play_pause_button.level                    = IPAD_DEFAULT_NOCLIP_LEVEL
mp3_play_pause_button.parent_element	       = "minimal_mp3_pos_ctrl"
Add(mp3_play_pause_button)

-- play next button
local mp3_play_next_button 				      = CreateElement "ceTexPoly"
mp3_play_next_button.vertices                 = mesh_vert_gen(120, 120)
mp3_play_next_button.indices                  = {0,1,2,2,3,0}
mp3_play_next_button.tex_coords               = symb_coord_gen(4,1,1,1)
mp3_play_next_button.material                 = basic_am_symbol_material
mp3_play_next_button.name 			          = create_guid_string()
mp3_play_next_button.init_pos                 = {0.16332, -0.60624*aspect}
mp3_play_next_button.init_rot		          = {0, 0, 0}
mp3_play_next_button.collimated	              = true
mp3_play_next_button.element_params           = {"MP3_SCR_ENABLE"} --, "D_GUNSIGHT_VISIBLE"
mp3_play_next_button.controllers              = {{"opacity_using_parameter",0}}
mp3_play_next_button.use_mipfilter            = true
mp3_play_next_button.additive_alpha           = true
mp3_play_next_button.h_clip_relation          = h_clip_relations.COMPARE
mp3_play_next_button.level                    = IPAD_DEFAULT_NOCLIP_LEVEL
mp3_play_next_button.parent_element	          = "minimal_mp3_pos_ctrl"
Add(mp3_play_next_button)

-- play last button
local mp3_play_last_button 				      = CreateElement "ceTexPoly"
mp3_play_last_button.vertices                 = mesh_vert_gen(120, 120)
mp3_play_last_button.indices                  = {0,1,2,2,3,0}
mp3_play_last_button.tex_coords               = symb_coord_gen(3,1,1,1)
mp3_play_last_button.material                 = basic_am_symbol_material
mp3_play_last_button.name 			          = create_guid_string()
mp3_play_last_button.init_pos                 = {-0.16332, -0.60624*aspect}
mp3_play_last_button.init_rot		          = {0, 0, 0}
mp3_play_last_button.collimated	              = true
mp3_play_last_button.element_params           = {"MP3_SCR_ENABLE"} --, "D_GUNSIGHT_VISIBLE"
mp3_play_last_button.controllers              = {{"opacity_using_parameter",0}}
mp3_play_last_button.use_mipfilter            = true
mp3_play_last_button.additive_alpha           = true
mp3_play_last_button.h_clip_relation          = h_clip_relations.COMPARE
mp3_play_last_button.level                    = IPAD_DEFAULT_NOCLIP_LEVEL
mp3_play_last_button.parent_element	          = "minimal_mp3_pos_ctrl"
Add(mp3_play_last_button)

-- loop button
local mp3_loop_button 				        = CreateElement "ceTexPoly"
mp3_loop_button.vertices                    = mesh_vert_gen(120, 120)
mp3_loop_button.indices                     = {0,1,2,2,3,0}
mp3_loop_button.state_tex_coords            = {symb_coord_gen(1,2,1,1),symb_coord_gen(2,2,1,1)}
mp3_loop_button.material                    = basic_am_symbol_material
mp3_loop_button.name 			            = create_guid_string()
mp3_loop_button.init_pos                    = {0.3434, -0.60624*aspect}
mp3_loop_button.init_rot		            = {0, 0, 0}
mp3_loop_button.collimated	                = true
mp3_loop_button.element_params              = {"MP3_HALF_OPC_ENABLE", "MP3_LOOP_SWITCH"} --, "D_GUNSIGHT_VISIBLE"
mp3_loop_button.controllers                 = {{"opacity_using_parameter",0}, {"change_texture_state_using_parameter",1}}
mp3_loop_button.use_mipfilter               = true
mp3_loop_button.additive_alpha              = true
mp3_loop_button.h_clip_relation             = h_clip_relations.COMPARE
mp3_loop_button.level                       = IPAD_DEFAULT_NOCLIP_LEVEL
mp3_loop_button.parent_element	            = "minimal_mp3_pos_ctrl"
Add(mp3_loop_button)

-- shuffle button
local mp3_loop_button 				        = CreateElement "ceTexPoly"
mp3_loop_button.vertices                    = mesh_vert_gen(120, 120)
mp3_loop_button.indices                     = {0,1,2,2,3,0}
mp3_loop_button.state_tex_coords            = {symb_coord_gen(3,2,1,1),symb_coord_gen(4,2,1,1)}
mp3_loop_button.material                    = basic_am_symbol_material
mp3_loop_button.name 			            = create_guid_string()
mp3_loop_button.init_pos                    = {-0.3434, -0.60624*aspect}
mp3_loop_button.init_rot		            = {0, 0, 0}
mp3_loop_button.collimated	                = true
mp3_loop_button.element_params              = {"MP3_HALF_OPC_ENABLE", "MP3_SHUFFLE_SWITCH"} --, "D_GUNSIGHT_VISIBLE"
mp3_loop_button.controllers                 = {{"opacity_using_parameter",0}, {"change_texture_state_using_parameter",1}}
mp3_loop_button.use_mipfilter               = true
mp3_loop_button.additive_alpha              = true
mp3_loop_button.h_clip_relation             = h_clip_relations.COMPARE
mp3_loop_button.level                       = IPAD_DEFAULT_NOCLIP_LEVEL
mp3_loop_button.parent_element	            = "minimal_mp3_pos_ctrl"
Add(mp3_loop_button)

-- the following is the volume bar , 
-- the playing progress bar 750 width, -644 from center 0.8958333
local mp3_volume_bar_base 				    = CreateElement "ceTexPoly"
mp3_volume_bar_base.vertices                = mesh_vert_gen(837.21, 327.41)
mp3_volume_bar_base.indices                 = {0,1,2,2,3,0}
mp3_volume_bar_base.tex_coords              = symb_coord_gen(2,5,3,1)
mp3_volume_bar_base.material                = basic_am_symbol_material
mp3_volume_bar_base.name 			        = create_guid_string()
mp3_volume_bar_base.init_pos                = {0, -0.7731*aspect}
mp3_volume_bar_base.init_rot		        = {0, 0, 0}
mp3_volume_bar_base.collimated	            = true
mp3_volume_bar_base.element_params          = {"MP3_LOW_OPC_ENABLE"} --, "D_GUNSIGHT_VISIBLE"
mp3_volume_bar_base.controllers             = {{"opacity_using_parameter",0},}
mp3_volume_bar_base.use_mipfilter           = true
mp3_volume_bar_base.additive_alpha          = true
mp3_volume_bar_base.h_clip_relation         = h_clip_relations.COMPARE
mp3_volume_bar_base.level                   = IPAD_DEFAULT_NOCLIP_LEVEL
mp3_volume_bar_base.parent_element	        = "minimal_mp3_pos_ctrl"
Add(mp3_volume_bar_base)

-- low volume icon -420
local mp3_volume_low_icon 				    = CreateElement "ceTexPoly"
mp3_volume_low_icon.vertices                = mesh_vert_gen(70, 70)
mp3_volume_low_icon.indices                 = {0,1,2,2,3,0}
mp3_volume_low_icon.tex_coords              = symb_coord_gen(1,4,1,1)
mp3_volume_low_icon.material                = basic_am_symbol_material
mp3_volume_low_icon.name 			        = create_guid_string()
mp3_volume_low_icon.init_pos                = {-0.35176, -0.7731*aspect}
mp3_volume_low_icon.init_rot		        = {0, 0, 0}
mp3_volume_low_icon.collimated	            = true
mp3_volume_low_icon.element_params          = {"MP3_HALF_OPC_ENABLE"} --, "D_GUNSIGHT_VISIBLE"
mp3_volume_low_icon.controllers             = {{"opacity_using_parameter",0},}
mp3_volume_low_icon.use_mipfilter           = true
mp3_volume_low_icon.additive_alpha          = true
mp3_volume_low_icon.h_clip_relation         = h_clip_relations.COMPARE
mp3_volume_low_icon.level                   = IPAD_DEFAULT_NOCLIP_LEVEL
mp3_volume_low_icon.parent_element	        = "minimal_mp3_pos_ctrl"
Add(mp3_volume_low_icon)

-- max volume icon -- 420
local mp3_volume_max_icon 				    = CreateElement "ceTexPoly"
mp3_volume_max_icon.vertices                = mesh_vert_gen(70, 70)
mp3_volume_max_icon.indices                 = {0,1,2,2,3,0}
mp3_volume_max_icon.tex_coords              = symb_coord_gen(2,4,1,1)
mp3_volume_max_icon.material                = basic_am_symbol_material
mp3_volume_max_icon.name 			        = create_guid_string()
mp3_volume_max_icon.init_pos                = {0.35176, -0.7731*aspect}
mp3_volume_max_icon.init_rot		        = {0, 0, 0}
mp3_volume_max_icon.collimated	            = true
mp3_volume_max_icon.element_params          = {"MP3_HALF_OPC_ENABLE"} --, "D_GUNSIGHT_VISIBLE"
mp3_volume_max_icon.controllers             = {{"opacity_using_parameter",0},}
mp3_volume_max_icon.use_mipfilter           = true
mp3_volume_max_icon.additive_alpha          = true
mp3_volume_max_icon.h_clip_relation         = h_clip_relations.COMPARE
mp3_volume_max_icon.level                   = IPAD_DEFAULT_NOCLIP_LEVEL
mp3_volume_max_icon.parent_element	        = "minimal_mp3_pos_ctrl"
Add(mp3_volume_max_icon)

-- the playing progress dot (start at 0 point)
local mp3_play_prog_icon 				    = CreateElement "ceTexPoly"
mp3_play_prog_icon.vertices                 = mesh_vert_gen(140, 140)
mp3_play_prog_icon.indices                  = {0,1,2,2,3,0}
mp3_play_prog_icon.tex_coords               = symb_coord_gen(1,5,1,1)
mp3_play_prog_icon.material                 = basic_am_symbol_material
mp3_play_prog_icon.name 			        = create_guid_string()
mp3_play_prog_icon.init_pos                 = {-0.31407, -0.7731*aspect}
mp3_play_prog_icon.init_rot		            = {0, 0, 0}
mp3_play_prog_icon.collimated	            = true
mp3_play_prog_icon.element_params           = {"MP3_SCR_ENABLE", "MP3_VOL_STATUS"} --, "D_GUNSIGHT_VISIBLE"
mp3_play_prog_icon.controllers              = {{"opacity_using_parameter",0}, {"move_left_right_using_parameter",1,0.62814}}
mp3_play_prog_icon.use_mipfilter            = true
mp3_play_prog_icon.additive_alpha           = true
mp3_play_prog_icon.h_clip_relation          = h_clip_relations.COMPARE
mp3_play_prog_icon.level                    = IPAD_DEFAULT_NOCLIP_LEVEL
mp3_play_prog_icon.parent_element	        = "minimal_mp3_pos_ctrl"
Add(mp3_play_prog_icon)

-- bottom right lyric icon 925, -750
local mp3_lyric_button 				         = CreateElement "ceTexPoly"
mp3_lyric_button.vertices                    = mesh_vert_gen(120, 120)
mp3_lyric_button.indices                     = {0,1,2,2,3,0}
mp3_lyric_button.state_tex_coords            = {symb_coord_gen(3,3,1,1),symb_coord_gen(4,3,1,1)}
mp3_lyric_button.material                    = basic_am_symbol_material
mp3_lyric_button.name 			             = create_guid_string()
mp3_lyric_button.init_pos                    = {0.77471, -0.90036*aspect}
mp3_lyric_button.init_rot		             = {0, 0, 0}
mp3_lyric_button.collimated	                 = true
mp3_lyric_button.element_params              = {"MP3_HALF_OPC_ENABLE", "MP3_LYRIC_SWITCH"} --, "D_GUNSIGHT_VISIBLE"
mp3_lyric_button.controllers                 = {{"opacity_using_parameter",0}, {"change_texture_state_using_parameter",1}}
mp3_lyric_button.use_mipfilter               = true
mp3_lyric_button.additive_alpha              = true
mp3_lyric_button.h_clip_relation             = h_clip_relations.COMPARE
mp3_lyric_button.level                       = IPAD_DEFAULT_NOCLIP_LEVEL
mp3_lyric_button.parent_element	             = "base_clip"
Add(mp3_lyric_button)

-- playlist display icon 1065, -750
local mp3_playlist_button 				         = CreateElement "ceTexPoly"
mp3_playlist_button.vertices                     = mesh_vert_gen(120, 120)
mp3_playlist_button.indices                      = {0,1,2,2,3,0}
mp3_playlist_button.state_tex_coords             = {symb_coord_gen(3,4,1,1),symb_coord_gen(4,4,1,1)}
mp3_playlist_button.material                     = basic_am_symbol_material
mp3_playlist_button.name 			             = create_guid_string()
mp3_playlist_button.init_pos                     = {0.89196, -0.90036*aspect}
mp3_playlist_button.init_rot		             = {0, 0, 0}
mp3_playlist_button.collimated	                 = true
mp3_playlist_button.element_params               = {"MP3_HALF_OPC_ENABLE", "MP3_PLAYLIST_SWITCH"} --, "D_GUNSIGHT_VISIBLE"
mp3_playlist_button.controllers                  = {{"opacity_using_parameter",0}, {"change_texture_state_using_parameter",1}}
mp3_playlist_button.use_mipfilter                = true
mp3_playlist_button.additive_alpha               = true
mp3_playlist_button.h_clip_relation              = h_clip_relations.COMPARE
mp3_playlist_button.level                        = IPAD_DEFAULT_NOCLIP_LEVEL
mp3_playlist_button.parent_element	             = "base_clip"
Add(mp3_playlist_button)

-- airplay icon 1065, -750
local mp3_airplay_button 				        = CreateElement "ceTexPoly"
mp3_airplay_button.vertices                     = mesh_vert_gen(120, 120)
mp3_airplay_button.indices                      = {0,1,2,2,3,0}
mp3_airplay_button.state_tex_coords             = {symb_coord_gen(1,3,1,1),symb_coord_gen(2,3,1,1)}
mp3_airplay_button.material                     = basic_am_symbol_material
mp3_airplay_button.name 			            = create_guid_string()
mp3_airplay_button.init_pos                     = {-0.8794, -0.90036*aspect}
mp3_airplay_button.init_rot		                = {0, 0, 0}
mp3_airplay_button.collimated	                = true
mp3_airplay_button.element_params               = {"MP3_HALF_OPC_ENABLE", "MP3_AIRPLAY_SWITCH"} --, "D_GUNSIGHT_VISIBLE"
mp3_airplay_button.controllers                  = {{"opacity_using_parameter",0}, {"change_texture_state_using_parameter",1}}
mp3_airplay_button.use_mipfilter                = true
mp3_airplay_button.additive_alpha               = true
mp3_airplay_button.h_clip_relation              = h_clip_relations.COMPARE
mp3_airplay_button.level                        = IPAD_DEFAULT_NOCLIP_LEVEL
mp3_airplay_button.parent_element	            = "base_clip"
Add(mp3_airplay_button)

-- End of basic structure