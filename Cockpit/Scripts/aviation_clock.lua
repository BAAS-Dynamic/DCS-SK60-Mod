dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")

local dev = GetSelf()

local update_time_step = 0.02  --每秒50次刷新
make_default_activity(update_time_step)

local sensor_data = get_base_data()

local hour_ind = get_param_handle("CLOCK_H")
local min_ind = get_param_handle("CLOCK_M")
local second_ind = get_param_handle("CLOCK_S")

function post_initialize()
    local current_time_in_second = get_absolute_model_time()
    local current_seconds = math.fmod(current_time_in_second , 60)
    second_ind:set(current_seconds/60)
end


function update()
    -- dprintf(get_absolute_model_time())
    local current_time_in_second = get_absolute_model_time()
    local current_hour = current_time_in_second / 3600
    local current_minute = math.fmod(current_time_in_second , 3600) / 60
    local target_seconds = math.fmod(current_time_in_second , 60)
    local current_seconds = second_ind:get() * 60
    if (current_hour > 12) then
        current_hour = current_hour - 12
    end
    if target_seconds > current_seconds then
        current_seconds = current_seconds + 0.1
    elseif target_seconds < 5 and current_seconds > 58 then
        if current_seconds < 60 then
            current_seconds = current_seconds + 0.1
        else
            current_seconds = current_seconds + 0.1 - 60
        end
    end
    hour_ind:set(current_hour / 12)
    min_ind:set(current_minute / 60)
    second_ind:set(current_seconds / 60)
end

need_to_be_closed = false
