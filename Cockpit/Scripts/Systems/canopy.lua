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
    sndhost_cockpit         = create_sound_host("COCKPIT","3D",0,-1,0) 
    snd_canopy_open_sound   = sndhost_cockpit:create_sound("Aircrafts/SK-60/CanopyOpen")
    snd_canopy_close_sound   = sndhost_cockpit:create_sound("Aircrafts/SK-60/CanopyClose")
end

set_aircraft_draw_argument_value(38, 0)
CANOPY_ANI_INSIDE:set(0)

LOCK_TIME_COUNT = 0

function SetCommand(command,value)			
	if (command == Canopy) then
        CANOPY_COMMAND = 1 - CANOPY_COMMAND
        if (CANOPY_COMMAND == 1) then
            print_message_to_user("Opening Canopy") -- 这是游戏内的调试输出，会显示在左上角，遇到奇怪的问题就用这个打印参数
            LOCK_TIME_COUNT = 0
        else
            print_message_to_user("Closing Canopy")
        end
        LOCK_TIME_COUNT = 0
	end
end

function update()		
    local CanoStatus= CANOPY_ANI_INSIDE:get()	--get_aircraft_draw_argument_value(38)
    -- 50 times/s 6 sec to finish
    -- step will be 1/300
    
    if (CANOPY_COMMAND == 0 and CanoStatus > 0) then
        LOCK_TIME_COUNT = 0
		-- lower canopy in increments of 0.01 (50x per second)
		CanoStatus = CanoStatus - 0.95/300
        set_aircraft_draw_argument_value(38,CanoStatus)
        CANOPY_ANI_INSIDE:set(CanoStatus)
        if not snd_canopy_close_sound:is_playing() then
            snd_canopy_close_sound:play_continue() 
        end
	elseif (CANOPY_COMMAND == 1 and CanoStatus < 0.95) then
        -- raise canopy in increment of 0.01 (50x per second)
        if LOCK_TIME_COUNT > 40 then
            CanoStatus = CanoStatus + 0.95/300
            set_aircraft_draw_argument_value(38,CanoStatus)
            CANOPY_ANI_INSIDE:set(CanoStatus)
        else
            LOCK_TIME_COUNT = LOCK_TIME_COUNT + 1
        end
        if not snd_canopy_open_sound:is_playing() then
            snd_canopy_open_sound:play_continue() 
        end
    else
        if snd_canopy_open_sound:is_playing() then
            snd_canopy_open_sound:stop()
        end
        if snd_canopy_close_sound:is_playing() then
            LOCK_TIME_COUNT = LOCK_TIME_COUNT + 1
            if LOCK_TIME_COUNT > 40 then
                snd_canopy_close_sound:stop()
            end
        end
    end
    
end

need_to_be_closed = false