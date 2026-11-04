-- Uses the installed transponder's relative sign/centred-click convention.
dofile(LockOn_Options.script_path .. "command_defs.lua")
local dev = GetSelf()
make_default_activity(0.05)
local ticks = {0, 0, 0, 0}
local handles = {}
local function draw(argument, value)
    if type(set_cockpit_draw_argument_value) == "function" then
        set_cockpit_draw_argument_value(argument, value)
    end
end
local function publish()
    for i=1,4 do
        local position = ticks[i] / 20
        handles[i]:set(position)
        draw(919+i, position)
        -- Reset only the input argument, never the visible mirror argument.
        draw(1919+i, 0)
    end
end
for i=1,4 do
    handles[i] = get_param_handle("SK60_MIRROR_PITCH_" .. i)
    dev:listen_command(mirror_commands["Mirror" .. i .. "Mouse"])
    dev:listen_command(mirror_commands["Mirror" .. i .. "Pitch"])
    dev:listen_command(mirror_commands["Mirror" .. i .. "Reset"])
end
function post_initialize() publish() end
function SetCommand(command, value)
    for i=1,4 do
        if command == mirror_commands["Mirror" .. i .. "Mouse"]
            or command == mirror_commands["Mirror" .. i .. "Pitch"] then
            if value > 0 then ticks[i] = math.min(20, ticks[i]+1)
            elseif value < 0 then ticks[i] = math.max(-20, ticks[i]-1) end
            publish()
            return
        elseif command == mirror_commands["Mirror" .. i .. "Reset"] then
            ticks[i] = 0
            publish()
            return
        end
    end
end
-- Re-publish the unchanged position and centre the input, just as XPDR does.
-- This update never advances the animation or smooths toward a target.
function update() publish() end
need_to_be_closed = false
