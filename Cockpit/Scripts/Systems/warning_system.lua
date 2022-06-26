--初始化加载要用lua文件
dofile(LockOn_Options.common_script_path.."devices_defs.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")
dofile(LockOn_Options.script_path.."debug_util.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")

--设置循环次数
local update_rate = 0.02 -- 20次每秒
make_default_activity(update_rate)

local ic_ctrl = GetSelf()

--初始化DCS读取API
local sensor_data = get_base_data()

------Here Strat the general Switch Control

local SWITCH_OFF = 0
local SWITCH_ON = 1
local SWITCH_TEST = -1

switch_count = 0
function _switch_counter()
    switch_count = switch_count + 1
    return switch_count
end

local strobe_light_switch = _switch_counter()

target_status = {
    {strobe_light_switch , SWITCH_OFF, get_param_handle("PTN_124"), "PTN_124"},
}

current_status = {
    {strobe_light_switch , SWITCH_OFF, SWITCH_OFF},
}

local element_name = {"FIRE_L_ENG", "CANOPY", "FIRE_R_ENG", "FUEL_L_ENG", "THRUST_REV", "FUEL_R_ENG", "OIL_L_ENG", "BRAKE", "OIL_R_ENG", "HYDRO_L", "CONVERT_A", "HYDRO_R", "GEN_L", "CONVERT_B", "GEN_R"}

function post_initialize()
    local birth = LockOn_Options.init_conditions.birth_place
    if birth == "GROUND_HOT" then

    elseif birth == "GROUND_COLD" then

    elseif birth == "AIR_HOT" then
        
    end
end

ic_ctrl:listen_command()

function SetCommand(command, value)

end

function update_switch_status()
    local switch_moving_step = 0.25
    for k,v in pairs(target_status) do
        if math.abs(target_status[k][2] - current_status[k][2]) < switch_moving_step then
            current_status[k][2] = target_status[k][2]
        elseif target_status[k][2] > current_status[k][2] then
            current_status[k][2] = current_status[k][2] + switch_moving_step
        elseif target_status[k][2] < current_status[k][2] then
            current_status[k][2] = current_status[k][2] - switch_moving_step
        end
        target_status[k][3]:set(current_status[k][2])
        local temp_switch_ref = get_clickable_element_reference(target_status[k][4])
        temp_switch_ref:update()
        -- print_message_to_user(k)
    end
end

warning_display = get_param_handle("WARNING_DIS_ENABLE")


warn_tick = 0

function update()
    if get_elec_dc_status() then
        warning_display:set(1)
    end
end

need_to_be_closed = false