local cscripts = folder.."../../../Cockpit/Scripts/"
dofile(cscripts.."devices.lua")
dofile(cscripts.."command_defs.lua")

local kneeboard_id = 100
if devices and devices.KNEEBOARD then
	kneeboard_id = devices.KNEEBOARD
end

return {
    keyCommands = {
    
    -- Debug
    {combos = {{key = '`', reformers = {'LAlt'}}},		down = ICommandToggleConsole,	name = _('Toggle Console'),		category = _('Debug')},
    
    -- General (Gameplay)
    {combos = {{key = '\''}},										down = iCommandScoresWindowToggle,				name = _('Score window'),							category = _('General')},
    
    {combos = {{key = 'Y',	 reformers = {'LCtrl'}}},				down = iCommandInfoOnOff,						name = _('Info bar view toggle'),					category = _('General')},
    {combos = {{key = 'Tab', reformers = {'RCtrl', 'RShift'}}},		down = iCommandRecoverHuman,					name = _('Get new plane - respawn'),				category = _('General')},
    {combos = {{key = 'J',	 reformers = {'RAlt'}}},				down = iCommandPlaneJump,						name = _('Jump into selected aircraft'),			category = _('General')},
    {combos = {{key = 'SysRQ'}},									down = iCommandScreenShot,						name = _('Screenshot'),								category = _('General'), disabled = true},
    {combos = {{key = 'Y',	 reformers = {'LAlt'}}},				down = iCommandViewCoordinatesInLinearUnits,	name = _('Info bar coordinate units toggle'),		category = _('General')},
    {combos = {{key = 'C',	 reformers = {'LAlt'}}},				down = iCommandCockpitClickModeOnOff,			name = _('Clickable mouse cockpit mode On/Off'),	category = _('General')},
    {combos = {{key = 'S',	 reformers = {'LCtrl'}}},				down = iCommandSoundOnOff,						name = _('Sound On/Off'),							category = _('General')},
    {combos = {{key = '\'',	 reformers = {'LAlt'}}}, 				down = iCommandMissionResourcesManagement,		name = _('Rearming and Refueling Window'),			category = _('General')},
    {combos = {{key = 'B',	 reformers = {'LAlt'}}},				down = iCommandViewBriefing,					name = _('View briefing on/off'),					category = _('General')},
    {combos = {{key = 'Pause', reformers = {'LShift', 'LWin'}}},	down = iCommandActivePauseOnOff,				name = _('Active Pause'),							category = _('Cheat')},
    {combos = {{key = 'Enter', reformers = {'RCtrl'}}},				down = iCommandPlane_ShowControls,				name = _('Show controls indicator'),				category = _('General')},
    
    -- Communications
    {combos = {{key = 'E', reformers = {'LWin'}}},					down = iCommandPlaneDoAndHome,					name = _('Flight - Complete mission and RTB'),		category = _('Communications')},
    {																down = iCommandPlaneReturnToBase,				name = _('Flight - RTB'),							category = _('Communications')},
    {combos = {{key = 'R', reformers = {'LWin'}}},					down = iCommandPlaneDoAndBack,					name = _('Flight - Complete mission and rejoin'),	category = _('Communications')},
    {combos = {{key = 'T', reformers = {'LWin'}}},					down = iCommandPlaneFormation,					name = _('Toggle Formation'),						category = _('Communications')},
    {combos = {{key = 'Y', reformers = {'LWin'}}},					down = iCommandPlaneJoinUp,						name = _('Join Up Formation'),						category = _('Communications')},
    {combos = {{key = 'Q', reformers = {'LWin'}}},					down = iCommandPlaneAttackMyTarget,				name = _('Attack My Target'),						category = _('Communications')},
    {combos = {{key = 'W', reformers = {'LWin'}}},					down = iCommandPlaneCoverMySix,					name = _('Cover Me'),								category = _('Communications')},
    {combos = {{key = 'U', reformers = {'LWin'}}},					down = iCommandAWACSHomeBearing,				name = _('Request AWACS Home Airbase'),				category = _('Communications')},
    {combos = {{key = 'O', reformers = {'LWin'}}},					down = iCommandAWACSBanditBearing,				name = _('Request AWACS Bogey Dope'),				category = _('Communications'), features = {"AWACS Bogey Dope"}},
    {combos = {{key = 'G', reformers = {'LWin'}}},					down = iCommandPlane_EngageGroundTargets,		name = _('Flight - Attack ground targets'),			category = _('Communications')},
    {combos = {{key = 'D', reformers = {'LWin'}}},					down = iCommandPlane_EngageAirDefenses,			name = _('Flight - Attack air defenses'),			category = _('Communications')},
    {combos = {{key = 'B', reformers = {'LWin'}}},					down = iCommandPlane_EngageBandits,				name = _('Flight - Engage Bandits'),				category = _('Communications')},
    {combos = {{key = '\\'}},										down = iCommandToggleCommandMenu,				name = _('Communication menu'),						category = _('Communications')},
    {combos = {{key = '\\', reformers = {'LShift'}}},				down = ICommandSwitchDialog,					name = _('Switch dialog'),							category = _('Communications')},
    {combos = {{key = '\\', reformers = {'LCtrl'}}},				down = ICommandSwitchToCommonDialog,			name = _('Switch to main menu'),					category = _('Communications')},
    
    -- View
    {combos = {{key = 'Num4'}},								pressed = iCommandViewLeftSlow,			up = iCommandViewStopSlow,				name = _('View Left slow'),										category = _('View')},
    {combos = {{key = 'Num6'}},								pressed = iCommandViewRightSlow,		up = iCommandViewStopSlow,				name = _('View Right slow'),									category = _('View')},
    {combos = {{key = 'Num8'}},								pressed = iCommandViewUpSlow,			up = iCommandViewStopSlow,				name = _('View Up slow'),										category = _('View')},
    {combos = {{key = 'Num2'}},								pressed = iCommandViewDownSlow,			up = iCommandViewStopSlow,				name = _('View Down slow'),										category = _('View')},
    {combos = {{key = 'Num9'}},								pressed = iCommandViewUpRightSlow,		up = iCommandViewStopSlow,				name = _('View Up Right slow'),									category = _('View')},
    {combos = {{key = 'Num3'}},								pressed = iCommandViewDownRightSlow,	up = iCommandViewStopSlow,				name = _('View Down Right slow'),								category = _('View')},
    {combos = {{key = 'Num1'}},								pressed = iCommandViewDownLeftSlow,		up = iCommandViewStopSlow,				name = _('View Down Left slow'),								category = _('View')},
    {combos = {{key = 'Num7'}},								pressed = iCommandViewUpLeftSlow,		up = iCommandViewStopSlow,				name = _('View Up Left slow'),									category = _('View')},
    {combos = {{key = 'Num5'}},								pressed = iCommandViewCenter,													name = _('View Center'),										category = _('View')},
    
    {combos = {{key = 'Num*'}},								pressed = iCommandViewForwardSlow,		up = iCommandViewForwardSlowStop,		name = _('Zoom in slow'),										category = _('View')},
    {combos = {{key = 'Num/'}},								pressed = iCommandViewBackSlow,			up = iCommandViewBackSlowStop,			name = _('Zoom out slow'),										category = _('View')},
    {combos = {{key = 'NumEnter'}},							down = iCommandViewAngleDefault,												name = _('Zoom normal'),										category = _('View')},
    {combos = {{key = 'Num*', reformers = {'RCtrl'}}},		pressed = iCommandViewExternalZoomIn,	up = iCommandViewExternalZoomInStop,	name = _('Zoom external in'),									category = _('View')},
    {combos = {{key = 'Num/', reformers = {'RCtrl'}}},		pressed = iCommandViewExternalZoomOut,	up = iCommandViewExternalZoomOutStop,	name = _('Zoom external out'),									category = _('View')},
    {combos = {{key = 'NumEnter', reformers = {'RCtrl'}}},	down = iCommandViewExternalZoomDefault,											name = _('Zoom external normal'),								category = _('View')},
    {combos = {{key = 'Num*', reformers = {'LAlt'}}},		down = iCommandViewSpeedUp,														name = _('F11 Camera moving forward'),							category = _('View')},
    {combos = {{key = 'Num/', reformers = {'LAlt'}}},		down = iCommandViewSlowDown,													name = _('F11 Camera moving backward'),							category = _('View')},
    
    {combos = {{key = 'F1'}},								down = iCommandViewCockpit,														name = _('F1 Cockpit view'),									category = _('View')},
    {combos = {{key = 'F1', reformers = {'LCtrl'}}},		down = iCommandNaturalViewCockpitIn,											name = _('F1 Natural head movement view'),						category = _('View')},
    {combos = {{key = 'F1', reformers = {'LAlt'}}},			down = iCommandViewHUDOnlyOnOff,												name = _('F1 HUD only view switch'),							category = _('View')},
    {combos = {{key = 'F2'}},								down = iCommandViewAir,															name = _('F2 Aircraft view'),									category = _('View')},
    {combos = {{key = 'F2', reformers = {'LCtrl'}}},		down = iCommandViewMe,															name = _('F2 View own aircraft'),								category = _('View')},
    {combos = {{key = 'F2', reformers = {'RAlt'}}},			down = iCommandViewFromTo,														name = _('F2 Toggle camera position'),							category = _('View')},
    {combos = {{key = 'F2', reformers = {'LAlt'}}},			down = iCommandViewLocal,														name = _('F2 Toggle local camera control'),						category = _('View')},
    {combos = {{key = 'F3'}},								down = iCommandViewTower,														name = _('F3 Fly-By view'),										category = _('View')},
    {combos = {{key = 'F3', reformers = {'LCtrl'}}},		down = iCommandViewTowerJump,													name = _('F3 Fly-By jump view'),								category = _('View')},
    {combos = {{key = 'F4'}},								down = iCommandViewRear,														name = _('F4 Look back view'),									category = _('View')},
    {combos = {{key = 'F4', reformers = {'LCtrl'}}},		down = iCommandViewChase,														name = _('F4 Chase view'),										category = _('View')},
    {combos = {{key = 'F4', reformers = {'LShift'}}},		down = iCommandViewChaseArcade,													name = _('F4 Arcade Chase view'),								category = _('View')},
    {combos = {{key = 'F5'}},								down = iCommandViewFight,														name = _('F5 nearest AC view'),									category = _('View')},
    {combos = {{key = 'F5', reformers = {'LCtrl'}}},		down = iCommandViewFightGround,													name = _('F5 Ground hostile view'),								category = _('View')},
    {combos = {{key = 'F6'}},								down = iCommandViewWeapons,														name = _('F6 Released weapon view'),							category = _('View')},
    {combos = {{key = 'F6', reformers = {'LCtrl'}}},		down = iCommandViewWeaponAndTarget,												name = _('F6 Weapon to target view'),							category = _('View')},
    {combos = {{key = 'F7'}},								down = iCommandViewGround,														name = _('F7 Ground unit view'),								category = _('View')},
    --{combos = {{key = 'F8'}},								down = iCommandViewTargets,														name = _('F8 Target view'),										category = _('View')},
    --{combos = {{key = 'F8', reformers = {'RCtrl'}}},		down = iCommandViewTargetType,													name = _('F8 Player targets/All targets filter'),				category = _('View')},
    {combos = {{key = 'F9'}},								down = iCommandViewNavy,														name = _('F9 Ship view'),										category = _('View')},
    {combos = {{key = 'F9', reformers = {'LAlt'}}},			down = iCommandViewLndgOfficer,													name = _('F9 Landing signal officer view'),						category = _('View')},
    {combos = {{key = 'F10'}},								down = iCommandViewAWACS,														name = _('F10 Theater map view'),								category = _('View')},
    {combos = {{key = 'F10', reformers = {'LCtrl'}}},		down = iCommandViewAWACSJump,													name = _('F10 Jump to theater map view over current point'),	category = _('View')},
    {combos = {{key = 'F11'}},								down = iCommandViewFree,														name = _('F11 Airport free camera'),							category = _('View')},
    {combos = {{key = 'F11', reformers = {'LCtrl'}}},		down = iCommandViewFreeJump,													name = _('F11 Jump to free camera'),							category = _('View')},
    {combos = {{key = 'F12'}},								down = iCommandViewStatic,														name = _('F12 Static object view'),								category = _('View')},
    {combos = {{key = 'F12', reformers = {'LCtrl'}}},		down = iCommandViewMirage,														name = _('F12 Civil traffic view'),								category = _('View')},
    {combos = {{key = 'F12', reformers = {'LShift'}}},		down = iCommandViewLocomotivesToggle,											name = _('F12 Trains/cars toggle'),								category = _('View')},
    {combos = {{key = 'F1', reformers = {'LWin'}}},			down = iCommandViewPitHeadOnOff,												name = _('F1 Head shift movement on / off'),					category = _('View')},
    
    
    
    -- Experimental object free camera
    {combos = {{key = 'F2', reformers = {'RCtrl'}}}, 		down = iCommandViewObject, name = _('Object free camera'), category = _('View')},
    {combos = {{key = '=', reformers = {'RCtrl', 'RAlt', 'RShift'}}}, 			down = iCommandViewBookmarksEditor, name = _('Object free camera bookmarks editor'), category = _('View')},
    {combos = {{key = '-', reformers = {'RCtrl', 'RAlt', 'RShift'}}}, 			down = iCommandViewBookmarksMenu, name = _('Object free camera bookmarks menu'), category = _('View')},
    --{combos = {{key = 'O', reformers = {'RCtrl', 'RAlt', 'RShift'}}}, 			down = iCommandViewPieMenu, name = _('Pie menu'), category = _('View')},
    -- Experimental wingman camera
    {combos = {{key = 'F4', reformers = {'LAlt'}}}, 		down = iCommandViewWingman, name = _('Wingman camera'), category = _('View')},
    -- Aircraft carrier cameras
    {combos = {{key = 'F9', reformers = {'RCtrl'}}}, 		down = iCommandViewCatapult		 , name = _('Aircraft carrier catapult camera'), category = _('View')},
    {combos = {{key = 'F9', reformers = {'RCtrl', 'RAlt'}}}, 		down = iCommandViewCatapultCrew, name = _('Aircraft carrier catapult crew camera'),	category = _('View')},
    -- Camera position to/from clipboard 
    {combos = {{key = ',', reformers = {'RAlt', 'RCtrl'}}}, 			down = iCommandViewCameraToClipboard, name = _('Unload camera position to clipboard'), category = _('View')},
    {combos = {{key = '.', reformers = {'RAlt', 'RCtrl'}}}, 			down = iCommandViewClipboardToCamera, name = _('Load camera position from clipboard'), category = _('View')},
    
    {combos = {{key = ']', reformers = {'LShift'}}},		down = iCommandViewFastKeyboard,												name = _('Keyboard Rate Fast'),									category = _('View')},
    {combos = {{key = ']', reformers = {'LCtrl'}}},			down = iCommandViewSlowKeyboard,												name = _('Keyboard Rate Slow'),									category = _('View')},
    {combos = {{key = ']', reformers = {'LAlt'}}},			down = iCommandViewNormalKeyboard,												name = _('Keyboard Rate Normal'),								category = _('View')},
    {combos = {{key = '[', reformers = {'LShift'}}},		down = iCommandViewFastMouse,													name = _('Mouse Rate Fast'),									category = _('View')},
    {combos = {{key = '[', reformers = {'LCtrl'}}},			down = iCommandViewSlowMouse,													name = _('Mouse Rate Slow'),									category = _('View')},
    {combos = {{key = '[', reformers = {'LAlt'}}},			down = iCommandViewNormalMouse,													name = _('Mouse Rate Normal'),									category = _('View')},
    
    -- Cockpit view
    {combos = {{key = 'L', reformers = {'LAlt'}}},				down = 3256,	cockpit_device_id = 0,	value_down = 1.0,						name = _('Flashlight'),						category = _('View Cockpit')},
    --{combos = {{key = 'P', reformers = {'RShift'}}},			down = iCommandCockpitShowPilotOnOff, 											name = _('Toggle Pilot'), 					category = _('View Cockpit')},
    {combos = {{key = 'Num0'}},									down = iCommandViewTempCockpitOn,		up = iCommandViewTempCockpitOff,		name = _('Cockpit panel view in'),			category = _('View Cockpit')},
    {combos = {{key = 'Num0', reformers = {'RCtrl'}}},			down = iCommandViewTempCockpitToggle,											name = _('Cockpit panel view toggle'),		category = _('View Cockpit')},
    --// Save current cockpit camera angles for fast numpad jumps
    {combos = {{key = 'Num0', reformers = {'RAlt'}}},			down = iCommandViewSaveAngles,													name = _('Save Cockpit Angles'),			category = _('View Cockpit')},
    {combos = {{key = 'Num8', reformers = {'RShift'}}},			pressed = iCommandViewUp,					up = iCommandViewStop,				name = _('View up'),						category = _('View Cockpit')},
    {combos = {{key = 'Num2', reformers = {'RShift'}}},			pressed = iCommandViewDown,					up = iCommandViewStop,				name = _('View down'),						category = _('View Cockpit')},
    {combos = {{key = 'Num4', reformers = {'RShift'}}},			pressed = iCommandViewLeft,					up = iCommandViewStop,				name = _('View left'),						category = _('View Cockpit')},
    {combos = {{key = 'Num6', reformers = {'RShift'}}},			pressed = iCommandViewRight,				up = iCommandViewStop,				name = _('View right'),						category = _('View Cockpit')},
    {combos = {{key = 'Num9', reformers = {'RShift'}}},			pressed = iCommandViewUpRight,				up = iCommandViewStop,				name = _('View up right'),					category = _('View Cockpit')},
    {combos = {{key = 'Num3', reformers = {'RShift'}}},			pressed = iCommandViewDownRight,			up = iCommandViewStop,				name = _('View down right'),				category = _('View Cockpit')},
    {combos = {{key = 'Num1', reformers = {'RShift'}}},			pressed = iCommandViewDownLeft,				up = iCommandViewStop,				name = _('View down left'),					category = _('View Cockpit')},
    {combos = {{key = 'Num7', reformers = {'RShift'}}},			pressed = iCommandViewUpLeft,				up = iCommandViewStop,				name = _('View up left'),					category = _('View Cockpit')},
    
    -- Cockpit Camera Motion (������������ ������ � ������)
    {combos = {{key = 'Num8', reformers = {'RCtrl','RShift'}}},	pressed = iCommandViewPitCameraMoveUp,		up = iCommandViewPitCameraMoveStop,	name = _('Cockpit Camera Move Up'),			category = _('View Cockpit')},
    {combos = {{key = 'Num2', reformers = {'RCtrl','RShift'}}},	pressed = iCommandViewPitCameraMoveDown,	up = iCommandViewPitCameraMoveStop,	name = _('Cockpit Camera Move Down'),		category = _('View Cockpit')},
    {combos = {{key = 'Num4', reformers = {'RCtrl','RShift'}}},	pressed = iCommandViewPitCameraMoveLeft,	up = iCommandViewPitCameraMoveStop,	name = _('Cockpit Camera Move Left'),		category = _('View Cockpit')},
    {combos = {{key = 'Num6', reformers = {'RCtrl','RShift'}}},	pressed = iCommandViewPitCameraMoveRight,	up = iCommandViewPitCameraMoveStop,	name = _('Cockpit Camera Move Right'),		category = _('View Cockpit')},
    {combos = {{key = 'Num*', reformers = {'RCtrl','RShift'}}},	pressed = iCommandViewPitCameraMoveForward,	up = iCommandViewPitCameraMoveStop,	name = _('Cockpit Camera Move Forward'),	category = _('View Cockpit')},
    {combos = {{key = 'Num/', reformers = {'RCtrl','RShift'}}, {key = 'Num-', reformers = {'RCtrl','RShift'}}},	pressed = iCommandViewPitCameraMoveBack,	up = iCommandViewPitCameraMoveStop,	name = _('Cockpit Camera Move Back'),	category = _('View Cockpit')},
    {combos = {{key = 'Num5', reformers = {'RCtrl','RShift'}}},	down = iCommandViewPitCameraMoveCenter,											name = _('Cockpit Camera Move Center'),		category = _('View Cockpit')},
    
    {combos = {{key = 'Num8', reformers = {'RCtrl'}}},			down = iCommandViewCameraUp,				up = iCommandViewCameraCenter,		name = _('Glance up'),						category = _('View Cockpit')},
    {combos = {{key = 'Num2', reformers = {'RCtrl'}}},			down = iCommandViewCameraDown,				up = iCommandViewCameraCenter,		name = _('Glance down'),					category = _('View Cockpit')},
    {combos = {{key = 'Num4', reformers = {'RCtrl'}}},			down = iCommandViewCameraLeft,				up = iCommandViewCameraCenter,		name = _('Glance left'),					category = _('View Cockpit')},
    {combos = {{key = 'Num6', reformers = {'RCtrl'}}},			down = iCommandViewCameraRight,				up = iCommandViewCameraCenter,		name = _('Glance right'),					category = _('View Cockpit')},
    {combos = {{key = 'Num7', reformers = {'RCtrl'}}},			down = iCommandViewCameraUpLeft,			up = iCommandViewCameraCenter,		name = _('Glance up-left'),					category = _('View Cockpit')},
    {combos = {{key = 'Num1', reformers = {'RCtrl'}}},			down = iCommandViewCameraDownLeft,			up = iCommandViewCameraCenter,		name = _('Glance down-left'),				category = _('View Cockpit')},
    {combos = {{key = 'Num9', reformers = {'RCtrl'}}},			down = iCommandViewCameraUpRight,			up = iCommandViewCameraCenter,		name = _('Glance up-right'),				category = _('View Cockpit')},
    {combos = {{key = 'Num3', reformers = {'RCtrl'}}},			down = iCommandViewCameraDownRight,			up = iCommandViewCameraCenter,		name = _('Glance down-right'),				category = _('View Cockpit')},
    {combos = {{key = 'Z', reformers = {'LAlt','LShift'}}},		down = iCommandViewPanToggle,													name = _('Camera pan mode toggle'),			category = _('View Cockpit')},
    
    {combos = {{key = 'Num8', reformers = {'RAlt'}}},			down = iCommandViewCameraUpSlow,												name = _('Camera snap view up'),			category = _('View Cockpit')},
    {combos = {{key = 'Num2', reformers = {'RAlt'}}},			down = iCommandViewCameraDownSlow,												name = _('Camera snap view down'),			category = _('View Cockpit')},
    {combos = {{key = 'Num4', reformers = {'RAlt'}}},			down = iCommandViewCameraLeftSlow,												name = _('Camera snap view left'),			category = _('View Cockpit')},
    {combos = {{key = 'Num6', reformers = {'RAlt'}}},			down = iCommandViewCameraRightSlow,												name = _('Camera snap view right'),			category = _('View Cockpit')},
    {combos = {{key = 'Num7', reformers = {'RAlt'}}},			down = iCommandViewCameraUpLeftSlow,											name = _('Camera snap view up-left'),		category = _('View Cockpit')},
    {combos = {{key = 'Num1', reformers = {'RAlt'}}},			down = iCommandViewCameraDownLeftSlow,											name = _('Camera snap view down-left'),		category = _('View Cockpit')},
    {combos = {{key = 'Num9', reformers = {'RAlt'}}},			down = iCommandViewCameraUpRightSlow,											name = _('Camera snap view up-right'),		category = _('View Cockpit')},
    {combos = {{key = 'Num3', reformers = {'RAlt'}}},			down = iCommandViewCameraDownRightSlow,											name = _('Camera snap view down-right'),	category = _('View Cockpit')},
    {combos = {{key = 'Num5', reformers = {'RShift'}}},			down = iCommandViewCameraCenter,												name = _('Center Camera View'),				category = _('View Cockpit')},
    {combos = {{key = 'Num5', reformers = {'RCtrl'}}},			down = iCommandViewCameraReturn,												name = _('Return Camera'),					category = _('View Cockpit')},
    {combos = {{key = 'Num5', reformers = {'RAlt'}}},			down = iCommandViewCameraBaseReturn,											name = _('Return Camera Base'),				category = _('View Cockpit')},
    
    {combos = {{key = 'Num0', reformers = {'LWin'}}},			down = iCommandViewSnapView0,				up = iCommandViewSnapViewStop,		name = _('Custom Snap View  0'),			category = _('View Cockpit')},
    {combos = {{key = 'Num1', reformers = {'LWin'}}},			down = iCommandViewSnapView1,				up = iCommandViewSnapViewStop,		name = _('Custom Snap View  1'),			category = _('View Cockpit')},
    {combos = {{key = 'Num2', reformers = {'LWin'}}},			down = iCommandViewSnapView2,				up = iCommandViewSnapViewStop,		name = _('Custom Snap View  2'),			category = _('View Cockpit')},
    {combos = {{key = 'Num3', reformers = {'LWin'}}},			down = iCommandViewSnapView3,				up = iCommandViewSnapViewStop,		name = _('Custom Snap View  3'),			category = _('View Cockpit')},
    {combos = {{key = 'Num4', reformers = {'LWin'}}},			down = iCommandViewSnapView4,				up = iCommandViewSnapViewStop,		name = _('Custom Snap View  4'),			category = _('View Cockpit')},
    {combos = {{key = 'Num5', reformers = {'LWin'}}},			down = iCommandViewSnapView5,				up = iCommandViewSnapViewStop,		name = _('Custom Snap View  5'),			category = _('View Cockpit')},
    {combos = {{key = 'Num6', reformers = {'LWin'}}},			down = iCommandViewSnapView6,				up = iCommandViewSnapViewStop,		name = _('Custom Snap View  6'),			category = _('View Cockpit')},
    {combos = {{key = 'Num7', reformers = {'LWin'}}},			down = iCommandViewSnapView7,				up = iCommandViewSnapViewStop,		name = _('Custom Snap View  7'),			category = _('View Cockpit')},
    {combos = {{key = 'Num8', reformers = {'LWin'}}},			down = iCommandViewSnapView8,				up = iCommandViewSnapViewStop,		name = _('Custom Snap View  8'),			category = _('View Cockpit')},
    {combos = {{key = 'Num9', reformers = {'LWin'}}},			down = iCommandViewSnapView9,				up = iCommandViewSnapViewStop,		name = _('Custom Snap View  9'),			category = _('View Cockpit')},
    
    {combos = {{key = 'Num*', reformers = {'RShift'}}},			pressed = iCommandViewForward,				up = iCommandViewForwardStop,		name = _('Zoom in'),						category = _('View Cockpit')},
    {combos = {{key = 'Num/', reformers = {'RShift'}}},			pressed = iCommandViewBack,					up = iCommandViewBackStop,			name = _('Zoom out'),						category = _('View Cockpit')},
    
    -- Extended view
    {combos = {{key = 'J', reformers = {'LShift'}}},			down = iCommandViewCameraJiggle,	name = _('Camera jiggle toggle'),					category = _('View Extended'), features = {"Camera jiggle"}},
    {combos = {{key = 'K', reformers = {'LAlt'}}},				down = iCommandViewKeepTerrain,		name = _('Keep terrain camera altitude'),			category = _('View Extended')},
    {combos = {{key = 'Home', reformers = {'RCtrl','RShift'}}},	down = iCommandViewFriends,			name = _('View friends mode'),						category = _('View Extended')},
    {combos = {{key = 'End', reformers = {'RCtrl','RShift'}}},	down = iCommandViewEnemies,			name = _('View enemies mode'),						category = _('View Extended')},
    {combos = {{key = 'Delete', reformers = {'RCtrl'}}},		down = iCommandViewAll,				name = _('View all mode'),							category = _('View Extended')},
    {combos = {{key = 'Num+', reformers = {'RCtrl'}}},			down = iCommandViewPlus,			name = _('Toggle tracking launched weapon'),		category = _('View Extended')},
    {combos = {{key = 'PageDown', reformers = {'LCtrl'}}},		down = iCommandViewSwitchForward,	name = _('Objects switching direction forward '),	category = _('View Extended')},
    {combos = {{key = 'PageUp', reformers = {'LCtrl'}}},		down = iCommandViewSwitchReverse,	name = _('Objects switching direction reverse '),	category = _('View Extended')},
    {combos = {{key = 'Delete', reformers = {'LAlt'}}},			down = iCommandViewObjectIgnore,	name = _('Object exclude '),						category = _('View Extended')},
    {combos = {{key = 'Insert', reformers = {'LAlt'}}},			down = iCommandViewObjectsAll,		name = _('Objects all excluded - include'),			category = _('View Extended')},
    
    -- Padlock
    {combos = {{key = 'Num.'}},							down = iCommandViewLock,				name = _('Lock View (cycle padlock)'),	category = _('View Padlock')},
    {combos = {{key = 'NumLock'}},						down = iCommandViewUnlock,				name = _('Unlock view (stop padlock)'),	category = _('View Padlock')},
    {combos = {{key = 'Num.', reformers = {'RShift'}}},	down = iCommandAllMissilePadlock,		name = _('All missiles padlock'),		category = _('View Padlock')},
    {combos = {{key = 'Num.', reformers = {'RAlt'}}},	down = iCommandThreatMissilePadlock,	name = _('Threat missile padlock'),		category = _('View Padlock')},
    {combos = {{key = 'Num.', reformers = {'RCtrl'}}},	down = iCommandViewTerrainLock,			name = _('Lock terrain view'),			category = _('View Padlock')},
    
    -- Labels
    {combos = {{key = 'F10', reformers = {'LShift'}}},	down = iCommandMarkerState,				name = _('All Labels'),					category = _('Labels')},
    {combos = {{key = 'F2', reformers = {'LShift'}}},	down = iCommandMarkerStatePlane,		name = _('Aircraft Labels'),			category = _('Labels')},
    {combos = {{key = 'F6', reformers = {'LShift'}}},	down = iCommandMarkerStateRocket,		name = _('Missile Labels'),				category = _('Labels')},
    {combos = {{key = 'F9', reformers = {'LShift'}}},	down = iCommandMarkerStateShip,			name = _('Vehicle & Ship Labels'),		category = _('Labels')},
    
    --Kneeboard
    {combos = {{key = 'K', reformers = {'RShift'}}},	down = iCommandPlaneShowKneeboard,																				name = _('Kneeboard ON/OFF'),						category = _('Kneeboard')},
    {combos = {{key = 'K'}},							down = iCommandPlaneShowKneeboard,	up = iCommandPlaneShowKneeboard,	value_down = 1.0,	value_up = -1.0,	name = _('Kneeboard glance view'),					category = _('Kneeboard')},
    {combos = {{key = ']'}},							down = 3001,	cockpit_device_id = kneeboard_id,						value_down = 1.0,						name = _('Kneeboard Next Page'),					category = _('Kneeboard')},
    {combos = {{key = '['}},							down = 3002,	cockpit_device_id = kneeboard_id,						value_down = 1.0,						name = _('Kneeboard Previous Page'),				category = _('Kneeboard')},
    {combos = {{key = 'K', reformers = {'RCtrl'}}},		down = 3003,	cockpit_device_id = kneeboard_id,						value_down = 1.0,						name = _('Kneeboard current position mark point'),	category = _('Kneeboard')},
    --shortcuts navigation
    {	down = 3004,	cockpit_device_id = kneeboard_id,						value_down =  1.0,						name = _('Kneeboard Make Shortcut'),				category = _('Kneeboard')},
    {	down = 3005,	cockpit_device_id = kneeboard_id,						value_down =  1.0,						name = _('Kneeboard Next Shortcut'),				category = _('Kneeboard')},
    {	down = 3005,	cockpit_device_id = kneeboard_id,						value_down = -1.0,						name = _('Kneeboard Previous Shortcut'),			category = _('Kneeboard')},
    {	down = iCommandPlaneKneeboardJumpBookmark,								value_down = 0,							name = _('Kneeboard Jump To Shortcut  1'),			category = _('Kneeboard')},
    {	down = iCommandPlaneKneeboardJumpBookmark,								value_down = 1,							name = _('Kneeboard Jump To Shortcut  2'),			category = _('Kneeboard')},
    {	down = iCommandPlaneKneeboardJumpBookmark,								value_down = 2,							name = _('Kneeboard Jump To Shortcut  3'),			category = _('Kneeboard')},
    {	down = iCommandPlaneKneeboardJumpBookmark,								value_down = 3,							name = _('Kneeboard Jump To Shortcut  4'),			category = _('Kneeboard')},
    {	down = iCommandPlaneKneeboardJumpBookmark,								value_down = 4,							name = _('Kneeboard Jump To Shortcut  5'),			category = _('Kneeboard')},
    {	down = iCommandPlaneKneeboardJumpBookmark,								value_down = 5,							name = _('Kneeboard Jump To Shortcut  6'),			category = _('Kneeboard')},
    {	down = iCommandPlaneKneeboardJumpBookmark,								value_down = 6,							name = _('Kneeboard Jump To Shortcut  7'),			category = _('Kneeboard')},
    {	down = iCommandPlaneKneeboardJumpBookmark,								value_down = 7,							name = _('Kneeboard Jump To Shortcut  8'),			category = _('Kneeboard')},
    {	down = iCommandPlaneKneeboardJumpBookmark,								value_down = 8,							name = _('Kneeboard Jump To Shortcut  9'),			category = _('Kneeboard')},
    {	down = iCommandPlaneKneeboardJumpBookmark,								value_down = 9,							name = _('Kneeboard Jump To Shortcut 10'),			category = _('Kneeboard')},
    {combos = {{key = '1'}},	down = iCommandViewCockpitChangeSeat, value_down = 1, name = _('Occupy Seat 1'),	category = _('View Cockpit')},
    {combos = {{key = '2'}},	down = iCommandViewCockpitChangeSeat, value_down = 2, name = _('Occupy Seat 2'),	category = _('View Cockpit')},

    -- Autopilot
    {combos = {{key = 'A'}, {key = '1', reformers = {'LAlt'}}}, down = iCommandPlaneAutopilot, name = _('Autopilot - Attitude Hold'), category = _('Autopilot')},
    {combos = {{key = 'H'}, {key = '2', reformers = {'LAlt'}}}, down = iCommandPlaneStabHbar, name = _('Autopilot - Altitude Hold'), category = _('Autopilot')},
    {combos = {{key = '9', reformers = {'LAlt'}}}, down = iCommandPlaneStabCancel, name = _('Autopilot Disengage'), category = _('Autopilot')},
    {combos = {{key = '1', reformers = {'LCtrl'}}}, down = iCommandHelicopter_PPR_button_T_up, name = _('CAS Pitch'), category = _('Autopilot')},
    {combos = {{key = '2', reformers = {'LCtrl'}}}, down = iCommandHelicopter_PPR_button_K_up, name = _('CAS Roll'), category = _('Autopilot')},
    {combos = {{key = '3', reformers = {'LCtrl'}}}, down = iCommandHelicopter_PPR_button_H_up, name = _('CAS Yaw'), category = _('Autopilot')},

    --Flight Control
    {combos = {{key = 'T', reformers = {'LAlt'}}}, down = iCommandPlaneTrimOn, up = iCommandPlaneTrimOff, name = _('T/O Trim'), category = _('Flight Control')},

    {down = iCommandPlaneAirBrakeOn,	up = iCommandPlaneAirBrakeOff,			name = _('HOTAS Airbrake'),					category = _('Systems') },

    -- Systems
    --{combos = {{key = 'F', reformers = {'LShift'}}}, down = Keys.FlapUp, name = _('Flaps Up'), category = _('Systems')},
    --{combos = {{key = 'F', reformers = {'LCtrl'}}}, down = Keys.FlapDown, name = _('Flaps Down'), category = _('Systems')},
    --{combos = {{key = 'F'}}, down = Keys.Flap, name = _('Flaps Up/Down'), category = _('Systems')},
    {combos = {{key = 'R', reformers = {'LCtrl'}}}, down = iCommandPlaneAirRefuel, name = _('Refueling Boom'), category = _('Systems')},
    {combos = {{key = 'R', reformers = {'LAlt'}}}, down = iCommandPlaneJettisonFuelTanks, name = _('Jettison Fuel Tanks'), category = _('Systems')},
    {combos = {{key = 'S'}}, down = iCommandPlane_HOTAS_NoseWheelSteeringButton, name = _('Nose Gear Maneuvering Range'), category = _('Systems')},
    {combos = {{key = 'Q', reformers = {'LAlt'}}}, down = iCommandPlane_HOTAS_NoseWheelSteeringButtonOff, up = iCommandPlane_HOTAS_NoseWheelSteeringButtonOff, name = _('Nose Wheel Steering'), category = _('Systems')},
    {combos = {{key = 'A', reformers = {'LCtrl'}}}, down = iCommandPlaneWheelBrakeLeftOn, up = iCommandPlaneWheelBrakeLeftOff, name = _('Wheel Brake Left On/Off'), category = _('Systems')},
    {combos = {{key = 'A', reformers = {'LAlt'}}}, down = iCommandPlaneWheelBrakeRightOn, up = iCommandPlaneWheelBrakeRightOff, name = _('Wheel Brake Right On/Off'), category = _('Systems')},
    {combos = {{key = 'T', reformers = {'LShift'}}}, down = iCommandClockElapsedTimeReset, name = _('Elapsed Time Clock Start/Stop/Reset'), category = _('Systems')},
    {combos = {{key = 'D', reformers = {'LShift'}}}, down = iCommandPlaneFSQuantityIndicatorSelectorMAIN, name = _('Fuel Quantity Selector'), category = _('Systems')},
    {combos = {{key = 'D', reformers = {'LCtrl','LAlt'}}}, down = iCommandPlaneFSQuantityIndicatorTest, up = iCommandPlaneFSQuantityIndicatorTest, value_down = 1, value_up = 0, name = _('Fuel Quantity Test'), category = _('Systems')},
    {combos = {{key = 'D', reformers = {'LAlt'}}}, down = iCommandPlaneFSQuantityIndicatorSelectorINT,	up = iCommandPlaneFSQuantityIndicatorSelectorINT, value_down = 1,  value_up = 0, 	name = _('Bingo Fuel Index, CW'),  category = _('Systems')},
    {combos = {{key = 'D', reformers = {'LCtrl'}}}, down = iCommandPlaneFSQuantityIndicatorSelectorINT,	up = iCommandPlaneFSQuantityIndicatorSelectorINT, value_down = -1, value_up = 0, 	name = _('Bingo Fuel Index, CCW'), category = _('Systems')},
    {combos = {{key = 'L', reformers = {'RCtrl','RAlt'}}}, down = iCommandPlaneAntiCollisionLights, name = _('Anti-collision lights'), category = _('Systems')},

    -- Weapons                                                                        
    {combos = {{key = 'V', reformers = {'LCtrl'}}}, down = iCommandPlaneSalvoOnOff, name = _('Salvo Mode'), category = _('Weapons')},
    {combos = {{key = 'Space', reformers = {'RAlt'}}}, down = iCommandPlanePickleOn,	up = iCommandPlanePickleOff, name = _('Weapon Release'), category = _('Weapons')},
    --{combos = {{key = 'C', reformers = {'LShift'}}}, down = iCommandChangeGunRateOfFire, name = _('Cannon Rate Of Fire / Cut Of Burst select'), category = _('Weapons')},

        -- General (Gameplay)
    {combos = {{key = 'U'}},							down = iCommandPlaneShipTakeOff,			name = _('Ship Take Off Position'),		category = _('General') , features = {"shiptakeoff"}},
    --{combos = {{key = 'P', reformers = {'RShift'}}},	down = iCommandCockpitShowPilotOnOff,		name = _('Show Pilot Body'),			category = _('General')},

    -- Flight Control
    {combos = {{key = 'Up'}},		down = iCommandPlaneUpStart,			up = iCommandPlaneUpStop,			name = _('Aircraft Pitch Down'),	category = _('Flight Control')},
    {combos = {{key = 'Down'}},		down = iCommandPlaneDownStart,			up = iCommandPlaneDownStop,			name = _('Aircraft Pitch Up'),		category = _('Flight Control')},
    {combos = {{key = 'Left'}},		down = iCommandPlaneLeftStart,			up = iCommandPlaneLeftStop,			name = _('Aircraft Bank Left'),		category = _('Flight Control')},
    {combos = {{key = 'Right'}},	down = iCommandPlaneRightStart,			up = iCommandPlaneRightStop,		name = _('Aircraft Bank Right'),	category = _('Flight Control')},
    {combos = {{key = 'Z'}},		down = iCommandPlaneLeftRudderStart,	up = iCommandPlaneLeftRudderStop,	name = _('Aircraft Rudder Left'),	category = _('Flight Control')},
    {combos = {{key = 'X'}},		down = iCommandPlaneRightRudderStart,	up = iCommandPlaneRightRudderStop,	name = _('Aircraft Rudder Right'),	category = _('Flight Control')},

    {combos = {{key = '.', reformers = {'RCtrl'}}},	pressed = iCommandPlaneTrimUp,			up = iCommandPlaneTrimStop, name = _('Trim: Nose Up'),			category = _('Flight Control')},
    {combos = {{key = ';', reformers = {'RCtrl'}}},	pressed = iCommandPlaneTrimDown,		up = iCommandPlaneTrimStop, name = _('Trim: Nose Down'),		category = _('Flight Control')},
    {combos = {{key = ',', reformers = {'RCtrl'}}},	pressed = iCommandPlaneTrimLeft,		up = iCommandPlaneTrimStop, name = _('Trim: Left Wing Down'),	category = _('Flight Control')},
    {combos = {{key = '/', reformers = {'RCtrl'}}},	pressed = iCommandPlaneTrimRight,		up = iCommandPlaneTrimStop, name = _('Trim: Right Wing Down'),	category = _('Flight Control')},
    {combos = {{key = 'Z', reformers = {'RCtrl'}}},	pressed = iCommandPlaneTrimLeftRudder,	up = iCommandPlaneTrimStop, name = _('Trim: Rudder Left'),		category = _('Flight Control')},
    {combos = {{key = 'X', reformers = {'RCtrl'}}},	pressed = iCommandPlaneTrimRightRudder,	up = iCommandPlaneTrimStop, name = _('Trim: Rudder Right'),		category = _('Flight Control')},

    {combos = {{key = 'Num+'}}, 						pressed = iCommandThrottleIncrease,		up = iCommandThrottleStop,  name = _('Throttle Up'),		category = _('Flight Control')},
    {combos = {{key = 'Num-'}}, 						pressed = iCommandThrottleDecrease,		up = iCommandThrottleStop,  name = _('Throttle Down'),		category = _('Flight Control')},
    {combos = {{key = 'Num+', reformers = {'RAlt'}}}, 	pressed = iCommandThrottle1Increase,	up = iCommandThrottle1Stop, name = _('Throttle Left Up'),	category = _('Flight Control')},
    {combos = {{key = 'Num-', reformers = {'RAlt'}}}, 	pressed = iCommandThrottle1Decrease,	up = iCommandThrottle1Stop, name = _('Throttle Left Down'), category = _('Flight Control')},
    {combos = {{key = 'Num+', reformers = {'RShift'}}}, pressed = iCommandThrottle2Increase,	up = iCommandThrottle2Stop, name = _('Throttle Right Up'),	category = _('Flight Control')},
    {combos = {{key = 'Num-', reformers = {'RShift'}}}, pressed = iCommandThrottle2Decrease,	up = iCommandThrottle2Stop, name = _('Throttle Right Down'), category = _('Flight Control')},

    {combos = {{key = 'PageUp'}},							down = iCommandPlaneAUTIncreaseRegime,		name = _('Throttle Step Up'),			category = _('Flight Control')},
    {combos = {{key = 'PageDown'}},							down = iCommandPlaneAUTDecreaseRegime,		name = _('Throttle Step Down'),			category = _('Flight Control')},
    {combos = {{key = 'PageUp', reformers = {'RAlt'}}},		down = iCommandPlaneAUTIncreaseRegimeLeft,	name = _('Throttle Step Up Left'),		category = _('Flight Control')},
    {combos = {{key = 'PageDown', reformers = {'RAlt'}}},	down = iCommandPlaneAUTDecreaseRegimeLeft,	name = _('Throttle Step Down Left'),	category = _('Flight Control')},
    {combos = {{key = 'PageUp', reformers = {'RShift'}}},	down = iCommandPlaneAUTIncreaseRegimeRight, name = _('Throttle Step Up Right'),		category = _('Flight Control')},
    {combos = {{key = 'PageDown', reformers = {'RShift'}}}, down = iCommandPlaneAUTDecreaseRegimeRight, name = _('Throttle Step Down Right'),	category = _('Flight Control')},

    -- Systems
    {combos = {{key = 'L', reformers = {'RShift'}}},	down = iCommandPowerOnOff,					name = _('Electric Power Switch'),					category = _('Systems')},
    {combos = {{key = 'B'}},							down = iCommandPlaneAirBrake,				name = _('Airbrake'),								category = _('Systems') , features = {"airbrake"}},
    {combos = {{key = 'B', reformers = {'LShift'}}},	down = iCommandPlaneAirBrakeOn,	up = Keys.AirbrakePauseMove,			name = _('Airbrake On'),							category = _('Systems') , features = {"airbrake"}},
    {combos = {{key = 'B', reformers = {'LCtrl'}}},		down = iCommandPlaneAirBrakeOff,up = Keys.AirbrakePauseMove,			name = _('Airbrake Off'),							category = _('Systems') , features = {"airbrake"}},
    {combos = {{key = 'T'}},							down = iCommandPlaneWingtipSmokeOnOff,		name = _('Smoke'),									category = _('Systems')},
    {combos = {{key = 'L'}},							down = iCommandPlaneCockpitIllumination,	name = _('Illumination Cockpit'),					category = _('Systems')},
    {combos = {{key = 'L', reformers = {'RCtrl'}}},		down = iCommandPlaneLightsOnOff,			name = _('Navigation lights'),						category = _('Systems')},
    {combos = {{key = 'L', reformers = {'RAlt'}}},		down = iCommandPlaneHeadLightOnOff,			name = _('Gear Light Near/Far/Off'),				category = _('Systems')},
    {combos = {{key = 'F'}},							down = iCommandPlaneFlaps,					name = _('Flaps Up/Down (Warthunder like logic)'),	category = _('Systems')},
    {combos = {{key = 'F', reformers = {'LShift'}}},	down = iCommandPlaneFlapsOn,				name = _('Flaps Move Down (One Step)'),			    category = _('Systems')},
    {combos = {{key = 'F', reformers = {'LCtrl'}}},		down = iCommandPlaneFlapsOff,				name = _('Flaps Move Up (One Step)'),				category = _('Systems')},
    {combos = {{key = 'G'}},							down = iCommandPlaneGear,					name = _('Landing Gear Up/Down'),					category = _('Systems')},
    {combos = {{key = 'G', reformers = {'LCtrl'}}},		down = iCommandPlaneGearUp,					name = _('Landing Gear Up'),						category = _('Systems')},
    {combos = {{key = 'G', reformers = {'LShift'}}},	down = iCommandPlaneGearDown,				name = _('Landing Gear Down'),						category = _('Systems')},
    {combos = {{key = 'W'}},							down = iCommandPlaneWheelBrakeOn, up = iCommandPlaneWheelBrakeOff, name = _('Wheel Brake On'),	category = _('Systems')},
    {combos = {{key = 'C', reformers = {'LCtrl'}}},		down = iCommandPlaneFonar,					name = _('Canopy Open/Close'),						category = _('Systems')},
    {combos = {{key = 'P'}},							down = iCommandPlaneParachute,				name = _('Dragging Chute'),							category = _('Systems') , features = {"dragchute"}},
    {combos = {{key = 'N', reformers = {'RShift'}}},	down = iCommandPlaneResetMasterWarning,		name = _('Audible Warning Reset'),					category = _('Systems')},
    {combos = {{key = 'W', reformers = {'LCtrl'}}},		down = iCommandPlaneJettisonWeapons,up = iCommandPlaneJettisonWeaponsUp, name = _('Weapons Jettison'), category = _('Systems')},
    {combos = {{key = 'E', reformers = {'LCtrl'}}},		down = iCommandPlaneEject,					name = _('Eject (3 times)'),						category = _('Systems')},
    {combos = {{key = 'C', reformers = {'RShift'}}},	down = iCommandFlightClockReset,			name = _('Flight Clock Start/Stop/Reset'),			category = _('Systems') , features = {"flightclock"}},
    {													down = iCommandClockElapsedTimeReset,		name = _('Elapsed Time Clock Start/Stop/Reset'),	category = _('Systems') , features = {"flightclock"}},
    {combos = {{key = 'Home', reformers = {'RShift'}}}, down = iCommandEnginesStart,				name = _('Engines Start'),							category = _('Systems')},
    {combos = {{key = 'End', reformers = {'RShift'}}},	down = iCommandEnginesStop,					name = _('Engines Stop'),							category = _('Systems')},
    {combos = {{key = 'Home', reformers = {'RAlt'}}},	down = iCommandLeftEngineStart,				name = _('Engine Left Start'),						category = _('Systems') , features = {"TwinEngineAircraft"}},
    {combos = {{key = 'End', reformers = {'RAlt'}}},	down = iCommandLeftEngineStop,				name = _('Engine Left Stop'),						category = _('Systems') , features = {"TwinEngineAircraft"}},
    {combos = {{key = 'Home', reformers = {'RCtrl'}}},	down = iCommandRightEngineStart,			name = _('Engine Right Start'),						category = _('Systems') , features = {"TwinEngineAircraft"}},
    {combos = {{key = 'End', reformers = {'RCtrl'}}},	down = iCommandRightEngineStop,				name = _('Engine Right Stop'),						category = _('Systems') , features = {"TwinEngineAircraft"}},
    {combos = {{key = 'H', reformers = {'RCtrl'}}},		down = iCommandBrightnessILS,				name = _('HUD Color'),								category = _('Systems') , features = {"HUDcolor"}},
    {combos = {{key = 'H', reformers = {'RCtrl','RShift'}}}, pressed = iCommandHUDBrightnessUp,		name = _('HUD Brightness up'),						category = _('Systems') , features = {"HUDbrightness"}},
    {combos = {{key = 'H', reformers = {'RShift','RAlt'}}}, pressed = iCommandHUDBrightnessDown,	name = _('HUD Brightness down'),					category = _('Systems') , features = {"HUDbrightness"}},
    {combos = {{key = 'R'}},							down = iCommandPlaneFuelOn, up = iCommandPlaneFuelOff, name = _('Fuel Dump'),					category = _('Systems') , features = {"fueldump"}},

    {combos = {{key = '=', reformers = {'RShift'}}}, pressed = iCommandAltimeterPressureIncrease,	up = iCommandAltimeterPressureStop, name = _('Altimeter Pressure Increase'), category = _('Systems')},
    {combos = {{key = '-', reformers = {'RShift'}}}, pressed = iCommandAltimeterPressureDecrease, up = iCommandAltimeterPressureStop, name = _('Altimeter Pressure Decrease'), category = _('Systems')},

    -- Engine Control
    {down = Keys.L_THROTTLE_IDLE,					name = _('Set Left Throttle IDLE/OFF'),			category = _('Engine')},
    {down = Keys.R_THROTTLE_IDLE,					name = _('Set Right Throttle IDLE/OFF'),		category = _('Engine')},
    {down = Keys.L_THROTTLE_SETOFF,    up = Keys.L_THROTTLE_SETIDLE,				name = _('Left Throttle IDLE (on/press) else OFF'),			category = _('Engine')},
    {down = Keys.R_THROTTLE_SETOFF,   	up = Keys.R_THROTTLE_SETIDLE,					name = _('Right Throttle IDLE (on/press) else OFF'),		category = _('Engine')},

    -- Countermeasures
    {combos = {{key = 'Q', reformers = {'LShift'}}},	down = iCommandPlaneDropSnar,			name = _('Countermeasures Continuously Dispense'),					category = _('Countermeasures') , features = {"Countermeasures"}},
    {combos = {{key = 'Q'}},							down = iCommandPlaneDropSnarOnce, up = iCommandPlaneDropSnarOnceOff, name = _('Countermeasures Release'),	category = _('Countermeasures') , features = {"Countermeasures"}},
    {combos = {{key = 'Delete'}},						down = iCommandPlaneDropFlareOnce,		name = _('Countermeasures Flares Dispense'),						category = _('Countermeasures') , features = {"Countermeasures"}},
    {combos = {{key = 'Insert'}},						down = iCommandPlaneDropChaffOnce,		name = _('Countermeasures Chaff Dispense'),							category = _('Countermeasures') , features = {"Countermeasures"}},
    {combos = {{key = 'E'}},							down = iCommandActiveJamming,			name = _('ECM'),													category = _('Countermeasures') , features = {"ECM"}},

    -- Communications
    {combos = {{key = 'I', reformers = {'LWin'}}},											down = iCommandAWACSTankerBearing,	name = _('Request AWACS Available Tanker'),	category = _('Communications')},
    {combos = {{key = '\\', reformers = {'RShift'}}, {key = 'M', reformers = {'RShift'}}},	down = iCommandToggleReceiveMode,	name = _('Receive Mode'),					category = _('Communications')},

    -- Cockpit Camera Motion (Передвижение камеры в кабине)
    {combos = {{key = 'N', reformers = {'RAlt'}}},	down = iCommandViewLeftMirrorOn ,	up = iCommandViewLeftMirrorOff ,	name = _('Mirror Left On'),		category = _('View Cockpit') , features = {"Mirrors"}},
    {combos = {{key = 'M', reformers = {'RAlt'}}},	down = iCommandViewRightMirrorOn,	up = iCommandViewRightMirrorOff,	name = _('Mirror Right On'),	category = _('View Cockpit') , features = {"Mirrors"}},
    {combos = {{key = 'M' }},						down = iCommandToggleMirrors,											name = _('Toggle Mirrors'),		category = _('View Cockpit') , features = {"Mirrors"}},

    -- self define for EFM
    {down = Keys.YawDamperSwitch, name = _('Yaw Damper Engage'), category = _('Flight Control')},
    {down = Keys.WingPylonSmokeOn,	name = _('Smoke Pod On/Off'),		category = _('Weapons')},
    {down = Keys.NozzleSmokeOn,	name = _('Nozzle Smoke On/Off'),		category = _('Weapons')},
    {down = Keys.WeaponFireOn, up = Keys.WeaponFireOff,	name = _('Weapon Fire Trigger'),		category = _('Weapons')},
    -- debug
    --{down = 5005,	name = _('DEBUG RECORD'),		category = _('Debugs')},

    --Multicrew Control
    {combos = {{key = 'J'}},	down = iCommandNetCrewRequestControl,	name = _('Request Aircraft Control'),	category = _('Flight Control')},
    {combos = {{key = '1'}},	down = iCommandViewCockpitChangeSeat, value_down = 1, name = _('Occupy Seat 1'),	category = _('View Cockpit')},
    {combos = {{key = '2'}},	down = iCommandViewCockpitChangeSeat, value_down = 2, name = _('Occupy Seat 2'),	category = _('View Cockpit')},

    --HOTAS
    {down = Keys.Flap_Pos_Up,	up = Keys.Flap_Pos_Half,			name = _('HOTAS Flap Up Position'),					category = _('HOTAS') },
    {down = Keys.Flap_Pos_Down,	up = Keys.Flap_Pos_Half,			name = _('HOTAS Flap Down Position'),				category = _('HOTAS') },

    -- special functions
    {down = Keys.SpecialSence,			name = _('Tjena Hejsan'),				category = _('Special Function') },
    {down = Keys.Custom_Menu,			name = _('Trigger on Screen Menu'),				category = _('Special Function') },
    {down = Keys.Custom_Menu_Enter,			name = _('Menu Enter'),				category = _('Special Function') },
	{down = Keys.PilotBody,			name = _('Toggle Pilot'),				category = _('Special Function') },

    -- Music Player
    {down = Keys.MusicPauseOrPlay,			name = _('Music Pause/Play'),				category = _('Music Player')},
    {down = Keys.MusicVolUp,			    name = _('Music Volume Up'),				category = _('Music Player')},
    {down = Keys.MusicVolDown,			    name = _('Music Volume Down'),				category = _('Music Player')},
    {down = Keys.MusicNext,			        name = _('Music Play Next'),				category = _('Music Player')},
    {down = Keys.MusicLast,			        name = _('Music Play Last'),				category = _('Music Player')},
    {down = Keys.MusicFastForward,			name = _('Music Play Fast Forward'),		category = _('Music Player')},
    {down = Keys.MusicFastBack,			    name = _('Music Play Fast Backward'),		category = _('Music Player')},
    {down = Keys.MusicLrcViewTrigger,		name = _('Music Display Lyrics'),			category = _('Music Player')},
},
}
