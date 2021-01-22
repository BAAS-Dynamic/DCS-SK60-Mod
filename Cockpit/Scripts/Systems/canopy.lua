dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")

local update_time_step = 0.02  --每秒50次刷新
make_default_activity(update_time_step)

local sensor_data = get_base_data()

local Canopy = 71  --定义舱盖按键

local CANOPY_COMMAND = 1   --舱盖状态 0 关闭, 1 开启
local CANOPY_ANI_INSIDE = get_param_handle("CanopyInsideView")

local canopy_system = GetSelf()
canopy_system:listen_command(Canopy)

function post_initialize()
	local CANOPY_ANI_INSIDE = get_param_handle("CanopyInsideView")
    local birth = LockOn_Options.init_conditions.birth_place
    if birth=="GROUND_HOT" then
        CANOPY_COMMAND = 0
    elseif birth=="AIR_HOT" then
        CANOPY_COMMAND = 0
    elseif birth=="GROUND_COLD" then
        CANOPY_COMMAND = 1
    end

    -- set_aircraft_draw_argument_value(38,CANOPY_COMMAND)
end

set_aircraft_draw_argument_value(38, 0)
CANOPY_ANI_INSIDE:set(0)

function SetCommand(command,value)			
	if (command == Canopy) then
        CANOPY_COMMAND = 1 - CANOPY_COMMAND
        if (CANOPY_COMMAND == 1) then
            print_message_to_user("Opening Canopy") -- 这是游戏内的调试输出，会显示在左上角，遇到奇怪的问题就用这个打印参数
        else
            print_message_to_user("Closing Canopy")
        end
	end
end

function update()		
    local CanoStatus= CANOPY_ANI_INSIDE:get()	--get_aircraft_draw_argument_value(38)
    
	if (CANOPY_COMMAND == 0 and CanoStatus > 0) then
		-- lower canopy in increments of 0.01 (50x per second)
		CanoStatus = CanoStatus - 0.01
        set_aircraft_draw_argument_value(38,CanoStatus)
        CANOPY_ANI_INSIDE:set(CanoStatus)
	elseif (CANOPY_COMMAND == 1 and CanoStatus < 0.9) then
        -- raise canopy in increment of 0.01 (50x per second)
		CanoStatus = CanoStatus + 0.01
        set_aircraft_draw_argument_value(38,CanoStatus)
        CANOPY_ANI_INSIDE:set(CanoStatus)
    end
    
end

need_to_be_closed = false