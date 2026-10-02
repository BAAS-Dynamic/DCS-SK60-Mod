dofile(LockOn_Options.script_path.."devices.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")

local dev = GetSelf()

-- SRS compatibility
function dev:is_on()
    return true
end

function dev:get_frequency()
    return 0
end

GUI = {
}

local update_time_step = 0.05

if make_default_activity then
    make_default_activity(update_time_step)
end

function update()
end

function post_initialize()
    str_ptr = string.sub(tostring(dev.link),10)
    local set_intercom_pointer = get_param_handle("INTERCOM_POINTER")
    set_intercom_pointer:set(str_ptr)
end

function SetCommand(command,value)
end

need_to_be_closed = false
