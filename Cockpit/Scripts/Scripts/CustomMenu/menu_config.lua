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
submenu_id["WEAPON_SELECTION"] = 1
submenu_id["ROCKET_FIRE_MODE"] = 2
submenu_id["ROCKET_QUANTITY"] = 3

-- Note: the max value of the table is 7 for each menu
-- config of submenu
submenu = {}
-- announce submenu
-- menu entry is the config of active menu when trigger
submenu[submenu_id.MAIN_MENU] = {}
-- default 0 is the center display config
-- the parameters are: display name, display icon, and the pervious menu
-- an return menu will be loaded automatically
submenu[submenu_id.MAIN_MENU][0] ={"Weapon Settings", 27, nil}
-- start from 1
--#region                   "lable", position of the icon, command, submenu id
-- if command == -1, it will be regarded as an submenu entry; use command 0 or <-2 for the not used place holder
-- fourth value is the entry of submenu if command is -1, else it will be marked as if auto close menu when action is send out
-- 0 is exit after this command, 1 is do not exit
-- the final value is the command value, set it to nil when no value is required
submenu[submenu_id.MAIN_MENU][#submenu[submenu_id.MAIN_MENU]+1] = {"Select Weapon",    27,   MENU_ENTRY,  submenu_id.WEAPON_SELECTION, nil}
submenu[submenu_id.MAIN_MENU][#submenu[submenu_id.MAIN_MENU]+1] = {"Rocket Firing Mode",    27,   MENU_ENTRY,  submenu_id.ROCKET_FIRE_MODE, nil}
submenu[submenu_id.MAIN_MENU][#submenu[submenu_id.MAIN_MENU]+1] = {"Rockets Per Impulse",    27,   MENU_ENTRY,  submenu_id.ROCKET_QUANTITY, nil}

submenu[submenu_id.WEAPON_SELECTION] = {}
submenu[submenu_id.WEAPON_SELECTION][0] = {"Select Weapon", 27, submenu_id.MAIN_MENU}
submenu[submenu_id.WEAPON_SELECTION][#submenu[submenu_id.WEAPON_SELECTION]+1] = {"AKAN",    27,   Keys.WeaponSelectAkan,  EXIT_AFTER_ACT, nil}
submenu[submenu_id.WEAPON_SELECTION][#submenu[submenu_id.WEAPON_SELECTION]+1] = {"ROCKET",    27,   Keys.WeaponSelectRocket,  EXIT_AFTER_ACT, nil}

submenu[submenu_id.ROCKET_FIRE_MODE] = {}
submenu[submenu_id.ROCKET_FIRE_MODE][0] = {"Rocket Firing Mode", 27, submenu_id.MAIN_MENU}
submenu[submenu_id.ROCKET_FIRE_MODE][#submenu[submenu_id.ROCKET_FIRE_MODE]+1] = {"SERIE",    27,   Keys.WeaponConfigSerie,  EXIT_AFTER_ACT, nil}
submenu[submenu_id.ROCKET_FIRE_MODE][#submenu[submenu_id.ROCKET_FIRE_MODE]+1] = {"IMPULS",    27,   Keys.WeaponConfigImpuls,  EXIT_AFTER_ACT, nil}

submenu[submenu_id.ROCKET_QUANTITY] = {}
submenu[submenu_id.ROCKET_QUANTITY][0] = {"Rockets Per Impulse", 27, submenu_id.MAIN_MENU}
submenu[submenu_id.ROCKET_QUANTITY][#submenu[submenu_id.ROCKET_QUANTITY]+1] = {"SINGEL",    27,   Keys.WeaponConfigSingle,  EXIT_AFTER_ACT, nil}
submenu[submenu_id.ROCKET_QUANTITY][#submenu[submenu_id.ROCKET_QUANTITY]+1] = {"DUBBEL",    27,   Keys.WeaponConfigPairs,  EXIT_AFTER_ACT, nil}
