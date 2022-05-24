dofile(LockOn_Options.script_path.."devices.lua")

cockpit_sound = 
{
    basic_switch = 1,
}

snd_device = GetDevice(devices.SOUND_SYSTEM)
-- dofile(LockOn_Options.script_path.."sounds_defs.lua")
-- snd_device:performClickableAction(command,value,false)
-- dispatch_action(devices.SOUND_SYSTEM, Keys.SND_CENTER_PANEL, cockpit_sound.basic_switch)
