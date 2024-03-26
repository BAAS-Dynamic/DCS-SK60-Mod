--Lua files are used for initial loading
dofile(LockOn_Options.common_script_path.."devices_defs.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")
dofile(LockOn_Options.script_path.."debug_util.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."sounds_def.lua")

local SoundSystem = GetSelf()
--Set the number of cycles
local update_rate = 0.05 -- 20次每秒
-- make_default_activity(update_rate)

--Initialize DCS read API
local sensor_data = get_base_data()

function post_initialize()
    local birth = LockOn_Options.init_conditions.birth_place

    if birth == "GROUND_HOT" then

    elseif birth == "GROUND_COLD" then

    elseif birth == "AIR_HOT" then
        
    end

    -- initial the sound
    -- center panel
    sndhost_cockpit_left            = create_sound_host("COCKPIT_LDP","3D",0.3,-0.3,-0.3) 
    snd_left_panel_switch           = sndhost_cockpit_left:create_sound("Aircrafts/SK-60/SK60_Switch")
    -- center panel
    sndhost_cockpit_center          = create_sound_host("COCKPIT_CDP","3D",0.3,-0.3,0.3) 
    snd_center_panel_switch         = sndhost_cockpit_center:create_sound("Aircrafts/SK-60/SK60_Switch")
    -- center panel
    sndhost_cockpit_right           = create_sound_host("COCKPIT_RDP","3D",0.3,-0.3,0.9) 
    snd_right_panel_switch          = sndhost_cockpit_right:create_sound("Aircrafts/SK-60/SK60_Switch")
    -- electrical power
    sndhost_electrical              = create_sound_host("ELECTRIC_UNIT", "3D", -0.5, 0, 0)
    snd_main_electric_invert        = sndhost_electrical:create_sound("Aircrafts/SK-60/SK60_Main_Elec")
    snd_gear_action                 = sndhost_electrical:create_sound("Aircrafts/SK-60/SK60_Gear_Down")
end

SoundSystem:listen_command(Keys.SND_LEFT_PANEL)
SoundSystem:listen_command(Keys.SND_CENTER_PANEL)
SoundSystem:listen_command(Keys.SND_RIGHT_PANEL)
SoundSystem:listen_command(Keys.SND_ELECTRIC)
SoundSystem:listen_command(Keys.SND_GEAR)

local snd_main_elec_play = 0

function SetCommand(command, value)
    dprintf("get command, value compare is"..value)
    if command == Keys.SND_LEFT_PANEL then
         if value == cockpit_sound.basic_switch then
            snd_left_panel_switch:play_once()
         end
    elseif command == Keys.SND_CENTER_PANEL then
        if value == cockpit_sound.basic_switch then
            snd_center_panel_switch:play_once()
        end
    elseif command == Keys.SND_RIGHT_PANEL then
        if value == cockpit_sound.basic_switch then
            snd_right_panel_switch:play_once()
        end
    elseif command == Keys.SND_ELECTRIC then
        if (value == 1 and not snd_main_electric_invert:is_playing()) then
            snd_main_electric_invert:play_continue()
        elseif value == 0 then
            snd_main_electric_invert:stop()
        end
    elseif command == Keys.SND_GEAR then
        snd_gear_action:play_once()
    end
end

function update()
end

need_to_be_closed = false