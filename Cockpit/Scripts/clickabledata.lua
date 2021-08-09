dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."devices.lua")

local gettext = require("i_18n")
_ = gettext.translate

cursor_mode = 
{ 
    CUMODE_CLICKABLE = 0,
    CUMODE_CLICKABLE_AND_CAMERA  = 1,
    CUMODE_CAMERA = 2,
};

clickable_mode_initial_status  = cursor_mode.CUMODE_CLICKABLE
use_pointer_name			   = true

cursor_mode = 
{
    CUMODE_CLICKABLE = 0,
    CUMODE_CLICKABLE_AND_CAMERA = 1,
    CUMODE_CAMERA = 2
}

clickable_mode_initial_status = cursor_mode.CUMODE_CLICKABLE
use_pointer_name = true
anim_speed_default = 16

function default_button(hint_, device_, command_, command2_,arg_, arg_val_, arg_lim_, sound_)
    local arg_val_ = arg_val_ or 1
    local arg_lim_ = arg_lim_ or {0, 1}

    return {
        class = {class_type.BTN},
        hint = hint_,
        device = device_,
        action = {command_},
        stop_action = {command2_},
        arg = {arg_},
        arg_value = {arg_val_},
        arg_lim = {arg_lim_},
        use_release_message = {true},
        sound = sound_ and {{sound_}, {sound_}} or nil
    }
end

-- not in use
function default_1_position_tumb(hint_, device_, command_, arg_, arg_val_, arg_lim_)
    local arg_val_ = arg_val_ or 1
    local arg_lim_ = arg_lim_ or {0, 1}
    return {
        class = {class_type.TUMB},
        hint = hint_,
        device = device_,
        action = {command_},
        arg = {arg_},
        arg_value = {arg_val_},
        arg_lim = {arg_lim_},
        updatable = true,
        use_OBB = true
    }
end

function default_2_position_tumb(hint_, device_, command_, arg_, animation_speed_, sound_)
    local animation_speed_ = animation_speed_ or anim_speed_default
    return {
        class           = {class_type.TUMB, class_type.TUMB},
        hint            = hint_,
        device          = device_,
        action          = {command_, command_},
        arg             = {arg_, arg_},
        arg_value       = {1, -1},
        arg_lim         = {{0, 1}, {0, 1}},
        updatable       = true,
        use_OBB         = true,
        animated        = {true, true},
        animation_speed = {animation_speed_, animation_speed_},
        sound           = sound_ and {{sound_, sound_}} or nil
    }
end

function default_multi_position_tumb(hint_, device_, command1_, command2_, arg_, animation_speed_, sound_)
    local animation_speed_ = animation_speed_ or anim_speed_default
    return {
        class           = {class_type.TUMB, class_type.TUMB},
        hint            = hint_,
        device          = device_,
        action          = {command1_, command2_},
        arg             = {arg_, arg_},
        arg_value       = {1, -1},
        arg_lim         = {{0, 1}, {0, 1}},
        updatable       = true,
        use_OBB         = true,
        animated        = {true, true},
        animation_speed = {animation_speed_, animation_speed_},
        sound           = sound_ and {{sound_, sound_}} or nil
    }
end

function default_3_position_tumb(hint_, device_, command_, arg_, cycled_, inversed_, sound_, animation_speed_)
    local animation_speed_ = animation_speed_ or anim_speed_default
    local cycled = false

    local val = 1
    if inversed_ then
        val = -1
    end

    if cycled_ ~= nil then
        cycled = cycled_
    end

    return {
        class           = {class_type.TUMB, class_type.TUMB},
        hint            = hint_,
        device          = device_,
        action          = {command_, command_},
        arg             = {arg_, arg_},
        arg_value       = {val, -val},
        arg_lim         = {{-1, 1}, {-1, 1}},
        updatable       = true,
        use_OBB         = true,
        cycle           = cycled,
        animated        = {true, true},
        animation_speed = {animation_speed_, animation_speed_},
        sound           = sound_ and {{sound_, sound_}} or nil
    }
end

function springloaded_3_pos_tumb(hint_, device_, command_, command2_, command3_, command4_, arg_, inversed_, sound_, animation_speed_)
    local animation_speed_ = animation_speed_ or anim_speed_default
    local val = 1
    if inversed_ then
        val = -1
    end

    return {
        class               = {class_type.BTN, class_type.BTN},
        hint                = hint_,
        device              = device_,
        action              = {command_, command3_},
        stop_action         = {command2_, command4_},
        arg                 = {arg_, arg_},
        arg_value           = {val, -val},
        arg_lim             = {{-1, 1}, {-1, 1}},
        updatable           = true,
        use_OBB             = true,
        use_release_message = true,
        animated            = {true, true},
        animation_speed     = {animation_speed_, animation_speed_},
        sound               = sound_ and {{sound_, sound_}} or nil
    }
end

-- rotary axis with no end stops. suitable for continuously rotating knobs
function default_axis(hint_, device_, command_, arg_, default_, gain_, updatable_, relative_)
    local default = default_ or 1
    local gain = gain_ or 0.1
    local updatable = updatable_ or false
    local relative = relative_ or false

    return {
        class       = {class_type.LEV},
        hint        = hint_,
        device      = device_,
        action      = {command_},
        arg         = {arg_},
        arg_value   = {default},
        arg_lim     = {{0, 1}},
        updatable   = updatable,
        use_OBB     = true,
        gain        = {gain},
        relative    = {relative}
    }
end

function default_axis_limited(hint_, device_, command_, arg_, default_, gain_, updatable_, relative_, arg_lim_)
    local default = default_ or 0
    local updatable = updatable_ or false
    local relative = relative_ or false

    local gain = gain_ or 0.1
    return {
        class       = {class_type.LEV},
        hint        = hint_,
        device      = device_,
        action      = {command_},
        arg         = {arg_},
        arg_value   = {default},
        arg_lim     = {arg_lim_},
        updatable   = updatable,
        use_OBB     = false,
        gain        = {gain},
        relative    = {relative},
        cycle       = false
    }
end

function default_movable_axis(hint_, device_, command_, arg_, default_, gain_, updatable_, relative_)
    local default = default_ or 1
    local gain = gain_ or 0.1
    local updatable = updatable_ or false
    local relative = relative_ or false

    return {
        class = {class_type.MOVABLE_LEV},
        hint = hint_,
        device = device_,
        action = {command_},
        arg = {arg_},
        arg_value = {default},
        arg_lim = {{0, 1}},
        updatable = updatable,
        use_OBB = true,
        gain = {gain},
        relative = {relative}
    }
end

-- not in use. this multiple position switch is cyclable.
function multiposition_switch(hint_, device_, command_, arg_, count_, delta_, inversed_, min_, sound_, animation_speed_)
    local animation_speed_ = animation_speed_ or anim_speed_default

    local min_ = min_ or 0
    local delta_ = delta_ or 0.5

    local inversed = 1
    if inversed_ then
        inversed = -1
    end

    return {
        class           = {class_type.TUMB, class_type.TUMB},
        hint            = hint_,
        device          = device_,
        action          = {command_, command_},
        arg             = {arg_, arg_},
        arg_value       = {-delta_ * inversed, delta_ * inversed},
        arg_lim         = {
                            {min_, min_ + delta_ * (count_ - 1)},
                            {min_, min_ + delta_ * (count_ - 1)}
                        },
        updatable       = true,
        use_OBB         = true,
        animated        = {true, true},
        animation_speed = {animation_speed_, animation_speed_},
        sound           = sound_ and {{sound_, sound_}} or nil
    }
end

function multiposition_switch_limited(hint_, device_, command_, arg_, count_, delta_, inversed_, min_, sound_, animation_speed_)
    local animation_speed_ = animation_speed_ or anim_speed_default

    local min_ = min_ or 0
    local delta_ = delta_ or 0.5

    local inversed = 1
    if inversed_ then
        inversed = -1
    end

    return {
        class           = {class_type.TUMB, class_type.TUMB},
        hint            = hint_,
        device          = device_,
        action          = {command_, command_},
        arg             = {arg_, arg_},
        arg_value       = {-delta_ * inversed, delta_ * inversed},
        arg_lim         = {
                            {min_, min_ + delta_ * (count_ - 1)},
                            {min_, min_ + delta_ * (count_ - 1)}
                        },
        updatable       = true,
        use_OBB         = true,
        cycle           = false,
        animated        = {true, true},
        animation_speed = {animation_speed_, animation_speed_},
        sound           = sound_ and {{sound_, sound_}} or nil
    }
end

-- rotary axis with push button
function default_button_axis(hint_, device_, command_1, command_2, arg_1, arg_2, limit_1, limit_2)
    local limit_1_ = limit_1 or 1.0
    local limit_2_ = limit_2 or 1.0
    return {
        class               = {class_type.BTN, class_type.LEV},
        hint                = hint_,
        device              = device_,
        action              = {command_1, command_2},
        stop_action         = {command_1, 0},
        arg                 = {arg_1, arg_2},
        arg_value           = {1, 0.5},
        arg_lim             = {{0, limit_1_}, {0, limit_2_}},
        animated            = {false, true},
        animation_speed     = {0, 0.4},
        gain                = {1.0, 0.1},
        relative            = {false, false},
        updatable           = true,
        use_OBB             = true,
        use_release_message = {true, false}
    }
end

-- NOT IN USE
function default_animated_lever(hint_, device_, command_, arg_, animation_speed_, arg_lim_)
    local animation_speed_ = animation_speed_ or anim_speed_default
    local arg_lim__ = arg_lim_ or {0.0, 1.0}
    return {
        class           = {class_type.TUMB, class_type.TUMB},
        hint            = hint_,
        device          = device_,
        action          = {command_, command_},
        arg             = {arg_, arg_},
        arg_value       = {1, 0},
        arg_lim         = {arg_lim__, arg_lim__},
        updatable       = true,
        gain            = {0.1, 0.1},
        animated        = {true, true},
        animation_speed = {animation_speed_, 0},
        cycle           = true
    }
end

function default_button_tumb(hint_, device_, command1_, command2_, arg_)
    return {
        class               = {class_type.BTN, class_type.TUMB},
        hint                = hint_,
        device              = device_,
        action              = {command1_, command2_},
        stop_action         = {command1_, 0},
        arg                 = {arg_, arg_},
        arg_value           = {-1, 1},
        arg_lim             = {{-1, 0}, {0, 1}},
        updatable           = true,
        use_OBB             = true,
        use_release_message = {true, false}
    }
end

elements = {}

--SWITCHOFF elements["POINTER"] = default_2_position_tumb(LOCALIZE("Test Command"),devices.TEST, device_commands.Button_1,444) -- 44 arg number


--elements["PTN_003"] = default_2_position_tumb("Landing Gear Handle", devices.GEAR_SYSTEM, click_cmd.GearLevel, 3)
elements["PNT_083"] = default_2_position_tumb(_("Landing Gear Handle"), devices.GEAR_SYSTEM, click_cmd.GearLevel, 118, 4)

-- Power Systems
-- elements["PTN_107"] = default_2_position_tumb("Battry Swith", devices.ELECTRIC_SYSTEM, Keys.BatteryPower, 107)
-- elements["PTN_108"] = default_multi_position_tumb("Left Generator Switch", devices.ELECTRIC_SYSTEM, Keys.PowerGeneratorLeftUP, Keys.PowerGeneratorLeftDOWN, -1)
-- elements["PTN_111"] = default_multi_position_tumb("Right Generator Switch", devices.ELECTRIC_SYSTEM, Keys.PowerGeneratorRightUP, Keys.PowerGeneratorRightDOWN, -1)


-- Engine system
elements["PTN_109"] = default_multi_position_tumb("Left Speed Drive Switch",  devices.ENGINE, Keys.LeftSpeedDriveUP, Keys.LeftSpeedDriveDOWN, 109)
elements["PTN_110"] = default_multi_position_tumb("Right Speed Drive Switch",  devices.ENGINE, Keys.RightSpeedDriveUP, Keys.RightSpeedDriveDOWN, 110)

elements["PTN_112"] = default_2_position_tumb("Left Fuel Master",  devices.ENGINE, Keys.FuelMasterLeft, 112)
elements["PTN_113"] = default_2_position_tumb("Right Fuel Master", devices.ENGINE, Keys.FuelMasterRight, 113)

elements["PTN_114"] = default_2_position_tumb("NWW Switch", devices.ENGINE, Keys.NWWSwitch, 114)
elements["PTN_115"] = default_2_position_tumb("CSD/S Switch", devices.ENGINE, Keys.CSDSwitch, 115)
elements["PTN_116"] = default_2_position_tumb("AirCondition Switch", devices.ENGINE, Keys.AirCondSwitch, 116)
elements["PTN_117"] = default_2_position_tumb("Bleed System Cover", devices.ENGINE, Keys.BleedHoldCover, 117)

elements["PTN_150"] = default_button("Left Engine Crank",  devices.ENGINE, Keys.LeftEngineCrank, Keys.LeftEngineCrankUP, 150)
elements["PTN_151"] = default_button("Right Engine Crank", devices.ENGINE, Keys.RightEngineCrank, Keys.RightEngineCrankUP, 151)

elements["PTN_LTHRO"] = default_2_position_tumb("Left ENGINE IDLE",  devices.ENGINE, Keys.LeftEngineIDLEPOS, 41)
elements["PTN_RTHRO"] = default_2_position_tumb("Right Engine IDLE",  devices.ENGINE, Keys.RightEngineIDLEPOS, 42)

-- 
elements["FLAP_LEVEL"] = default_multi_position_tumb("Flap handle", devices.FLAP_SYSTEM, Keys.FlapUp, Keys.FlapDown, 43, 5.0)

elements["PARKING_BREAK"] = default_2_position_tumb("Parking Break", devices.BREAK_SYSTEM, Keys.ParkingBrakes, 50)

elements["PTN_118"] = default_button("Boost Pump Test", devices.FUEL_SYSTEM, Keys.BoostPumpTestUP, Keys.BoostPumpTestDOWN, 118)

multi_tumb_click_list = {

    {"PTN_429", "Anti-Collision Light", devices.LIGHT_SYSTEM, 429, Keys.LightStrobeUP, Keys.LightStrobeDOWN},
    {"PTN_424", "Navigation Light", devices.LIGHT_SYSTEM, 424, Keys.LightNaviWingUP,Keys.LightNaviWingDOWN},
    
    {"PTN_125", "Taxi/Probe Light", devices.LIGHT_SYSTEM, 125, Keys.LightTaxi},
    {"PTN_128", "Tail Navigation Light", devices.LIGHT_SYSTEM, 128, Keys.LightNaviTailUP, Keys.LightNaviTailDOWN},
    {"PTN_130", "Formation Light", devices.LIGHT_SYSTEM, 130, Keys.LightFormationUP, Keys.LightFormationDOWN},
    {"PTN_133", "Flood Light", devices.LIGHT_SYSTEM, 133, Keys.LightFloodUP, Keys.LightFloodDOWN},

    -- Electric Power Switches
    {"PTN_401", "Main Power Switch", devices.ELECTRIC_SYSTEM, 401, Keys.BatteryPower},
    {"PTN_402", "Left Generator Switch", devices.ELECTRIC_SYSTEM, 402, Keys.PowerGeneratorLeft},
    {"PTN_404", "Right Generator Switch", devices.ELECTRIC_SYSTEM, 404, Keys.PowerGeneratorRight},

    -- EADI
    {"PTN_501", "Screen Display Dim-", devices.HUD_DCMS, 501, Keys.Display_Darker},
    {"PTN_502", "Screen Display Dim+", devices.HUD_DCMS, 502, Keys.Display_Brighter},

    -- GNS430
    {"PTN_513", "VLOC/COM Focus Change", devices.HUD_DCMS, 513, Keys.Freq_Knob_Push},
    {"PTN_514", "COM frequency Flip-flop", devices.HUD_DCMS, 514, Keys.COM_Freq_Swap},
    {"PTN_515", "VLOC frequency Flip-flop", devices.HUD_DCMS, 515, Keys.VLOC_Freq_Swap},
    {"PTN_526", "Enter", devices.HUD_DCMS, 526, Keys.Nav_Ent},

    {"PTN_601", "Canopy Handle", devices.CANOPY, 601, 71}, -- iCommandPlaneCanopy
}

for k,v in pairs(multi_tumb_click_list) do
    if multi_tumb_click_list[k][6] == nil then
        elements[multi_tumb_click_list[k][1]] = default_2_position_tumb( multi_tumb_click_list[k][2],multi_tumb_click_list[k][3],multi_tumb_click_list[k][5],multi_tumb_click_list[k][4])
    else
        elements[multi_tumb_click_list[k][1]] = default_multi_position_tumb( multi_tumb_click_list[k][2],multi_tumb_click_list[k][3],multi_tumb_click_list[k][5],multi_tumb_click_list[k][6],multi_tumb_click_list[k][4])
    end
end

elements["PTN_132"] = default_axis("Instrument Light", devices.LIGHT_SYSTEM, Keys.LightInstruBRT, 1132, 0, 0.1)
elements["PTN_131"] = default_axis("Console Light", devices.LIGHT_SYSTEM, Keys.LightConsoleBRT, 1133, 0, 0.1)
elements["PTN_134"] = default_axis("Approach Index Light", devices.LIGHT_SYSTEM, Keys.LightApproIndexBRT, 1134, 0, 0.1)

elements["PTN_211"] = default_axis("Auto Temperature Control", devices.ECS_SYSTEM, Keys.AircondTemp, 1134, 0, 0.1)
elements["PTN_213"] = default_axis("Defog Airflow", devices.ECS_SYSTEM, Keys.AircondDefog, 1134, 0, 0.1)
-- UHF
elements["PTN_178"] = default_axis("UHF Mode Selection", devices.RADIO_SYSTEM, Keys.UHFMode, 1134, 0, 0.1)
elements["PTN_183"] = default_axis("UHF Volume", devices.RADIO_SYSTEM, Keys.UHFVolume, 1134, 0, 0.1)
-- TACAN
elements["PTN_184"] = default_axis("TACAN Mode Selection", devices.RADIO_SYSTEM, Keys.TACANMode, 1134, 0, 0.1)
elements["PTN_185"] = default_axis("TACAN Channel x10", devices.RADIO_SYSTEM, Keys.TACANChanA, 1134, 0, 0.1)
elements["PTN_186"] = default_axis("TACAN Channel x1", devices.RADIO_SYSTEM, Keys.TACANChanB, 1134, 0, 0.1)

-- Weapon 550-557
elements["PTN_550"] = default_axis("Interval x100", devices.WEAPON_SYSTEM, Keys.IntervalTumbWheel100, 1134, 0, 0.1)
elements["PTN_551"] = default_axis("Interval x10", devices.WEAPON_SYSTEM, Keys.IntervalTumbWheel10, 1134, 0, 0.1)
elements["PTN_552"] = default_axis("Interval x1", devices.WEAPON_SYSTEM, Keys.IntervalTumbWheel, 1134, 0, 0.1)
elements["PTN_553"] = default_axis("Quantity x10", devices.WEAPON_SYSTEM, Keys.QuantityTumbWheel10, 1134, 0, 0.1)
elements["PTN_554"] = default_axis("Quantity x1", devices.WEAPON_SYSTEM, Keys.QuantityTumbWheel, 1134, 0, 0.1)
elements["PTN_555"] = default_axis("Time x100", devices.WEAPON_SYSTEM, Keys.TimeTumbWheel100, 1134, 0, 0.1)
elements["PTN_556"] = default_axis("Time x10", devices.WEAPON_SYSTEM, Keys.TimeTumbWheel10, 1134, 0, 0.1)
elements["PTN_557"] = default_axis("Time x1", devices.WEAPON_SYSTEM, Keys.TimeTumbWheel, 1134, 0, 0.1)

-- EHSI SANDEL SN3500
elements["PTN_534"] = default_axis("Course Selection Knob", devices.HUD_DCMS, Keys.Nav_Course_Sel, 1134, 0, 0.1)
elements["PTN_541"] = default_axis("Heading Selection Knob", devices.HUD_DCMS, Keys.Nav_Heading_Sel, 1134, 0, 0.1)

-- GNS430 Unit
elements["PTN_509"] = default_axis("Vol/PWR Knob", devices.HUD_DCMS, Keys.Nav_Vol_PWR, 1134, 0, 0.1)
elements["PTN_510"] = default_axis("Vol Knob", devices.HUD_DCMS, Keys.Nav_Vol, 1134, 0, 0.1)
elements["PTN_511"] = default_axis("Freqency MHz Knob", devices.HUD_DCMS, Keys.Freq_Num, 1134, 0, 0.1)
elements["PTN_512"] = default_axis("Freqency kHz Knob", devices.HUD_DCMS, Keys.Freq_Degi, 1134, 0, 0.1)
elements["PTN_527"] = default_axis("Right Large Knob", devices.HUD_DCMS, Keys.Nav_Right_Knob_L, 1134, 0, 0.1)
elements["PTN_528"] = default_axis("Right Small Knob", devices.HUD_DCMS, Keys.Nav_Right_Knob_S, 1134, 0, 0.1)


elements["PTN_179"] = springloaded_3_pos_tumb("UHF tens of Mega hertz", devices.RADIO_SYSTEM, Keys.UHFFreqAUP, Keys.UHFFreqASTOP, Keys.UHFFreqADOWN, Keys.UHFFreqASTOP, 1134)
elements["PTN_180"] = springloaded_3_pos_tumb("UHF Mega hertz", devices.RADIO_SYSTEM, Keys.UHFFreqBUP, Keys.UHFFreqBSTOP, Keys.UHFFreqBDOWN, Keys.UHFFreqBSTOP, 1134)
elements["PTN_181"] = springloaded_3_pos_tumb("UHF hundreds and tens of Kilo hertz", devices.RADIO_SYSTEM, Keys.UHFFreqCUP, Keys.UHFFreqCSTOP, Keys.UHFFreqCDOWN, Keys.UHFFreqCSTOP, 1134)
--for i,o in pairs(elements) do
--	if  o.class[1] == class_type.TUMB or 
--	   (o.class[2]  and o.class[2] == class_type.TUMB) or
--	   (o.class[3]  and o.class[3] == class_type.TUMB)  then
--	   o.updatable = true
--	   o.use_OBB   = true
--	end
--end