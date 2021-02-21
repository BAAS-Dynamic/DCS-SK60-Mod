dofile(LockOn_Options.script_path.."devices.lua")
dofile(LockOn_Options.script_path.."materials.lua") -- 加载材质

-- set panel
-- 初始化舱内仪表台
MainPanel = {"ccMainPanel",LockOn_Options.script_path.."mainpanel_init.lua"}

creators  = {}

-- 基础的电力模块
creators[devices.ELECTRIC_SYSTEM] ={"avSimpleElectricSystem",LockOn_Options.script_path.."Systems/electric_system.lua"}
-- 控制面模块
creators[devices.PRISURFACE]      ={"avLuaDevice"           ,LockOn_Options.script_path.."priControlSurface.lua"}
-- 舱盖，最简单的单监听模块
creators[devices.CANOPY]          ={"avLuaDevice"           ,LockOn_Options.script_path.."Systems/canopy.lua"}
-- 刹车包含空气刹车, 主要是看调用刹车系统（dispatch action
creators[devices.BREAK_SYSTEM]    ={"avLuaDevice"           ,LockOn_Options.script_path.."Systems/break_system.lua"}
-- 武器模块
creators[devices.WEAPON_SYSTEM]	  ={"avSimpleWeaponSystem"  ,LockOn_Options.script_path.."Systems/weapon_system.lua"}
-- 这两个是为了调用地勤
creators[devices.INTERCOM]        ={"avIntercom"            ,LockOn_Options.script_path.."Intercom.lua", {devices.UHF_RADIO} }
creators[devices.UHF_RADIO]       ={"avUHF_ARC_164"         ,LockOn_Options.script_path.."uhf_radio.lua", {devices.INTERCOM, devices.ELECTRIC_SYSTEM} }
-- 雷达模块
creators[devices.RADAR_RAW]		  ={"avSimpleRadar"			,LockOn_Options.script_path.."avRadar/Device/Radar_init.lua"}
-- hud Display processor
creators[devices.HUD_DCMS]        ={"avLuaDevice"           ,LockOn_Options.script_path.."Systems/dcms_hud.lua"}
-- Basic instrument, including an array that I encapsulated to process instrument animation and update function can simplify basic flight instrument drawing
creators[devices.BASIC_FLIGHT_INS]={"avLuaDevice"           ,LockOn_Options.script_path.."Systems/basic_flight_instru.lua"}
-- 时钟系统，包含读取系统时间（游戏内任务时间
creators[devices.CLOCK]           ={"avLuaDevice"           ,LockOn_Options.script_path.."aviation_clock.lua"}
--
creators[devices.GEAR_SYSTEM]     ={"avLuaDevice"           ,LockOn_Options.script_path.."Systems/gear_system.lua"}

creators[devices.LIGHT_SYSTEM]     ={"avLuaDevice"           ,LockOn_Options.script_path.."Systems/light_system.lua"}
 
-- 定义显示器
-- Indicators
indicators = {}

-- EADI left
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."EADI/EADI_L_init.lua",nil,{{"LEAD_center","LAEDI_down","LEAD_right"},{sx_l =  -0.001,}}}
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."EADI/EADI_R_init.lua",nil,{{"READI_center","READI_down","READI_right"},{sx_l =  -0.001,}}}
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."EADI/EADI_L_On_init.lua",nil,{{"LEAD_center","LAEDI_down","LEAD_right"},{sx_l =  -0.0012,}}}

indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."ERPM/ERPM_init.lua",nil,{{"LN2_center","LN2_down","LN2_right"},{sx_l =  -0.0001,}}}
-- NS430
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."NS430/NS430_init.lua",nil,{{"GPS_center","GPS_down","GPS_right"},{sx_l =  -0.001,}}}
-- HUD
-- indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."HUD/Indicator/hud_init.lua",nil,{{"HUD_Center","HUD_Down","HUD_Right"}}}
-- RADAR RAW DISPLAY
-- indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."avRadar/indicator/init.lua",nil,{{},{sz_l = 0.0,sx_l = -0.50, sy_l = -0.1},1}}		
--RADAROFF indicators[#indicators + 1] = {"ccIndicator",LockOn_Options.script_path.."RADAR/Indicator/init.lua",--init script
--RADAROFF   nil,--id of parent device
--RADAROFF   {
--RADAROFF 	{}, -- initial geometry anchor , triple of connector names 
--RADAROFF 	{sx_l =  0,  -- center position correction in meters (forward , backward)1
--RADAROFF 	 sy_l =  0,  -- center position correction in meters (up , down)
--RADAROFF 	 sz_l =  0.3,  -- center position correction in meters (left , right)
--RADAROFF 	 sh   =  0,  -- half height correction
--RADAROFF 	 sw   =  0,  -- half width correction
--RADAROFF 	 rz_l =  0,  -- rotation corrections
--RADAROFF 	 rx_l =  0,
--RADAROFF 	 ry_l =  0}
--RADAROFF   }
--RADAROFF }


-- Enable KneeBoard for Test
dofile(LockOn_Options.common_script_path.."KNEEBOARD/declare_kneeboard_device.lua")