dofile(LockOn_Options.script_path.."DBGiPad/ipad_def.lua")

local MFD_IND_TEX_PATH        	= LockOn_Options.script_path .. "../Textures/IPAD/"  --定义屏幕贴图路径
local mp3_symbol_material     	= MakeMaterial(MFD_IND_TEX_PATH.."mp3_symbols.dds", {152,195,100,255})
local mp3_symbol_white_material = MakeMaterial(MFD_IND_TEX_PATH.."mp3_symbols.dds", {255,255,255,255})
local green_material			= MakeMaterial(MFD_IND_TEX_PATH.."mp3_symbols.dds", {255,255,255,255})
local darkGray_material			= MakeMaterial(nil,{30,30,30,255})
SHOW_MASKS = true
--
local mp3_screen_x_offset = 0 --设置这个来确定中心偏移
local mp3_screen_z_offset = 1  --用来设置屏幕效果，显示层与上层流出空间
local mp3_screen_y_offset = 0

local width=1
local height=GetAspect()

function tex_coord_gen(x_dis,y_dis,width,height,size_X,size_Y)
    -- 参数说明，裁减点X,y 要裁减的宽高，原图尺寸
    return {{x_dis / size_X , y_dis / size_Y},
			{(x_dis + width) / size_X , y_dis / size_Y},
			{(x_dis + width) / size_X , (y_dis + height) / size_Y},
			{x_dis / size_X , (y_dis + height) / size_Y},}
end

-- 创建一个基础的虚拟对象来控制基础飞行界面的所有显示内容移动（为后续触屏控制准备）
-- 做个simple作为相对定位的基础
-- MP3_SCR_ENABLE 为这个界面的统一是否显示控制表
mp3_screen_ctrl                      = CreateElement "ceSimple"
mp3_screen_ctrl.name                 = "mp3_screen_ctrl"
mp3_screen_ctrl.init_pos             = {mp3_screen_x_offset, mp3_screen_y_offset} --为第一个显示区(四分)正中位置
mp3_screen_ctrl.element_params       = {"MP3_SCR_ENABLE"}
mp3_screen_ctrl.controllers          = {{"opacity_using_parameter",0}}
mp3_screen_ctrl.collimated	        = true
mp3_screen_ctrl.use_mipfilter        = true
mp3_screen_ctrl.additive_alpha       = true
mp3_screen_ctrl.h_clip_relation      = h_clip_relations.COMPARE
mp3_screen_ctrl.level                = IPAD_DEFAULT_NOCLIP_LEVEL
-- mp3_screen_ctrl.parent_element	    = "base_clip" --父对象为主屏幕裁剪层
mp3_screen_ctrl.isvisible            = false
Add(mp3_screen_ctrl)

local scale=0.1
-- MP3播放控制按钮div
mp3_play_controller_clip 			            = CreateElement "ceMeshPoly" --这是创建一个平面
mp3_play_controller_clip.name 			    	= "mp3_play_controller_clip"
mp3_play_controller_clip.vertices 		    	= {{-height*scale,height*scale},{height*scale,height*scale},{height*scale,-height*scale},{-height*scale,-height*scale}}
mp3_play_controller_clip.indices 		        = {0,1,2,2,3,0}
mp3_play_controller_clip.init_pos		        = {0, -height*0.85}
mp3_play_controller_clip.init_rot		        = {0, 0, 0}
mp3_play_controller_clip.material		        = "DBG_GREEN"
mp3_play_controller_clip.h_clip_relation        = h_clip_relations.INCREASE_IF_LEVEL --COMPARE --REWRITE_LEVEL
mp3_play_controller_clip.level			    	= IPAD_DEFAULT_LEVEL - 1
--main_screen_1.isdraw		        = true
mp3_play_controller_clip.change_opacity       	= false
--main_screen_1.element_params      = {"D_ENABLE"}
--main_screen_1.controllers         = {{"opacity_using_parameter",0}}
mp3_play_controller_clip.isvisible		    	= SHOW_MASKS
-- mp3_play_controller_clip.parent_element			= "mp3_screen_ctrl" --使用它作为父对象，便于位置控制这里不能用父对象
Add(mp3_play_controller_clip)

-- 播放符号
mp3_play_border 			           	= CreateElement "ceTexPoly" --这是创建一个平面
mp3_play_border.name 			   		= create_guid_string()
mp3_play_border.vertices 		    	= {
											{-height*scale*0.5,height*scale*0.6},
											{-height*scale*0.2,height*scale*0.6},
											{-height*scale*0.2,-height*scale*0.6},
											{-height*scale*0.5,-height*scale*0.6},
										
											{height*scale*0.2,height*scale*0.6},
											{height*scale*0.5,height*scale*0.6},
											{height*scale*0.5,-height*scale*0.6},
											{height*scale*0.2,-height*scale*0.6}
										}
mp3_play_border.indices 		        = {0,1,2,2,3,0,4,5,6,6,7,4}
mp3_play_border.init_pos		        = {0, 0}
mp3_play_border.init_rot		        = {0, 0, 0}
mp3_play_border.material		        = "DBG_WHITE"
mp3_play_border.element_params          = {"MP3_PLAY_ENABLE"} --, "D_GUNSIGHT_VISIBLE"
mp3_play_border.controllers             = {{"opacity_using_parameter",0},}
mp3_play_border.h_clip_relation      	= h_clip_relations.COMPARE--COMPARE --REWRITE_LEVEL
mp3_play_border.level			    	= IPAD_DEFAULT_LEVEL
mp3_play_border.change_opacity       	= false
mp3_play_border.isvisible		    	= true
mp3_play_border.parent_element			= "mp3_play_controller_clip" --使用它作为父对象，便于位置控制这里不能用父对象
Add(mp3_play_border)

-- 暂停符号

mp3_pause_border 			           = CreateElement "ceMeshPoly" --这是创建一个平面
mp3_pause_border.name 			    	= create_guid_string()
mp3_pause_border.vertices 		    	= {
											{-height*scale*0.4,height*scale*0.8},
											{-height*scale*0.4,-height*scale*0.8},
											{height*scale*0.8,-height*scale*0}
										}
mp3_pause_border.indices 		        = {0,1,2}
mp3_pause_border.init_pos		        = {0, 0}
mp3_pause_border.init_rot		        = {0, 0, 0}
mp3_pause_border.material		        = "DBG_WHITE"
mp3_pause_border.element_params         = {"MP3_PAUSE_ENABLE"} --, "D_GUNSIGHT_VISIBLE"
mp3_pause_border.controllers            = {{"opacity_using_parameter",0},}
mp3_pause_border.h_clip_relation      	= h_clip_relations.COMPARE--COMPARE --REWRITE_LEVEL
mp3_pause_border.level			    	= IPAD_DEFAULT_LEVEL
mp3_pause_border.change_opacity       	= false
mp3_pause_border.isvisible		    	= true
mp3_pause_border.parent_element			= "mp3_play_controller_clip" --使用它作为父对象，便于位置控制这里不能用父对象
Add(mp3_pause_border)

-- 下一首符号
scale=scale*0.5
mp3_next_mesh 			           = CreateElement "ceMeshPoly" --这是创建一个平面
mp3_next_mesh.name 			    = create_guid_string()
mp3_next_mesh.vertices 		    = {
										{-height*scale,height*scale},
										{-height*scale,-height*scale},
										{height*scale*0.70,-height*scale*0.1},
										{height*scale*0.70,height*scale*0.1},
										
										{height*scale,height*scale},
										{height*scale*0.70,height*scale},
										{height*scale*0.70,-height*scale},
										{height*scale,-height*scale},
									}
mp3_next_mesh.indices 		        = {0,1,2,2,3,0,4,5,6,6,7,4}
mp3_next_mesh.init_pos		        = {width*0.15, 0}
mp3_next_mesh.init_rot		        = {0, 0, 0}
mp3_next_mesh.material		        = green_material
mp3_next_mesh.element_params            = {"MP3_SCR_ENABLE"} --, "D_GUNSIGHT_VISIBLE"
mp3_next_mesh.controllers               = {{"opacity_using_parameter",0},}
mp3_next_mesh.h_clip_relation      = h_clip_relations.COMPARE--COMPARE --REWRITE_LEVEL
mp3_next_mesh.level			    = IPAD_DEFAULT_NOCLIP_LEVEL
mp3_next_mesh.change_opacity       = false
mp3_next_mesh.isvisible		    = true
mp3_next_mesh.parent_element	= "mp3_play_controller_clip" --使用它作为父对象，便于位置控制这里不能用父对象
Add(mp3_next_mesh)

-- 上一首符号
mp3_last_mesh 			           = CreateElement "ceMeshPoly" --这是创建一个平面
mp3_last_mesh.name 			    = create_guid_string()
mp3_last_mesh.vertices 		    = {
										{height*scale,height*scale},
										{height*scale,-height*scale},
										{-height*scale*0.70,-height*scale*0.1},
										{-height*scale*0.70,height*scale*0.1},
										
										{-height*scale,height*scale},
										{-height*scale*0.70,height*scale},
										{-height*scale*0.70,-height*scale},
										{-height*scale,-height*scale},
									}
mp3_last_mesh.indices 		        = {0,1,2,2,3,0,4,5,6,6,7,4}
mp3_last_mesh.init_pos		        = {-width*0.15, 0}
mp3_last_mesh.init_rot		        = {0, 0, 0}
mp3_last_mesh.material		        = green_material
mp3_last_mesh.element_params            = {"MP3_SCR_ENABLE"} --, "D_GUNSIGHT_VISIBLE"
mp3_last_mesh.controllers               = {{"opacity_using_parameter",0},}
mp3_last_mesh.h_clip_relation      = h_clip_relations.COMPARE--COMPARE --REWRITE_LEVEL
mp3_last_mesh.level			    = IPAD_DEFAULT_NOCLIP_LEVEL
mp3_last_mesh.change_opacity       = false
mp3_last_mesh.isvisible		    = true
mp3_last_mesh.parent_element	= "mp3_play_controller_clip" --使用它作为父对象，便于位置控制这里不能用父对象
Add(mp3_last_mesh)

--歌单div
mp3_music_list_div 			            = CreateElement "ceMeshPoly" --这是创建一个平面
mp3_music_list_div.name 			    = "mp3_music_list_div"
mp3_music_list_div.vertices 		    = {{-width*0.7,height*0.7},{width*0.7,height*0.7},{width*0.7,-height*0.7},{-width*0.7,-height*0.7}}
mp3_music_list_div.indices 		        = {0,1,2,2,3,0}
mp3_music_list_div.init_pos		        = {0, -height*0.3}
mp3_music_list_div.init_rot		        = {0, 0, 0}
mp3_music_list_div.material		        = "DBG_GREEN"
mp3_music_list_div.element_params            = {"MP3_MUSIC_LIST_ENABLE"} --, "D_GUNSIGHT_VISIBLE"
mp3_music_list_div.controllers               = {{"opacity_using_parameter",0},}
mp3_music_list_div.h_clip_relation      = h_clip_relations.COMPARE--COMPARE --REWRITE_LEVEL
mp3_music_list_div.level			    = IPAD_DEFAULT_NOCLIP_LEVEL
mp3_music_list_div.change_opacity       = false
mp3_music_list_div.isvisible		    = false
mp3_music_list_div.parent_element	= "mp3_screen_ctrl" --使用它作为父对象，便于位置控制这里不能用父对象
Add(mp3_music_list_div)

--上一首歌单
mp3_name_last_text              = CreateElement "ceStringPoly" --创建一个字符输出元素 "ceTexPoly"表示创建一个贴图模型
mp3_name_last_text.name               = ("mp3_name_last_text" .. create_guid_string())
mp3_name_last_text.material           = "unicode_cn" --FONT_             --材质类型（注意上面创建的字体材质）
mp3_name_last_text.init_pos           = {-width*0.8,height*0.8}         -- 这是设置对齐点的坐标【这是当前模型的最大限制(在边角对齐时不要超出)】
mp3_name_last_text.alignment          = "Center"       --对齐方式设置：Left/Right/Center; Top/Down/Center
mp3_name_last_text.stringdefs         = {0.75*0.011,0.75*0.75 * 0.011, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} 第一个值控制宽度，第二个值控制高度
mp3_name_last_text.formats            = {"%s","%s"} -- 这里设置输出，类似于C的printf模型 %开头的是输出类型，后面的%s是输入类型
mp3_name_last_text.element_params     = {"MP3_NAME_LAST_TEXT", "MP3_MUSIC_LIST_ENABLE"} --生成的para控制句柄
mp3_name_last_text.controllers        = {{"text_using_parameter",0,0},{"opacity_using_parameter",1}}   --输入控制模型
mp3_name_last_text.collimated         = true
mp3_name_last_text.use_mipfilter      = true
mp3_name_last_text.additive_alpha     = true
mp3_name_last_text.isvisible		    = true
mp3_name_last_text.h_clip_relation 	= h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
mp3_name_last_text.level			    = IPAD_DEFAULT_NOCLIP_LEVEL
mp3_name_last_text.parent_element     = "mp3_music_list_div"  --父节点名字 --可以绑定不在同一层的父节点
Add(mp3_name_last_text)

--当前播放歌名
mp3_name_text              = CreateElement "ceStringPoly" --创建一个字符输出元素 "ceTexPoly"表示创建一个贴图模型
mp3_name_text.name               = create_guid_string()
mp3_name_text.material           = "unicode_cn_white" --FONT_             --材质类型（注意上面创建的字体材质）
mp3_name_text.init_pos           = {0,height*0.85}         -- 这是设置对齐点的坐标【这是当前模型的最大限制(在边角对齐时不要超出)】
mp3_name_text.alignment          = "CenterCenter"       --对齐方式设置：Left/Right/Center; Top/Down/Center
mp3_name_text.stringdefs         = {0.55*0.011,0.55 * 0.011, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} 第一个值控制宽度，第二个值控制高度
mp3_name_text.formats            = {"%s","%s"} -- 这里设置输出，类似于C的printf模型 %开头的是输出类型，后面的%s是输入类型
mp3_name_text.element_params     = {"MP3_NAME_TEXT", "MP3_SCR_ENABLE"} --生成的para控制句柄
mp3_name_text.controllers        = {{"text_using_parameter",0,0},{"opacity_using_parameter",1}}   --输入控制模型
mp3_name_text.collimated         = true
mp3_name_text.use_mipfilter      = true
mp3_name_text.additive_alpha     = true
mp3_name_text.isvisible		    = true
mp3_name_text.h_clip_relation 	= h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
mp3_name_text.level			    = IPAD_DEFAULT_NOCLIP_LEVEL
mp3_name_text.parent_element     = "mp3_screen_ctrl"  --父节点名字 --可以绑定不在同一层的父节点
Add(mp3_name_text)

--下一首歌单
mp3_name_next_text              = CreateElement "ceStringPoly" --创建一个字符输出元素 "ceTexPoly"表示创建一个贴图模型
mp3_name_next_text.name               = ("mp3_name_next_text" .. create_guid_string())
mp3_name_next_text.material           = "unicode_cn" --FONT_             --材质类型（注意上面创建的字体材质）
mp3_name_next_text.init_pos           = {-width*0.8,height*0.30}         -- 这是设置对齐点的坐标【这是当前模型的最大限制(在边角对齐时不要超出)】
mp3_name_next_text.alignment          = "Center"       --对齐方式设置：Left/Right/Center; Top/Down/Center
mp3_name_next_text.stringdefs         = {0.75*0.011,0.75*0.75 * 0.011, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} 第一个值控制宽度，第二个值控制高度
mp3_name_next_text.formats            = {"%s","%s"} -- 这里设置输出，类似于C的printf模型 %开头的是输出类型，后面的%s是输入类型
mp3_name_next_text.element_params     = {"MP3_NAME_NEXT_TEXT", "MP3_MUSIC_LIST_ENABLE"} --生成的para控制句柄
mp3_name_next_text.controllers        = {{"text_using_parameter",0,0},{"opacity_using_parameter",1}}   --输入控制模型
mp3_name_next_text.collimated         = true
mp3_name_next_text.use_mipfilter      = true
mp3_name_next_text.additive_alpha     = true
mp3_name_next_text.isvisible		    = true
mp3_name_next_text.h_clip_relation 	= h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
mp3_name_next_text.level			    = IPAD_DEFAULT_NOCLIP_LEVEL
mp3_name_next_text.parent_element     = "mp3_music_list_div"  --父节点名字 --可以绑定不在同一层的父节点
Add(mp3_name_next_text)

--当前播放进度时间
mp3_playback_pro_text              = CreateElement "ceStringPoly" --创建一个字符输出元素 "ceTexPoly"表示创建一个贴图模型
mp3_playback_pro_text.name               = ("mp3_playback_pro_text" .. create_guid_string())
mp3_playback_pro_text.material           = "unicode_cn" --FONT_             --材质类型（注意上面创建的字体材质）
mp3_playback_pro_text.init_pos           = {-width*0.95,-height*0.85}         -- 这是设置对齐点的坐标【这是当前模型的最大限制(在边角对齐时不要超出)】
mp3_playback_pro_text.alignment          = "LeftCenter"       --对齐方式设置：Left/Right/Center; Top/Down/Center
mp3_playback_pro_text.stringdefs         = {0.75*0.011,0.75*0.75 * 0.011, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} 第一个值控制宽度，第二个值控制高度
mp3_playback_pro_text.formats            = {"%s","%s"} -- 这里设置输出，类似于C的printf模型 %开头的是输出类型，后面的%s是输入类型
mp3_playback_pro_text.element_params     = {"MP3_PLAYBACK_PRO_TEXT", "MP3_SCR_ENABLE"} --生成的para控制句柄
mp3_playback_pro_text.controllers        = {{"text_using_parameter",0,0},{"opacity_using_parameter",1}}   --输入控制模型
mp3_playback_pro_text.collimated         = true
mp3_playback_pro_text.use_mipfilter      = true
mp3_playback_pro_text.additive_alpha     = true
mp3_playback_pro_text.isvisible		    = true
mp3_playback_pro_text.h_clip_relation 	= h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
mp3_playback_pro_text.level			    = IPAD_DEFAULT_NOCLIP_LEVEL
mp3_playback_pro_text.parent_element     = "mp3_screen_ctrl"  --父节点名字 --可以绑定不在同一层的父节点
Add(mp3_playback_pro_text)

--当前歌曲长度
mp3_music_length_text              = CreateElement "ceStringPoly" --创建一个字符输出元素 "ceTexPoly"表示创建一个贴图模型
mp3_music_length_text.name               = ("mp3_music_length_text" .. create_guid_string())
mp3_music_length_text.material           = "unicode_cn" --FONT_             --材质类型（注意上面创建的字体材质）
mp3_music_length_text.init_pos           = {width*0.95,-height*0.85}         -- 这是设置对齐点的坐标【这是当前模型的最大限制(在边角对齐时不要超出)】
mp3_music_length_text.alignment          = "RightCenter"       --对齐方式设置：Left/Right/Center; Top/Down/Center
mp3_music_length_text.stringdefs         = {0.75*0.011,0.75*0.75 * 0.011, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} 第一个值控制宽度，第二个值控制高度
mp3_music_length_text.formats            = {"%s","%s"} -- 这里设置输出，类似于C的printf模型 %开头的是输出类型，后面的%s是输入类型
mp3_music_length_text.element_params     = {"MP3_MUSIC_LENGTH_TEXT", "MP3_SCR_ENABLE"} --生成的para控制句柄
mp3_music_length_text.controllers        = {{"text_using_parameter",0,0},{"opacity_using_parameter",1}}   --输入控制模型
mp3_music_length_text.collimated         = true
mp3_music_length_text.use_mipfilter      = true
mp3_music_length_text.additive_alpha     = true
mp3_music_length_text.isvisible		    = true
mp3_music_length_text.h_clip_relation 	= h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
mp3_music_length_text.level			    = IPAD_DEFAULT_NOCLIP_LEVEL
mp3_music_length_text.parent_element     = "mp3_screen_ctrl"  --父节点名字 --可以绑定不在同一层的父节点
Add(mp3_music_length_text)

--当前播放进度条（框）
scale=0.9
mp3_playback_pro_bar_border 			           = CreateElement "ceMeshPoly" --这是创建一个平面
mp3_playback_pro_bar_border.name 			    = "mp3_playback_pro_bar_border"
mp3_playback_pro_bar_border.vertices 		    = {{-width*scale,height*0.01},{width*scale,height*0.01},{width*scale,-height*0.01},{-width*scale,-height*0.01}}
mp3_playback_pro_bar_border.indices 		        = {0,1,2,2,3,0}
mp3_playback_pro_bar_border.init_pos		        = {0, -height*0.7}
mp3_playback_pro_bar_border.init_rot		        = {0, 0, 0}
mp3_playback_pro_bar_border.material		        = "DBG_WHITE"
mp3_playback_pro_bar_border.element_params            = {"MP3_SCR_ENABLE"} --, "D_GUNSIGHT_VISIBLE"
mp3_playback_pro_bar_border.controllers               = {{"opacity_using_parameter",0}}
mp3_playback_pro_bar_border.h_clip_relation      = h_clip_relations.COMPARE--COMPARE --REWRITE_LEVEL
mp3_playback_pro_bar_border.level			    = IPAD_DEFAULT_NOCLIP_LEVEL
mp3_playback_pro_bar_border.change_opacity       = false
mp3_playback_pro_bar_border.isvisible		    = true
mp3_playback_pro_bar_border.parent_element	= "mp3_screen_ctrl" --使用它作为父对象，便于位置控制这里不能用父对象
Add(mp3_playback_pro_bar_border)

--当前播放进度条

mp3_playback_pro_bar 			           = CreateElement "ceMeshPoly" --这是创建一个平面
mp3_playback_pro_bar.name 			    = create_guid_string()
mp3_playback_pro_bar.vertices 		    = create_circle_pos(61, 0, 0, height*2000*0.04)
mp3_playback_pro_bar.indices 		        = create_circle_index(61)
mp3_playback_pro_bar.init_pos		        = {-width*scale, 0}
mp3_playback_pro_bar.init_rot		        = {0, 0, 0}
mp3_playback_pro_bar.material		        = "DBG_WHITE"
mp3_playback_pro_bar.element_params            = {"MP3_SCR_ENABLE","MP3_PLAYBACK_PRO_BAR"} --, "D_GUNSIGHT_VISIBLE"
mp3_playback_pro_bar.controllers               = {{"opacity_using_parameter",0},{"move_left_right_using_parameter",1,0.14}}
mp3_playback_pro_bar.h_clip_relation      = h_clip_relations.COMPARE--COMPARE --REWRITE_LEVEL
mp3_playback_pro_bar.level			    = IPAD_DEFAULT_NOCLIP_LEVEL
mp3_playback_pro_bar.change_opacity       = false
mp3_playback_pro_bar.isvisible		    = true
mp3_playback_pro_bar.parent_element	= "mp3_playback_pro_bar_border" --使用它作为父对象，便于位置控制这里不能用父对象
Add(mp3_playback_pro_bar)

--已播放歌词
mp3_last_lrc_text              = CreateElement "ceStringPoly" --创建一个字符输出元素 "ceTexPoly"表示创建一个贴图模型
mp3_last_lrc_text.name               = ("mp3_last_lrc_text" .. create_guid_string())
mp3_last_lrc_text.material           = "unicode_cn" --FONT_             --材质类型（注意上面创建的字体材质）
mp3_last_lrc_text.init_pos           = {0,height*0.3}         -- 这是设置对齐点的坐标【这是当前模型的最大限制(在边角对齐时不要超出)】
mp3_last_lrc_text.alignment          = "CenterCenter"       --对齐方式设置：Left/Right/Center; Top/Down/Center
mp3_last_lrc_text.stringdefs         = {0.45*0.011,0.45 * 0.011, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} 第一个值控制宽度，第二个值控制高度
mp3_last_lrc_text.formats            = {"%s","%s"} -- 这里设置输出，类似于C的printf模型 %开头的是输出类型，后面的%s是输入类型
mp3_last_lrc_text.element_params     = {"MP3_LAST_LRC_TEXT", "MP3_LRC_ENABLE"} --生成的para控制句柄
mp3_last_lrc_text.controllers        = {{"text_using_parameter",0,0},{"opacity_using_parameter",1}}   --输入控制模型
mp3_last_lrc_text.collimated         = true
mp3_last_lrc_text.use_mipfilter      = true
mp3_last_lrc_text.additive_alpha     = true
mp3_last_lrc_text.isvisible		    = true
mp3_last_lrc_text.h_clip_relation 	= h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
mp3_last_lrc_text.level			    = IPAD_DEFAULT_NOCLIP_LEVEL
mp3_last_lrc_text.parent_element     = "mp3_screen_ctrl"  --父节点名字 --可以绑定不在同一层的父节点
Add(mp3_last_lrc_text)

--当前播放歌词
mp3_current_lrc_text              = CreateElement "ceStringPoly" --创建一个字符输出元素 "ceTexPoly"表示创建一个贴图模型
mp3_current_lrc_text.name               = ("mp3_current_lrc_text" .. create_guid_string())
mp3_current_lrc_text.material           = "unicode_cn_white" --FONT_             --材质类型（注意上面创建的字体材质）
mp3_current_lrc_text.init_pos           = {0,0}         -- 这是设置对齐点的坐标【这是当前模型的最大限制(在边角对齐时不要超出)】
mp3_current_lrc_text.alignment          = "CenterCenter"       --对齐方式设置：Left/Right/Center; Top/Down/Center
mp3_current_lrc_text.stringdefs         = {0.45*0.011,0.45 * 0.011, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} 第一个值控制宽度，第二个值控制高度
mp3_current_lrc_text.formats            = {"%s","%s"} -- 这里设置输出，类似于C的printf模型 %开头的是输出类型，后面的%s是输入类型
mp3_current_lrc_text.element_params     = {"MP3_CUR_LRC_TEXT", "MP3_LRC_ENABLE"} --生成的para控制句柄
mp3_current_lrc_text.controllers        = {{"text_using_parameter",0,0},{"opacity_using_parameter",1}}   --输入控制模型
mp3_current_lrc_text.collimated         = true
mp3_current_lrc_text.use_mipfilter      = true
mp3_current_lrc_text.additive_alpha     = true
mp3_current_lrc_text.isvisible		    = true
mp3_current_lrc_text.h_clip_relation 	= h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
mp3_current_lrc_text.level			    = IPAD_DEFAULT_NOCLIP_LEVEL
mp3_current_lrc_text.parent_element     = "mp3_screen_ctrl"  --父节点名字 --可以绑定不在同一层的父节点
Add(mp3_current_lrc_text)

--未播放歌词
mp3_next_lrc_text              = CreateElement "ceStringPoly" --创建一个字符输出元素 "ceTexPoly"表示创建一个贴图模型
mp3_next_lrc_text.name               = ("mp3_next_lrc_text" .. create_guid_string())
mp3_next_lrc_text.material           = "unicode_cn" --FONT_             --材质类型（注意上面创建的字体材质）
mp3_next_lrc_text.init_pos           = {0,-height*0.2}         -- 这是设置对齐点的坐标【这是当前模型的最大限制(在边角对齐时不要超出)】
mp3_next_lrc_text.alignment          = "CenterCenter"       --对齐方式设置：Left/Right/Center; Top/Down/Center
mp3_next_lrc_text.stringdefs         = {0.45*0.011,0.45 * 0.011, 0, 0}    --{ecrase vertical si inf a 0.01,ecrase lateral * streccth, 0, 0} 第一个值控制宽度，第二个值控制高度
mp3_next_lrc_text.formats            = {"%s","%s"} -- 这里设置输出，类似于C的printf模型 %开头的是输出类型，后面的%s是输入类型
mp3_next_lrc_text.element_params     = {"MP3_NEXT_LRC_TEXT", "MP3_LRC_ENABLE"} --生成的para控制句柄
mp3_next_lrc_text.controllers        = {{"text_using_parameter",0,0},{"opacity_using_parameter",1}}   --输入控制模型
mp3_next_lrc_text.collimated         = true
mp3_next_lrc_text.use_mipfilter      = true
mp3_next_lrc_text.additive_alpha     = true
mp3_next_lrc_text.isvisible		    = true
mp3_next_lrc_text.h_clip_relation 	= h_clip_relations.COMPARE -- INCREASE_IF_LEVEL-- --REWRITE_LEVEL
mp3_next_lrc_text.level			    = IPAD_DEFAULT_NOCLIP_LEVEL
mp3_next_lrc_text.parent_element     = "mp3_screen_ctrl"  --父节点名字 --可以绑定不在同一层的父节点
Add(mp3_next_lrc_text)



--光盘底色
mp3_disk_mesh 			           = CreateElement "ceMeshPoly" --这是创建一个平面
mp3_disk_mesh.name 			    = create_guid_string()
mp3_disk_mesh.vertices 		    = create_circle_pos(61, 0, 0, height*2000*0.6)
mp3_disk_mesh.indices 		        = create_circle_index(61)
mp3_disk_mesh.init_pos		        = {0, height*0.1}
mp3_disk_mesh.init_rot		        = {0, 0, 0}
mp3_disk_mesh.material		        = darkGray_material
mp3_disk_mesh.element_params            = {"MP3_DISK_ENABLE","MP3_DISK_ROT"} --, "D_GUNSIGHT_VISIBLE"
mp3_disk_mesh.controllers               = {{"opacity_using_parameter",0},{"rotate_using_parameter",1,math.rad(1)}}
mp3_disk_mesh.h_clip_relation      = h_clip_relations.COMPARE--COMPARE --REWRITE_LEVEL
mp3_disk_mesh.level			    = IPAD_DEFAULT_NOCLIP_LEVEL
mp3_disk_mesh.change_opacity       = false
mp3_disk_mesh.isvisible		    = true
mp3_disk_mesh.parent_element	= "mp3_screen_ctrl" --使用它作为父对象，便于位置控制这里不能用父对象
Add(mp3_disk_mesh)

--光盘裁减层
mp3_disk_clip 			            = CreateElement "ceMeshPoly" --这是创建一个平面
mp3_disk_clip.name 			    = "mp3_disk_clip"
mp3_disk_clip.vertices 		    = create_circle_pos(61, 0, 0, height*2000*0.45)
mp3_disk_clip.indices 		        = create_circle_index(61)
mp3_disk_clip.init_pos		        = {0, height*0.1}
mp3_disk_clip.init_rot		        = {0, 0, 0}
mp3_disk_clip.material		        = "DBG_GREEN"
mp3_disk_clip.element_params            = {"MP3_DISK_ROT"} --, "D_GUNSIGHT_VISIBLE"
mp3_disk_clip.controllers               = {{"rotate_using_parameter",0,math.rad(1)}}
mp3_disk_clip.h_clip_relation      = h_clip_relations.INCREASE_IF_LEVEL--COMPARE --REWRITE_LEVEL
mp3_disk_clip.level			    = IPAD_DEFAULT_LEVEL - 1
mp3_disk_clip.change_opacity       = false
mp3_disk_clip.isvisible		    = false
Add(mp3_disk_clip)

dofile(LockOn_Options.script_path.."Systems/mp3List.lua")
for i=1,#mp3List,1 do
	
	local img_material=	MakeMaterial(mp3List[i].img, {255,255,255,255})
	local mp3_disk_img 				            = CreateElement "ceTexPoly"
	mp3_disk_img.vertices                  		= {{-height*0.5,height*0.5},{height*0.5,height*0.5},{height*0.5,-height*0.5},{-height*0.5,-height*0.5}}
	mp3_disk_img.indices                   		= {0,1,2,2,3,0}
	mp3_disk_img.tex_coords                		= tex_coord_gen(0,0,mp3List[i].img_w,mp3List[i].img_h,mp3List[i].img_w,mp3List[i].img_h)
	mp3_disk_img.material                  		= img_material
	mp3_disk_img.name 			            	= create_guid_string()
	mp3_disk_img.init_pos                  		= {0, 0}
	mp3_disk_img.init_rot		            	= {0, 0, 0}
	mp3_disk_img.collimated	            		= true
	mp3_disk_img.element_params            		= {"MP3_DISK_IMG_ENABLE_"..i} --, "D_GUNSIGHT_VISIBLE"
	mp3_disk_img.controllers               		= {{"opacity_using_parameter",0},}
	mp3_disk_img.use_mipfilter             		= true
	mp3_disk_img.additive_alpha            		= true
	mp3_disk_img.h_clip_relation           		= h_clip_relations.COMPARE
	mp3_disk_img.level                     		= IPAD_DEFAULT_LEVEL
	mp3_disk_img.parent_element	        		= "mp3_disk_clip"
	Add(mp3_disk_img)
end

--磁头轴辅助点
mp3_mag_head_sim                      = CreateElement "ceSimple"
mp3_mag_head_sim.name                 = "mp3_mag_head_sim"
mp3_mag_head_sim.init_pos             = {-width*0.8, height*0.6}
mp3_mag_head_sim.init_rot			  = {-30,0,0}
mp3_mag_head_sim.element_params       = {"MP3_SCR_ENABLE","MP3_MAG_HEAD_ROT"}
mp3_mag_head_sim.controllers          = {{"opacity_using_parameter",0},{"rotate_using_parameter",1,math.rad(30)}}
mp3_mag_head_sim.collimated	        = true
mp3_mag_head_sim.use_mipfilter        = true
mp3_mag_head_sim.additive_alpha       = true
mp3_mag_head_sim.h_clip_relation      = h_clip_relations.COMPARE
mp3_mag_head_sim.level                = IPAD_DEFAULT_NOCLIP_LEVEL
mp3_mag_head_sim.parent_element	    = "mp3_screen_ctrl" --父对象为主屏幕裁剪层
mp3_mag_head_sim.isvisible            = false
Add(mp3_mag_head_sim)

--磁头
scale=0.3
mp3_mag_head_tex 				            = CreateElement "ceTexPoly"
mp3_mag_head_tex.vertices                  = {{-height*scale,(height*scale)/(429/349)},{height*scale,(height*scale)/(429/349)},{height*scale,-(height*scale)/(429/349)},{-height*scale,-(height*scale)/(429/349)}}
mp3_mag_head_tex.indices                   = {0,1,2,2,3,0}
mp3_mag_head_tex.tex_coords                = tex_coord_gen(0,494,429,349,1024,1024)
mp3_mag_head_tex.material                  = mp3_symbol_white_material
mp3_mag_head_tex.name 			            = create_guid_string()
mp3_mag_head_tex.init_pos                  = {height*0.26, -height*0.205}
mp3_mag_head_tex.init_rot		            = {0, 0, 0}
mp3_mag_head_tex.collimated	            = true
mp3_mag_head_tex.element_params            = {"MP3_DISK_ENABLE"} --, "D_GUNSIGHT_VISIBLE"
mp3_mag_head_tex.controllers               = {{"opacity_using_parameter",0}}
mp3_mag_head_tex.use_mipfilter             = true
mp3_mag_head_tex.additive_alpha            = true
mp3_mag_head_tex.h_clip_relation           = h_clip_relations.COMPARE
mp3_mag_head_tex.level                     = IPAD_DEFAULT_NOCLIP_LEVEL
mp3_mag_head_tex.parent_element	        = "mp3_mag_head_sim"
Add(mp3_mag_head_tex)

--音量线

mp3_vol_line_mesh 			           = CreateElement "ceMeshPoly" --这是创建一个平面
mp3_vol_line_mesh.name 			    = "mp3_vol_line_mesh"
mp3_vol_line_mesh.vertices 		    = {{-width*0.8,height*0.01},{width*0.8,height*0.01},{width*0.8,-height*0.01},{-width*0.8,-height*0.01}}
mp3_vol_line_mesh.indices 		        = {0,1,2,2,3,0}
mp3_vol_line_mesh.init_pos		        = {0, height*0.75}
mp3_vol_line_mesh.init_rot		        = {0, 0, 0}
mp3_vol_line_mesh.material		        = "DBG_WHITE"
mp3_vol_line_mesh.element_params            = {"MP3_SCR_ENABLE"} --, "D_GUNSIGHT_VISIBLE"
mp3_vol_line_mesh.controllers               = {{"opacity_using_parameter",0}}
mp3_vol_line_mesh.h_clip_relation      = h_clip_relations.COMPARE--COMPARE --REWRITE_LEVEL
mp3_vol_line_mesh.level			    = IPAD_DEFAULT_NOCLIP_LEVEL
mp3_vol_line_mesh.change_opacity       = false
mp3_vol_line_mesh.isvisible		    = true
mp3_vol_line_mesh.parent_element	= "mp3_screen_ctrl" --使用它作为父对象，便于位置控制这里不能用父对象
Add(mp3_vol_line_mesh)

mp3_vol_cir_mesh 			           = CreateElement "ceMeshPoly" --这是创建一个平面
mp3_vol_cir_mesh.name 			    = "mp3_vol_cir_mesh"
mp3_vol_cir_mesh.vertices 		    = create_circle_pos(61, 0, 0, height*2000*0.02)
mp3_vol_cir_mesh.indices 		        = create_circle_index(61)
mp3_vol_cir_mesh.init_pos		        = {-width*0.8, 0}
mp3_vol_cir_mesh.init_rot		        = {0, 0, 0}
mp3_vol_cir_mesh.material		        = "DBG_WHITE"
mp3_vol_cir_mesh.element_params            = {"MP3_SCR_ENABLE","MP3_VOL_MOVE"} --, "D_GUNSIGHT_VISIBLE"
mp3_vol_cir_mesh.controllers               = {{"opacity_using_parameter",0},{"move_left_right_using_parameter",1,0.125}}
mp3_vol_cir_mesh.h_clip_relation      = h_clip_relations.COMPARE--COMPARE --REWRITE_LEVEL
mp3_vol_cir_mesh.level			    = IPAD_DEFAULT_NOCLIP_LEVEL
mp3_vol_cir_mesh.change_opacity       = false
mp3_vol_cir_mesh.isvisible		    = true
mp3_vol_cir_mesh.parent_element	= "mp3_vol_line_mesh" --使用它作为父对象，便于位置控制这里不能用父对象
Add(mp3_vol_cir_mesh)