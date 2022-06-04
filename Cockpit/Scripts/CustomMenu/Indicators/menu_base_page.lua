dofile(LockOn_Options.script_path.."CustomMenu/menu_def.lua")

SHOW_MASKS = true -- enable debug

-- This operation can align the newly created cropping block to the three connectors
-- Must use FOV mode
local half_width   = GetScale()
local half_height  = GetAspect() * half_width

local  screen_height =          LockOn_Options.screen.height * 0.5
local  screen_width  =          LockOn_Options.screen.width * 0.5

-- local aspect                = 1 --GetAspect()
-- local screen_width          = 4 --GetAspect()

-- This is the top trim layer of the total instrument
local base_clip 			 	= CreateElement "ceMeshPoly" --This is the clipping layer
base_clip.name 			        = "base_clip"
base_clip.primitivetype   	    = "triangles"
base_clip.vertices 		        = { {screen_width, screen_height}, { screen_width,-screen_height}, { -screen_width,-screen_height}, {-screen_width,screen_height},} --四个边角
base_clip.indices 		        = {0,1,2,0,2,3}
base_clip.init_pos		        = {0, 0, 0}
base_clip.init_rot		        = {0, 0, 0}
base_clip.material		        = "DBG_GREEN"
base_clip.h_clip_relation       = h_clip_relations.REWRITE_LEVEL --INCREASE_IF_LEVEL--COMPARE --REWRITE_LEVEL
base_clip.level			        = MENU_DEFAULT_NOCLIP_LEVEL 
base_clip.isdraw		        = true
base_clip.change_opacity        = false
base_clip.element_params        = {"IPAD_DIS_ENABLE"}              -- Initialize the main display control
base_clip.controllers           = {{"opacity_using_parameter",0}}
base_clip.isvisible		        = SHOW_MASKS
Add(base_clip)

-- dofile(LockOn_Options.script_path.."DBGiPad/Indicators/ipad_mp3_page.lua")

-- StartUP Logo -- test only
local ns430_startup_icon 				        = CreateElement "ceTexPoly"
ns430_startup_icon.vertices                     = mesh_vert_gen(1500,750)
ns430_startup_icon.indices                      = {0,1,2,2,3,0}
ns430_startup_icon.tex_coords                   = tex_coord_gen(1024,0,512,256,2048,2048)
ns430_startup_icon.material                     = basic_ns430_material
ns430_startup_icon.name 			            = create_guid_string()
ns430_startup_icon.init_pos                     = {0, 0, 0}
ns430_startup_icon.init_rot		                = {0, 0, 0}
ns430_startup_icon.collimated	                = true
ns430_startup_icon.element_params               = {"IPAD_DIS_ENABLE"}              -- Initialize the main display control
ns430_startup_icon.controllers                  = {{"opacity_using_parameter",0}}
ns430_startup_icon.use_mipfilter                = true
ns430_startup_icon.additive_alpha               = true
ns430_startup_icon.h_clip_relation              = h_clip_relations.COMPARE
ns430_startup_icon.level                        = MENU_DEFAULT_NOCLIP_LEVEL
ns430_startup_icon.parent_element	            = "base_clip"
Add(ns430_startup_icon)