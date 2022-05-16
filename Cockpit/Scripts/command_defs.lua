start_custom_command   = 10000
local __count_custom = start_custom_command-1
local function __custom_counter()
	__count_custom = __count_custom + 1
	return __count_custom
end


Keys =
{
	PlanePickleOn	= 350,
	PlanePickleOff	= 351,
    PlaneChgWeapon  = 101,
    PlaneChgTargetNext = 102,    -- iCommandPlaneChangeTarget
    PlaneModeNAV    = 105,
    PlaneModeBVR    = 106,
    PlaneModeVS     = 107,
    PlaneModeBore   = 108,
    PlaneModeGround = 111,

	Canopy = 71,
	
	PlaneAirBrake = 73,		
	PlaneAirBrakeOn = 147,
	PlaneAirBrakeOff = 148,	
	
	PlaneFlaps = 72,
	PlaneFlapsOn = 145, -- Fully down
	PlaneFlapsOff = 146, -- Fully up
    	
	PlaneGear = 68,						-- Шасси
	PlaneGearUp	= 430,
	PlaneGearDown = 431,
    
	--LeftEngineStart = 311,			
	--RightEngineStart = 312,			
	--LeftEngineStop = 313,			
	--RightEngineStop = 314,			

	PowerOnOff = 315,

    --[[   -- Do not use the built-in altimeter adjustments, they have internal SSM affects on the altimeter that we cannot limit
    AltimeterPressureIncrease = 316,  
    AltimeterPressureDecrease = 317,
    AltimeterPressureStop = 318,        ]]--

    PlaneLightsOnOff = 175,
    PlaneHeadlightOnOff = 328,

    PowerGeneratorLeft = 711,
    PowerGeneratorRight = 712,

    BatteryPower = 1073,        -- iCommandBatteryPower

    PlaneChgTargetPrev = 1315,   -- iCommandPlaneUFC_STEER_DOWN

    -- 自定义按键从这里开始，可以自动从10000开始增加，避免冲突 --
    ThrottleAxisTest = __custom_counter(),  --油门位置
    EnginesStart = __custom_counter(), --自定义引擎启动输入
    EnginesStop = __custom_counter(), --自定义引擎关闭输入
    EnginesStartStop = __custom_counter(), --自定义引擎开关按下
    EnginesStartStopUp = __custom_counter(), --自定义引擎开关松开

    BrakesOn = __custom_counter(), --自定义刹车
    BrakesOff = __custom_counter(), --自定义刹车关闭

    DragParachute = __custom_counter(), --自定义减速伞释放

    --PlaneFlapsStop = __custom_counter(),      --目前屏蔽手动缝翼
    --PlaneFlapsUpHotas = __custom_counter(),   --
    --PlaneFlapsDownHotas = __custom_counter(), --
    
    SpoilersArmToggle = __custom_counter(),
    SpoilersArmOn = __custom_counter(),
    SpoilersArmOff = __custom_counter(),
    PlaneFireOn		= __custom_counter(), -- replaces iCommandPlaneFire
    PlaneFireOff	= __custom_counter(), -- replaces iCommandPlaneFireOff
    PickleOn = __custom_counter(),  -- replaces iCommandPlanePickleOn
    PickleOff = __custom_counter(), -- replaces iCommandPlanePickleOff

    -- 武器测试用按键
    WeaponSelectNext = __custom_counter(),
    WeaponLaunch = __custom_counter(),

    -- 襟翼动作
    FlapUp = __custom_counter(),
    FlapDown = __custom_counter(),

    ParkingBrakesOn = __custom_counter(),
    ParkingBrakesOff = __custom_counter(),
    ParkingBrakes = __custom_counter(),

    LeftThrottleAxis = __custom_counter(),
    RightThrottleAxis = __custom_counter(),

    LeftThrottleCrank = __custom_counter(),
    RightThrottleCrank = __custom_counter(),

    LeftThrottleCrankUP = __custom_counter(),
    RightThrottleCrankUP = __custom_counter(),

    LeftSpeedDriveUP = __custom_counter(),
    RightSpeedDriveUP = __custom_counter(),

    LeftSpeedDriveDOWN = __custom_counter(),
    RightSpeedDriveDOWN = __custom_counter(),

    NWWSwitch = __custom_counter(),
    CSDSwitch = __custom_counter(),
    AirCondSwitch = __custom_counter(),

    FuelMasterLeft = __custom_counter(),
    FuelMasterRight = __custom_counter(),

    --PowerGeneratorLeft = __custom_counter(),
    --PowerGeneratorRight = __custom_counter(),

    LeftEngineIDLE = __custom_counter(),
    RightEngineIDLE = __custom_counter(),
    
    FuelDisMain = __custom_counter(),
    FuelDisWing = __custom_counter(),
    FuelDisCtr = __custom_counter(),
    FuelDisLout = __custom_counter(),
    FuelDisLin = __custom_counter(),
    FuelDisRin = __custom_counter(),
    FuelDisRout = __custom_counter(),

    FuelTankPressUP = __custom_counter(),
    WingDropTankTransUP = __custom_counter(),
    FuelTankPressDOWN = __custom_counter(),
    WingDropTankTransDOWN = __custom_counter(),
    WingTankDump = __custom_counter(),
    FuseTankDump = __custom_counter(),
    FuelReadyUP = __custom_counter(),
    BoostPumpTestUP = __custom_counter(),
    FuelReadyDOWN = __custom_counter(),
    BoostPumpTestDOWN = __custom_counter(),

    LightStrobeUP = __custom_counter(),
    LightStrobeDOWN = __custom_counter(),
    LightTaxiDOWN = __custom_counter(),
    LightTaxiUP = __custom_counter(),
    LightNaviWingUP = __custom_counter(),
    LightNaviWingDOWN = __custom_counter(),
    LightNaviTailUP = __custom_counter(),
    LightNaviTailDOWN = __custom_counter(),
    LightFormationUP = __custom_counter(),
    LightFormationDOWN = __custom_counter(),
    LightFloodUP = __custom_counter(),
    LightFloodDOWN = __custom_counter(),

    LightConsoleBRT = __custom_counter(),
    LightInstruBRT = __custom_counter(),
    LightApproIndexBRT = __custom_counter(),

    AutoPilotPowerSwitch = __custom_counter(),
    AutoPilotStabSwitch = __custom_counter(),
    AutoPilotCmdSwitch = __custom_counter(),
    AutoPilotAltHoldSwitch = __custom_counter(),
    AutoPilotMachHoldSwitch = __custom_counter(),

    -- ECS aircondition
    AircondMasterSwitch = __custom_counter(),
    AircondAutoManSwitch = __custom_counter(),
    AircondCockpitSwitchUP = __custom_counter(),
    AircondCockpitSwitchDOWN = __custom_counter(),
    AircondCMPTREmerUP = __custom_counter(),
    AircondCMPTREmerDOWN = __custom_counter(),
    DeiceEngine = __custom_counter(),
    DeiceWindShieldUP = __custom_counter(),
    DeiceWindShieldDOWN = __custom_counter(),
    DeicePitot = __custom_counter(),
    AircondTemp = __custom_counter(),
    AircondDefog = __custom_counter(),

    -- UHF radio
    UHFMode = __custom_counter(),
    UHFFreqAUP = __custom_counter(),
    UHFFreqADOWN = __custom_counter(),
    UHFFreqBDOWN = __custom_counter(),
    UHFFreqBUP = __custom_counter(),
    UHFFreqCDOWN = __custom_counter(),
    UHFFreqCUP = __custom_counter(),
    UHFFreqASTOP = __custom_counter(),
    UHFFreqBSTOP = __custom_counter(),
    UHFFreqCSTOP = __custom_counter(),
    UHFGuard = __custom_counter(),
    UHFVolume = __custom_counter(),

    -- TACAN
    TACANMode = __custom_counter(),
    TACANChanA = __custom_counter(),
    TACANChanB = __custom_counter(),

    -- Radio System Antanna
    TACANAntUP = __custom_counter(),
    TACANAntDOWN = __custom_counter(),
    UHFAntUP = __custom_counter(),
    UHFAntDOWN = __custom_counter(),

    -- VDI System
    VDIControlOff = __custom_counter(),
    VDIControlTC = __custom_counter(),
    VDIControlTest = __custom_counter(),
    VDIControlTCCal = __custom_counter(),
    VDIControlAnalog = __custom_counter(),
    VDIControlSTBY = __custom_counter(),

    -- Gear System add-ons

    HookHandle = __custom_counter(),
    LaunchBarHandle = __custom_counter(),

    -- Weapon System
    MasterArmamentUP = __custom_counter(),
    MasterArmamentDOWN = __custom_counter(),

    Pylon1SelUP = __custom_counter(),
    Pylon1SelDOWN = __custom_counter(),
    Pylon2SelUP = __custom_counter(),
    Pylon2SelDOWN = __custom_counter(),
    Pylon3SelUP = __custom_counter(),
    Pylon3SelDOWN = __custom_counter(),
    Pylon4SelUP = __custom_counter(),
    Pylon4SelDOWN = __custom_counter(),
    Pylon5SelUP = __custom_counter(),
    Pylon5SelDOWN = __custom_counter(),

    ReleaseJettison = __custom_counter(),
    ReleaseGun = __custom_counter(),
    ReleaseMissile = __custom_counter(),
    ReleaseRocketSalvo = __custom_counter(),
    ReleaseRocketTrain = __custom_counter(),
    ReleaseBombSalve = __custom_counter(),
    ReleaseBombTrain = __custom_counter(),
    ReleaseStep = __custom_counter(),

    AttackGCB = __custom_counter(),
    AttackDelay = __custom_counter(),
    AttackLabTGT = __custom_counter(),
    AttackLabIP = __custom_counter(),
    AttackRocket = __custom_counter(),
    AttackHILoft = __custom_counter(),
    AttackStraight = __custom_counter(),
    AttackGeneral = __custom_counter(),

    MechArmUP = __custom_counter(),
    MechArmDOWN = __custom_counter(),
    RocketModeSwitch = __custom_counter(),
    GunsModeSwitchUP = __custom_counter(),
    GunsModeSwitchDOWN = __custom_counter(),

    IntervalTumbWheel100 = __custom_counter(),
    IntervalTumbWheel10 = __custom_counter(),
    IntervalTumbWheel = __custom_counter(),

    QuantityTumbWheel10 = __custom_counter(),
    QuantityTumbWheel = __custom_counter(),

    TimeTumbWheel100 = __custom_counter(),
    TimeTumbWheel10 = __custom_counter(),
    TimeTumbWheel = __custom_counter(),

    MissileControl = __custom_counter(),
    MissileCoolingUP = __custom_counter(),
    MissileCoolingDOWN = __custom_counter(),

    --起落架手柄 5001// 5050 EFM - 6000 for EFM
    NoseWheelSteeringOn = 5050,
    NoseWheelSteeringOff = 5051,
    -- LeftEngineOFF = __custom_counter(),
    -- RightEngineOFF = __custom_counter(),
    YawDamperSwitch = 5052,

    -- Weapon Part till 5070
    WingPylonSmokeOn = 5053,
    NozzleSmokeOn = 5054,
    WeaponFireOn = 5055,
    WeaponFireOff = 5056,
    WeaponConfigAll = 5057,
    WeaponConfigSingle = 5058,
    WeaponConfigPairs = 5059,
    WeaponMasterSwitch = 5060,
    WeaponAirGroundChange = 5061,
    GunSightInstall = 5062,
    GunSightUninstall = 5063,

    -- special functions
    SpecialSence = 5070,

    -- Flight Control Key start from 5071 - 5100
    AirbrakePauseMove = 5071,
    Flap_Pos_Up = 5072,
    Flap_Pos_Half = 5073,
    Flap_Pos_Down = 5074,
    
    -- 5100-5500 Navigation input
    -- GNS 430
    COM_Freq_Swap = 5100,
    VLOC_Freq_Swap = 5101,
    Freq_Degi = 5102,
    Freq_Num = 5103,
    Freq_Knob_Push = 5104,
    Nav_Map_range_increse = 5105, -- range + zoom out
    Nav_Map_range_decrease = 5106, -- range -
    Nav_Direct_to = 5107,
    Nav_Menu = 5108,
    Nav_Clear = 5109,
    Nav_Ent = 5110,
    Nav_CDI = 5111,
    Nav_OBS = 5112,
    Nav_MSG = 5113,
    Nav_FPL = 5114,
    Nav_PROC = 5115,
    Nav_Right_Knob_L = 5116,
    Nav_Right_Knob_S = 5117,
    Nav_Right_Knob_Push = 5118,
    Nav_Vol_PWR = 5119,
    Nav_Vol = 5120,
    -- SN3500
    Nav_Course_Sel = 5150,
    Nav_Heading_Sel = 5151,
    -- EADI
    Display_Brighter = 5200,
    Display_Darker = 5201,
    EALT_BARO = 5202,

    -- 5500 - 5550 Engine Conrol
    L_LP_PUMP = 5501,
    R_LP_PUMP = 5502,
    L_HP_PUMP = 5503,
    R_HP_PUMP = 5504,
    L_STARTER_PRESS = 5505,
    R_STARTER_PRESS = 5506,
    L_STARTER_RELEASE = 5507,
    R_STARTER_RELEASE = 5508,
    L_THROTTLE_IDLE = 5509,
    R_THROTTLE_IDLE = 5510,
    L_THROTTLE_SETIDLE = 5511,
    L_THROTTLE_SETOFF = 5512,
    R_THROTTLE_SETIDLE = 5513,
    R_THROTTLE_SETOFF = 5514,

    -- 5601 - 5700 for UHF radio
    UHF_Vol_Up = 5601,
    UHF_Vol_Down = 5602,
    UHF_SQLACK_Up = 5603,
    UHF_SQLACK_Down = 5604,
    UHF_Mode_Left = 5605,
    UHF_Mode_Right = 5606,
    UHF_TAKE_Button_Press = 5607,
    UHF_TAKE_Button_Release = 5608,
    UHF_Vol = 5609,
    UHF_Key_0 = 5610,
    UHF_Key_1 = 5611,
    UHF_Key_2 = 5612,
    UHF_Key_3 = 5613,
    UHF_Key_4 = 5614,
    UHF_Key_5 = 5615,
    UHF_Key_6 = 5616,
    UHF_Key_7 = 5617,
    UHF_Key_8 = 5618,
    UHF_Key_9 = 5619,
    UHF_Key_MAN = 5620,
    UHF_Key_ENT = 5621,
    RadioUpdate = 5622,
}

--从5000开始递增点击指令
start_command   = 5000
local __count_click = start_command-1
local function __click_counter()
	__count_click = __count_click + 1
	return __count_click
end


click_cmd =
{
    GearLevel = __click_counter(), --起落架手柄
}