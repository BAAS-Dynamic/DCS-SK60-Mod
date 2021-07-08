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

function post_initialize()

end

local smokepodstatus = 0
local nozzlesmokestatus = 0

function SetCommand(command,value)
    if (command == Keys.WingPylonSmokeOn) then
        WeaponSystem:launch_station(0)
        WeaponSystem:launch_station(1)
        smokepodstatus = 1 - smokepodstatus
        if smokepodstatus == 1 then
            print_message_to_user("Smoke pod is ON")
        else
            print_message_to_user("Smoke pod is OFF")
        end
    elseif (command == Keys.NozzleSmokeOn) then
        WeaponSystem:launch_station(2)
        WeaponSystem:launch_station(3)
        nozzlesmokestatus = 1 - nozzlesmokestatus
        if nozzlesmokestatus == 1 then
            print_message_to_user("Nozzle smoke is ON")
        else
            print_message_to_user("Nozzle smoke is OFF")
        end
    end
end

function update()

end

need_to_be_closed = false