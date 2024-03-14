dofile(LockOn_Options.script_path .. "command_defs.lua")



local updateTimeStep = 1/30
make_default_activity(updateTimeStep)



local misc = GetSelf()

misc:listen_command(Keys.pilotToggle)


local pilotToggle = get_param_handle("pilotToggle")

function post_initialize()

end

function update()

end

function SetCommand(command, value)
	if command == Keys.pilotToggle then
		if pilotToggle:get() == 1 then
			pilotToggle:set(0)
		else
			pilotToggle:set(1)
		end
	end
end



need_to_be_closed = false