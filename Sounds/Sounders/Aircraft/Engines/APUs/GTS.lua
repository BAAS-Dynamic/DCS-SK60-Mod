GTS = {cockpit = {}}

function GTS:new()
	o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function GTS:create(APUhost)
	self.sndAPU = ED_AudioAPI.createSource(APUhost, "Aircrafts/Engines/Rolls-Royce Adour/GTSLoop")
	self.sndAPUbegin = ED_AudioAPI.createSource(APUhost, "Aircrafts/Engines/Rolls-Royce Adour/GTSBegin")
	-- self.sndAPUend = ED_AudioAPI.createSource(APUhost, "Aircrafts/Engines/Rolls-Royce Adour/GTSEnd")
end

function GTS:createCpt(APUhostCpt, path)
	--self.cockpit.sndAPU = ED_AudioAPI.createSource(APUhostCpt, path .. "APUIn") -- have to assign cockpit path directly!
	self.cockpit.sndAPU = ED_AudioAPI.createSource(APUhostCpt, "Aircrafts/BAEHawk/Cockpit" .. "GTSLoopIn")
	ED_AudioAPI.linkSource(self.sndAPU, self.cockpit.sndAPU)

	--self.cockpit.sndAPUbegin = ED_AudioAPI.createSource(APUhostCpt, path .. "APUBeginIn") -- have to assign cockpit path directly!
	self.cockpit.sndAPUbegin = ED_AudioAPI.createSource(APUhostCpt, "Aircrafts/BAEHawk/Cockpit" .. "GTSBeginIn")
	ED_AudioAPI.linkSource(self.sndAPUbegin, self.cockpit.sndAPUbegin)
end

function GTS:update(params)
	if params.APU_RPM < 0.01 then
		ED_AudioAPI.stopSource(self.sndAPU)
		ED_AudioAPI.stopSource(self.sndAPUbegin)
		-- ED_AudioAPI.playSourceOnce(self.sndAPUend)
	elseif params.APU_RPM > 0.02 then
		ED_AudioAPI.setSourcePitch(self.sndAPU, params.APU_RPM)
		ED_AudioAPI.setSourceGain(self.sndAPU, math.sqrt(params.APU_RPM))
			
		if not ED_AudioAPI.isSourcePlaying(self.sndAPU) then
			ED_AudioAPI.playSourceOnce(self.sndAPUbegin)
			ED_AudioAPI.playSourceLooped(self.sndAPU)
		end
	end
end
