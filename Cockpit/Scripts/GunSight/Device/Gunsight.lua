dofile(LockOn_Options.script_path .. "command_defs.lua")
dofile(LockOn_Options.script_path .. "devices.lua")



local updateTimeStep = 1/17
make_default_activity(updateTimeStep)



local gunsight = GetSelf()


local armamentType = get_param_handle("armamentType")

local gunsightEnable = get_param_handle("gunsightEnable")
local gunsightBrightness = get_param_handle("gunsightBrightness")
local gunsightX = get_param_handle("gunsightX")
local gunsightY = get_param_handle("gunsightY")




local sensorData = get_base_data()


local fadeIn  = 0
local fadeOut = 0

local prevStatus = 0



function post_initialize()
	
end

function update()
	gunsightY:set(sensorData.getVerticalAcceleration() - 1)
	gunsightX:set(-sensorData.getLateralAcceleration() * 10)



	if gunsightEnable:get() == 1 and prevStatus == 0 then
		fadeOut = 0
		fadeIn = fadeIn + updateTimeStep

		if gunsightBrightness:get() >= 1 then
			gunsightBrightness:set(1)
			fadeIn = 0
			prevStatus = 1
		else
			gunsightBrightness:set(gunsightBrightness:get() + fadeIn)
		end
	elseif gunsightEnable:get() == 0 and prevStatus == 1 then
		fadeIn = 0
		fadeOut = fadeOut + updateTimeStep

		if gunsightBrightness:get() <= 0 then
			gunsightBrightness:set(0)
			fadeOut = 0
			prevStatus = 0
		else
			gunsightBrightness:set(gunsightBrightness:get() - fadeOut)
		end
	end
end

function SetCommand(command, value)

end



need_to_be_closed = false