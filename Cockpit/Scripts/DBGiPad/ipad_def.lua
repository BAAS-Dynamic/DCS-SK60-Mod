dofile(LockOn_Options.common_script_path.."elements_defs.lua")

-- EADI_IND_TEX_PATH        = LockOn_Options.script_path .. "../Textures/EADI/" 

IPAD_IND_TEX_PATH        = LockOn_Options.script_path .. "../Textures/IPAD/" 

-- set fov here to make sure always same
SetScale(FOV)

DEGREE_TO_MRAD = 17.4532925199433
DEGREE_TO_RAD  = 0.0174532925199433
RAD_TO_DEGREE  = 57.29577951308233
MRAD_TO_DEGREE = 0.05729577951308233

IPAD_DEFAULT_LEVEL = 4                             
IPAD_DEFAULT_NOCLIP_LEVEL  = IPAD_DEFAULT_LEVEL - 1 

DEBUG_COLOR                 = {0,255,0,200}

EADI_DAY_COLOR              = {150,150,150,255}

-- basic_eadi_material = MakeMaterial(EADI_IND_TEX_PATH.."EADI_BASE_IND.dds", EADI_DAY_COLOR)

default_size_x = 1194
default_size_y = 1194

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

function tex_center_coord_gen(x_dis,y_dis,width,height,size_X,size_Y)
    return {{(x_dis - width/2) / size_X , (y_dis - height/2) / size_Y},
            {(x_dis + width/2) / size_X , (y_dis - height/2) / size_Y},
            {(x_dis + width/2) / size_X , (y_dis + height/2) / size_Y},
            {(x_dis - width/2) / size_X , (y_dis + height/2) / size_Y},}
end

function tex_scaler_gen(x_cen,y_cen,width,height,size_X,size_Y,scale_end, frame)
    tex_state = {}
    scale_step = (scale_end - 1)/frame
    current_scale = 1
    for i = 1,frame,1 do
        tex_state[#tex_state+1] = tex_center_coord_gen(x_cen,y_cen,width*current_scale,height*current_scale,size_X,size_Y)
        current_scale = current_scale + scale_step
    end
    return tex_state
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