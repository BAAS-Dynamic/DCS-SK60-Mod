dofile(LockOn_Options.script_path.."devices.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")

package.cpath = package.cpath .. ";" .. LockOn_Options.script_path .. "..\\..\\bin\\?.dll"
require('avSimplestRadio')

local dev = GetSelf()

local iCommandPlaneIntercomUHFPress = 1172
local voice_ptt_0_icommand = 1731
local voice_ptt_1_icommand = 1732

function post_initialize()
    avSimplestRadio.SetupRadios(
        devices.ELECTRIC_SYSTEM,
        devices.INTERCOM,
        2,
        devices.UHF_RADIO,
        devices.VHF2_RADIO
    )
end

dev:listen_command(iCommandPlaneIntercomUHFPress)
dev:listen_command(voice_ptt_0_icommand)
dev:listen_command(voice_ptt_1_icommand)

function SetCommand(command, value)
   -- Keep the old in-cockpit UHF press behavior mapped to radio 1.
    if command == iCommandPlaneIntercomUHFPress then
        avSimplestRadio.PTT(1)
        return
    end

   -- SRS/DCS PTT 1 -> UHF, PTT 2 -> VHF2.
    if command == voice_ptt_0_icommand then
        if value == 1 then
            avSimplestRadio.PTT(1)
        end
    elseif command == voice_ptt_1_icommand then
        if value == 1 then
            avSimplestRadio.PTT(2)
        end
    end
end

need_to_be_closed = false
