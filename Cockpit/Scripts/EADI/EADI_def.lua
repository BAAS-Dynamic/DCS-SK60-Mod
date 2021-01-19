dofile(LockOn_Options.common_script_path.."elements_defs.lua")

EADI_IND_TEX_PATH        = LockOn_Options.script_path .. "../Textures/EADI/" 

-- set fov here to make sure always same
SetScale(FOV)

DEGREE_TO_MRAD = 17.4532925199433
DEGREE_TO_RAD  = 0.0174532925199433
RAD_TO_DEGREE  = 57.29577951308233
MRAD_TO_DEGREE = 0.05729577951308233

EADI_DEFAULT_LEVEL = 4                             
EADI_DEFAULT_NOCLIP_LEVEL  = EADI_DEFAULT_LEVEL - 1 

DEBUG_COLOR                 = {0,255,0,200}

EADI_DAY_COLOR               = {0,250,0,255}

basic_eadi_material = MakeMaterial(EADI_IND_TEX_PATH.."EADI_BASE_IND.dds", EADI_DAY_COLOR)

default_eadi_x = 2000
default_eadi_y = 2000

default_eadi_z_offset = 0
default_eadi_rot_offset = 0

function EADI_vert_gen(width, height)
    return {{(0 - width) / 2 / default_eadi_x , (0 + height) / 2 / default_eadi_y},
    {(0 + width) / 2 / default_eadi_x , (0 + height) / 2 / default_eadi_y},
    {(0 + width) / 2 / default_eadi_x , (0 - height) / 2 / default_eadi_y},
    {(0 - width) / 2 / default_eadi_x , (0 - height) / 2 / default_eadi_y},}
end

function EADI_duo_vert_gen(width, total_height, not_include_height)
    return {
        {(0 - width) / 2 / default_eadi_x , (0 + total_height) / 2 / default_eadi_y},
        {(0 + width) / 2 / default_eadi_x , (0 + total_height) / 2 / default_eadi_y},
        {(0 + width) / 2 / default_eadi_x , (0 + not_include_height) / 2 / default_eadi_y},
        {(0 - width) / 2 / default_eadi_x , (0 + not_include_height) / 2 / default_eadi_y},
        {(0 + width) / 2 / default_eadi_x , (0 - not_include_height) / 2 / default_eadi_y},
        {(0 - width) / 2 / default_eadi_x , (0 - not_include_height) / 2 / default_eadi_y},
        {(0 + width) / 2 / default_eadi_x , (0 - total_height) / 2 / default_eadi_y},
        {(0 - width) / 2 / default_eadi_x , (0 - total_height) / 2 / default_eadi_y},
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