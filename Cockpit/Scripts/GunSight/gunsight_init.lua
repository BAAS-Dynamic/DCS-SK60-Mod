dofile(LockOn_Options.common_script_path.."devices_defs.lua") --加载默认，不知道原因，没有在里面找到有效函数
dofile(LockOn_Options.common_script_path.."ViewportHandling.lua") --大多数的非hud显示器均加载了这一个文件(似乎是视角控制函数)

indicator_type       = indicator_types.COLLIMATOR	--大多数hud采用COLLIMATOR，主显示器均采用COMMON，此处存疑
purposes 	   = {render_purpose.GENERAL,render_purpose.HUD_ONLY_VIEW} --渲染模型

--子页面 id
BASE    = 1 
--子页面
page_subsets  = {
	[BASE]    		= LockOn_Options.script_path.."GunSight/gunsight_base.lua",    --底页面
}
--目前暂时无法控制页面集显示,所以只用一个页面控制
--页面集
pages = {
	{ BASE, },
}

init_pageID = 1 --TEST_NORMAL --默认加载为第一个页面集

update_screenspace_diplacement(SelfWidth/SelfHeight,false)

--[[
	这行的操作很奇怪，上面的操作结果是重新设置两个视角，
	dedicated_viewport 		  = {default_x,default_y,default_width,default_height}
	dedicated_viewport_arcade = {default_x, 0	    ,default_width,default_height}
	但是A4在最后又把arcade值重新定义为viewport值？存疑
]] 
dedicated_viewport_arcade = dedicated_viewport