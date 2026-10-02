dofile("Tools.lua")

SK60Canopy = {}

local CANOPY_STOP_EPSILON = 0.0005

local CANOPY_PARAM_CANDIDATES = {
    "SK60_CANOPY_EXT_SOUND",
    "CanopyInsideView",
    "Inside_Canopy",
    "arg_38",
    "argument_38",
    "drawArgument_38",
    "draw_argument_38",
    "drawArg_38",
}

local function firstNumber(params, names)
    for _, name in ipairs(names) do
        local value = params[name]
        if type(value) == "number" then
            return value
        end
    end

    return nil
end

function SK60Canopy:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.open_sound = nil
    o.close_sound = nil
    o.last_canopy_pos = nil
    o.current_direction = 0
    return o
end

function SK60Canopy:init(host)
    self.open_sound = ED_AudioAPI.createSource(host, "Aircrafts/SK-60/CanopyOpenExt")
    self.close_sound = ED_AudioAPI.createSource(host, "Aircrafts/SK-60/CanopyCloseExt")
end

function SK60Canopy:stopSound(sound)
    if sound ~= nil and ED_AudioAPI.isSourcePlaying(sound) then
        ED_AudioAPI.stopSource(sound)
    end
end

function SK60Canopy:stopAll()
    self:stopSound(self.open_sound)
    self:stopSound(self.close_sound)
    self.current_direction = 0
end

function SK60Canopy:playDirection(direction)
    if direction > 0 then
        self:stopSound(self.close_sound)
        if self.open_sound ~= nil and not ED_AudioAPI.isSourcePlaying(self.open_sound) then
            ED_AudioAPI.playSourceLooped(self.open_sound)
        end
    elseif direction < 0 then
        self:stopSound(self.open_sound)
        if self.close_sound ~= nil and not ED_AudioAPI.isSourcePlaying(self.close_sound) then
            ED_AudioAPI.playSourceLooped(self.close_sound)
        end
    end

    self.current_direction = direction
end

function SK60Canopy:update(params)
    local command = params["SK60_CANOPY_EXT_SOUND"]
    if type(command) == "number" then
        if command > 0.5 then
            self:playDirection(1)
            return
        elseif command < -0.5 then
            self:playDirection(-1)
            return
        elseif command == 0 and self.current_direction ~= 0 then
            self:stopAll()
            return
        end
    end

    local canopy_pos = firstNumber(params, CANOPY_PARAM_CANDIDATES)
    if canopy_pos == nil then
        return
    end

    if self.last_canopy_pos == nil then
        self.last_canopy_pos = canopy_pos
        return
    end

    local delta = canopy_pos - self.last_canopy_pos
    self.last_canopy_pos = canopy_pos

    if delta > CANOPY_STOP_EPSILON then
        self:playDirection(1)
    elseif delta < -CANOPY_STOP_EPSILON then
        self:playDirection(-1)
    elseif self.current_direction ~= 0 then
        self:stopAll()
    end
end
