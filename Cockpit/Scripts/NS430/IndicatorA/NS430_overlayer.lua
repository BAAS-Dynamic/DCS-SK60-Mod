local SHOW_OVERLAYER_MASKS = true

-- Test Layer for 
-- 790 * 475 // 1024 * 512
local Moving_Map_Clip                   = CreateElement "ceMeshPoly" --This is the clipping layer
Moving_Map_Clip.name 			        = "overlayer_clip"
Moving_Map_Clip.primitivetype   	    = "triangles"
Moving_Map_Clip.vertices 		        = { {0.29297, aspect * 0.92773}, {0.29297,-aspect * 0.92773}, {-0.29297,-aspect * 0.92773}, {-0.29297,aspect * 0.92773},} --四个边角
Moving_Map_Clip.indices 		        = {0,1,2,0,2,3}
Moving_Map_Clip.init_pos		        = {0.70703, 0.0722344, 0}
Moving_Map_Clip.init_rot		        = {0, 0, 0}
Moving_Map_Clip.material		        = "DBG_GREY"
Moving_Map_Clip.h_clip_relation         = h_clip_relations.INCREASE_IF_LEVEL --INCREASE_IF_LEVEL--COMPARE --REWRITE_LEVEL
Moving_Map_Clip.level			        = NS430_DEFAULT_LEVEL - 1
Moving_Map_Clip.isdraw		            = true
Moving_Map_Clip.change_opacity          = false
Moving_Map_Clip.element_params          = {"NS430_MAP_DISPLAY_3"}              -- Initialize the main display control
Moving_Map_Clip.controllers             = {{"opacity_using_parameter",0}}
Moving_Map_Clip.isvisible		        = SHOW_OVERLAYER_MASKS
Add(Moving_Map_Clip)