dofile(LockOn_Options.script_path.."EWarningPanel/warning_def.lua")

SHOW_MASKS = true -- enable debug

-- This operation can align the newly created cropping block to the three connectors
-- Must use FOV mode
local half_width   = GetScale()
local half_height  = GetAspect() * half_width

local aspect       = GetAspect()

-- This is the top trim layer of the total instrument
local base_clip 			 	= CreateElement "ceMeshPoly" --This is the clipping layer
base_clip.name 			        = "warn_base_clip"
base_clip.primitivetype   	    = "triangles"
base_clip.vertices 		        = { {1, aspect}, { 1,-aspect}, { -1,-aspect}, {-1,aspect},} --四个边角
base_clip.indices 		        = {0,1,2,0,2,3}
base_clip.init_pos		        = {0, 0, 0}
base_clip.init_rot		        = {0, 0, 0}
base_clip.material		        = "DBG_GREY"
base_clip.h_clip_relation       = h_clip_relations.REWRITE_LEVEL --INCREASE_IF_LEVEL--COMPARE --REWRITE_LEVEL
base_clip.level			        = WARN_DEFAULT_NOCLIP_LEVEL
base_clip.isdraw		        = true
base_clip.change_opacity        = false
base_clip.element_params        = {"WARNING_DIS_ENABLE"}              -- Initialize the main display control
base_clip.controllers           = {{"opacity_using_parameter",0}}
base_clip.isvisible		        = SHOW_MASKS
Add(base_clip)

local elem_size_x = 140
local elem_num_row = 3
local elem_num_total = 15
local elem_size_y = 40
local element_name = {"FIRE_L_ENG", "CANOPY", "FIRE_R_ENG", "FUEL_L_ENG", "THRUST_REV", "FUEL_R_ENG", "OIL_L_ENG", "BRAKE", "OIL_R_ENG", "HYDRO_L", "CONVERT_A", "HYDRO_R", "GEN_L", "CONVERT_B", "GEN_R"}
local warn_elements 				    = CreateElement "ceTexPoly"
for i = 1, elem_num_total, 1 do
    -- calculate the init position
    local init_pos_x = math.fmod((i-1), elem_num_row) * (default_size_x / elem_num_row) / default_size_x
    local init_pos_y = math.modf((i-1)/elem_num_row) * (default_size_x * aspect() / (elem_num_total/elem_num_row)) / default_size_x
    --  generate the cover for warning signs
    warn_elements 				            = CreateElement "ceTexPoly"
    warn_elements.vertices                  =  mesh_vert_gen(elem_size_x, elem_size_y) --GPS_vert_gen(2*80*temp_map_size*math.cos(math.rad(44)),80*temp_map_size)
    warn_elements.indices                   = {0,1,2,2,3,0}
    --warn_elements.state_tex_coords          = state_map_scale_coord_gen()
    if (math.fmod(i, 2) == 1) then
        warn_elements.material                  = "DBG_RED"
    else
        warn_elements.material                  = "DBG_GREEN"--blue_ns430_material 
    end
    warn_elements.name 			            = create_guid_string()
    warn_elements.init_pos                  = {init_pos_x, init_pos_y, 0}
    warn_elements.init_rot		            = {0, 0, 0}
    warn_elements.collimated	            = true
    warn_elements.element_params            = {"WARNING_DIS_ENABLE", "WARN_"..element_name[i]}
    warn_elements.controllers               = {{"opacity_using_parameter",0}}
    warn_elements.use_mipfilter             = true
    warn_elements.additive_alpha            = true
    warn_elements.h_clip_relation           = h_clip_relations.COMPARE
    warn_elements.level                     = WARN_DEFAULT_NOCLIP_LEVEL
    warn_elements.parent_element	        = "warn_base_clip"
    Add(warn_elements)
end