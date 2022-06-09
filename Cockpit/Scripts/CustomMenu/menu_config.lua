-- this is menu config
dofile(LockOn_Options.script_path.."command_defs.lua")

-- declear submenu list
submenu_id = {}
-- main menu is the entry, it will always trigger submenu 0 first
submenu_id["MAIN_MENU"] = 0
submenu_id["GROUND_CREW"] = 1
submenu_id["CONFIGURATION"] = 2
submenu_id["WEAPON_SETTING"] = 3
-- submenu_id["HMD_DISPLAY"] = 4

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
-- if command == -1, it will be regarded as an submenu entry; use command 0 for the not used
submenu[submenu_id.MAIN_MENU][#submenu[submenu_id.MAIN_MENU]+1] ={"Ground Crew",    35,   -1,  submenu_id.GROUND_CREW}
submenu[submenu_id.MAIN_MENU][#submenu[submenu_id.MAIN_MENU]+1] ={"Configuration",    10,   -1,  submenu_id.CONFIGURATION}
submenu[submenu_id.MAIN_MENU][#submenu[submenu_id.MAIN_MENU]+1] ={"Weapon setting",    27,   -1,  submenu_id.WEAPON_SETTING}
-- menuEntry[#menuEntry+1] ={"On Screen Display",    3,   -1,  submenu_id.HMD_DISPLAY}

submenu[submenu_id.GROUND_CREW] = {}
submenu[submenu_id.GROUND_CREW][0] = {"Ground Crew", 35, submenu_id.MAIN_MENU}
submenu[submenu_id.GROUND_CREW][#submenu[submenu_id.GROUND_CREW]+1] = {"Ladder",    11,   -5,  nil}
submenu[submenu_id.GROUND_CREW][#submenu[submenu_id.GROUND_CREW]+1] = {"iPad",    12,   -5,  nil}
submenu[submenu_id.GROUND_CREW][#submenu[submenu_id.GROUND_CREW]+1] = {"SunGlass",    12,   -5,  nil}

submenu[submenu_id.CONFIGURATION] = {}
submenu[submenu_id.CONFIGURATION][0] = {"Configuration", 10, submenu_id.MAIN_MENU}
submenu[submenu_id.CONFIGURATION][#submenu[submenu_id.CONFIGURATION]+1] = {"CoG",    28,   -5,  nil}
submenu[submenu_id.CONFIGURATION][#submenu[submenu_id.CONFIGURATION]+1] = {"iPad",    12,   -5,  nil}

submenu[submenu_id.WEAPON_SETTING] = {}
submenu[submenu_id.WEAPON_SETTING][0] = {"Rocket Settings", 27, submenu_id.MAIN_MENU}
submenu[submenu_id.WEAPON_SETTING][#submenu[submenu_id.WEAPON_SETTING]+1] = {"Single Mode",    27,   -5,  nil}
submenu[submenu_id.WEAPON_SETTING][#submenu[submenu_id.WEAPON_SETTING]+1] = {"Pairs Mode",    27,   -5,  nil}
submenu[submenu_id.WEAPON_SETTING][#submenu[submenu_id.WEAPON_SETTING]+1] = {"All Mode",    27,   -5,  nil}