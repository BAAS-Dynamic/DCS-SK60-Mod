dofile(LockOn_Options.common_script_path.."elements_defs.lua")

EADI_IND_TEX_PATH        = LockOn_Options.script_path .. "../Textures/EALT/" 

-- set fov here to make sure always same
SetScale(FOV)

DEGREE_TO_MRAD = 17.4532925199433
DEGREE_TO_RAD  = 0.0174532925199433
RAD_TO_DEGREE  = 57.29577951308233
MRAD_TO_DEGREE = 0.05729577951308233

EALT_DEFAULT_LEVEL = 4                             
EALT_DEFAULT_NOCLIP_LEVEL  = EALT_DEFAULT_LEVEL - 1 

DEBUG_COLOR                 = {0,255,0,200}

EALT1_DAY_COLOR              = {200,200,200,255}

--basic_eadi_material = MakeMaterial(EADI_IND_TEX_PATH.."EADI_BASE_IND.dds", EADI_DAY_COLOR)

default_ealt_x = 1500
default_ealt_y = 1000

default_ealt_z_offset = 0
default_ealt_rot_offset = 0

function EALT_vert_gen(width, height)
    return {{(0 - width) / 2 / default_ealt_x , (0 + height) / 2 / default_ealt_y},
    {(0 + width) / 2 / default_ealt_x , (0 + height) / 2 / default_ealt_y},
    {(0 + width) / 2 / default_ealt_x , (0 - height) / 2 / default_ealt_y},
    {(0 - width) / 2 / default_ealt_x , (0 - height) / 2 / default_ealt_y},}
end

function EALT_duo_vert_gen(width, total_height, not_include_height)
    return {
        {(0 - width) / 2 / default_ealt_x , (0 + total_height) / 2 / default_ealt_y},
        {(0 + width) / 2 / default_ealt_x , (0 + total_height) / 2 / default_ealt_y},
        {(0 + width) / 2 / default_ealt_x , (0 + not_include_height) / 2 / default_ealt_y},
        {(0 - width) / 2 / default_ealt_x , (0 + not_include_height) / 2 / default_ealt_y},
        {(0 + width) / 2 / default_ealt_x , (0 - not_include_height) / 2 / default_ealt_y},
        {(0 - width) / 2 / default_ealt_x , (0 - not_include_height) / 2 / default_ealt_y},
        {(0 + width) / 2 / default_ealt_x , (0 - total_height) / 2 / default_ealt_y},
        {(0 - width) / 2 / default_ealt_x , (0 - total_height) / 2 / default_ealt_y},
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

function create_EADI_circle_index(total_dots)
    local return_group = {}
    -- we can calculate for every three
    for i = 1, (total_dots - 1), 1 do
        return_group[i*3 - 2] = 0;
        return_group[i*3 - 1] = i;
        return_group[i*3] = i + 1;
    end
    return return_group
end

function create_EADI_circle_pos(total_dots, center_X, center_y, radius)
    local return_group = {}
    local temp_deg = 0
    local temp_x = 0
    local temp_y = 0
    for i = 1, total_dots, 1 do
        temp_x = math.sin(temp_deg) * radius + center_X
        temp_y = math.cos(temp_deg) * radius + center_y
        return_group[i] = {temp_x/ default_ealt_x, temp_y/ default_ealt_y}
        temp_deg = temp_deg + 360 / total_dots
    end
    return return_group
end