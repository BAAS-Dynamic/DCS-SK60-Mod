--Lua files are used for initial loading
dofile(LockOn_Options.common_script_path.."devices_defs.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")
dofile(LockOn_Options.script_path.."debug_util.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."sounds_def.lua")

local SoundSystem = GetSelf()
--Set the number of cycles
local update_rate = 0.05 -- 20
make_default_activity(update_rate)

--Initialize DCS read API
local sensor_data = get_base_data()

local engine_sounds = {}
local airframe_sounds = {}
local STARTUP_RPM_RESET = 0.0001
local ENGINE_LOOP_RPM_START = 0.001
local WIND_ONSET_G = 2.0
local WIND_FULL_G = 6.0
local WIND_ONSET_GAIN = 0.03
local RATTLE_FULL_G = 7.0
local AIRFRAME_MIN_IAS = 80 / 3.6 -- Do not react to bumps while taxiing.
local AIRFRAME_FULL_IAS = 250 / 3.6

local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

local function normalize_engine_rpm(value)
    -- The SK60 EFM exposes base-data engine RPM as a 0..1 ratio. Other cockpit
    -- systems use thresholds such as 0.5 and 0.04 against the same value.
    return clamp(value or 0, 0, 1)
end

local function create_engine_sounds(host, get_rpm)
    return {
        get_rpm = get_rpm,
        low = host:create_sound("Aircrafts/SK-60/SK60_Engine_Cockpit_Lo"),
        high = host:create_sound("Aircrafts/SK-60/SK60_Engine_Cockpit_Hi"),
        startup = host:create_sound("Aircrafts/SK-60/SK60_Engine_Cockpit_Startup"),
        startup_armed = normalize_engine_rpm(get_rpm()) <= STARTUP_RPM_RESET,
    }
end

local function update_loop(sound, pitch, gain)
    if gain > 0.01 then
        if not sound:is_playing() then
            sound:play_continue()
        end
        sound:update(pitch, gain, nil)
    elseif sound:is_playing() then
        sound:stop()
    end
end

local function update_engine_sound(engine)
    local rpm = normalize_engine_rpm(engine.get_rpm())

    -- Re-arm only after a complete shutdown. Playback itself is commanded by
    -- the starter switch so it begins before the engine RPM starts to rise.
    if rpm <= STARTUP_RPM_RESET then
        engine.startup_armed = true
    end

    local low_pitch = 0.55 + rpm * 0.55
    local high_pitch = 0.70 + rpm * 0.60
    -- Bring both layers in with the first sustained RPM rise. The different
    -- slopes retain a low-frequency emphasis while the engine is spooling.
    local low_gain = clamp((rpm - ENGINE_LOOP_RPM_START) * 1.35, 0, 0.9)
    local high_gain = clamp((rpm - ENGINE_LOOP_RPM_START) * 0.75, 0, 0.7)

    update_loop(engine.low, low_pitch, low_gain)
    update_loop(engine.high, high_pitch, high_gain)
end

local function normalized_range(value, onset, maximum)
    return clamp((value - onset) / (maximum - onset), 0, 1)
end

local function wind_gain_for_load(load_factor)
    if load_factor < WIND_ONSET_G then
        return 0
    end
    local fade = normalized_range(load_factor, WIND_ONSET_G, WIND_FULL_G)
    return WIND_ONSET_GAIN + fade * (1 - WIND_ONSET_GAIN)
end

local function approach(current, target, rate)
    local step = rate * update_rate
    if current < target then
        return math.min(current + step, target)
    end
    return math.max(current - step, target)
end

local function update_airframe_sounds()
    if airframe_sounds.wind == nil or airframe_sounds.rattle == nil then
        return
    end

    -- Load factor supplies the tactile cue requested by the pilot, while IAS
    -- prevents a hard landing or a taxi bump from sounding like aerodynamic
    -- stress. Separate smoothing rates avoid clicks and threshold chatter.
    local load_factor = math.max(sensor_data.getVerticalAcceleration() or 1, 0)
    local ias = math.max(sensor_data.getIndicatedAirSpeed() or 0, 0)
    local airflow = normalized_range(ias, AIRFRAME_MIN_IAS, AIRFRAME_FULL_IAS)
    local wind_target = wind_gain_for_load(load_factor) * airflow
    local rattle_target = normalized_range(load_factor, 4.0, RATTLE_FULL_G) * airflow

    airframe_sounds.wind_gain = approach(airframe_sounds.wind_gain, wind_target, wind_target > airframe_sounds.wind_gain and 1.5 or 0.8)
    airframe_sounds.rattle_gain = approach(airframe_sounds.rattle_gain, rattle_target, rattle_target > airframe_sounds.rattle_gain and 2.5 or 1.5)

    update_loop(airframe_sounds.wind, 1.0, airframe_sounds.wind_gain * 0.85)
    update_loop(airframe_sounds.rattle, 0.95 + airframe_sounds.rattle_gain * 0.1, airframe_sounds.rattle_gain * 0.9)
end

local function play_engine_startup(engine_number)
    local engine = engine_sounds[engine_number]
    if engine ~= nil and engine.startup_armed then
        engine.startup:play_once()
        engine.startup_armed = false
    end
end

function post_initialize()
    local birth = LockOn_Options.init_conditions.birth_place

    if birth == "GROUND_HOT" then

    elseif birth == "GROUND_COLD" then

    elseif birth == "AIR_HOT" then

    end

   -- initial the sound
   -- center panel
    sndhost_cockpit_left            = create_sound_host("COCKPIT_LDP","3D",0.3,-0.3,-0.3)
    snd_left_panel_switch           = sndhost_cockpit_left:create_sound("Aircrafts/SK-60/SK60_Switch")
   -- center panel
    sndhost_cockpit_center          = create_sound_host("COCKPIT_CDP","3D",0.3,-0.3,0.3)
    snd_center_panel_switch         = sndhost_cockpit_center:create_sound("Aircrafts/SK-60/SK60_Switch")
   -- center panel
    sndhost_cockpit_right           = create_sound_host("COCKPIT_RDP","3D",0.3,-0.3,0.9)
    snd_right_panel_switch          = sndhost_cockpit_right:create_sound("Aircrafts/SK-60/SK60_Switch")
   -- electrical power
    sndhost_electrical              = create_sound_host("ELECTRIC_UNIT", "3D", -0.5, 0, 0)
    snd_main_electric_invert        = sndhost_electrical:create_sound("Aircrafts/SK-60/SK60_Main_Elec")
    snd_gear_action                 = sndhost_electrical:create_sound("Aircrafts/SK-60/SK60_Gear_Down")

    -- "COCKPIT" is a DCS audio context, not an arbitrary host label.  It puts
    -- these sources on the In-Cockpit submix; the A-4 and UH-60 references use
    -- this exact context for their internal engine sounds.
    sndhost_cockpit_engine = create_sound_host("COCKPIT", "2D", 0, 0, 0)
    engine_sounds = {
        create_engine_sounds(sndhost_cockpit_engine, sensor_data.getEngineLeftRPM),
        create_engine_sounds(sndhost_cockpit_engine, sensor_data.getEngineRightRPM),
    }
    airframe_sounds = {
        wind = sndhost_cockpit_engine:create_sound("Aircrafts/SK-60/SK60_Airframe_Wind"),
        rattle = sndhost_cockpit_engine:create_sound("Aircrafts/SK-60/SK60_Airframe_Rattle"),
        wind_gain = 0,
        rattle_gain = 0,
    }
end

SoundSystem:listen_command(Keys.SND_LEFT_PANEL)
SoundSystem:listen_command(Keys.SND_CENTER_PANEL)
SoundSystem:listen_command(Keys.SND_RIGHT_PANEL)
SoundSystem:listen_command(Keys.SND_ELECTRIC)
SoundSystem:listen_command(Keys.SND_GEAR)
SoundSystem:listen_command(Keys.L_STARTER_PRESS)
SoundSystem:listen_command(Keys.R_STARTER_PRESS)

local snd_main_elec_play = 0

function SetCommand(command, value)
    dprintf("get command, value compare is"..value)
    if command == Keys.SND_LEFT_PANEL then
         if value == cockpit_sound.basic_switch then
            snd_left_panel_switch:play_once()
         end
    elseif command == Keys.SND_CENTER_PANEL then
        if value == cockpit_sound.basic_switch then
            snd_center_panel_switch:play_once()
        end
    elseif command == Keys.SND_RIGHT_PANEL then
        if value == cockpit_sound.basic_switch then
            snd_right_panel_switch:play_once()
        end
    elseif command == Keys.SND_ELECTRIC then
        if (value == 1 and not snd_main_electric_invert:is_playing()) then
            snd_main_electric_invert:play_continue()
        elseif value == 0 then
            snd_main_electric_invert:stop()
        end
    elseif command == Keys.SND_GEAR then
        snd_gear_action:play_once()
    elseif command == Keys.L_STARTER_PRESS then
        play_engine_startup(1)
    elseif command == Keys.R_STARTER_PRESS then
        play_engine_startup(2)
    end
end

function update()
    for _, engine in ipairs(engine_sounds) do
        update_engine_sound(engine)
    end
    update_airframe_sounds()
end

need_to_be_closed = false
