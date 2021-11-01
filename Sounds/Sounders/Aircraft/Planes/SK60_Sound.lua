dofile("Aircraft/Planes/SK60Plane.lua")

BAEHawk = plane:new()

dofile("Aircraft/Engines/APUs/GTS.lua")
dofile("Aircraft/Engines/Rolls-Royce Adour.lua")

function BAEHawk:createEngines()
	-- self.engines[0] = engine:new()
	-- self.engines[0]:init(0, host)
	-- self.engines[0]:initCptNames()
	self.engines[1] = engine:new()
	self.engines[1]:init(1, host)
	self.engines[1]:initCptNames()
end

BAEHawk:createEngines()

function onUpdate(params)
	BAEHawk:onUpdate(params)
end