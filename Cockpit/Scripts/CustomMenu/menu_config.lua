-- this is menu config
dofile(LockOn_Options.script_path.."command_defs.lua")

EXIT_AFTER_ACT = 0
NOT_EXIT = 1
UNUSED = -5
MENU_ENTRY = -1

-- declear submenu list
submenu_id = {}
-- main menu is the entry, it will always trigger submenu 0 first
submenu_id["MAIN_MENU"] = 0
submenu_id["GROUND_CREW"] = 1
submenu_id["CONFIGURATION"] = 2
submenu_id["WEAPON_SETTING"] = 3
-- submenu_id["HMD_DISPLAY"] = 4

-- Note: the max value of the table is 7 for each menu
-- config of submenu
submenu = {}
-- announce submenu
-- menu entry is the config of active menu when trigger
submenu[submenu_id.MAIN_MENU] = {}
-- default 0 is the center display config
-- the parameters are: display name, display icon, and the pervious menu
-- an return menu will be loaded automatically
submenu[submenu_id.MAIN_MENU][0] ={"Main Menu", 1, nil}
-- start from 1
--#region                   "lable", position of the icon, command, submenu id
-- if command == -1, it will be regarded as an submenu entry; use command 0 or <-2 for the not used place holder
-- fourth value is the entry of submenu if command is -1, else it will be marked as if auto close menu when action is send out
-- 0 is exit after this command, 1 is do not exit
-- the final value is the command value, set it to nil when no value is required
submenu[submenu_id.MAIN_MENU][#submenu[submenu_id.MAIN_MENU]+1] ={"Ground Crew",    35,   MENU_ENTRY,  submenu_id.GROUND_CREW, nil}
submenu[submenu_id.MAIN_MENU][#submenu[submenu_id.MAIN_MENU]+1] ={"Configuration",    10,   MENU_ENTRY,  submenu_id.CONFIGURATION, nil}
submenu[submenu_id.MAIN_MENU][#submenu[submenu_id.MAIN_MENU]+1] ={"Weapon setting",    27,   MENU_ENTRY,  submenu_id.WEAPON_SETTING, nil}
-- menuEntry[#menuEntry+1] ={"On Screen Display",    3,   -1,  submenu_id.HMD_DISPLAY}

submenu[submenu_id.GROUND_CREW] = {}
submenu[submenu_id.GROUND_CREW][0] = {"Ground Crew", 35, submenu_id.MAIN_MENU}
submenu[submenu_id.GROUND_CREW][#submenu[submenu_id.GROUND_CREW]+1] = {"Ladder",    11,   -5,  EXIT_AFTER_ACT, nil}
submenu[submenu_id.GROUND_CREW][#submenu[submenu_id.GROUND_CREW]+1] = {"iPad",    12,   Keys.MusicScreenHide, EXIT_AFTER_ACT, nil}
submenu[submenu_id.GROUND_CREW][#submenu[submenu_id.GROUND_CREW]+1] = {"SunGlass",    12,   -5,  EXIT_AFTER_ACT, nil}
submenu[submenu_id.GROUND_CREW][#submenu[submenu_id.GROUND_CREW]+1] = {"Install Gunsight",    37,   Keys.GunSightInstall,  EXIT_AFTER_ACT, nil}
submenu[submenu_id.GROUND_CREW][#submenu[submenu_id.GROUND_CREW]+1] = {"Unmount Gunsight",    36,   Keys.GunSightUninstall,  EXIT_AFTER_ACT, nil}

submenu[submenu_id.CONFIGURATION] = {}
submenu[submenu_id.CONFIGURATION][0] = {"Configuration", 10, submenu_id.MAIN_MENU}
submenu[submenu_id.CONFIGURATION][#submenu[submenu_id.CONFIGURATION]+1] = {"CoG",    28,   -5,  EXIT_AFTER_ACT, nil}
submenu[submenu_id.CONFIGURATION][#submenu[submenu_id.CONFIGURATION]+1] = {"iPad",    12,   -5,  EXIT_AFTER_ACT, nil}

submenu[submenu_id.WEAPON_SETTING] = {}
submenu[submenu_id.WEAPON_SETTING][0] = {"Rocket Settings", 27, submenu_id.MAIN_MENU}
submenu[submenu_id.WEAPON_SETTING][#submenu[submenu_id.WEAPON_SETTING]+1] = {"Single Mode",    27,   Keys.WeaponConfigSingle,  EXIT_AFTER_ACT, nil}
submenu[submenu_id.WEAPON_SETTING][#submenu[submenu_id.WEAPON_SETTING]+1] = {"Pairs Mode",    27,   Keys.WeaponConfigPairs,  EXIT_AFTER_ACT, nil}
submenu[submenu_id.WEAPON_SETTING][#submenu[submenu_id.WEAPON_SETTING]+1] = {"All Mode",    27,   Keys.WeaponConfigAll,  EXIT_AFTER_ACT, nil}