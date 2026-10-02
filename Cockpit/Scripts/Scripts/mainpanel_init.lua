--Initialize cockpit model
shape_name   	   = "Cockpit_SK_60"
is_EDM			   = true
new_model_format   = true

-- Some color definitions are basically useless
ambient_light    = {255,255,255}
ambient_color_day_texture    = {72, 100, 160}
ambient_color_night_texture  = {40, 60 ,150}
ambient_color_from_devices   = {50, 50, 40}
ambient_color_from_panels	 = {35, 25, 25}

-- Some untouched data
dusk_border					 = 0.4
draw_pilot					 = false

-- Define the arg value of the external hatch model
external_model_canopy_arg	 = 38

-- Whether to use the cockpit of the external model (referring to whether 114 is set to hide the cockpit of the external model by default)
use_external_views = false

local controllers = LoRegisterPanelControls()

day_texture_set_value   = 0.0
night_texture_set_value = 0.1

-- mirror settings
mirrors_data = {
 center_point        = {0.4, 0.03 , 0.1}, --F/B,U/D,L/R location of reflection image generation--{ 0.279, 0.4, 0.00 } 0.279, 0.3, 0.00, difference from cockpit_local_point {2.00, 0.2553,-0.2576},
    width               = 2.2, --integrated (keep in mind that mirrors can be none planar old=0.7)
    aspect              = 2,
    rotation            = math.rad(-6),
    animation_speed     = 2.0,
    near_clip           = 0.10,
    middle_clip         = 20,
    far_clip            = 60000,
    arg_value_when_on   = 1.0,
}

mirrors_draw                    = CreateGauge()
mirrors_draw.arg_number         = 16
mirrors_draw.input              = {0,1}
mirrors_draw.output             = {1,0}
mirrors_draw.controller         = controllers.mirrors_draw


TEMP_VAR = {}

-- This is an encapsulated function that sets the cabin animation and binds parameters.

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
    {"N1_NEEDLE_LEFT", 301},
    {"N1_NEEDLE_RIGHT", 302},
    {"RPM_LEFT", 303},
    {"RPM_RIGHT", 304},
    {"EGT_LEFT", 305},
    {"EGT_RIGHT", 306},
    {"OP_LEFT", 307},
    {"OP_RIGHT", 308},
    {"OT_LEFT", 309},
    {"OT_RIGHT", 310},
    --{"OP_L", 311},
    --{"OP_R", 312},
    {"AIRBREAK_IND", 316},
    {"NoseWPOS_IND",318},
    {"MainLWPOS_IND", 319},
    {"MainRWPOS_IND", 320},
    {"MACH_IND", 322},
    -- {"G_METER", 323},
    {"G_CURRENT_EFM", 323},
    {"G_MAX_EFM", 324},
    {"GYRO_ROLL", 335},
    {"GYRO_PITCH", 334},

    -- new clock
    {"CLOCK_H", 343},
    {"CLOCK_M", 342},
    {"CLOCK_S", 344},

    {"OXY_QUAN", 329},
    {"ALT_XH_ANALOG", 430},
    {"BARO_x1H", 431},
    {"BARO_x1K", 432},
    {"BARO_x1W", 433},
    {"QNH_x1K", 434},
    {"QNH_x100", 435},
    {"QNH_x10", 436},
    {"QNH_x1", 437},
    {"CLIMB_RATE", 339},
    {"SLIDE_IND", 340}, -- slip indicator
    {"HSI_COMPASS", 341},
    {"HSI_CDI", 742},
    {"HSI_COURSE_NEEDLE", 752},
    {"HSI_HEADING_BUG", 753},
    {"HSI_COURSE", 3420},
    -- Preserve all three flag positions: -1=FROM/down, 0=OFF, 1=TO/up.
    {"HSI_CRS_TOF", 3430, {-1, 1}, {-1, 1}},
    {"HSI_HEADING", 3440},
    {"HSI_TACAN", 345},
    {"HSI_ADF", 346},
    {"HSI_T_D_x1k", 347},
    {"HSI_T_D_x100", 348},
    {"HSI_T_D_x10", 349},
    {"HSI_T_D_x1", 350},
    {"HSI_HDG_x100", 351},
    {"HSI_HDG_x10", 352},
    {"HSI_HDG_x1", 353},
    {"BACKUP_ADI_PITCH", 660},
    {"BACKUP_ADI_BANK", 661},
	{"FUEL_QUAN_LEFT", 354},
    {"FUEL_QUAN_RIGHT", 355},
    {"FUEL_QUAN_A_x1W", 356},
    {"FUEL_QUAN_A_x1K", 357},
    {"FUEL_QUAN_A_x100", 358},
    {"FUEL_QUAN_A_x10", 359},
    {"FUEL_QUAN_A_x1", 360},

    -- Bind the condensation model parameter to the cockpit EDM. Writing an
    -- aircraft draw argument only drives the external model; cockpit argument
    -- 5002 needs a panel gauge to make the canopy-glass fog visible in-cockpit.
    {"CONDENSATION_GLASS_FOG", 5002, {0, 1}, {0, 1}},
    {"RUDDER_PADDLE", 3, {-1, 1}, {1, -1}},
    -- Pedal travel is independent of pressure retained by the parking brake.
    {"BRAKE_PEDAL_LEFT", 4},
    {"BRAKE_PEDAL_RIGHT", 5},
    {"PARKINGBREAK_HANDLE", 7, {0, 1}, {0, 1}},

    {"PTN_109", 109},
    {"PTN_110", 110},
    {"PTN_112", 112},
    {"PTN_113", 113},
    {"PTN_114", 114},
    {"PTN_115", 115},
    {"PTN_116", 116},
    {"PTN_117", 117},
    {"PTN_120", 120, {0, 1}, {0, 1}}, -- Thrust breaker arming switch
    {"PTN_51", 51, {0, 1}, {0, 1}}, -- Ejection seat safety lever
	{"PTN_131", 131}, --{0, 1}, {0.12, 0.19}},
    {"PTN_132", 132}, --{0, 1}, {0.7, 1}},

    {"PTN_136", 136}, --{0, 1}, {0.12, 0.19}},
    {"PTN_137", 137}, --{0, 1}, {0.7, 1}},
    
    {"PTN_601", 601},

    -- Transponder code wheels, power switch, and momentary IDENT button.
    {"XPDR_DIGIT_1", 200, {0, 7}, {0, 1}},
    {"XPDR_DIGIT_2", 201, {0, 7}, {0, 1}},
    {"XPDR_DIGIT_3", 202, {0, 7}, {0, 1}},
    {"XPDR_DIGIT_4", 203, {0, 7}, {0, 1}},
    {"XPDR_POWER", 204, {0, 1}, {0, 1}},
    {"XPDR_IDENT", 209, {0, 1}, {0, 1}},

    -- Airbrake Ind
    {"AIRBRAKE_IND", 316},
    {"FLAP_LEVEL", 43},

    -- Electric power
    {"PTN_401", 401}, -- Main Power
    {"PTN_402", 402}, -- Left Gen
    {"PTN_404", 404}, -- Right Gen
    {"PTN_417", 417}, -- Nav Bus

    -- Engine
    {"PTN_405", 405}, -- Left Engine Motor Starter
    {"PTN_406", 406}, -- Left Main Fuel Pump
    {"PTN_407", 407}, -- Right Engine Motor Starter
    {"PTN_408", 408}, -- Left Main Fuel Pump
    {"PTN_418", 418}, -- Left Low Pressure Fuel Pump
    {"PTN_420", 420}, -- Right Low Pressure Fuel Pump
    {"PTN_604", 604}, -- Left throttle idle
    {"PTN_605", 605}, -- Right Throttle Idle

    -- Weapon panel
    {"PTN_413", 413},
    {"PTN_414", 414},

    -- generator
    {"PTN_415", 415},
    {"PTN_422", 422},

    -- gun sight
    {"GUN_SIGHT", 915},
    -- Grip safety trigger (0 = safe, 1 = armed)
    {"WEAPON_SAFETY_TRIGGER", 916},

    {"PTN_424", 424}, -- Nav light
    {"PTN_429", 429}, -- Anti Col light
    {"PTN_121", 121}, -- Taxi/landing light; 436 is reserved for a QNH roll.

    -- EADI
    {"PTN_501", 501},
    {"PTN_502", 502},

    {"RUDDER_PADEL", 3},
    {"STICK_PITCH", 1, {-1, 1}, {1, -1}},
    {"STICK_ROLL", 2},
    {"EFM_LEFT_THRUST_A", 104},
    {"EFM_RIGHT_THRUST_A", 105},
    -- Use the Lua metric IAS calibration from basic_flight_instru.lua.
    -- AIRSPEED_IND is driven by the EFM's knot-based fallback curve and under-reads the km/h gauge.
    {"AIR_SPEED", 321},
    {"TURN_RATE_IND", 338},

    {"POD_SMOKE", 902},
    {"NOZZLE_SMOKE", 903},

    -- GNS 430
    {"PTN_509", 509},
    {"PTN_510", 510},
    {"PTN_511", 511},
    {"PTN_512", 512},
    {"PTN_513", 513},
    {"PTN_514", 514},
    {"PTN_515", 515},
    {"PTN_516", 516},
    {"PTN_517", 517},
    {"PTN_518", 518},
    {"PTN_519", 519},
    {"PTN_520", 520},
    {"PTN_521", 521},
    {"PTN_522", 522},
    {"PTN_523", 523},
    {"PTN_524", 524},

    -- NAV Unit (power knob animations driven by nav_system.lua)
    {"PTN_718", 718},
    {"PTN_735", 735},
    {"PTN_751", 751},
    {"RNAV_EDIT_SEGMENT_CARD", 736, {0, 1}, {0, 1}},
   
    -- warning panel
    {"FIRE_L_ENG"   , 500}, 
    {"CANOPY"       , 501},
    {"FIRE_R_ENG"   , 502},
    {"FUEL_L_ENG"   , 503},
    {"THRUST_BREAKER", 504},
    {"FUEL_R_ENG"   , 505},
    {"OIL_L_ENG"    , 506},
    {"BRAKE"        , 507}, 
    {"OIL_R_ENG"    , 508}, 
    {"HYDRO_L"      , 509}, 
    {"CONVERT_A"    , 510}, 
    {"HYDRO_R"      , 511}, 
    {"GEN_L"        , 512}, 
    {"CONVERT_B"    , 513}, 
    {"GEN_R"        , 514},
    {"FLAP_GEAR_WARN", 317},
    {"MASTER_WARN"  , 135},

    -- FR33 frequency rolls
    {"FR33_DIAL_100MHZ", 950, {0, 1}, {0, 1}},
    {"FR33_DIAL_10MHZ", 951, {0, 1}, {0, 1}},
    {"FR33_DIAL_1MHZ", 952, {0, 1}, {0, 1}},
    {"FR33_DIAL_100KHZ", 953, {0, 1}, {0, 1}},
    {"FR33_DIAL_10KHZ", 954, {0, 1}, {0, 1}},
    {"FR33_DIAL_1KHZ", 955, {0, 1}, {0, 1}},

    -- show the ias panel
    {"IAS_TEXT", 900},
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

-- DCS's base canopy controller drives more than the cockpit animation: it
-- also publishes the canopy state used by the built-in cockpit sound mix.
-- A plain parameter gauge bypasses that integration and leaves external
-- aircraft sound permanently in the same open/closed mix.
Canopy = CreateGauge()
Canopy.arg_number = 38
Canopy.input = {0, 1}
Canopy.output = {0, 0.9}
Canopy.controller = controllers.base_gauge_CanopyPos


-- This is the definition of the traditional model standard
--Initialize cockpit animation

--Controls
Landinggearhandle					= CreateGauge("parameter")
Landinggearhandle.arg_number		= 83
Landinggearhandle.input				= {0, 1}
Landinggearhandle.output			= {0, 1}
Landinggearhandle.parameter_name	= "PTN_083"

--[[
Fuel								= CreateGauge ()
Fuel.arg_number						= 354
Fuel.input							= {0, 1640}
Fuel.output							= {0, 1}
Fuel.controller						= controllers.base_gauge_TotalFuelWeight
]]--


local function create_parameter_gauge(parameter_name, arg_number, input_range, output_range)
    local gauge = CreateGauge("parameter")
    gauge.arg_number = arg_number
    gauge.input = input_range
    gauge.output = output_range
    gauge.parameter_name = parameter_name
    return gauge
end

local visibility_range = {0, 1}
local head_motion_range = {-1, 1}

PilotDraw = create_parameter_gauge("pilotToggle", 3100, visibility_range, visibility_range)
LeftPilotBodyDraw = create_parameter_gauge("LEFT_PILOT_BODY_VISIBLE", 3101, visibility_range, visibility_range)
LeftPilotHeadDraw = create_parameter_gauge("LEFT_PILOT_HEAD_VISIBLE", 3102, visibility_range, visibility_range)
RightPilotBodyDraw = create_parameter_gauge("RIGHT_PILOT_BODY_VISIBLE", 3103, visibility_range, visibility_range)
RightPilotHeadDraw = create_parameter_gauge("RIGHT_PILOT_HEAD_VISIBLE", 3104, visibility_range, visibility_range)

CockpitLeftPilotHeadLR = create_parameter_gauge("PILOT_HEAD_YAW", 40, head_motion_range, head_motion_range)
CockpitLeftPilotHeadUD = create_parameter_gauge("COCKPIT_LEFT_PILOT_HEAD_UD", 99, head_motion_range, head_motion_range)
CockpitRightPilotHeadLR = create_parameter_gauge("COPILOT_HEAD_YAW", 336, head_motion_range, head_motion_range)

CockpitPilotBodyLeanLR = create_parameter_gauge("COCKPIT_PILOT_BODY_LEAN_LR", 800, head_motion_range, head_motion_range)
CockpitPilotHeadLeanLR = create_parameter_gauge("COCKPIT_PILOT_HEAD_LEAN_LR", 801, head_motion_range, head_motion_range)
CockpitPilotEyesLR = create_parameter_gauge("COCKPIT_PILOT_EYES_LR", 802, head_motion_range, head_motion_range)
CockpitPilotEyesUD = create_parameter_gauge("COCKPIT_PILOT_EYES_UD", 803, head_motion_range, head_motion_range)
CockpitPilotEyesBlink = create_parameter_gauge("COCKPIT_PILOT_EYES_BLINK", 804, visibility_range, visibility_range)
CockpitPilotClearVisor = create_parameter_gauge("COCKPIT_PILOT_CLEAR_VISOR", 805, visibility_range, visibility_range)
CockpitPilotTintedVisor = create_parameter_gauge("COCKPIT_PILOT_TINTED_VISOR", 806, visibility_range, visibility_range)



need_to_be_closed = false

--SOUNDS
dofile(LockOn_Options.common_script_path.."tools.lua")


-- get_player_crew_index()  -- this function can be used to get the index of the player crew in a multi-crew aircraft
