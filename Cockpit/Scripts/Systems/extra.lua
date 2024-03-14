--======================================================================================================================================    
dofile(LockOn_Options.script_path.."command_defs.lua")
local update_time_step = 1/30
make_default_activity(update_time_step)

local dev = GetSelf()

dev:listen_command(Keys.PilotBody)
dev:listen_command(Keys.TogglePilotBody)

local ToggleExempelState = 0

function SetCommand(command, value)

    if command == Keys.PilotBody then
        set_aircraft_draw_argument_value(903, 1)
    end
    
    if command == Keys.TogglePilotBody then
        if ToggleExempelState == 0 then
            set_aircraft_draw_argument_value(903, 1)
            ToggleExempelState = 1
        else
            set_aircraft_draw_argument_value(903, 0)
            ToggleExempelState = 0
        end
    
    end
    
end

function post_initialize()
end

function update()
end

need_to_be_closed = false