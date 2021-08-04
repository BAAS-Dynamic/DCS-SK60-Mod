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

WeaponSystem:listen_command(Keys.WingPylonSmokeOn)
WeaponSystem:listen_command(Keys.NozzleSmokeOn)

local pod_smoke_light = get_param_handle("POD_SMOKE")
local nozzle_smoke_light = get_param_handle("NOZZLE_SMOKE")

function post_initialize()

end

local smokepodstatus = 0
local nozzlesmokestatus = 0

-- 0,1,2,3 position
local loading_list = {0,0,0,0}

function check_load_status()
    for i = 1,4,1 do
        local station = WeaponSystem:get_station_info(i-1)
        if (string.sub(station.CLSID,1,36) == "{3d7bfa20-fefe-4642-ba1f-380d5ae4f9c") then
            loading_list[i] = 1
        elseif (string.sub(station.CLSID,1,36) == "{3d7bfa20-fefe-4642-ba1f-380d5ae4f9d") then
            loading_list[i] = 1
        else
            loading_list[i] = 0
        end
    end
end

function SetCommand(command,value)
    if (command == Keys.WingPylonSmokeOn) then
        if (loading_list[1] == 1 or loading_list[2] == 1) then
            WeaponSystem:launch_station(0)
            WeaponSystem:launch_station(1)
            smokepodstatus = 1 - smokepodstatus
            if smokepodstatus == 1 then
                print_message_to_user("Smoke pod is ON")
            else
                print_message_to_user("Smoke pod is OFF")
            end
        else
            print_message_to_user("No Smoke Pod on Pylon")
            smokepodstatus = 0
        end
    elseif (command == Keys.NozzleSmokeOn) then
        if (loading_list[3] == 1 or loading_list[4] == 1) then
            WeaponSystem:launch_station(2)
            WeaponSystem:launch_station(3)
            nozzlesmokestatus = 1 - nozzlesmokestatus
            if nozzlesmokestatus == 1 then
                print_message_to_user("Nozzle smoke is ON")
            else
                print_message_to_user("Nozzle smoke is OFF")
            end
        else
            nozzlesmokestatus = 0
            print_message_to_user("Nozzle Smoke Not Loaded")
        end
    end
end

function update()
    check_load_status()
    pod_smoke_light:set(smokepodstatus)
    nozzle_smoke_light:set(nozzlesmokestatus)
end

need_to_be_closed = false