dofile("Aircraft/Planes/Plane.lua")
SK_60 = aircraft:new()

function SK_60:createCanopy()
	self.sndCanopy  = ED_AudioAPI.createSource(self.cockpit.host, "Aircrafts/SK-60/SK60_CanopyOpen")
end

local isPlayedCanopy = 0
local playstartpos = 0
local canopy_last_time = 0

function SK_60:updateCanopy(params)
    local gain = 2
    local pitch = 1
    if params.canopyPos / 0.9 > 0.95 then
        playstartpos = 0.147
    elseif params.canopyPos / 0.9 < 0.05 then
        playstartpos = 0.147
    else
        playstartpos = params.canopyPos / 0.9 * 0.853 + 0.147
    end
    local canopyMoveDirection = params.canopyPos - canopy_last_time
    if canopyMoveDirection ~= 0 then
        if canopyMoveDirection > 0 then
            -- opening
            if isPlayedCanopy == 0 and params.canopyPos / 0.9 < 0.95 then
                ED_AudioAPI.setSourceGain(self.sndCanopy, gain)
                ED_AudioAPI.setSourcePitch(self.sndCanopy, pitch)
                ED_AudioAPI.playSourceOnce(self.sndCanopy)
                isPlayedCanopy = 1
            end
        else
            -- closing
            if isPlayedCanopy == 0 and params.canopyPos / 0.9 > 0.05 then
                ED_AudioAPI.setSourceGain(self.sndCanopy, gain)
                ED_AudioAPI.setSourcePitch(self.sndCanopy, pitch)
                ED_AudioAPI.playSourceOnce(self.sndCanopy)
                isPlayedCanopy = 1
            end
        end 
    else
        if isPlayedCanopy == 1 then
            -- ED_AudioAPI.stopSource(self.sndCanopy)
            -- isPlayedCanopy = 0
        end
    end
    canopy_last_time = params.canopyPos
end

function SK_60:createCanopycpt()
    self.cockpit.sndCanopy  = ED_AudioAPI.createSource(self.cockpit.host, "Aircrafts/SK-60/SK60_CanopyOpen")

    ED_AudioAPI.linkSource(self.sndCanopy, self.cockpit.sndCanopy)
end

function onEvent_cockpitCreate()
    SK_60:createCanopycpt()
end

function SK_60:onUpdate(params)
	SK_60:updateCanopy(params)
	aircraft:onUpdate(params)
end

SK_60:createCockpit()
SK_60:createCanopy()