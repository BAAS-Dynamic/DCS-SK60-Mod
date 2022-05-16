dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."debug_util.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")

local update_time_step = 0.02  --每秒50次刷新
make_default_activity(update_time_step)

local sensor_data = get_base_data()

local Canopy = 71  --定义舱盖按键

local CANOPY_COMMAND = 1   --舱盖状态 0 关闭, 1 开启
local CANOPY_ANI_INSIDE = get_param_handle("CanopyInsideView")
local CANOPY_INSIDE = get_param_handle("Inside_Canopy")

local canopy_system = GetSelf()
canopy_system:listen_command(Canopy)

local SWITCH_OFF = 0
local SWITCH_ON = 1
local SWITCH_TEST = -1

switch_count = 0
function _switch_counter()
    switch_count = switch_count + 1
    return switch_count
end

local canopy_switch = _switch_counter()

target_status = {
    {canopy_switch , SWITCH_OFF, get_param_handle("PTN_601"), "PTN_601", 1/40, 0},
}

current_status = {
    {canopy_switch , SWITCH_OFF,},
}


function post_initialize()
	local CANOPY_ANI_INSIDE = get_param_handle("CanopyInsideView")
    local birth = LockOn_Options.init_conditions.birth_place
    if birth=="GROUND_HOT" then
        CANOPY_COMMAND = 0
    elseif birth=="AIR_HOT" then
        CANOPY_COMMAND = 0
    elseif birth=="GROUND_COLD" then
        CANOPY_COMMAND = 1
        target_status[canopy_switch][2] = SWITCH_ON
    end
    sndhost_cockpit         = create_sound_host("COCKPIT","3D",0,-1,0) 
    snd_canopy_open_sound   = sndhost_cockpit:create_sound("Aircrafts/SK-60/CanopyOpen")
    -- use same for open and close
    snd_canopy_close_sound   = sndhost_cockpit:create_sound("Aircrafts/SK-60/CanopyOpen") -- sndhost_cockpit:create_sound("Aircrafts/SK-60/CanopyClose")
    for k, v in pairs(target_status)do
        current_status[k][2] = target_status[k][2]
        target_status[k][3]:set(current_status[k][2])
    end
    set_aircraft_draw_argument_value(38, CANOPY_COMMAND)
end

CANOPY_ANI_INSIDE:set(0)
CANOPY_INSIDE:set(0)

LOCK_TIME_COUNT = 0

function SetCommand(command,value)			
    if (command == Canopy) then
        if not snd_canopy_close_sound:is_playing() and not snd_canopy_open_sound:is_playing() then
            CANOPY_COMMAND = 1 - CANOPY_COMMAND
            if (CANOPY_COMMAND == 1) then
                dprintf("Opening Canopy") -- 这是游戏内的调试输出，会显示在左上角，遇到奇怪的问题就用这个打印参数
            else
                dprintf("Closing Canopy")
            end
            LOCK_TIME_COUNT = 0
            target_status[canopy_switch][2] = CANOPY_COMMAND
        else
            dprintf("Canopy Acuactor is Moving")
        end
	end
end

function update_switch_status()
    for k,v in pairs(target_status) do
        if math.abs(target_status[k][2] - current_status[k][2]) < target_status[k][5] then
            current_status[k][2] = target_status[k][2]
        elseif target_status[k][2] > current_status[k][2] then
            current_status[k][2] = current_status[k][2] + target_status[k][5]
        elseif target_status[k][2] < current_status[k][2] then
            current_status[k][2] = current_status[k][2] - target_status[k][5]
        end
        target_status[k][3]:set(current_status[k][2])
        local temp_switch_ref = get_clickable_element_reference(target_status[k][4])
        temp_switch_ref:update()
        if target_status[k][6] == 1 then
            if current_status[k][2] == SWITCH_ON then
                current_status[k][2] = SWITCH_OFF
            end
        end
        -- dprintf(k)
    end
end

function update()		
    local CanoStatus= CANOPY_INSIDE:get()	--get_aircraft_draw_argument_value(38)
    -- 50 times/s 6 sec to finish
    -- step will be 1/300

    update_switch_status()
    
    if (CANOPY_COMMAND == 0 and CanoStatus > 0) then
        -- LOCK_TIME_COUNT = 0
        -- lower canopy in increments of 0.01 (50x per second)
        if LOCK_TIME_COUNT > 40 then
            CanoStatus = CanoStatus - 0.95/300
            set_aircraft_draw_argument_value(38,CanoStatus)
            CANOPY_ANI_INSIDE:set(CanoStatus)
            CANOPY_INSIDE:set(CanoStatus)
        else
            LOCK_TIME_COUNT = LOCK_TIME_COUNT + 1
        end
        if not snd_canopy_close_sound:is_playing() then
            snd_canopy_close_sound:play_continue() 
        end
	elseif (CANOPY_COMMAND == 1 and CanoStatus < 0.95) then
        -- raise canopy in increment of 0.01 (50x per second)
        if LOCK_TIME_COUNT > 40 then
            CanoStatus = CanoStatus + 0.95/300
            set_aircraft_draw_argument_value(38,CanoStatus)
            CANOPY_ANI_INSIDE:set(CanoStatus)
            CANOPY_INSIDE:set(CanoStatus)
        else
            LOCK_TIME_COUNT = LOCK_TIME_COUNT + 1
        end
        if not snd_canopy_open_sound:is_playing() then
            snd_canopy_open_sound:play_continue() 
        end
    else
        if snd_canopy_open_sound:is_playing() then
            snd_canopy_open_sound:stop()
            LOCK_TIME_COUNT = 0
        end
        if snd_canopy_close_sound:is_playing() then
            snd_canopy_close_sound:stop()
            LOCK_TIME_COUNT = 0
        end
    end
    
end

need_to_be_closed = false