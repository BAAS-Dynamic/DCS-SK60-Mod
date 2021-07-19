--初始化座舱模型
shape_name   	   = "Cockpit_SK_60"
is_EDM			   = true
new_model_format   = true

-- 一些颜色定义，基本没啥用
ambient_light    = {255,255,255}
ambient_color_day_texture    = {72, 100, 160}
ambient_color_night_texture  = {40, 60 ,150}
ambient_color_from_devices   = {50, 50, 40}
ambient_color_from_panels	 = {35, 25, 25}

-- 一些不用动的数据
dusk_border					 = 0.4
draw_pilot					 = false

-- 定义外部舱盖模型的arg值
external_model_canopy_arg	 = 38

-- 是否使用外部模型的座舱（指是否默认设置好114隐藏外部模型的座舱
use_external_views = false

local controllers = LoRegisterPanelControls()

day_texture_set_value   = 0.0
night_texture_set_value = 0.1

-- mirror settings
mirrors_data = {
    center_point      = { 0.418, 0.054 , 0.0 }, --{ 0.279, 0.4, 0.00 }, difference from cockpit_local_point {3.1, 0.55, 0.0},
    width 			  = 0.7, --integrated (keep in mind that mirrors can be none planar old=0.7)
    aspect 			  = 1,--0.8/0.3,
	rotation 	 	  = math.rad(0);
	animation_speed   = 2.0;
	near_clip 		  = 0.1;
	middle_clip		  = 100;		
	far_clip		  = 60000;	
	arg_value_when_on = 1.0;
}

TEMP_VAR = {}

-- 这是封装的设置舱内动画与parameter绑定的函数

function create_cockpit_animation_controller(input_num, set_parameter, _arg_number, _input, _output)
    if (_input == nil) then
        _input = {-1,1}
    end
    if (_output == nil) then
        _output = {-1,1}
    end
    TEMP_VAR[input_num] = CreateGauge("parameter")
    TEMP_VAR[input_num].arg_number		    = _arg_number
    TEMP_VAR[input_num].input				= _input
    TEMP_VAR[input_num].output			    = _output
    TEMP_VAR[input_num].parameter_name		= set_parameter
end

counter_rec = 0

function _counter()
    counter_rec = counter_rec + 1
    return(counter_rec)
end

animation_list = {
    {"AOA_IND", 301},
    {"RADAR_ALT_IND", 302},
    {"RPM_L", 303},
    {"RPM_R", 304},
    {"EGT_L", 305},
    {"EGT_R", 306},
    {"FF_L", 307},
    {"FF_R", 308},
    {"PT_L", 309},
    {"PT_R", 310},
    {"OP_L", 311},
    {"OP_R", 312},
    {"AIRBREAK_IND", 316},
    {"NoseWPOS_IND",318},
    {"MainLWPOS_IND", 319},
    {"MainRWPOS_IND", 320},
    {"AIR_SPEED", 321},
    {"MACH_IND", 322},
    {"G_METER", 323},
    {"GYRO_ROLL", 324},
    {"GYRO_PITCH", 325},
    {"CLOCK_H", 326},
    {"CLOCK_M", 327},
    {"CLOCK_S", 328},
    {"OXY_QUAN", 329},
    {"BARO_ALT", 330},
    {"BARO_x1H", 331},
    {"BARO_x1K", 332},
    {"BARO_x1W", 333},
    {"QNH_x1K", 334},
    {"QNH_x100", 335},
    {"QNH_x10", 336},
    {"QNH_x1", 337},
    {"BARO_POWER", 338},
    {"CLIMB_RATE", 339},
    {"SLIDE_IND", 340},
    {"HSI_COMPASS", 341},
    {"HSI_COURSE", 342},
    {"HSI_CRS_TOF", 343},
    {"HSI_HEADING", 344},
    {"HSI_TACAN", 345},
    {"HSI_ADF", 346},
    {"HSI_T_D_x1k", 347},
    {"HSI_T_D_x100", 348},
    {"HSI_T_D_x10", 349},
    {"HSI_T_D_x1", 350},
    {"HSI_HDG_x100", 351},
    {"HSI_HDG_x10", 352},
    {"HSI_HDG_x1", 353},
    {"FUEL_QUAN_IN", 354},
    {"FUEL_QUAN_SEL", 355},
    {"FUEL_QUAN_A_x1W", 356},
    {"FUEL_QUAN_A_x1K", 357},
    {"FUEL_QUAN_A_x100", 358},
    {"FUEL_QUAN_A_x10", 359},
    {"FUEL_QUAN_A_x1", 360},
	{"NoseWPOS_IND", 318},
	{"MainLWPOS_IND", 319},
	{"MainRWPOS_IND", 320},

    {"Inside_Canopy", 38, {0, 1}, {1, 0}},

    {"PTN_109", 109},
    {"PTN_110", 110},
    {"PTN_112", 112},
    {"PTN_113", 113},
    {"PTN_114", 114},
    {"PTN_115", 115},
    {"PTN_116", 116},
    {"PTN_117", 117},
	{"PTN_131", 131},
    {"PTN_132", 132},
    
    {"PTN_601", 601},
}

--[[
    animation_list[_counter] = {"RPM_L", 303}
    animation_list[_counter] = {"RPM_R", 304}
    animation_list[_counter] = {"EGT_L", 305}
    animation_list[_counter] = {"EGT_R", 306}
    animation_list[_counter] = {"FF_L", 307}
    animation_list[_counter] = {"FF_R", 308}
    animation_list[_counter] = {"RPM_L", 303}
]]

for k,v in pairs(animation_list) do
    create_cockpit_animation_controller(k,v[1],v[2],v[3],v[4])
end


-- This is the definition of the traditional model standard
--Initialize cockpit animation

--Controls
Landinggearhandle					= CreateGauge("parameter")
Landinggearhandle.arg_number		= 50
Landinggearhandle.input				= {0, 1}
Landinggearhandle.output			= {0, 1}
Landinggearhandle.parameter_name	= "LandingGearLevel"


StickPitch							= CreateGauge()
StickPitch.arg_number				= 2
StickPitch.input					= {-100, 100}
StickPitch.output					= {-1, 1}
StickPitch.controller				= controllers.base_gauge_StickPitchPosition

StickBank							= CreateGauge()
StickBank.arg_number				= 1
StickBank.input						= {-100, 100}
StickBank.output					= {1, -1}
StickBank.controller				= controllers.base_gauge_StickRollPosition

ThrottleLeft						= CreateGauge()
ThrottleLeft.arg_number				= 104
ThrottleLeft.input					= {0, 1}
ThrottleLeft.output					= {0, 1}
ThrottleLeft.parameter_name			= "EFM_LEFT_THRUST_A"

ThrottleRight						= CreateGauge()
ThrottleRight.arg_number			= 105
ThrottleRight.input					= {0, 1}
ThrottleRight.output				= {0, 1}
ThrottleRight.parameter_name		= "EFM_RIGHT_THRUST_A"

--INSTRUMENTS--
LeftRPM								= CreateGauge ()
LeftRPM.arg_number					= 303
LeftRPM.input						= {0, 120}
LeftRPM.output						= {0, 1}
LeftRPM.controller					= controllers.base_gauge_EngineLeftRPM

RightRPM							= CreateGauge ()
RightRPM.arg_number					= 304
RightRPM.input						= {0, 120}
RightRPM.output						= {0, 1}
RightRPM.controller					= controllers.base_gauge_EngineRightRPM

Fuel									= CreateGauge ()
Fuel.arg_number						= 354
Fuel.input							= {0, 1134}
Fuel.output							= {0, 1}
Fuel.controller						= controllers.base_gauge_TotalFuelWeight


need_to_be_closed = false