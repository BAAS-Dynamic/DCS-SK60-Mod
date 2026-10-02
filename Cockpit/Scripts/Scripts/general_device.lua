dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."devices.lua")
local JSON = loadfile "Scripts\\JSON.lua"()


------------------------------------- NWS_Coupled_Separate_Input_Device
local NWS_Coupled_Separate_Input_Device = get_param_handle("NWS_Coupled_Separate_Input_Device")
if (get_plugin_option_value("Hercules","NWS_Coupled_Separate_Input_Device") == true) then
	NWS_Coupled_Separate_Input_Device:set(1.0)
else
	NWS_Coupled_Separate_Input_Device:set(0.0)
end

