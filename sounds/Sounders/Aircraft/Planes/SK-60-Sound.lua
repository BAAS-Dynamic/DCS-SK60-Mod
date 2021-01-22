dofile("Aircraft/Planes/Plane.lua")
SK_60 = plane:new()

function SK_60:createCanopy()
	aircraft.sndCanopy  = ED_AudioAPI.createSource(self.cockpit.host, "Aircrafts/SK_60/SK60_CanopyOpen")
end

local isPlayedCanopy = 0
local playstartpos = 0

function SK_60:updateCanopy(params)
    local gain = 1
    local pitch = 1
    if params.canopyPos / 0.9 > 0.95 then
        playstartpos = 0.147
    elseif params.canopyPos / 0.9 < 0.05 then
        playstartpos = 0.147
    else
        playstartpos = params.canopyPos / 0.9 * 0.853 + 0.147
    end
    if params.canopyMoveDirection ~= 0 then
        if params.canopyMoveDirection > 0 then
            -- opening
            if isPlayedCanopy == 0 and params.canopyPos / 0.9 < 0.95 then
                ED_AudioAPI.setSourceGain(self.sndCanopy, gain)
                ED_AudioAPI.setSourcePitch(self.sndCanopy, pitch)
                ED_AudioAPI.playSourceOnce(self.sndCanopy, playstartpos)
                isPlayedCanopy = 1
            end
        else
            -- closing
            if isPlayedCanopy == 0 and params.canopyPos / 0.9 > 0.05 then
                ED_AudioAPI.setSourceGain(self.sndCanopy, gain)
                ED_AudioAPI.setSourcePitch(self.sndCanopy, pitch)
                ED_AudioAPI.playSourceOnce(self.sndCanopy, playstartpos)
                isPlayedCanopy = 1
            end
        end 
    else
        if isPlayedCanopy == 1 then
            ED_AudioAPI.stopSource(self.sndCanopy)
            isPlayedCanopy = 0
        end
    end
end

function SK_60:onUpdate(params)
	SK_60:updateCanopy(params)
	aircraft:onUpdate(params)
end

SK_60:createCanopy()