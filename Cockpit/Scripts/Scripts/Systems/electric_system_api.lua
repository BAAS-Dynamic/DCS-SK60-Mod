--api,
--:115v28v

elec_ac_status = get_param_handle("ELEC_AC_BUS") -- 1 or 0
elec_dc_status = get_param_handle("ELEC_DC_BUS") -- 1 or 0
elec_charging_status = get_param_handle("ELEC_DC_CHARGE") -- 1 or 0
elec_battery_status = get_param_handle("ELEC_DC_BATT") -- 1 or 0
elec_invA_switch = get_param_handle("PTN_402")
elec_invB_switch = get_param_handle("PTN_404")
hydro_l_status = get_param_handle("HYDRO_L")
hydro_r_status = get_param_handle("HYDRO_R")

function get_elec_ac_status()
    if elec_ac_status:get() == 1 then
        return true
    else
        return false
    end
end

function get_elec_dc_status()
    if elec_dc_status:get() == 1 then
        return true
    else
        return false
    end
end

function get_elec_inverterA_status()
    if elec_ac_status:get() == 1 and elec_invA_switch:get() > 0.5 then
        return true
    else
        return false
    end
end

function get_elec_inverterB_status()
    if elec_ac_status:get() == 1 and elec_invB_switch:get() > 0.5 then
        return true
    else
        return false
    end
end

function get_hydro_system_status()
    if elec_dc_status:get() == 1 and (hydro_l_status:get() < 0.1 or hydro_r_status:get() < 0.1) then
        return true
    else
        return false
    end
end