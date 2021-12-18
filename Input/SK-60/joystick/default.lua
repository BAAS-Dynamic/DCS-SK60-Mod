local cscripts = folder.."../../../Cockpit/Scripts/"
dofile(cscripts.."devices.lua")
dofile(cscripts.."command_defs.lua")

local kneeboard_id = 100
if devices and devices.KNEEBOARD then
   kneeboard_id = devices.KNEEBOARD
end

return {

forceFeedback = {
    trimmer = 1.0,
    shake = 0.5,
    swapAxes = false,
    invertX = false,
    invertY = false,
},

keyCommands = {

    -- Gameplay
    {down = iCommandPlaneShipTakeOff,		name = _('Ship Take Off Position'), category = _('General') , features = {"shiptakeoff"}},
    {down = iCommandCockpitShowPilotOnOff,	name = _('Show Pilot Body'),		category = _('General')},

    --Flight Control
    {down = iCommandPlaneUpStart,				up = iCommandPlaneUpStop,			name = _('Aircraft Pitch Down'),	category = _('Flight Control')},
    {down = iCommandPlaneDownStart,				up = iCommandPlaneDownStop,			name = _('Aircraft Pitch Up'),		category = _('Flight Control')},
    {down = iCommandPlaneLeftStart,				up = iCommandPlaneLeftStop,			name = _('Aircraft Bank Left'),		category = _('Flight Control')},
    {down = iCommandPlaneRightStart,			up = iCommandPlaneRightStop,		name = _('Aircraft Bank Right'),	category = _('Flight Control')},
    {down = iCommandPlaneLeftRudderStart,		up = iCommandPlaneLeftRudderStop,	name = _('Aircraft Rudder Left'),	category = _('Flight Control')},
    {down = iCommandPlaneRightRudderStart,		up = iCommandPlaneRightRudderStop,	name = _('Aircraft Rudder Right'),	category = _('Flight Control')},

    {pressed = iCommandPlaneTrimUp,				up = iCommandPlaneTrimStop,	name = _('Trim: Nose Up'),			category = _('Flight Control')},
    {pressed = iCommandPlaneTrimDown,			up = iCommandPlaneTrimStop,	name = _('Trim: Nose Down'),		category = _('Flight Control')},
    {pressed = iCommandPlaneTrimLeft,			up = iCommandPlaneTrimStop,	name = _('Trim: Left Wing Down'),	category = _('Flight Control')},
    {pressed = iCommandPlaneTrimRight,			up = iCommandPlaneTrimStop,	name = _('Trim: Right Wing Down'),	category = _('Flight Control')},
    {pressed = iCommandPlaneTrimLeftRudder,		up = iCommandPlaneTrimStop,	name = _('Trim: Rudder Left'),		category = _('Flight Control')},
    {pressed = iCommandPlaneTrimRightRudder,	up = iCommandPlaneTrimStop,	name = _('Trim: Rudder Right'),		category = _('Flight Control')},

    {pressed = iCommandThrottleIncrease, up = iCommandThrottleStop,  name = _('Throttle Up'),			category = _('Flight Control')},
    {pressed = iCommandThrottleDecrease, up = iCommandThrottleStop,  name = _('Throttle Down'),			category = _('Flight Control')},
    {pressed = iCommandThrottle1Increase,up = iCommandThrottle1Stop, name = _('Throttle Left Up'),		category = _('Flight Control')},
    {pressed = iCommandThrottle1Decrease,up = iCommandThrottle1Stop, name = _('Throttle Left Down'),	category = _('Flight Control')},
    {pressed = iCommandThrottle2Increase,up = iCommandThrottle2Stop, name = _('Throttle Right Up'),		category = _('Flight Control')},
    {pressed = iCommandThrottle2Decrease,up = iCommandThrottle2Stop, name = _('Throttle Right Down'),	category = _('Flight Control')},

    {down = iCommandPlaneAUTIncreaseRegime,			name = _('Throttle Step Up'),			category = _('Flight Control')},
    {down = iCommandPlaneAUTDecreaseRegime,			name = _('Throttle Step Down'),			category = _('Flight Control')},
    {down = iCommandPlaneAUTIncreaseRegimeLeft,		name = _('Throttle Step Up Left'),		category = _('Flight Control')},
    {down = iCommandPlaneAUTDecreaseRegimeLeft,		name = _('Throttle Step Down Left'),	category = _('Flight Control')},
    {down = iCommandPlaneAUTIncreaseRegimeRight,	name = _('Throttle Step Up Right'),		category = _('Flight Control')},
    {down = iCommandPlaneAUTDecreaseRegimeRight,	name = _('Throttle Step Down Right'),	category = _('Flight Control')},

    -- Systems
    {down = iCommandPowerOnOff,					name = _('Electric Power Switch'),		category = _('Systems')},
    {down = iCommandPlaneAirBrake,				name = _('Airbrake'),					category = _('Systems') , features = {"airbrake"}},
    {down = iCommandPlaneAirBrakeOn,up = Keys.AirbrakePauseMove,			name = _('Airbrake On'),				category = _('Systems') , features = {"airbrake"}},
    {down = iCommandPlaneAirBrakeOff,up = Keys.AirbrakePauseMove,			name = _('Airbrake Off'),				category = _('Systems') , features = {"airbrake"}},
    {down = iCommandPlaneWingtipSmokeOnOff,		name = _('Smoke'),						category = _('Systems')},
    {down = iCommandPlaneCockpitIllumination,	name = _('Illumination Cockpit'),		category = _('Systems')},
    {down = iCommandPlaneLightsOnOff,			name = _('Navigation lights'),			category = _('Systems')},
    {down = iCommandPlaneHeadLightOnOff,		name = _('Gear Light Near/Far/Off'),	category = _('Systems')},
    {down = iCommandPlaneFlaps,					name = _('Flaps Up/Down'),				category = _('Systems')},
    {down = iCommandPlaneFlapsOn,				name = _('Flaps Landing Position'),		category = _('Systems')},
    {down = iCommandPlaneFlapsOff,				name = _('Flaps Up'),					category = _('Systems')},
    {down = iCommandPlaneGear,					name = _('Landing Gear Up/Down'),		category = _('Systems')},
    {down = iCommandPlaneGearUp,				name = _('Landing Gear Up'),			category = _('Systems')},
    {down = iCommandPlaneGearDown,				name = _('Landing Gear Down'),			category = _('Systems')},
    {down = iCommandPlaneWheelBrakeOn, up = iCommandPlaneWheelBrakeOff,			name = _('Wheel Brake On'),		category = _('Systems')},
    {down = iCommandPlaneFonar,					name = _('Canopy Open/Close'),			category = _('Systems')},
    {down = iCommandPlaneParachute,				name = _('Dragging Chute'),				category = _('Systems'),	features = {"dragchute"}},
    {down = iCommandPlaneResetMasterWarning,	name = _('Audible Warning Reset'),		category = _('Systems')},
    {down = iCommandPlaneJettisonWeapons,up = iCommandPlaneJettisonWeaponsUp,	name = _('Weapons Jettison'),	category = _('Systems')},
    {down = iCommandPlaneEject,					name = _('Eject (3 times)'),			category = _('Systems')},
    {down = iCommandFlightClockReset,			name = _('Flight Clock Start/Stop/Reset'),						category = _('Systems') , features = {"flightclock"}},
    {down = iCommandClockElapsedTimeReset,		name = _('Elapsed Time Clock Start/Stop/Reset'),				category = _('Systems') , features = {"flightclock"}},
    {down = iCommandEnginesStart,				name = _('Engines Start'),				category = _('Systems')},
    {down = iCommandEnginesStop,				name = _('Engines Stop'),				category = _('Systems')},
    {down = iCommandLeftEngineStart,			name = _('Engine Left Start'),			category = _('Systems') , features = {"TwinEngineAircraft"}},
    {down = iCommandLeftEngineStop,				name = _('Engine Left Stop'),			category = _('Systems') , features = {"TwinEngineAircraft"}},
    {down = iCommandRightEngineStart,			name = _('Engine Right Start'),			category = _('Systems') , features = {"TwinEngineAircraft"}},
    {down = iCommandRightEngineStop,			name = _('Engine Right Stop'),			category = _('Systems') , features = {"TwinEngineAircraft"}},
    {down = iCommandBrightnessILS,				name = _('HUD Color'),					category = _('Systems') , features = {"HUDcolor"}},
    {pressed = iCommandHUDBrightnessUp,			name = _('HUD Brightness up'),			category = _('Systems') , features = {"HUDbrightness"}},
    {pressed = iCommandHUDBrightnessDown,		name = _('HUD Brightness down'),		category = _('Systems') , features = {"HUDbrightness"}},
    {down = iCommandPlaneFuelOn,	up = iCommandPlaneFuelOff,					name = _('Fuel Dump'),			category = _('Systems') , features = {"fueldump"}},

    -- Engine Control
    {down = Keys.LeftEngineIDLE,					name = _('Set Left Throttle IDLE/OFF'),			category = _('Engine')},
    {down = Keys.RightEngineIDLE,					name = _('Set Right Throttle IDLE/OFF'),		category = _('Engine')},

    {pressed = iCommandAltimeterPressureIncrease,	up = iCommandAltimeterPressureStop, name = _('Altimeter Pressure Increase'), category = _('Systems')},
    {pressed = iCommandAltimeterPressureDecrease, up = iCommandAltimeterPressureStop, name = _('Altimeter Pressure Decrease'), category = _('Systems')},

    -- Weapons                                                                        

    -- Countermeasures
    {down = iCommandPlaneDropSnar,		name = _('Countermeasures Continuously Dispense'),	category = _('Countermeasures') , features = {"Countermeasures"}},
    {down = iCommandPlaneDropSnarOnce,	up = iCommandPlaneDropSnarOnceOff,	name = _('Countermeasures Release'),	category = _('Countermeasures') , features = {"Countermeasures"}},
    {down = iCommandPlaneDropFlareOnce, name = _('Countermeasures Flares Dispense'),		category = _('Countermeasures') , features = {"Countermeasures"}},
    {down = iCommandPlaneDropChaffOnce, name = _('Countermeasures Chaff Dispense'),			category = _('Countermeasures') , features = {"Countermeasures"}},
    {down = iCommandActiveJamming,		name = _('ECM'),									category = _('Countermeasures') , features = {"ECM"}},

    -- Communications
    {down = iCommandAWACSTankerBearing, name = _('Request AWACS Available Tanker'), category = _('Communications')},
    {down = iCommandToggleReceiveMode,	name = _('Receive Mode'),					category = _('Communications')},

    -- Cockpit Camera Motion (������������ ������ � ������)
    {down = iCommandViewLeftMirrorOn,	up = iCommandViewLeftMirrorOff,		name = _('Mirror Left On'),		category = _('View Cockpit') , features = {"Mirrors"}},
    {down = iCommandViewRightMirrorOn,	up = iCommandViewRightMirrorOff,	name = _('Mirror Right On'),	category = _('View Cockpit') , features = {"Mirrors"}},
    {down = iCommandToggleMirrors,											name = _('Toggle Mirrors'),		category = _('View Cockpit') , features = {"Mirrors"}},

    {action = iCommandPlaneThrustLeft,			name = _('Thrust Left')},
    {action = iCommandPlaneThrustRight,			name = _('Thrust Right')},
    --{action = iCommandPlaneTrimPitchAbs,		name = _('Trim Pitch')},
    --{action = iCommandPlaneTrimRollAbs,		name = _('Trim Roll')},
    --{action = iCommandPlaneTrimRudderAbs,		name = _('Trim Rudder')},

    {	down = iCommandScoresWindowToggle,				name = _('Score window'),							category = _('General')},

    --{	down = iCommandChat,							name = _('Multiplayer chat - mode All'),			category = _('General')},
    --{	down = iCommandFriendlyChat,					name = _('Multiplayer chat - mode Allies'),			category = _('General')},
    --{	down = iCommandAllChat,							name = _('Chat read/write All'),					category = _('General')},
    {	down = iCommandInfoOnOff,						name = _('Info bar view toggle'),					category = _('General')},
    {	down = iCommandRecoverHuman,					name = _('Get new plane - respawn'),				category = _('General')},
    {	down = iCommandPlaneJump,						name = _('Jump into selected aircraft'),			category = _('General')},
    {	down = iCommandViewCoordinatesInLinearUnits,	name = _('Info bar coordinate units toggle'),		category = _('General')},
    {	down = iCommandCockpitClickModeOnOff,			name = _('Clickable mouse cockpit mode On/Off'),	category = _('General')},
    {	down = iCommandSoundOnOff,						name = _('Sound On/Off'),							category = _('General')},
    {	down = iCommandMissionResourcesManagement,		name = _('Rearming and Refueling Window'),			category = _('General')},
    {	down = iCommandViewBriefing,					name = _('View briefing on/off'),					category = _('General')},
    {	down = iCommandActivePauseOnOff,				name = _('Active Pause'),							category = _('Cheat')},
    {	down = iCommandPlane_ShowControls,				name = _('Show controls indicator'),				category = _('General')},

    -- Communications
    {	down = iCommandPlaneDoAndHome,					name = _('Flight - Complete mission and RTB'),		category = _('Communications')},
    {	down = iCommandPlaneReturnToBase,				name = _('Flight - RTB'),							category = _('Communications')},
    {	down = iCommandPlaneDoAndBack,					name = _('Flight - Complete mission and rejoin'),	category = _('Communications')},
    {	down = iCommandPlaneFormation,					name = _('Toggle Formation'),						category = _('Communications')},
    {	down = iCommandPlaneJoinUp,						name = _('Join Up Formation'),						category = _('Communications')},
    {	down = iCommandPlaneAttackMyTarget,				name = _('Attack My Target'),						category = _('Communications')},
    {	down = iCommandPlaneCoverMySix,					name = _('Cover Me'),								category = _('Communications')},
    {	down = iCommandAWACSHomeBearing,				name = _('Request AWACS Home Airbase'),				category = _('Communications')},
    {	down = iCommandAWACSBanditBearing,				name = _('Request AWACS Bogey Dope'),				category = _('Communications'), features = {"AWACS Bogey Dope"}},
    {	down = iCommandPlane_EngageGroundTargets,		name = _('Flight - Attack ground targets'),			category = _('Communications')},
    {	down = iCommandPlane_EngageAirDefenses,			name = _('Flight - Attack air defenses'),			category = _('Communications')},
    {	down = iCommandPlane_EngageBandits,				name = _('Flight - Engage Bandits'),				category = _('Communications')},
    {	down = iCommandToggleCommandMenu,				name = _('Communication menu'),						category = _('Communications')},
    {	down = ICommandSwitchDialog,					name = _('Switch dialog'),							category = _('Communications')},
    {	down = ICommandSwitchToCommonDialog,			name = _('Switch to main menu'),					category = _('Communications')},

    -- View
    {combos = {{key = 'JOY_BTN_POV1_L'}},		pressed = iCommandViewLeftSlow,			up = iCommandViewStopSlow,	name = _('View Left slow'),			category = _('View')},
    {combos = {{key = 'JOY_BTN_POV1_R'}},		pressed = iCommandViewRightSlow,		up = iCommandViewStopSlow,	name = _('View Right slow'),		category = _('View')},
    {combos = {{key = 'JOY_BTN_POV1_U'}},		pressed = iCommandViewUpSlow,			up = iCommandViewStopSlow,	name = _('View Up slow'),			category = _('View')},
    {combos = {{key = 'JOY_BTN_POV1_D'}},		pressed = iCommandViewDownSlow,			up = iCommandViewStopSlow,	name = _('View Down slow'),			category = _('View')},
    {combos = {{key = 'JOY_BTN_POV1_UR'}},		pressed = iCommandViewUpRightSlow,		up = iCommandViewStopSlow,	name = _('View Up Right slow'),		category = _('View')},
    {combos = {{key = 'JOY_BTN_POV1_DR'}},		pressed = iCommandViewDownRightSlow,	up = iCommandViewStopSlow,	name = _('View Down Right slow'),	category = _('View')},
    {combos = {{key = 'JOY_BTN_POV1_DL'}},		pressed = iCommandViewDownLeftSlow,		up = iCommandViewStopSlow,	name = _('View Down Left slow'),	category = _('View')},
    {combos = {{key = 'JOY_BTN_POV1_UL'}},		pressed = iCommandViewUpLeftSlow,		up = iCommandViewStopSlow,	name = _('View Up Left slow'),		category = _('View')},
    {											pressed = iCommandViewCenter,										name = _('View Center'),			category = _('View')},

    {	pressed = iCommandViewForwardSlow,		up = iCommandViewForwardSlowStop,		name = _('Zoom in slow'),										category = _('View')},
    {	pressed = iCommandViewBackSlow,			up = iCommandViewBackSlowStop,			name = _('Zoom out slow'),										category = _('View')},
    {	down = iCommandViewAngleDefault,												name = _('Zoom normal'),										category = _('View')},
    {	pressed = iCommandViewExternalZoomIn,	up = iCommandViewExternalZoomInStop,	name = _('Zoom external in'),									category = _('View')},
    {	pressed = iCommandViewExternalZoomOut,	up = iCommandViewExternalZoomOutStop,	name = _('Zoom external out'),									category = _('View')},
    {	down = iCommandViewExternalZoomDefault,											name = _('Zoom external normal'),								category = _('View')},
    {	down = iCommandViewSpeedUp,														name = _('F11 Camera moving forward'),							category = _('View')},
    {	down = iCommandViewSlowDown,													name = _('F11 Camera moving backward'),							category = _('View')},

    {	down = iCommandViewCockpit,														name = _('F1 Cockpit view'),									category = _('View')},
    {	down = iCommandNaturalViewCockpitIn,											name = _('F1 Natural head movement view'),						category = _('View')},
    {	down = iCommandViewHUDOnlyOnOff,												name = _('F1 HUD only view switch'),							category = _('View')},
    {	down = iCommandViewAir,															name = _('F2 Aircraft view'),									category = _('View')},
    {	down = iCommandViewMe,															name = _('F2 View own aircraft'),								category = _('View')},
    {	down = iCommandViewFromTo,														name = _('F2 Toggle camera position'),							category = _('View')},
    {	down = iCommandViewLocal,														name = _('F2 Toggle local camera control'),						category = _('View')},
    {	down = iCommandViewTower,														name = _('F3 Fly-By view'),										category = _('View')},
    {	down = iCommandViewTowerJump,													name = _('F3 Fly-By jump view'),								category = _('View')},
    {	down = iCommandViewRear,														name = _('F4 Look back view'),									category = _('View')},
    {	down = iCommandViewChase,														name = _('F4 Chase view'),										category = _('View')},
    {	down = iCommandViewChaseArcade,													name = _('F4 Arcade Chase view'),								category = _('View')},
    {	down = iCommandViewFight,														name = _('F5 nearest AC view'),									category = _('View')},
    {	down = iCommandViewFightGround,													name = _('F5 Ground hostile view'),								category = _('View')},
    {	down = iCommandViewWeapons,														name = _('F6 Released weapon view'),							category = _('View')},
    {	down = iCommandViewWeaponAndTarget,												name = _('F6 Weapon to target view'),							category = _('View')},
    {	down = iCommandViewGround,														name = _('F7 Ground unit view'),								category = _('View')},
    {	down = iCommandViewTargets,														name = _('F8 Target view'),										category = _('View')},
    {	down = iCommandViewTargetType,													name = _('F8 Player targets/All targets filter'),				category = _('View')},
    {	down = iCommandViewNavy,														name = _('F9 Ship view'),										category = _('View')},
    {	down = iCommandViewLndgOfficer,													name = _('F9 Landing signal officer view'),						category = _('View')},
    {	down = iCommandViewAWACS,														name = _('F10 Theater map view'),								category = _('View')},
    {	down = iCommandViewAWACSJump,													name = _('F10 Jump to theater map view over current point'),	category = _('View')},
    {	down = iCommandViewFree,														name = _('F11 Airport free camera'),							category = _('View')},
    {	down = iCommandViewFreeJump,													name = _('F11 Jump to free camera'),							category = _('View')},
    {	down = iCommandViewStatic,														name = _('F12 Static object view'),								category = _('View')},
    {	down = iCommandViewMirage,														name = _('F12 Civil traffic view'),								category = _('View')},
    {	down = iCommandViewLocomotivesToggle,											name = _('F12 Trains/cars toggle'),								category = _('View')},
    {	down = iCommandViewPitHeadOnOff,												name = _('F1 Head shift movement on / off'),					category = _('View')},

    {	down = iCommandViewFastKeyboard,												name = _('Keyboard Rate Fast'),									category = _('View')},
    {	down = iCommandViewSlowKeyboard,												name = _('Keyboard Rate Slow'),									category = _('View')},
    {	down = iCommandViewNormalKeyboard,												name = _('Keyboard Rate Normal'),								category = _('View')},
    {	down = iCommandViewFastMouse,													name = _('Mouse Rate Fast'),									category = _('View')},
    {	down = iCommandViewSlowMouse,													name = _('Mouse Rate Slow'),									category = _('View')},
    {	down = iCommandViewNormalMouse,													name = _('Mouse Rate Normal'),									category = _('View')},

    -- Cockpit view
    {	down = 3256,	cockpit_device_id = 0,	value_down = 1.0,						name = _('Flashlight'),						category = _('View Cockpit')},

    {	down = iCommandViewTempCockpitOn,		up = iCommandViewTempCockpitOff,		name = _('Cockpit panel view in'),			category = _('View Cockpit')},
    {	down = iCommandViewTempCockpitToggle,											name = _('Cockpit panel view toggle'),		category = _('View Cockpit')},
    --// Save current cockpit camera angles for fast numpad jumps
    {	down = iCommandViewSaveAngles,													name = _('Save Cockpit Angles'),			category = _('View Cockpit')},
    {	pressed = iCommandViewUp,				up = iCommandViewStop,					name = _('View up'),						category = _('View Cockpit')},
    {	pressed = iCommandViewDown,				up = iCommandViewStop,					name = _('View down'),						category = _('View Cockpit')},
    {	pressed = iCommandViewLeft,				up = iCommandViewStop,					name = _('View left'),						category = _('View Cockpit')},
    {	pressed = iCommandViewRight,			up = iCommandViewStop,					name = _('View right'),						category = _('View Cockpit')},
    {	pressed = iCommandViewUpRight,			up = iCommandViewStop,					name = _('View up right'),					category = _('View Cockpit')},
    {	pressed = iCommandViewDownRight,		up = iCommandViewStop,					name = _('View down right'),				category = _('View Cockpit')},
    {	pressed = iCommandViewDownLeft,			up = iCommandViewStop,					name = _('View down left'),					category = _('View Cockpit')},
    {	pressed = iCommandViewUpLeft,			up = iCommandViewStop,					name = _('View up left'),					category = _('View Cockpit')},

    -- Cockpit Camera Motion (������������ ������ � ������)
    {	pressed = iCommandViewPitCameraMoveUp,		up = iCommandViewPitCameraMoveStop,	name = _('Cockpit Camera Move Up'),			category = _('View Cockpit')},
    {	pressed = iCommandViewPitCameraMoveDown,	up = iCommandViewPitCameraMoveStop,	name = _('Cockpit Camera Move Down'),		category = _('View Cockpit')},
    {	pressed = iCommandViewPitCameraMoveLeft,	up = iCommandViewPitCameraMoveStop,	name = _('Cockpit Camera Move Left'),		category = _('View Cockpit')},
    {	pressed = iCommandViewPitCameraMoveRight,	up = iCommandViewPitCameraMoveStop,	name = _('Cockpit Camera Move Right'),		category = _('View Cockpit')},
    {	pressed = iCommandViewPitCameraMoveForward,	up = iCommandViewPitCameraMoveStop,	name = _('Cockpit Camera Move Forward'),	category = _('View Cockpit')},
    {	pressed = iCommandViewPitCameraMoveBack,	up = iCommandViewPitCameraMoveStop,	name = _('Cockpit Camera Move Back'),		category = _('View Cockpit')},
    {	down = iCommandViewPitCameraMoveCenter,											name = _('Cockpit Camera Move Center'),		category = _('View Cockpit')},

    {	down = iCommandViewCameraUp,				up = iCommandViewCameraCenter,		name = _('Glance up'),						category = _('View Cockpit')},
    {	down = iCommandViewCameraDown,				up = iCommandViewCameraCenter,		name = _('Glance down'),					category = _('View Cockpit')},
    {	down = iCommandViewCameraLeft,				up = iCommandViewCameraCenter,		name = _('Glance left'),					category = _('View Cockpit')},
    {	down = iCommandViewCameraRight,				up = iCommandViewCameraCenter,		name = _('Glance right'),					category = _('View Cockpit')},
    {	down = iCommandViewCameraUpLeft,			up = iCommandViewCameraCenter,		name = _('Glance up-left'),					category = _('View Cockpit')},
    {	down = iCommandViewCameraDownLeft,			up = iCommandViewCameraCenter,		name = _('Glance down-left'),				category = _('View Cockpit')},
    {	down = iCommandViewCameraUpRight,			up = iCommandViewCameraCenter,		name = _('Glance up-right'),				category = _('View Cockpit')},
    {	down = iCommandViewCameraDownRight,			up = iCommandViewCameraCenter,		name = _('Glance down-right'),				category = _('View Cockpit')},
    {	down = iCommandViewPanToggle,													name = _('Camera pan mode toggle'),			category = _('View Cockpit')},

    {	down = iCommandViewCameraUpSlow,												name = _('Camera snap view up'),			category = _('View Cockpit')},
    {	down = iCommandViewCameraDownSlow,												name = _('Camera snap view down'),			category = _('View Cockpit')},
    {	down = iCommandViewCameraLeftSlow,												name = _('Camera snap view left'),			category = _('View Cockpit')},
    {	down = iCommandViewCameraRightSlow,												name = _('Camera snap view right'),			category = _('View Cockpit')},
    {	down = iCommandViewCameraUpLeftSlow,											name = _('Camera snap view up-left'),		category = _('View Cockpit')},
    {	down = iCommandViewCameraDownLeftSlow,											name = _('Camera snap view down-left'),		category = _('View Cockpit')},
    {	down = iCommandViewCameraUpRightSlow,											name = _('Camera snap view up-right'),		category = _('View Cockpit')},
    {	down = iCommandViewCameraDownRightSlow,											name = _('Camera snap view down-right'),	category = _('View Cockpit')},
    {	down = iCommandViewCameraCenter,												name = _('Center Camera View'),				category = _('View Cockpit')},
    {	down = iCommandViewCameraReturn,												name = _('Return Camera'),					category = _('View Cockpit')},
    {	down = iCommandViewCameraBaseReturn,											name = _('Return Camera Base'),				category = _('View Cockpit')},

    {	down = iCommandViewSnapView0,				up = iCommandViewSnapViewStop,		name = _('Custom Snap View  0'),			category = _('View Cockpit')},
    {	down = iCommandViewSnapView1,				up = iCommandViewSnapViewStop,		name = _('Custom Snap View  1'),			category = _('View Cockpit')},
    {	down = iCommandViewSnapView2,				up = iCommandViewSnapViewStop,		name = _('Custom Snap View  2'),			category = _('View Cockpit')},
    {	down = iCommandViewSnapView3,				up = iCommandViewSnapViewStop,		name = _('Custom Snap View  3'),			category = _('View Cockpit')},
    {	down = iCommandViewSnapView4,				up = iCommandViewSnapViewStop,		name = _('Custom Snap View  4'),			category = _('View Cockpit')},
    {	down = iCommandViewSnapView5,				up = iCommandViewSnapViewStop,		name = _('Custom Snap View  5'),			category = _('View Cockpit')},
    {	down = iCommandViewSnapView6,				up = iCommandViewSnapViewStop,		name = _('Custom Snap View  6'),			category = _('View Cockpit')},
    {	down = iCommandViewSnapView7,				up = iCommandViewSnapViewStop,		name = _('Custom Snap View  7'),			category = _('View Cockpit')},
    {	down = iCommandViewSnapView8,				up = iCommandViewSnapViewStop,		name = _('Custom Snap View  8'),			category = _('View Cockpit')},
    {	down = iCommandViewSnapView9,				up = iCommandViewSnapViewStop,		name = _('Custom Snap View  9'),			category = _('View Cockpit')},

    {	pressed = iCommandViewForward,				up = iCommandViewForwardStop,		name = _('Zoom in'),						category = _('View Cockpit')},
    {	pressed = iCommandViewBack,					up = iCommandViewBackStop,			name = _('Zoom out'),						category = _('View Cockpit')},

    -- Extended view
    {	down = iCommandViewCameraJiggle,		name = _('Camera jiggle toggle'),					category = _('View Extended')},
    {	down = iCommandViewKeepTerrain,			name = _('Keep terrain camera altitude'),			category = _('View Extended')},
    {	down = iCommandViewFriends,				name = _('View friends mode'),						category = _('View Extended')},
    {	down = iCommandViewEnemies,				name = _('View enemies mode'),						category = _('View Extended')},
    {	down = iCommandViewAll,					name = _('View all mode'),							category = _('View Extended')},
    {	down = iCommandViewPlus,				name = _('Toggle tracking launched weapon'),		category = _('View Extended')},
    {	down = iCommandViewSwitchForward,		name = _('Objects switching direction forward '),	category = _('View Extended')},
    {	down = iCommandViewSwitchReverse,		name = _('Objects switching direction reverse '),	category = _('View Extended')},
    {	down = iCommandViewObjectIgnore,		name = _('Object exclude '),						category = _('View Extended')},
    {	down = iCommandViewObjectsAll,			name = _('Objects all excluded - include'),			category = _('View Extended')},

    -- Padlock
    {	down = iCommandViewLock,				name = _('Lock View (cycle padlock)'),				category = _('View Padlock')},
    {	down = iCommandViewUnlock,				name = _('Unlock view (stop padlock)'),				category = _('View Padlock')},
    {	down = iCommandAllMissilePadlock,		name = _('All missiles padlock'),					category = _('View Padlock')},
    {	down = iCommandThreatMissilePadlock,	name = _('Threat missile padlock'),					category = _('View Padlock')},
    {	down = iCommandViewTerrainLock,			name = _('Lock terrain view'),						category = _('View Padlock')},

    --	Head Tracker View
    {down = iHeadTrackerZoomToggle,			up = iHeadTrackerZoomToggle, 		 value_down = 1.0, value_up = 0.0, name = _('VR tracker Zoom'),			 category = _('Head Tracker')},
    {down = iHeadTrackerSpyglassZoomToggle,	up = iHeadTrackerSpyglassZoomToggle, value_down = 1.0, value_up = 0.0, name = _('VR tracker Spyglass Zoom'), category = _('Head Tracker')},
    {down = iHeadTrackerPosReset,																				   name = _('VR tracker Reset Base'),	 category = _('Head Tracker')},

    -- Labels
    {	down = iCommandMarkerState,				name = _('All Labels'),								category = _('Labels')},
    {	down = iCommandMarkerStatePlane,		name = _('Aircraft Labels'),						category = _('Labels')},
    {	down = iCommandMarkerStateRocket,		name = _('Missile Labels'),							category = _('Labels')},
    {	down = iCommandMarkerStateShip,			name = _('Vehicle & Ship Labels'),					category = _('Labels')},

    --Kneeboard
    {	down = iCommandPlaneShowKneeboard,																				name = _('Kneeboard ON/OFF'),						category = _('Kneeboard')},
    {	down = iCommandPlaneShowKneeboard,	up = iCommandPlaneShowKneeboard,	value_down = 1.0,	value_up = -1.0,	name = _('Kneeboard glance view'),					category = _('Kneeboard')},
    {	down = 3001,	cockpit_device_id = kneeboard_id,						value_down = 1.0,						name = _('Kneeboard Next Page'),					category = _('Kneeboard')},
    {	down = 3002,	cockpit_device_id = kneeboard_id,						value_down = 1.0,						name = _('Kneeboard Previous Page'),				category = _('Kneeboard')},
    {	down = 3003,	cockpit_device_id = kneeboard_id,						value_down = 1.0,						name = _('Kneeboard current position mark point'),	category = _('Kneeboard')},
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

    {down = iCommandPlaneAutopilot, name = _('Autopilot - Attitude Hold'), category = _('Autopilot')},
    {down = iCommandPlaneStabHbar, name = _('Autopilot - Altitude Hold'), category = _('Autopilot')},
    {down = iCommandPlaneStabCancel, name = _('Autopilot Disengage'), category = _('Autopilot')},
    {down = iCommandHelicopter_PPR_button_T_up, name = _('CAS Pitch'), category = _('Autopilot')},
    {down = iCommandHelicopter_PPR_button_K_up, name = _('CAS Roll'), category = _('Autopilot')},
    {down = iCommandHelicopter_PPR_button_H_up, name = _('CAS Yaw'), category = _('Autopilot')},

    --Flight Control
    {down = iCommandPlaneTrimOn, up = iCommandPlaneTrimOff, name = _('T/O Trim'), category = _('Flight Control')},

    {down = iCommandPlaneAirBrakeOn,	up = iCommandPlaneAirBrakeOff,			name = _('HOTAS Airbrake'),					category = _('Systems') },

    -- Systems
    --{down = Keys.FlapUp, name = _('Flaps Up'), category = _('Systems')},
    --{down = Keys.FlapDown, name = _('Flaps Down'), category = _('Systems')},
    --{down = Keys.Flap, name = _('Flaps Up/Down'), category = _('Systems')},
    {down = iCommandPlaneAirRefuel, name = _('Refueling Boom'), category = _('Systems')},
    {down = iCommandPlaneJettisonFuelTanks, name = _('Jettison Fuel Tanks'), category = _('Systems')},
    {down = iCommandPlane_HOTAS_NoseWheelSteeringButton, up = iCommandPlane_HOTAS_NoseWheelSteeringButton, name = _('Nose Gear Maneuvering Range'), category = _('Systems')},
    {down = iCommandPlane_HOTAS_NoseWheelSteeringButtonOff, up = iCommandPlane_HOTAS_NoseWheelSteeringButtonOff, name = _('Nose Wheel Steering'), category = _('Systems')},
    {down = iCommandPlaneWheelBrakeLeftOn, up = iCommandPlaneWheelBrakeLeftOff, name = _('Wheel Brake Left On/Off'), category = _('Systems')},
    {down = iCommandPlaneWheelBrakeRightOn, up = iCommandPlaneWheelBrakeRightOff, name = _('Wheel Brake Right On/Off'), category = _('Systems')},
    {down = iCommandPlaneFSQuantityIndicatorSelectorMAIN, name = _('Fuel Quantity Selector'), category = _('Systems')},
    {down = iCommandPlaneFSQuantityIndicatorTest, up = iCommandPlaneFSQuantityIndicatorTest, value_down = 1, value_up = 0, name = _('Fuel Quantity Test'), category = _('Systems')},
    {down = iCommandPlaneFSQuantityIndicatorSelectorINT,	up = iCommandPlaneFSQuantityIndicatorSelectorINT, value_down = 1,  value_up = 0, 	name = _('Bingo Fuel Index, CW'),  category = _('Systems')},
    {down = iCommandPlaneFSQuantityIndicatorSelectorINT,	up = iCommandPlaneFSQuantityIndicatorSelectorINT, value_down = -1, value_up = 0, 	name = _('Bingo Fuel Index, CCW'), category = _('Systems')},
    {down = iCommandPlaneAntiCollisionLights, name = _('Anti-collision lights'), category = _('Systems')},

    -- self define for EFM
    {down = Keys.YawDamperSwitch, name = _('Yaw Damper Engage'), category = _('Flight Control')},

    {down = Keys.WingPylonSmokeOn,	name = _('Smoke Pod On/Off'),		category = _('Weapons')},
    {down = Keys.NozzleSmokeOn,	name = _('Nozzle Smoke On/Off'),		category = _('Weapons')},

    --HOTAS
    {down = Keys.Flap_Pos_Up,	up = Keys.Flap_Pos_Half,			name = _('HOTAS Flap Up Position'),					category = _('HOTAS') },
    {down = Keys.Flap_Pos_Down,	up = Keys.Flap_Pos_Half,			name = _('HOTAS Flap Down Position'),				category = _('HOTAS') },

    {down = Keys.SpecialSence,			name = _('Tjena Hejsan'),				category = _('Special Function') },
},

-- joystick axes 
axisCommands = {
    {action = iCommandPlaneSelecterHorizontalAbs, name = _('TDC Slew Horizontal')},
    {action = iCommandPlaneSelecterVerticalAbs	, name = _('TDC Slew Vertical')},
    {action = iCommandPlaneRadarHorizontalAbs	, name = _('Radar Horizontal')},
    {action = iCommandPlaneRadarVerticalAbs		, name = _('Radar Vertical')},

    {	action = iCommandViewHorizontalAbs,		name = _('Absolute Camera Horizontal View')},
    {	action = iCommandViewVerticalAbs,		name = _('Absolute Camera Vertical View')},
    {	action = iCommandViewZoomAbs,			name = _('Zoom View')},
    {	action = iCommandViewRollAbs,			name = _('Absolute Roll Shift Camera View')},
    {	action = iCommandViewHorTransAbs,		name = _('Absolute Horizontal Shift Camera View')},
    {	action = iCommandViewVertTransAbs,		name = _('Absolute Vertical Shift Camera View')},
    {	action = iCommandViewLongitudeTransAbs,	name = _('Absolute Longitude Shift Camera View')},

    {action = iCommandPlaneRoll,			name = _('Roll')},
    {action = iCommandPlanePitch,		name = _('Pitch')},
    {action = iCommandPlaneRudder,		name = _('Rudder')},
    {action = iCommandPlaneThrustCommon, name = _('Thrust')},

    {action = iCommandPlaneThrustLeft, name = _('Left Throttle')},
    {action = iCommandPlaneThrustRight, name = _('Right Throttle')},

    {action = iCommandPlaneMFDZoomAbs 			, name = _('MFD Range')},
    {action = iCommandPlaneBase_DistanceAbs 	, name = _('Base/Distance')},

    {action = iCommandWheelBrake,		name = _('Wheel Brake')},
    {action = iCommandLeftWheelBrake,	name = _('Wheel Brake Left')},
    {action = iCommandRightWheelBrake,	name = _('Wheel Brake Right')},

    -- trim
    {action = iCommandPlaneTrimPitch,	name = _('Elevator Trim')},
    },

}

