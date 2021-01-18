dofile(LockOn_Options.common_script_path.."elements_defs.lua")

HUD_IND_TEX_PATH        = LockOn_Options.script_path .. "../Textures/HUD/"  --定义屏幕贴图路径

--这个应该是设置弧度单位（？），用来定义屏幕倾斜 1mrad=0.001弧度=0.0573度
-- 此处存疑，A4雷达屏幕用的是FOV
-- 这个似乎是缩放模型
SetScale(FOV)--MILLYRADIANS) --这里设置了毫弧度 -- 设置FOV可以使hud对齐

-- JF-17的hud在这里定义了hud一半的宽度和高度
--[[
    HUD_HALF_WIDTH  = math.rad(10.0) * 1000
    HUD_HALF_HEIGHT = math.rad(10.0) * 1000
]]

-- 一些预定义角度/弧度换算(均为全局变量)
DEGREE_TO_MRAD = 17.4532925199433
DEGREE_TO_RAD  = 0.0174532925199433
RAD_TO_DEGREE  = 57.29577951308233
MRAD_TO_DEGREE = 0.05729577951308233

-- JF17定义了大量材质的全局描述

-- JF17定义了默认clip层级

--A4定义了两个层级
--数值越小越靠上
HUD_DEFAULT_LEVEL = 4                              -- 二次裁剪显示层
HUD_DEFAULT_NOCLIP_LEVEL  = HUD_DEFAULT_LEVEL - 1 -- 一次裁剪显示层

-- 默认hud单色吧
-- 排错颜色（大雾）
DEBUG_COLOR                 = {0,255,0,200}
-- 白天模式hud的颜色
HUD_DAY_COLOR               = {0,250,0,255}

-- 现在就一张hud贴图
basic_HUD_material = MakeMaterial(HUD_IND_TEX_PATH.."HUD_base_ind_tex.dds", HUD_DAY_COLOR)

-- 定义hud默认长宽
default_hud_x = 2000
default_hud_y = 2000 

-- 定义默认HUD旋转角度和hud显示深度
default_hud_z_offset = 0.8
default_hud_rot_offset = 0

-- 定义一些函数简化画外框
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