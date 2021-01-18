local WeaponSystem     = GetSelf()
dofile(LockOn_Options.common_script_path.."devices_defs.lua")
--dofile(LockOn_Options.script_path.."Systems/stores_config.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")

local update_time_step = 0.02  --每秒50次刷新
make_default_activity(update_time_step)

local sensor_data = get_base_data()

local iCommandPlaneWingtipSmokeOnOff = 78
local iCommandPlaneJettisonWeapons = 82
local iCommandPlaneFire = 84
local iCommandPlaneFireOff = 85
local iCommandPlaneChangeWeapon = 101
local iCommandActiveJamming = 136
local iCommandPlaneJettisonFuelTanks = 178
local iCommandPlanePickleOn = 350
local iCommandPlanePickleOff = 351
--local iCommandPlaneDropFlareOnce = 357
--local iCommandPlaneDropChaffOnce = 358

local main_bay_target = 0
local main_bay_status = 0
local pylonSelected = -1

-- 获取锁定状态
-- 是否锁定
local ir_missile_lock_param = get_param_handle("WS_IR_MISSILE_LOCK")
-- 锁定的目标的高程和方向
local ir_missile_az_param = get_param_handle("WS_IR_MISSILE_TARGET_AZIMUTH")
local ir_missile_el_param = get_param_handle("WS_IR_MISSILE_TARGET_ELEVATION")

-- 似乎是设置预设锁定方向？
-- 方位角
local ir_missile_des_az_param = get_param_handle("WS_IR_MISSILE_SEEKER_DESIRED_AZIMUTH")
-- 高程
local ir_missile_des_el_param = get_param_handle("WS_IR_MISSILE_SEEKER_DESIRED_ELEVATION")

-- 获取仪表weaponpage句柄
local weapon_bay_display = get_param_handle("WEAPON_BAY_STATUS_DIS")
local weapon_select_display = get_param_handle("WEAPON_SELECT_DIS")
local weapon_status_display = get_param_handle("WEAPON_STATUS_DIS")
local weapon_mode_display = get_param_handle("WEAPON_MODE_DIS")

WeaponSystem:listen_command(Keys.WeaponSelectNext)
WeaponSystem:listen_command(Keys.WeaponLaunch)
WeaponSystem:listen_command(iCommandPlanePickleOn)

weapon_select_display:set("NO")
weapon_bay_display:set("CLOSE")
weapon_status_display:set("NO")
weapon_mode_display:set("NO WEAPON")

function post_initialize()
    weapon_select_display:set("NO")
    weapon_bay_display:set("CLOSE")
    weapon_status_display:set("NO")
    weapon_mode_display:set("TEST")
end

IS_FOX3 = 0

function getPylonInfo()
    -- WeaponSystem:select_station(pylonSelected - 1)
    local station = WeaponSystem:get_station_info(pylonSelected - 1)
    if (station.count == 0) then
        weapon_select_display:set("PYLON"..pylonSelected)
        weapon_status_display:set("NO")
        weapon_mode_display:set("NO")
    else
        local weapon_name = ""
        if (station.CLSID == "{6CEB49FC-DED8-4DED-B053-E1F033FF72D3}") then
            weapon_name = "AIM-9M"
        elseif (station.CLSID == "{5CE2FF2A-645A-4197-B48D-8720AC69394F}") then
            weapon_name = "AIM-9X"
        elseif (station.CLSID == "{40EF17B7-F508-45de-8566-6FFECC0C1AB8}") then
            weapon_name = "AIM-120C"
            IS_FOX3 = 1
        end
        weapon_select_display:set("PYLON"..pylonSelected)
        weapon_status_display:set("STBY")
        weapon_mode_display:set(weapon_name)
        WeaponSystem:select_station(pylonSelected - 1)
    end
end

function SetCommand(command,value)
    if (command == Keys.WeaponSelectNext) then
        if (pylonSelected == -1) then
            pylonSelected = 1
            main_bay_target = 1
            getPylonInfo()
        elseif (pylonSelected == 7) then
            pylonSelected = -1
            main_bay_target = 0
            weapon_select_display:set("NO")
            weapon_status_display:set("NO")
            weapon_mode_display:set("NO")
        else
            pylonSelected = pylonSelected + 1
            getPylonInfo()
        end
    elseif (command == iCommandPlanePickleOn) then
        if (IS_FOX3 == 1) then
            local radar_mode = get_param_handle("RADAR_MODE")
            -- print_message_to_user(radar_mode:get())
            if (radar_mode:get() == 3) then
                WeaponSystem:launch_station(pylonSelected - 1)
                getPylonInfo()
            end
        else
			WeaponSystem:launch_station(0)
            WeaponSystem:launch_station(1)
        end
    end
end

function update()
    -- 开关舱门
    if (main_bay_status < main_bay_target and main_bay_target == 1) then
		set_aircraft_draw_argument_value(25, main_bay_status)
		--set_aircraft_draw_argument_value(26, get_aircraft_draw_argument_value(26) + 0.06)
        main_bay_status = main_bay_status + 0.05
        weapon_bay_display:set("OPENING")
	elseif (main_bay_status > main_bay_target and main_bay_target == 0) then
		set_aircraft_draw_argument_value(25, main_bay_status)
        --set_aircraft_draw_argument_value(26, get_aircraft_draw_argument_value(26) - 0.06)
        weapon_bay_display:set("CLOSEING")
        main_bay_status = main_bay_status - 0.05
    elseif (main_bay_target == 1) then
        set_aircraft_draw_argument_value(25, 1)
        weapon_bay_display:set("OPEN")
    elseif (main_bay_target == 0) then
        set_aircraft_draw_argument_value(25, 0)
        weapon_bay_display:set("CLOSE")
    end
    
    -- 刷新IR导弹状态
    if (ir_missile_lock_param:get() == 1) then
        weapon_status_display:set("LOCK")
    elseif (ir_missile_lock_param:get() == 0) then
        weapon_status_display:set("STBY")
    end
end

need_to_be_closed = false