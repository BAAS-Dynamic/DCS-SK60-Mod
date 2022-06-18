dofile(LockOn_Options.common_script_path.."elements_defs.lua")

GPS_IND_TEX_PATH        = LockOn_Options.script_path .. "../Textures/NAVU/"
MENU_IND_TEX_PATH       = LockOn_Options.script_path .. "../Textures/MENU/"

-- set fov here to make sure always same
SetScale(FOV)

DEGREE_TO_MRAD = 17.4532925199433
DEGREE_TO_RAD  = 0.0174532925199433
RAD_TO_DEGREE  = 57.29577951308233
MRAD_TO_DEGREE = 0.05729577951308233

MENU_DEFAULT_LEVEL = 22                             
MENU_DEFAULT_NOCLIP_LEVEL  = MENU_DEFAULT_LEVEL - 1 

DEBUG_COLOR                 = {0,255,0,100}

EADI_DAY_COLOR              = {150,150,150,255}

-- basic_eadi_material = MakeMaterial(EADI_IND_TEX_PATH.."EADI_BASE_IND.dds", EADI_DAY_COLOR)

default_size_x = LockOn_Options.screen.width
default_size_y = LockOn_Options.screen.height
--
--local  default_height = 0.5 * LockOn_Options.screen.height - 10
--local  default_width  =       LockOn_Options.screen.width - 20

-- Test use only
GPS_DAY_COLOR              = {200,200,200,255}
GPS_BLUE_COLOR             = {70,165,180,255} -- {130,145,150,255}
ON_SEL_COLOR               = {30, 30, 30, 150}


basic_ns430_material = MakeMaterial(GPS_IND_TEX_PATH.."NAVU_BASE_IND.dds", GPS_DAY_COLOR)
blue_ns430_material = MakeMaterial(GPS_IND_TEX_PATH.."NAVU_BASE_IND.dds", GPS_BLUE_COLOR)
basic_menu_material = MakeMaterial(MENU_IND_TEX_PATH.."MENU_IND.dds", GPS_DAY_COLOR)
empty_menu_material = MakeMaterial(nil, ON_SEL_COLOR)


default__z_offset = 0
default_rot_offset = 0

function mesh_vert_gen(width, height)
    return {{(0 - width) / 2 / default_size_x , (0 + height) / 2 / default_size_y},
    {(0 + width) / 2 / default_size_x , (0 + height) / 2 / default_size_y},
    {(0 + width) / 2 / default_size_x , (0 - height) / 2 / default_size_y},
    {(0 - width) / 2 / default_size_x , (0 - height) / 2 / default_size_y},}
end

function mesh_duo_vert_gen(width, total_height, not_include_height)
    return {
        {(0 - width) / 2 / default_size_x , (0 + total_height) / 2 / default_size_y},
        {(0 + width) / 2 / default_size_x , (0 + total_height) / 2 / default_size_y},
        {(0 + width) / 2 / default_size_x , (0 + not_include_height) / 2 / default_size_y},
        {(0 - width) / 2 / default_size_x , (0 + not_include_height) / 2 / default_size_y},
        {(0 + width) / 2 / default_size_x , (0 - not_include_height) / 2 / default_size_y},
        {(0 - width) / 2 / default_size_x , (0 - not_include_height) / 2 / default_size_y},
        {(0 + width) / 2 / default_size_x , (0 - total_height) / 2 / default_size_y},
        {(0 - width) / 2 / default_size_x , (0 - total_height) / 2 / default_size_y},
    }
end

function tex_coord_gen(x_dis,y_dis,width,height,size_X,size_Y)
    return {{x_dis / size_X , y_dis / size_Y},
			{(x_dis + width) / size_X , y_dis / size_Y},
			{(x_dis + width) / size_X , (y_dis + height) / size_Y},
			{x_dis / size_X , (y_dis + height) / size_Y},}
end

function mirror_tex_coord_gen(x_dis,y_dis,width,height,size_X,size_Y)
    return {{(x_dis + width) / size_X , y_dis / size_Y},
			{x_dis / size_X , y_dis / size_Y},
			{x_dis / size_X , (y_dis + height) / size_Y},
			{(x_dis + width) / size_X , (y_dis + height) / size_Y},}
end

function create_circle_index(total_dots)
    local return_group = {}
    -- we can calculate for every three
    for i = 1, (total_dots - 1), 1 do
        return_group[i*3 - 2] = 0;
        return_group[i*3 - 1] = i;
        return_group[i*3] = i + 1;
    end
    return return_group
end

function create_circle_pos(total_dots, center_X, center_y, radius)
    local return_group = {}
    local temp_deg = 0
    local temp_x = 0
    local temp_y = 0
    for i = 1, total_dots, 1 do
        temp_x = math.sin(math.rad(temp_deg)) * radius + center_X
        temp_y = math.cos(math.rad(temp_deg)) * radius + center_y
        return_group[i] = {temp_x/ default_size_x, temp_y/ default_size_y}
        temp_deg = temp_deg + 360 / total_dots
    end
    return return_group
end