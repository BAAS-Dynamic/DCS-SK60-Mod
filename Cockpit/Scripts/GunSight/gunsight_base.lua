dofile(LockOn_Options.common_script_path .. "elements_defs.lua")
dofile(LockOn_Options.common_script_path .. "devices_defs.lua")
dofile(LockOn_Options.script_path .. "Gunsight/gunsight_def.lua")



local aspect = GetAspect()



local baseClip      = addGunsightMeshPoly(nil, nil, nil, nil, hcr.rw, lvl.noclip, nil, nil, {{1, aspect/2}, {1, -aspect}, {-1, -aspect}, {-1, aspect/2}, {-0.76, aspect}, {0.76, aspect}}, {0,1,2, 0,2,3, 0,3,4, 0,4,5}, matl.mask, true)
baseClip.collimated = false

addGunsightMeshPoly(nil, {0, gunsightYOffset, gunsightZOffset}, {0, 0, gunsightRotOffset}, nil, hcr.incIf, lvl.noclip, nil, nil, create_circle_pos(120, 0, 0, 3000 * gunsightSizeScaler), create_circle_index(120), matl.mask, true)


addGunsightSimple("Gunsight_Base", {0, gunsightYOffset, gunsightZOffset}, {0, 0, gunsightRotOffset}, nil, nil, nil)



addGunsightCircle("Gunsight", {1.45}, nil, "Gunsight_Base", nil, nil, {"gunsightX", "gunsightY"}, {{ctrl.moveX,0, 1}, {ctrl.moveY,1, -1}}, 7, 8, 360, 25)

for i = -1, 1, 2 do
	addGunsightSimpleLine(nil, nil, nil, "Gunsight", nil, nil, nil, nil, nil, {{20 * i, 0}, {7.9 * i, 0}})
end