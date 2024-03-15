dofile(LockOn_Options.common_script_path .. "elements_defs.lua")



SetScale(FOV)



ctrl = {
	argInRange    = "draw_argument_in_range",                      --{ctrl.argInRange,argNum, greaterThanValue, lessThanValue} If greaterThanValue < argValue < lessThanValue then obj is visible.
	changeColor   = "change_color_when_parameter_equal_to_number", --{ctrl.changeColor,paramNum, num, r, g, b} If paramNum == num then set color to rgb.
	compareNum    = "parameter_compare_with_number",               --{ctrl.compareNum,paramNum, num} If paramValue == num then obj is visible.
	compareParams = "compare_parameters",                          --{ctrl.compare,param1Num, param2Num} If param1Value == param1Value then obj is visible.
	inRange       = "parameter_in_range",                          --{ctrl.inRange,paramNum, greaterThanValue, lessThanValue} If greaterThanValue < paramValue < lessThanValue then obj is visible.
	moveX         = "move_left_right_using_parameter",             --{ctrl.moveX,paramNum, gain} Moves obj 1 gain on the x plane per value.
	moveY         = "move_up_down_using_parameter",                --{ctrl.moveY,paramNum, gain} Moves obj 1 gain on the y plane per value.
	opacity       = "opacity_using_parameter",                     --{ctrl.opacity,paramNum} Changes opacity with value (1 = 100%, 0 = 0%).
	rotate        = "rotate_using_parameter",                      --{ctrl.rotate,paramNum, gain} Rotates obj 1 gain per value.
	setPoint      = "line_object_set_point_using_parameters",      --{ctrl.setPoint,verticeNum, paramX, paramY, gainX, gainY} (ONLY APPLIES TO "ceSimpleLineObject") Moves verticeNum 1 gainX on the x plane per paramXValue + Moves verticeNum 1 gainY on the y plane per paramYValue.
	text          = "text_using_parameter"                         --{ctrl.text,paramNum, formatNum} Prints paramNum value (dunno what formatNum means).
}


hcr = {
	cmp   = h_clip_relations.COMPARE, 
	dec   = h_clip_relations.DECREASE_LEVEL, 
	decIf = h_clip_relations.DECREASE_IF_LEVEL, 
	inc   = h_clip_relations.INCREASE_LEVEL, 
	incIf = h_clip_relations.INCREASE_IF_LEVEL, 
	rw    = h_clip_relations.REWRITE_LEVEL
}


lvl = {
	def    = 8, 
	mask   = 5, 
	noclip = 7, 
}


matl = {
	mY   = MakeMaterial(nil, {233, 139, 42, 255}), 
	mask = MakeMaterial(nil, {255, 0, 255, 255/2})
}


gunsightZOffset = 750
gunsightYOffset = -0.95 * gunsightZOffset
gunsightRotOffset = 40
gunsightSizeScaler = 150



function create_circle_index(totalDots)
    local returnGroup = {}

    for i = 1, totalDots - 1, 1 do
        returnGroup[i * 3 - 2] = 0;
        returnGroup[i * 3 - 1] = i;
        returnGroup[i * 3] = i + 1;
    end

    return returnGroup
end

function create_circle_pos(totalDots, centerX, centerY, radius)
    local returnGroup = {}
    local tmpDeg = 0
    local tmpX = 0
    local tmpY = 0

    for i = 1, totalDots, 1 do
        tmpX = math.sin(math.rad(tmpDeg)) * radius + centerX
        tmpY = math.cos(math.rad(tmpDeg)) * radius + centerY
        returnGroup[i] = {tmpX / 2000, tmpY / 2000}
        tmpDeg = tmpDeg + 360 / totalDots
    end

    return returnGroup
end


function setGunsightBrightness(obj, elementParams, controllers)
	if elementParams and controllers then
		elementParams[#elementParams + 1] = "gunsightBrightness"
		controllers[#controllers + 1]     = {ctrl.opacity,#elementParams - 1}

		obj.element_params = elementParams
		obj.controllers    = controllers
	else
		obj.element_params = {"gunsightBrightness"}
		obj.controllers    = {{ctrl.opacity,0}}
	end
end

function setCommonGunsightProperties(obj, name, pos, rot, parentElement, hClip, level, elementParams, controllers, isMask)
	obj.name                   = name or create_guid_string()
	obj.init_pos               = pos or nil
	obj.init_rot               = rot or nil
	if parentElement then
		if type(parentElement) == 'userdata' and parentElement.name then
			obj.parent_element = parentElement.name
		elseif type(parentElement) == 'string' then
			obj.parent_element = parentElement
		end
	end
	obj.h_clip_relation        = hClip or hcr.cmp
	obj.level                  = level or lvl.def
	setGunsightBrightness(obj, elementParams, controllers)
	obj.collimated             = true
	obj.use_mipfilter          = true
	obj.additive_alpha         = true
	obj.blend_mode             = blend_mode.IBM_REGULAR_ADDITIVE_ALPHA
	obj.isvisible              = not isMask
	Add(obj)

	return obj
end


function addGunsightSimple(name, pos, rot, parentElement, hClip, level, elementParams, controllers)
	local simple = CreateElement "ceSimple"
	setCommonGunsightProperties(simple, name, pos, rot, parentElement, hClip, level, elementParams, controllers)

	return simple
end


function addGunsightMeshPoly(name, pos, rot, parentElement, hClip, level, elementParams, controllers, vertices, indices, material, isMask)
	local meshPoly         = CreateElement "ceMeshPoly"
	meshPoly.primitivetype = "triangles"
	meshPoly.vertices      = vertices
	meshPoly.indices       = indices
	meshPoly.material      = material or matl.mY
	setCommonGunsightProperties(meshPoly, name, pos, rot, parentElement, hClip, level, elementParams, controllers, isMask)

	return meshPoly
end

function addGunsightCircle(name, pos, rot, parentElement, hClip, level, elementParams, controllers, outerRadius, innerRadius, arc, res, material, isMask)
	local circle = {}
	set_circle(circle, outerRadius, innerRadius, arc, res)

	return addGunsightMeshPoly(name, pos, rot, parentElement, hClip, level, elementParams, controllers, circle.vertices, circle.indices, material, isMask)
end

function addGunsightSimpleLine(name, pos, rot, parentElement, hClip, level, elementParams, controllers, width, vertices, material, isMask)
	local simpleLine           = CreateElement "ceSimpleLineObject"
	simpleLine.width           = width or 0.5
	simpleLine.vertices        = vertices or {{0}, {0}}
	simpleLine.material        = material or matl.mY
	setCommonGunsightProperties(simpleLine, name, pos, rot, parentElement, hClip, level, elementParams, controllers, isMask)

	return simpleLine
end