dofile(LockOn_Options.script_path.."devices.lua")
dofile(LockOn_Options.script_path.."materials.lua") -- Load material

-- set panel
-- Initialize the cabin instrument panel
MainPanel = {"ccMainPanel",LockOn_Options.script_path.."mainpanel_init.lua"}

creators  = {}
creators[devices.MULTICREW] = {"avLuaDevice", LockOn_Options.script_path.."Multicrew/device.lua"}

-- NAV system
creators[devices.NAV_SYSTEM] = { "avLuaDevice", LockOn_Options.script_path.."Systems/nav_system.lua"}
-- Basic power module
creators[devices.ELECTRIC_SYSTEM] ={"avSimpleElectricSystem",LockOn_Options.script_path.."Systems/electric_system.lua"}
-- Control plane module
--creators[devices.PRISURFACE]      ={"avLuaDevice"           ,LockOn_Options.script_path.."priControlSurface.lua"}
-- Hatch, the simplest single monitoring module
creators[devices.CANOPY]          ={"avLuaDevice"           ,LockOn_Options.script_path.."Systems/canopy.lua"}
-- Brakes include air brakes, which mainly depend on the dispatch action of the braking system.
creators[devices.BREAK_SYSTEM]    ={"avLuaDevice"           ,LockOn_Options.script_path.."Systems/break_system.lua"}
-- weapon module
creators[devices.WEAPON_SYSTEM]	  ={"avSimpleWeaponSystem"  ,LockOn_Options.script_path.."Systems/weapon_system.lua"}
-- These two are for calling ground staff
creators[devices.INTERCOM]        ={"avIntercom"            ,LockOn_Options.script_path.."Intercom.lua", {devices.UHF_RADIO, devices.VHF_RADIO} }
creators[devices.UHF_RADIO]       ={"avUHF_ARC_164"         ,LockOn_Options.script_path.."uhf_radio.lua", {devices.INTERCOM, devices.ELECTRIC_SYSTEM} }
creators[devices.FR31_RADIO]      ={"avLuaDevice"           ,LockOn_Options.script_path.."Systems/fr31_radio.lua"}
creators[devices.VHF_RADIO]       ={"avUHF_ARC_164"         ,LockOn_Options.script_path.."vhf_radio.lua", {devices.INTERCOM, devices.ELECTRIC_SYSTEM} }
creators[devices.FR33_RADIO]      ={"avLuaDevice"           ,LockOn_Options.script_path.."Systems/fr33_radio.lua"}
creators[devices.TRANSPONDER]     ={"avLuaDevice"           ,LockOn_Options.script_path.."Systems/transponder.lua"}
-- radar module
creators[devices.RADAR_RAW]		  ={"avSimpleRadar"			,LockOn_Options.script_path.."avRadar/Device/Radar_init.lua"}
-- hud Display processor
creators[devices.HUD_DCMS]        ={"avLuaDevice"           ,LockOn_Options.script_path.."Systems/dcms_hud.lua"}
-- Basic instrument, including an array that I encapsulated to process instrument animation and update function can simplify basic flight instrument drawing
creators[devices.BASIC_FLIGHT_INS]={"avLuaDevice"           ,LockOn_Options.script_path.."Systems/basic_flight_instru.lua"}
-- Clock system, including reading system time (in-game task time
creators[devices.CLOCK]           ={"avLuaDevice"           ,LockOn_Options.script_path.."aviation_clock.lua"}
--
creators[devices.GEAR_SYSTEM]     ={"avLuaDevice"           ,LockOn_Options.script_path.."Systems/gear_system.lua"}

creators[devices.LIGHT_SYSTEM]    ={"avLuaDevice"           ,LockOn_Options.script_path.."Systems/light_system.lua"}
-- this is 14, dont move this position for now XD, the command from EFM is constant send to lua device 14
creators[devices.SOUND_SYSTEM]    ={"avLuaDevice"           ,LockOn_Options.script_path.."Systems/sound_system.lua"}
-- warning panel controller
creators[devices.WARNING_SYSTEM]  ={"avLuaDevice"           ,LockOn_Options.script_path.."Systems/warning_system.lua"}
-- ipad controller
--creators[devices.IPAD_SYSTEM]     ={"avLuaDevice"           ,LockOn_Options.script_path.."Systems/ipad_ctrl.lua"}
-- menu controller
creators[devices.MENU_SYSTEM]     ={"avLuaDevice"           ,LockOn_Options.script_path.."Systems/menu_ctrl_system.lua"}
-- gps_receiver & the uplink databus to EFM
creators[devices.UP_LINK]         ={"avLuaDevice"           ,LockOn_Options.script_path.."Systems/gps_receiver.lua"}
creators[devices.MISCELANIOUS]     ={"avLuaDevice"            ,LockOn_Options.script_path.."Systems/miscelanious.lua"}
creators[devices.animations]     		={"avLuaDevice"            ,LockOn_Options.script_path.."Systems/animations.lua"}
creators[devices.gunsight]              = {"avLuaDevice", LockOn_Options.script_path .. "GunSight/Device/Gunsight.lua"}
-- Define display
-- Indicators
indicators = {}

-- EADI left
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."EADI/EADI_L_init.lua",nil,{{"LEADI_center","LEADI_down","LEADI_right"},{sx_l =  -0.001,}}}
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."EADI/EADI_R_init.lua",nil,{{"READI_center","READI_down","READI_right"},{sx_l =  -0.001,}}}
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."EADI/EADI_L_On_init.lua",nil,{{"LEADI_center","LEADI_down","LEADI_right"},{sx_l =  -0.0012,}}}

-- ERPM
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."ERPM/ERPM_init.lua",nil,{{"LN2_center","LN2_down","LN2_right"},{sx_l =  -0.0001,}}}
-- N1 RPM display left
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."N1RPM/N1RPM_L_init.lua",nil,{{"N1L_center","N1L_down","N1L_right"},{sx_l =  -0.0001,}}}
-- N1 RPM display right
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."N1RPM/N1RPM_R_init.lua",nil,{{"N1R_center","N1R_down","N1R_right"},{sx_l =  -0.0001,}}}
-- ITT display left
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."ITT/ITT_L_init.lua",nil,{{"ITTL_center","ITTL_down","ITTL_right"},{sx_l =  -0.0001,}}}
-- ITT display right
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."ITT/ITT_R_init.lua",nil,{{"ITTR_center","ITTR_down","ITTR_right"},{sx_l =  -0.0001,}}}
-- TRIM display
--indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."ETRIM/ETRIM_init.lua",nil,{{"T60DISPLAY_center","T60DISPLAY_down","T60DISPLAY_right"},{sx_l =  -0.0001,}}}
-- Legacy display indicators were removed from the active cockpit stack.
-- Radio display
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."RSGB6500/Radio_init.lua",nil,{{"T60DISPLAY_center","T60DISPLAY_down","T60DISPLAY_right"},{sx_l =  -0.0001,}}}--{{"COM1_center","COM1_down","COM1_right"}}
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."FR31/FR31_init.lua",nil,{{"FR31_center","FR31_down","FR31_right"},{sx_l =  -0.0001,}}}
-- RNAV display
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."RNAV/RNAV_init.lua",nil,{{"RNAV_center","RNAV_down","RNAV_right"},{sx_l =  -0.0001,}}}
-- ADF display
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."ADF/ADF_init.lua",nil,{{"ADF_center","ADF_down","ADF_right"},{sx_l =  -0.0001,}}}
-- DME display
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."DME/DME_init.lua",nil,{{"DME_center","DME_down","DME_right"},{sx_l =  -0.0001,}}}
-- HUD indicator was moved out/combined into CustomMenu; keep this disabled to avoid missing-file crash.
--indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."HUD/Indicator/hud_init.lua",nil,{{"hud_center","hud_down","hud_right"}}}
--Gunsight display
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."GunSight/gunsight_init.lua",nil,{{"hud_center","hud_down","hud_right"}}}
-- warning panel disabled as all moved to the animation
-- indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."EWarningPanel/warning_init.lua",nil,{{"WarningPanel_center","WarningPanel_down","WarningPanel_right"}}}
-- debug ipad
--indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."DBGiPad/ipad_init.lua",nil,{{"IPAD_center","IPAD_down","IPAD_right"},{sx_l =  -0.001,}}}
-- custom menu indicator
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."CustomMenu/menu_init.lua",nil,{{}, {sh = 0.5, sw = 0.5}, 4}}
-- Player-view tinted visor overlay
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."VisorEffect/visor_init.lua", nil}


-- Enable KneeBoard for Test
dofile(LockOn_Options.common_script_path.."KNEEBOARD/declare_kneeboard_device.lua")
