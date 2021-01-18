dofile(LockOn_Options.common_script_path.."devices_defs.lua") --加载默认，不知道原因，没有在里面找到有效函数
dofile(LockOn_Options.common_script_path.."ViewportHandling.lua") --大多数的非hud显示器均加载了这一个文件(似乎是视角控制函数)

indicator_type       = indicator_types.COLLIMATOR	--大多数hud采用COLLIMATOR，主显示器均采用COMMON，此处存疑
purposes 	   = {render_purpose.GENERAL,render_purpose.HUD_ONLY_VIEW} --渲染模型

--子页面 id
BASE    = 1    --这是最上层的裁剪框
--BASIC_PAGE = 2 --这是基础仪表页面

--子页面
page_subsets  = {
	[BASE]    		= LockOn_Options.script_path.."HUD/Indicator/hud_base_page.lua",    --底页面
	--[BASIC_PAGE]    = LockOn_Options.script_path.."MFD/Indicator/basic_page.lua",	--基础飞行数据页面
}
--目前暂时无法控制页面集显示,所以只用一个页面控制
--页面集
pages = {
	{ BASE, }, --只有一个页面集，多页面集情况为增加这个数组
}

-- 注：关于多个屏幕控制的问题，这里可以加载一个function来区分不同屏幕初始化，basepage要弄三个

init_pageID = 1 --TEST_NORMAL --默认加载为第一个页面集

-- mat_tbl = {
-- jf17在这里有很多的材质定义，似乎是在后面直接调用这个宏定义
-- }

--这是一些材质定义，暂时不理解
-- brightness_sensitive_materials = mat_tbl
-- opacity_sensitive_materials    = mat_tbl
-- color_sensitive_materials      = mat_tbl

--这里标记一些颜色描述，原理未知
-- is_colored   = true
-- day_color    = {0, 1.0, 0}
-- night_color  = {0, 0.5, 0}

-- jf17在这里引用的material.lua也定义了一部分的显示字符

----在xxxx分割线以上的部分是JF-17的实现方式
-- JF-17的MFD屏蔽了默认的update_screenspace函数
-- 下面两个是获取屏幕的宽和高，似乎是在device_init.lua定义了三个helper坐标后可以获取到
--local w = LockOn_Options.screen.width;
--local h = LockOn_Options.screen.height;
--[[
	这部分主要转换的是这两个全局参数:[非HUD的显示屏]
	JF-17 用了这个best_fit_rect函数来求了一个同步值
	这个函数来自他自己的util文件，求的是视角校准（似乎）
	local hud_only_view_position = best_fit_rect(0, h * (1 - 50/120), w/3 , h * 50/120, Viewport_Align.left, Viewport_Align.vcenter, MFCD_aspect)
	dedicated_viewport
	dedicated_viewport_arcade
]]--

----XXXXXXXXXXXXXXXXXXXXXXXXXXXXX----------
-- A4采用这个函数来重新定义视角(标注是视角移位),函数来自viewpointerhandling
-- 在common文件夹中这个函数的描述是 positioning on screen in HUD Only view
-- 函数有三个参数：第一个是屏幕比例，第二个是is_left,第三个是缩放值（A4在这里没有第三个值）
-- 不清楚这个selfwidth和hight来自何处，这个参数在所有脚本中均没有出现过
-- 目前看JF-17在这个函数的地方自己定义了一个同样的控制函数，但是这个函数没有被使用过，使用的地方全部注释掉了

-- 目前看下面这俩也不是必须的


update_screenspace_diplacement(SelfWidth/SelfHeight,false)

--[[
	这行的操作很奇怪，上面的操作结果是重新设置两个视角，
	dedicated_viewport 		  = {default_x,default_y,default_width,default_height}
	dedicated_viewport_arcade = {default_x, 0	    ,default_width,default_height}
	但是A4在最后又把arcade值重新定义为viewport值？存疑
]] 
dedicated_viewport_arcade = dedicated_viewport