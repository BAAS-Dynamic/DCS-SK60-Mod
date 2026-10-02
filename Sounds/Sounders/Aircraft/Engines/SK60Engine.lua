dofile("Tools.lua")

local SOUND_CORE_RPM = 0
local SOUND_FAN_RPM = 1
local SOUND_TURBINE_POWER = 2
local SOUND_THRUST = 3
local SOUND_TRUE_AIRSPEED = 4

SK60Engine = {number = 0, sounds = {}}

local STARTUP_FAN_RPM_TRIGGER = 0.001
local STARTUP_FAN_RPM_RESET = 0.0001

local function clamp(v, min_v, max_v)
    if v < min_v then return min_v end
    if v > max_v then return max_v end
    return v
end

local function makeCurve(points, min_x, max_x)
    local curve = {
        points = points,
        min_x = min_x,
        max_x = max_x,
    }

    function curve:value(x)
        local p = self.points
        if x == nil then
            return p[1]
        end

        local range = self.max_x - self.min_x
        if range <= 0.0 then
            return p[1]
        end

        local t = clamp((x - self.min_x) / range, 0.0, 1.0)
        local scaled = t * (#p - 1)
        local i = math.floor(scaled) + 1

        if i >= #p then
            return p[#p]
        end

        local frac = scaled - (i - 1)
        return p[i] + (p[i + 1] - p[i]) * frac
    end

    return curve
end

function SK60Engine:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.number = 1
    o.sounds = {}
    o.prev_fan_rpm = 0.0
    o.startup_initialized = false
    o.startup_armed = true
    o.startup_sound = nil
    return o
end

function SK60Engine:init(number_, host)
    self.number = number_
    self.prev_fan_rpm = 0.0
    self.startup_initialized = false
    self.startup_armed = true

    self.sounds = {
        {
            sound = nil,
            type_pitch = SOUND_FAN_RPM,
            type_gain = SOUND_FAN_RPM,
            sdef_name = "Aircrafts/Engines/SK-60/sk60_engine_ext_front_lo",
            pitch_curve = makeCurve({0.33, 0.62, 0.84, 1.00, 1.05, 1.10, 1.14}, 0.0, 1.0),
            gain_curve = makeCurve({0.00, 0.50, 0.62, 0.80, 0.88, 0.95, 1.00}, 0.0, 1.0),
        },
        {
            sound = nil,
            type_pitch = SOUND_FAN_RPM,
            type_gain = SOUND_FAN_RPM,
            sdef_name = "Aircrafts/Engines/SK-60/sk60_engine_ext_front_hi",
            pitch_curve = makeCurve({0.33, 0.62, 0.84, 1.00, 1.11, 1.21, 1.30}, 0.0, 1.0),
            gain_curve = makeCurve({0.00, 0.00, 0.22, 0.50, 0.72, 0.90, 1.00}, 0.30, 1.0),
        },
        {
            sound = nil,
            type_pitch = SOUND_FAN_RPM,
            type_gain = SOUND_FAN_RPM,
            sdef_name = "Aircrafts/Engines/SK-60/sk60_engine_ext_around_lo",
            pitch_curve = makeCurve({0.33, 0.62, 0.84, 1.00, 1.05, 1.10, 1.14}, 0.0, 1.0),
            gain_curve = makeCurve({0.00, 0.52, 0.64, 0.82, 0.88, 0.95, 1.00}, 0.0, 1.0),
        },
        {
            sound = nil,
            type_pitch = SOUND_FAN_RPM,
            type_gain = SOUND_FAN_RPM,
            sdef_name = "Aircrafts/Engines/SK-60/sk60_engine_ext_around_hi",
            pitch_curve = makeCurve({0.33, 0.62, 0.84, 1.00, 1.11, 1.21, 1.30}, 0.0, 1.0),
            gain_curve = makeCurve({0.00, 0.00, 0.20, 0.44, 0.66, 0.86, 1.00}, 0.32, 1.0),
        },
        {
            sound = nil,
            type_pitch = SOUND_TURBINE_POWER,
            type_gain = SOUND_FAN_RPM,
            sdef_name = "Aircrafts/Engines/SK-60/sk60_engine_ext_back_lo",
            pitch_curve = makeCurve({0.33, 0.62, 0.84, 1.00, 1.05, 1.10, 1.14}, 0.0, 1.0),
            gain_curve = makeCurve({0.00, 0.52, 0.64, 0.82, 0.88, 0.95, 1.00}, 0.0, 1.0),
        },
        {
            sound = nil,
            type_pitch = SOUND_TURBINE_POWER,
            type_gain = SOUND_FAN_RPM,
            sdef_name = "Aircrafts/Engines/SK-60/sk60_engine_ext_back_hi",
            pitch_curve = makeCurve({0.90, 1.00, 1.07}, 0.45, 1.0),
            gain_curve = makeCurve({0.00, 0.00, 0.18, 0.40, 0.65, 0.86, 1.00}, 0.35, 1.0),
        },
        {
            sound = nil,
            type_pitch = SOUND_FAN_RPM,
            type_gain = SOUND_TRUE_AIRSPEED,
            sdef_name = "Aircrafts/Engines/SK-60/sk60_engine_ext_far_roar",
            pitch_curve = makeCurve({0.70, 1.00, 1.28}, 0.0, 1.0),
            gain_curve = makeCurve({0.00, 0.05, 0.30, 0.70, 0.88, 1.00}, 70.0, 330.0),
        },
    }

    self:createSounds(host)
end

function SK60Engine:createSounds(host)
    for i, v in pairs(self.sounds) do
        self.sounds[i].sound = ED_AudioAPI.createSource(host, v.sdef_name)
    end

    self.startup_sound = ED_AudioAPI.createSource(host, "Aircrafts/Engines/SK-60/sk60_engine_ext_startup")
end

function SK60Engine:createSoundsCpt(hostCpt)
    -- Internal engine audio is owned by Cockpit/Scripts/Systems/sound_system.lua.
    -- Keep this interface for Plane.lua, but do not create a second set of
    -- cockpit sources here.
end

function SK60Engine:destroySoundsCpt()
    -- See createSoundsCpt().
end

function SK60Engine:DBGstop()
    for _, v in pairs(self.sounds) do
        if v.sound ~= nil and ED_AudioAPI.isSourcePlaying(v.sound) then
            ED_AudioAPI.stopSource(v.sound)
        end
    end

    if self.startup_sound ~= nil and ED_AudioAPI.isSourcePlaying(self.startup_sound) then
        ED_AudioAPI.stopSource(self.startup_sound)
    end

end

function SK60Engine:controlSound(snd, pitch, gain)
    if snd == nil then
        return
    end

    if gain < 0.01 then
        ED_AudioAPI.stopSource(snd)
        return
    end

    ED_AudioAPI.setSourcePitch(snd, pitch)
    ED_AudioAPI.setSourceGain(snd, gain)

    if not ED_AudioAPI.isSourcePlaying(snd) then
        ED_AudioAPI.playSourceLooped(snd)
    end
end

function SK60Engine:handleStartup(fanRPM)
    local fan = fanRPM or 0.0

    if not self.startup_initialized then
        self.prev_fan_rpm = fan
        self.startup_armed = fan <= STARTUP_FAN_RPM_RESET
        self.startup_initialized = true
        return
    end

    if self.startup_armed and self.prev_fan_rpm < STARTUP_FAN_RPM_TRIGGER and fan >= STARTUP_FAN_RPM_TRIGGER then
        if self.startup_sound ~= nil then
            ED_AudioAPI.playSourceOnce(self.startup_sound)
        end

        self.startup_armed = false
    end

    if fan <= STARTUP_FAN_RPM_RESET then
        self.startup_armed = true
    end

    self.prev_fan_rpm = fan
end

function SK60Engine:update(coreRPM, fanRPM, turbPower, thrust, flame, vTrue)
    self:handleStartup(fanRPM)

    local sound_param = {
        [SOUND_CORE_RPM] = coreRPM,
        [SOUND_FAN_RPM] = fanRPM,
        [SOUND_TURBINE_POWER] = turbPower,
        [SOUND_THRUST] = thrust,
        [SOUND_TRUE_AIRSPEED] = vTrue,
    }

    for _, v in pairs(self.sounds) do
        local param_gain = sound_param[v.type_gain]
        local param_pitch = sound_param[v.type_pitch]
        self:controlSound(v.sound, v.pitch_curve:value(param_pitch), v.gain_curve:value(param_gain))
    end
end
