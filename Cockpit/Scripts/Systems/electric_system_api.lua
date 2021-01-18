--电力状态api,返回全部为布尔型
--初步仅设置两条电力总线:交流115v总线和直流28v总线

function get_elec_primary_ac_ok()
    return elec_primary_ac_ok:get()==1 and true or false
end

function get_elec_primary_dc_ok()
    return elec_primary_dc_ok:get()==1 and true or false
end

elec_primary_ac_ok = get_param_handle("ELEC_PRIMARY_AC_OK") -- 1 or 0
elec_primary_dc_ok = get_param_handle("ELEC_PRIMARY_DC_OK") -- 1 or 0