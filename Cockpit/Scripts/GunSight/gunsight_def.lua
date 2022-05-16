dofile(LockOn_Options.common_script_path.."elements_defs.lua")

HUD_IND_TEX_PATH        = LockOn_Options.script_path .. "../Textures/HUD/"  --定义屏幕贴图路径

--这个应该是设置弧度单位（？），用来定义屏幕倾斜 1mrad=0.001弧度=0.0573度
-- 此处存疑，A4雷达屏幕用的是FOV
-- 这个是画面比例计算模式
-- Fov 提供了-1 -> 1， - aspect -> aspect 的屏幕映射
SetScale(FOV)

-- 一些预定义角度/弧度换算(均为全局变量)
DEGREE_TO_MRAD = 17.4532925199433
DEGREE_TO_RAD  = 0.0174532925199433
RAD_TO_DEGREE  = 57.29577951308233
MRAD_TO_DEGREE = 0.05729577951308233

GUNSIGHT_DEFAULT_LEVEL = 8                              -- 二次裁剪显示层
GUNSIGHT_DEFAULT_NOCLIP_LEVEL  = GUNSIGHT_DEFAULT_LEVEL - 1 -- 一次裁剪显示层

-- 默认hud单色吧
-- 排错颜色（大雾）
DEBUG_COLOR                 = {0,255,0,200}
-- 白天模式hud的颜色
HUD_DAY_COLOR               = {0,255,0,255}

-- this hud texture model is belong to another mod i made
basic_HUD_material = MakeMaterial(HUD_IND_TEX_PATH.."HUD_base_ind_tex.dds", HUD_DAY_COLOR)

-- 定义hud默认长宽
default_hud_x = 2000
default_hud_y = 2000 

-- 定义默认HUD旋转角度和hud显示深度
default_hud_z_offset = 3
default_hud_y_offset = - 0.5 * default_hud_z_offset
default_hud_rot_offset = 40

function hud_vert_gen(width, height)
    return {{(0 - width) / 2 / default_hud_x , (0 + height) / 2 / default_hud_y},
    {(0 + width) / 2 / default_hud_x , (0 + height) / 2 / default_hud_y},
    {(0 + width) / 2 / default_hud_x , (0 - height) / 2 / default_hud_y},
    {(0 - width) / 2 / default_hud_x , (0 - height) / 2 / default_hud_y},}
end

function hud_duo_vert_gen(width, total_height, not_include_height)
    return {
        {(0 - width) / 2 / default_hud_x , (0 + total_height) / 2 / default_hud_y},
        {(0 + width) / 2 / default_hud_x , (0 + total_height) / 2 / default_hud_y},
        {(0 + width) / 2 / default_hud_x , (0 + not_include_height) / 2 / default_hud_y},
        {(0 - width) / 2 / default_hud_x , (0 + not_include_height) / 2 / default_hud_y},
        {(0 + width) / 2 / default_hud_x , (0 - not_include_height) / 2 / default_hud_y},
        {(0 - width) / 2 / default_hud_x , (0 - not_include_height) / 2 / default_hud_y},
        {(0 + width) / 2 / default_hud_x , (0 - total_height) / 2 / default_hud_y},
        {(0 - width) / 2 / default_hud_x , (0 - total_height) / 2 / default_hud_y},
    }
end

-- 自动算贴图位置
function tex_coord_gen(x_dis,y_dis,width,height,size_X,size_Y)
    -- 参数说明，裁减点X,y 要裁减的宽高，原图尺寸
    return {{x_dis / size_X , y_dis / size_Y},
			{(x_dis + width) / size_X , y_dis / size_Y},
			{(x_dis + width) / size_X , (y_dis + height) / size_Y},
			{x_dis / size_X , (y_dis + height) / size_Y},}
end

-- 反向贴图生成
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
        temp_x = math.sin(temp_deg) * radius + center_X
        temp_y = math.cos(temp_deg) * radius + center_y
        return_group[i] = {temp_x/ default_hud_x, temp_y/ default_hud_y}
        temp_deg = temp_deg + 360 / total_dots
    end
    return return_group
end