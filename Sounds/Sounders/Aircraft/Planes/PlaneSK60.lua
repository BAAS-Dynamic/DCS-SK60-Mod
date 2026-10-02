dofile("Aircraft/Planes/Plane.lua")

SK60Plane = plane:new()

dofile("Aircraft/Engines/SK60Engine.lua")

function SK60Plane:createEngines()
    self.engines[1] = SK60Engine:new()
    self.engines[1]:init(1, host)

    self.engines[2] = SK60Engine:new()
    self.engines[2]:init(2, host)
end

SK60Plane:createEngines()

function onUpdate(params)
    SK60Plane:onUpdate(params)
end
