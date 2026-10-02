local nav_system = GetSelf()
dofile(LockOn_Options.script_path .. "command_defs.lua")

local update_time_step = 0.02
make_default_activity(update_time_step)
local RAD_TO_DEGREE  = 57.29577951308233
local DEG_TO_RADIAN  = 0.0174532925199433

dofile(LockOn_Options.script_path .. "NavDataPlugin/Nav.lua")

local sensor_data = get_base_data()
local rnav_power_knob_arg = 735
local rnav_edit_segment_card_arg = 736
local dme_power_knob_arg = 718
local rmi_needle_arg = 345
local adf_needle_arg = 346
local hsi_course_needle_arg = 752
local hsi_heading_bug_arg = 753
local hsi_cdi_arg = 742
local hsi_tacan_handle = get_param_handle("HSI_TACAN")
local hsi_adf_handle = get_param_handle("HSI_ADF")
local hsi_course_needle_handle = get_param_handle("HSI_COURSE_NEEDLE")
local hsi_heading_bug_handle = get_param_handle("HSI_HEADING_BUG")
local hsi_cdi_handle = get_param_handle("HSI_CDI")
local hsi_to_from_handle = get_param_handle("HSI_CRS_TOF")
local hsi_course_roll = get_param_handle("COURSE_ROLL")
local hsi_course_heading = get_param_handle("EHSI_COURSE")
local rnav_display_enable = get_param_handle("RNAV_DISPLAY_ENABLE")
local rnav_display_frq = get_param_handle("RNAV_DISPLAY_FRQ")
local rnav_display_rad = get_param_handle("RNAV_DISPLAY_RAD")
local rnav_display_dst = get_param_handle("RNAV_DISPLAY_DST")
local rnav_display_wpt = get_param_handle("RNAV_DISPLAY_WPT")
local rnav_wpt_active = get_param_handle("RNAV_WPT_ACTIVE")
local rnav_wpt_pending = get_param_handle("RNAV_WPT_PENDING")
local rnav_edit_segment_card = get_param_handle("RNAV_EDIT_SEGMENT_CARD")
local rnav_power_knob_anim = get_param_handle("PTN_735")
local rnav_sel_blink = get_param_handle("RNAV_SEL_BLINK")
local rnav_ils_mode = get_param_handle("RNAV_ILS_MODE")
local ils_bars_visible = get_param_handle("ILS_BARS_VISIBLE")
local ils_loc_dev = get_param_handle("ILS_LOC_DEV")
local ils_gs_dev = get_param_handle("ILS_GS_DEV")
local eadi_ils_overlay_enable = get_param_handle("EADI_ILS_OVERLAY_ENABLE")
local eadi_ils_dots_enable = get_param_handle("EADI_ILS_DOTS_ENABLE")
local eadi_ils_overlay_mode = 0 -- 0=all off, 1=bars+dots, 2=bars only
local rnav_display_power = 0
local adf_display_enable = get_param_handle("ADF_DISPLAY_ENABLE")
local adf_display_freq = get_param_handle("ADF_DISPLAY_FREQ")
local adf_display_power = 0
local dme_display_enable = get_param_handle("DME_DISPLAY_ENABLE")
local dme_display_dist = get_param_handle("DME_DISPLAY_DIST")
local dme_display_gs = get_param_handle("DME_DISPLAY_GS")
local dme_display_time = get_param_handle("DME_DISPLAY_TIME")
local dme_data_valid = get_param_handle("DME_DATA_VALID")
local dme_power_knob_anim = get_param_handle("PTN_718")
local nav_main_power_switch = get_param_handle("PTN_401")
local nav_bus_power_switch = get_param_handle("PTN_417")
local dme_display_power = 0
local selected_vor_course_deg = 0
local selected_heading_bug_deg = 0
local selected_offset_radial_deg = 0
local selected_offset_distance_nm = 0
local rnav_check_pressed = false
local EDIT_SEGMENT_FRQ = 1
local EDIT_SEGMENT_RAD = 2
local EDIT_SEGMENT_DST = 3
local active_rnav_edit_segment = EDIT_SEGMENT_FRQ
local current_waypoint_index = 1
local active_waypoint = {
    index = 1,
    vor_frequency_mhz = 113.00,
    offset_radial_deg = 0,
    offset_distance_nm = 0,
}
local waypoint_slot_count = 10
local waypoint_slots = {}

-- Initial VOR station tuning (MHz). We will replace this with cockpit controls later.
local tuned_vor_frequency_mhz = 113.00
local vor_min_frequency_mhz = 108.00
local vor_max_frequency_mhz = 117.95
local vor_small_step_mhz = 0.05
local vor_large_step_mhz = 1.00
local tuned_ndb_frequency_khz = 350
local ndb_min_frequency_khz = 200
local ndb_max_frequency_khz = 1799
local ndb_small_step_khz = 1
local ndb_large_step_khz = 100
local ndb_large_min_khz = 200
local ndb_large_max_khz = 1700

local last_message_time = 0
local message_interval_seconds = 2.0
local ils_message_interval_seconds = 0.5
local last_ils_message_time = -10
local current_rmi_value = 0
local target_rmi_value = 0
local current_adf_value = 0
local target_adf_value = 0
local rmi_slew_rate_arg_per_second = 1.2
local current_ils_loc_value = 0
local target_ils_loc_value = 0
local current_ils_gs_value = 0
local target_ils_gs_value = 0
local ils_bar_slew_per_second = 0.7
local VOR_DME_MAX_RANGE_NM = 200
local HSI_TO_FROM_FROM = -1
local HSI_TO_FROM_OFF = 0
local HSI_TO_FROM_TO = 1
local ILS_LOCALIZER_MAX_RANGE_NM = 18
local nav_debug_popup_enabled = false
local ils_debug_text_enabled = false
local last_announced_ils_frequency_hz = nil
local last_magnetic_variation_deg = 0

-- Persist NAV unit programming in a global SK60 namespace for cockpit/device reloads,
-- and mirror it to Fligtplan.lua for full DCS session persistence.
local sk60_global_state = rawget(_G, "SK60")
if type(sk60_global_state) ~= "table" then
    sk60_global_state = {}
    rawset(_G, "SK60", sk60_global_state)
end

sk60_global_state.nav_unit_persistence = sk60_global_state.nav_unit_persistence or {}
local nav_unit_persistence = sk60_global_state.nav_unit_persistence
local nav_data_memory_path = LockOn_Options.script_path .. "Systems/Fligtplan.lua"
local persist_nav_unit_state = function() end
local copy_waypoint_slot

local function load_nav_unit_state_from_file()
    if type(loadfile) ~= "function" then
        return false
    end

    local chunk = loadfile(nav_data_memory_path)
    if type(chunk) ~= "function" then
        return false
    end

    local ok, data = pcall(chunk)
    if not ok or type(data) ~= "table" then
        return false
    end

    local state = type(data.state) == "table" and data.state or {}
    if type(data.waypoints) == "table" then
        state.waypoint_slots = data.waypoints
    end

    if type(state) ~= "table" then
        return false
    end

    nav_unit_persistence.state = state
    return true
end

local function serialize_lua_value(value, indent)
    indent = indent or ""

    if type(value) == "number" then
        return string.format("%.17g", value)
    elseif type(value) == "boolean" then
        return value and "true" or "false"
    elseif type(value) == "string" then
        return string.format("%q", value)
    elseif type(value) ~= "table" then
        return "nil"
    end

    local next_indent = indent .. "    "
    local keys = {}
    for key in pairs(value) do
        keys[#keys + 1] = key
    end

    table.sort(keys, function(a, b)
        if type(a) == type(b) then
            return a < b
        end
        return type(a) < type(b)
    end)

    local lines = {"{"}
    for _, key in ipairs(keys) do
        local serialized_key
        if type(key) == "number" then
            serialized_key = string.format("[%s]", string.format("%.17g", key))
        else
            serialized_key = string.format("[%q]", tostring(key))
        end

        lines[#lines + 1] = next_indent .. serialized_key .. " = " .. serialize_lua_value(value[key], next_indent) .. ","
    end
    lines[#lines + 1] = indent .. "}"

    return table.concat(lines, "\n")
end

local function write_nav_unit_state_to_file(state)
    if type(io) ~= "table" or type(io.open) ~= "function" then
        return false
    end

    local file = io.open(nav_data_memory_path, "w")
    if file == nil then
        return false
    end

    file:write("-- SK60 RNAV flight plan. Generated by nav_system.lua.\n")
    file:write("-- Edit the waypoints table before a mission to pre-program/shared routes.\n")
    file:write("-- Columns: FRQ = VOR frequency (MHz), RAD = radial (degrees), DST = distance (NM).\n\n")
    file:write("local waypoints = {\n")
    file:write("    -- WPT   FRQ      RAD    DST\n")
    for i = 1, waypoint_slot_count do
        local slot = copy_waypoint_slot(type(state.waypoint_slots) == "table" and state.waypoint_slots[i] or nil)
        file:write(string.format("    [%2d] = { FRQ = %6.2f, RAD = %3.0f, DST = %5.1f },\n",
            i, slot.vor_frequency_mhz, slot.offset_radial_deg, slot.offset_distance_nm))
    end
    file:write("}\n\n")

    local persisted_state = {}
    for key, value in pairs(state) do
        if key ~= "waypoint_slots" then
            persisted_state[key] = value
        end
    end

    file:write("return {\n")
    file:write("    waypoints = waypoints,\n")
    file:write("    state = ")
    file:write(serialize_lua_value(persisted_state, "    "))
    file:write(",\n")
    file:write("}\n")
    file:close()

    return true
end

local function nav_debug_popup(message)
    if nav_debug_popup_enabled then
        print_message_to_user(message)
    end
end

local function set_rnav_display_power(is_on)
    rnav_display_power = is_on and 1 or 0
    rnav_display_enable:set(rnav_display_power)
    rnav_power_knob_anim:set(rnav_display_power)
    set_aircraft_draw_argument_value(rnav_power_knob_arg, rnav_display_power)
    if type(set_cockpit_draw_argument_value) == "function" then
        set_cockpit_draw_argument_value(rnav_power_knob_arg, rnav_display_power)
    end
end

local function set_adf_display_power(is_on)
    adf_display_power = is_on and 1 or 0
    adf_display_enable:set(adf_display_power)
end

local function set_dme_display_power(is_on)
    dme_display_power = is_on and 1 or 0
    dme_display_enable:set(dme_display_power)
    dme_power_knob_anim:set(dme_display_power)
    set_aircraft_draw_argument_value(dme_power_knob_arg, dme_display_power)
    if type(set_cockpit_draw_argument_value) == "function" then
        set_cockpit_draw_argument_value(dme_power_knob_arg, dme_display_power)
    end
end

local function is_nav_units_power_available()
    return nav_main_power_switch:get() > 0.5 and nav_bus_power_switch:get() > 0.5
end

local function enforce_nav_units_power_dependency()
    if is_nav_units_power_available() then
        return
    end

    if rnav_display_power ~= 0 then
        set_rnav_display_power(false)
    end
    if adf_display_power ~= 0 then
        set_adf_display_power(false)
    end
    if dme_display_power ~= 0 then
        set_dme_display_power(false)
    end
end

local function normalize_bearing(bearing_deg)
    local bearing = bearing_deg % 360
    if bearing < 0 then
        bearing = bearing + 360
    end
    return bearing
end

local function shortest_angle_delta(from_deg, to_deg)
    local delta = (to_deg - from_deg + 180) % 360 - 180
    return delta
end

local function get_magnetic_variation_deg()
    -- getHeading() is not guaranteed to be true heading. Prefer DCS's explicit
    -- true-heading accessor when it is exposed by the current cockpit API; using
    -- getHeading() here can make true and magnetic resolve to the same value and
    -- leave an entered magnetic RAD uncorrected.
    local true_heading_accessor = sensor_data.getTrueHeading or sensor_data.getHeading
    local true_heading_rad = true_heading_accessor()
    local magnetic_heading_rad = sensor_data.getMagneticHeading()
    if type(true_heading_rad) ~= "number" or type(magnetic_heading_rad) ~= "number" then
        return last_magnetic_variation_deg
    end

    local function norm180(angle_deg)
        return (angle_deg + 180) % 360 - 180
    end

    -- In DCS avionics device scripts, getHeading() is commonly mirrored relative
    -- to cockpit compass convention. Convert it before comparing to magnetic.
    local true_heading_deg = normalize_bearing((360.0 - (true_heading_rad * RAD_TO_DEGREE)))
    local magnetic_heading_deg = normalize_bearing(magnetic_heading_rad * RAD_TO_DEGREE)

    -- Variation is (true - magnetic), signed in [-180, 180).
    local variation_deg = norm180(true_heading_deg - magnetic_heading_deg)
    last_magnetic_variation_deg = variation_deg
    return variation_deg
end

local function true_to_magnetic(true_bearing_deg)
    local variation_deg = get_magnetic_variation_deg()
    return normalize_bearing(true_bearing_deg - variation_deg)
end

local function magnetic_to_true(magnetic_bearing_deg)
    local variation_deg = get_magnetic_variation_deg()
    return normalize_bearing(magnetic_bearing_deg + variation_deg)
end

local function get_aircraft_grid_heading_deg()
    if type(sensor_data.getHeading) ~= "function" then
        return nil
    end

    local heading_rad = sensor_data.getHeading()
    if type(heading_rad) ~= "number" then
        return nil
    end

    -- DCS world/grid headings use the opposite sign convention from compass
    -- bearings. Convert to the same clockwise 0-360 frame used by local X/Z
    -- bearings before comparing it with the cockpit magnetic heading.
    return normalize_bearing(360.0 - (heading_rad * RAD_TO_DEGREE))
end

local function get_aircraft_magnetic_heading_deg()
    if type(sensor_data.getMagneticHeading) ~= "function" then
        return nil
    end

    local magnetic_heading_rad = sensor_data.getMagneticHeading()
    if type(magnetic_heading_rad) ~= "number" then
        return nil
    end

    return normalize_bearing(magnetic_heading_rad * RAD_TO_DEGREE)
end

local function grid_to_magnetic(grid_bearing_deg)
    local grid_heading_deg = get_aircraft_grid_heading_deg()
    local magnetic_heading_deg = get_aircraft_magnetic_heading_deg()
    if grid_heading_deg == nil or magnetic_heading_deg == nil then
        return true_to_magnetic(grid_bearing_deg)
    end

    local magnetic_grid_correction_deg = shortest_angle_delta(grid_heading_deg, magnetic_heading_deg)
    return normalize_bearing(grid_bearing_deg + magnetic_grid_correction_deg)
end

local function magnetic_to_grid(magnetic_bearing_deg)
    local grid_heading_deg = get_aircraft_grid_heading_deg()
    local magnetic_heading_deg = get_aircraft_magnetic_heading_deg()
    if grid_heading_deg == nil or magnetic_heading_deg == nil then
        return magnetic_to_true(magnetic_bearing_deg)
    end

    local magnetic_grid_correction_deg = shortest_angle_delta(grid_heading_deg, magnetic_heading_deg)
    return normalize_bearing(magnetic_bearing_deg - magnetic_grid_correction_deg)
end

local function clamp(value, min_value, max_value)
    return math.max(min_value, math.min(max_value, value))
end

local function normalize_vor_frequency(freq_mhz)
    local snapped = math.floor((freq_mhz / vor_small_step_mhz) + 0.5) * vor_small_step_mhz

    while snapped > vor_max_frequency_mhz do
        snapped = snapped - (vor_max_frequency_mhz - vor_min_frequency_mhz + vor_small_step_mhz)
    end

    while snapped < vor_min_frequency_mhz do
        snapped = snapped + (vor_max_frequency_mhz - vor_min_frequency_mhz + vor_small_step_mhz)
    end

    return snapped
end

local function normalize_radial(radial_deg)
    return normalize_bearing(radial_deg)
end

local function set_offset_radial(radial_deg)
    selected_offset_radial_deg = normalize_radial(radial_deg)
end

local function set_offset_distance(distance_nm)
    selected_offset_distance_nm = clamp(distance_nm, 0, 999.9)
end

local function create_default_waypoint_slot()
    return {
        vor_frequency_mhz = 113.00,
        offset_radial_deg = 0,
        offset_distance_nm = 0,
    }
end

local function wrap_waypoint_index(waypoint_index)
    return ((waypoint_index - 1) % waypoint_slot_count) + 1
end

local function waypoint_slot_to_array_index(waypoint_index)
    return wrap_waypoint_index(waypoint_index)
end

local function save_current_waypoint_slot()
    local slot = waypoint_slots[waypoint_slot_to_array_index(current_waypoint_index)]
    if slot == nil then
        return
    end

    slot.vor_frequency_mhz = tuned_vor_frequency_mhz
    slot.offset_radial_deg = selected_offset_radial_deg
    slot.offset_distance_nm = selected_offset_distance_nm
end

local function load_waypoint_slot(waypoint_index)
    local slot = waypoint_slots[waypoint_slot_to_array_index(waypoint_index)]
    if slot == nil then
        return
    end

    current_waypoint_index = wrap_waypoint_index(waypoint_index)
    tuned_vor_frequency_mhz = normalize_vor_frequency(slot.vor_frequency_mhz or tuned_vor_frequency_mhz)
    set_offset_radial(slot.offset_radial_deg or selected_offset_radial_deg)
    set_offset_distance(slot.offset_distance_nm or selected_offset_distance_nm)
end

local function activate_current_waypoint_slot(show_message)
    save_current_waypoint_slot()
    active_waypoint.index = current_waypoint_index
    active_waypoint.vor_frequency_mhz = tuned_vor_frequency_mhz
    active_waypoint.offset_radial_deg = selected_offset_radial_deg
    active_waypoint.offset_distance_nm = selected_offset_distance_nm
    if show_message then
        nav_debug_popup(string.format("RNAV waypoint %d active", active_waypoint.index))
    end
end

local function cycle_waypoint_slot(delta_slots)
    if delta_slots == 0 then
        return
    end

    save_current_waypoint_slot()
    load_waypoint_slot(current_waypoint_index + delta_slots)
    nav_debug_popup(string.format("RNAV waypoint %d shown - press USE to activate", current_waypoint_index))
end

local function return_to_active_waypoint(show_message)
    save_current_waypoint_slot()

    current_waypoint_index = wrap_waypoint_index(active_waypoint.index)
    tuned_vor_frequency_mhz = normalize_vor_frequency(active_waypoint.vor_frequency_mhz or tuned_vor_frequency_mhz)
    set_offset_radial(active_waypoint.offset_radial_deg or selected_offset_radial_deg)
    set_offset_distance(active_waypoint.offset_distance_nm or selected_offset_distance_nm)

    local slot = waypoint_slots[waypoint_slot_to_array_index(current_waypoint_index)]
    if slot ~= nil then
        slot.vor_frequency_mhz = tuned_vor_frequency_mhz
        slot.offset_radial_deg = selected_offset_radial_deg
        slot.offset_distance_nm = selected_offset_distance_nm
    end

    if show_message then
        nav_debug_popup(string.format("RNAV returned to active waypoint %d", current_waypoint_index))
    end
end

local function cycle_rnav_edit_segment()
    active_rnav_edit_segment = active_rnav_edit_segment + 1
    if active_rnav_edit_segment > EDIT_SEGMENT_DST then
        active_rnav_edit_segment = EDIT_SEGMENT_FRQ
    end
end

local function get_rnav_edit_segment_card_value()
    if active_rnav_edit_segment == EDIT_SEGMENT_FRQ then
        return 0
    elseif active_rnav_edit_segment == EDIT_SEGMENT_RAD then
        return 0.5
    end

    -- The 3D model's third card position is labelled NAV; it corresponds to the DST edit segment.
    return 1
end

local function set_rnav_edit_segment_card()
    local card_value = get_rnav_edit_segment_card_value()
    rnav_edit_segment_card:set(card_value)
    set_aircraft_draw_argument_value(rnav_edit_segment_card_arg, card_value)
    if type(set_cockpit_draw_argument_value) == "function" then
        set_cockpit_draw_argument_value(rnav_edit_segment_card_arg, card_value)
    end
end

local function update_rnav_selection_indicator()
    set_rnav_edit_segment_card()

    local now = get_absolute_model_time()
    local blink_on = (math.floor(now * 2) % 2) == 0
    rnav_sel_blink:set(blink_on and 1 or 0)

    local waypoint_matches_active = current_waypoint_index == active_waypoint.index
    rnav_wpt_active:set(waypoint_matches_active and 1 or 0)
    rnav_wpt_pending:set(waypoint_matches_active and 0 or 1)
end

local function tune_vor_frequency(delta_mhz)
    local new_frequency = normalize_vor_frequency(tuned_vor_frequency_mhz + delta_mhz)
    if math.abs(new_frequency - tuned_vor_frequency_mhz) > 0.0001 then
        tuned_vor_frequency_mhz = new_frequency
        nav_debug_popup(string.format("VOR Tune: %.2f MHz", tuned_vor_frequency_mhz))
    end
end

local function tune_ndb_frequency_small(delta_khz)
    local large = math.floor(tuned_ndb_frequency_khz / 100) * 100
    local small = tuned_ndb_frequency_khz % 100
    local new_small = (small + delta_khz) % 100
    if new_small < 0 then
        new_small = new_small + 100
    end

    local new_frequency = large + new_small
    if math.abs(new_frequency - tuned_ndb_frequency_khz) > 0.0001 then
        tuned_ndb_frequency_khz = new_frequency
        nav_debug_popup(string.format("ADF Tune: %04.0f kHz", tuned_ndb_frequency_khz))
    end
end

local function tune_ndb_frequency_large(delta_khz)
    local large = math.floor(tuned_ndb_frequency_khz / 100) * 100
    local small = tuned_ndb_frequency_khz % 100
    local steps = math.floor(delta_khz / ndb_large_step_khz)
    if steps == 0 then
        return
    end

    local range_steps = math.floor((ndb_large_max_khz - ndb_large_min_khz) / ndb_large_step_khz) + 1
    local large_index = math.floor((large - ndb_large_min_khz) / ndb_large_step_khz)
    large_index = (large_index + steps) % range_steps
    if large_index < 0 then
        large_index = large_index + range_steps
    end

    local new_large = ndb_large_min_khz + (large_index * ndb_large_step_khz)
    local new_frequency = new_large + small
    if new_frequency < ndb_min_frequency_khz then
        new_frequency = ndb_min_frequency_khz
    elseif new_frequency > ndb_max_frequency_khz then
        new_frequency = ndb_max_frequency_khz
    end

    if math.abs(new_frequency - tuned_ndb_frequency_khz) > 0.0001 then
        tuned_ndb_frequency_khz = new_frequency
        nav_debug_popup(string.format("ADF Tune: %04.0f kHz", tuned_ndb_frequency_khz))
    end
end

local function command_value_to_clicks(value)
    if value == nil or math.abs(value) < 0.0001 then
        return 0
    end

    local clicks = math.max(1, math.floor((math.abs(value) / 0.09) + 0.5))
    if value < 0 then
        clicks = -clicks
    end
    return clicks
end

local function course_knob_value_to_degrees(value)
    if value == nil or math.abs(value) < 0.0001 then
        return 0
    end

    -- PTN_750 reports very small relative deltas compared to the VOR frequency knobs.
    -- Use a dedicated conversion so every valid scroll input creates at least 1° change.
    local degrees = math.max(1, math.floor((math.abs(value) * 20) + 0.5))
    if value < 0 then
        degrees = -degrees
    end
    return degrees
end

local function heading_bug_knob_value_to_degrees(value)
    -- PTN_751 is a mouse-wheel driven relative knob. Treat each wheel detent as
    -- one click so the selected heading indicator advances exactly 1° per scroll
    -- in either direction.
    return command_value_to_clicks(value)
end

local function bearing_to_rmi_argument(bearing_deg)
    local normalized = normalize_bearing(bearing_deg)
    local signed = normalized
    if signed > 180 then
        signed = signed - 360
    end

    return signed / 180
end

local function set_rmi_needle(value)
    current_rmi_value = value
    hsi_tacan_handle:set(value)
    set_aircraft_draw_argument_value(rmi_needle_arg, value)

    if type(set_cockpit_draw_argument_value) == "function" then
        set_cockpit_draw_argument_value(rmi_needle_arg, value)
    end
end

local function set_adf_needle(value)
    current_adf_value = value
    hsi_adf_handle:set(value)
    set_aircraft_draw_argument_value(adf_needle_arg, value)

    if type(set_cockpit_draw_argument_value) == "function" then
        set_cockpit_draw_argument_value(adf_needle_arg, value)
    end
end

local function course_deg_to_hsi_argument(course_deg)
    local normalized = normalize_bearing(course_deg)
    if normalized > 180 then
        normalized = normalized - 360
    end
    return normalized / 180
end

local function set_course_needle(course_deg)
    local arg_value = course_deg_to_hsi_argument(course_deg)
    hsi_course_needle_handle:set(arg_value)
    set_aircraft_draw_argument_value(hsi_course_needle_arg, arg_value)

    if type(set_cockpit_draw_argument_value) == "function" then
        set_cockpit_draw_argument_value(hsi_course_needle_arg, arg_value)
    end
end

local function set_heading_bug(heading_deg)
    selected_heading_bug_deg = normalize_bearing(heading_deg)
    local arg_value = course_deg_to_hsi_argument(selected_heading_bug_deg)
    hsi_heading_bug_handle:set(arg_value)
    set_aircraft_draw_argument_value(hsi_heading_bug_arg, arg_value)

    if type(set_cockpit_draw_argument_value) == "function" then
        set_cockpit_draw_argument_value(hsi_heading_bug_arg, arg_value)
    end
end

local function set_hsi_cdi(value)
    local clamped = clamp(value, -1, 1)
    hsi_cdi_handle:set(clamped)
    set_aircraft_draw_argument_value(hsi_cdi_arg, clamped)

    if type(set_cockpit_draw_argument_value) == "function" then
        set_cockpit_draw_argument_value(hsi_cdi_arg, clamped)
    end
end

local function set_hsi_to_from(value)
    hsi_to_from_handle:set(value)
end

local function calculate_hsi_course_data(course_deg, bearing_to_target_deg)
    local deviation_deg = shortest_angle_delta(course_deg, bearing_to_target_deg)
    local absolute_deviation_deg = math.abs(deviation_deg)

    if absolute_deviation_deg < 90.0 then
        return deviation_deg, HSI_TO_FROM_TO
    elseif absolute_deviation_deg > 90.0 then
        -- A FROM course uses the reciprocal of the bearing to the target. Fold
        -- the deviation onto that reciprocal so a correctly selected outbound
        -- radial centers the CDI instead of commanding full-scale deflection.
        if deviation_deg > 0 then
            deviation_deg = deviation_deg - 180.0
        else
            deviation_deg = deviation_deg + 180.0
        end
        return deviation_deg, HSI_TO_FROM_FROM
    end

    -- At exactly 90 degrees neither TO nor FROM is geometrically defined.
    return deviation_deg, HSI_TO_FROM_OFF
end

local function set_selected_vor_course(course_deg)
    selected_vor_course_deg = normalize_bearing(course_deg)
    hsi_course_roll:set(selected_vor_course_deg)
    hsi_course_heading:set(selected_vor_course_deg)
    set_course_needle(selected_vor_course_deg)
end

local function sanitize_number(value, fallback, min_value, max_value)
    if type(value) ~= "number" then
        return fallback
    end

    if min_value ~= nil and value < min_value then
        return min_value
    end

    if max_value ~= nil and value > max_value then
        return max_value
    end

    return value
end

local function sanitize_waypoint_index(value, fallback)
    return wrap_waypoint_index(math.floor(sanitize_number(value, fallback or 1, 1, waypoint_slot_count)))
end

local function sanitize_edit_segment(value)
    return math.floor(sanitize_number(value, EDIT_SEGMENT_FRQ, EDIT_SEGMENT_FRQ, EDIT_SEGMENT_DST))
end

copy_waypoint_slot = function(slot)
    slot = type(slot) == "table" and slot or {}
    return {
        vor_frequency_mhz = normalize_vor_frequency(sanitize_number(slot.vor_frequency_mhz or slot.FRQ, 113.00, vor_min_frequency_mhz, vor_max_frequency_mhz)),
        offset_radial_deg = normalize_radial(sanitize_number(slot.offset_radial_deg or slot.RAD, 0)),
        offset_distance_nm = clamp(sanitize_number(slot.offset_distance_nm or slot.DST, 0, 0, 999.9), 0, 999.9),
    }
end

local function copy_active_waypoint(waypoint)
    waypoint = type(waypoint) == "table" and waypoint or {}
    return {
        index = sanitize_waypoint_index(waypoint.index, 1),
        vor_frequency_mhz = normalize_vor_frequency(sanitize_number(waypoint.vor_frequency_mhz, 113.00, vor_min_frequency_mhz, vor_max_frequency_mhz)),
        offset_radial_deg = normalize_radial(sanitize_number(waypoint.offset_radial_deg, 0)),
        offset_distance_nm = clamp(sanitize_number(waypoint.offset_distance_nm, 0, 0, 999.9), 0, 999.9),
    }
end

local function initialize_default_nav_unit_state()
    current_waypoint_index = 1
    tuned_vor_frequency_mhz = 113.00
    set_offset_radial(0)
    set_offset_distance(0)

    waypoint_slots = {}
    for i = 1, waypoint_slot_count do
        waypoint_slots[i] = create_default_waypoint_slot()
    end

    active_waypoint.index = 1
    active_waypoint.vor_frequency_mhz = tuned_vor_frequency_mhz
    active_waypoint.offset_radial_deg = selected_offset_radial_deg
    active_waypoint.offset_distance_nm = selected_offset_distance_nm
    active_rnav_edit_segment = EDIT_SEGMENT_FRQ
    selected_vor_course_deg = 0
    selected_heading_bug_deg = 0
    tuned_ndb_frequency_khz = 350
end

persist_nav_unit_state = function()
    local current_slot = waypoint_slots[waypoint_slot_to_array_index(current_waypoint_index)]
    if current_slot ~= nil then
        current_slot.vor_frequency_mhz = tuned_vor_frequency_mhz
        current_slot.offset_radial_deg = selected_offset_radial_deg
        current_slot.offset_distance_nm = selected_offset_distance_nm
    end

    local persisted_slots = {}
    for i = 1, waypoint_slot_count do
        persisted_slots[i] = copy_waypoint_slot(waypoint_slots[i])
    end

    nav_unit_persistence.state = {
        version = 1,
        current_waypoint_index = sanitize_waypoint_index(current_waypoint_index, 1),
        active_waypoint = copy_active_waypoint(active_waypoint),
        waypoint_slots = persisted_slots,
        tuned_vor_frequency_mhz = normalize_vor_frequency(sanitize_number(tuned_vor_frequency_mhz, 113.00, vor_min_frequency_mhz, vor_max_frequency_mhz)),
        selected_offset_radial_deg = normalize_radial(sanitize_number(selected_offset_radial_deg, 0)),
        selected_offset_distance_nm = clamp(sanitize_number(selected_offset_distance_nm, 0, 0, 999.9), 0, 999.9),
        active_rnav_edit_segment = sanitize_edit_segment(active_rnav_edit_segment),
        selected_vor_course_deg = normalize_bearing(sanitize_number(selected_vor_course_deg, 0)),
        selected_heading_bug_deg = normalize_bearing(sanitize_number(selected_heading_bug_deg, 0)),
        tuned_ndb_frequency_khz = sanitize_number(tuned_ndb_frequency_khz, 350, ndb_min_frequency_khz, ndb_max_frequency_khz),
    }
    write_nav_unit_state_to_file(nav_unit_persistence.state)
end

local function restore_nav_unit_state()
    if type(nav_unit_persistence.state) ~= "table" then
        load_nav_unit_state_from_file()
    end

    local state = nav_unit_persistence.state
    if type(state) ~= "table" then
        initialize_default_nav_unit_state()
        persist_nav_unit_state()
        return false
    end

    waypoint_slots = {}
    for i = 1, waypoint_slot_count do
        waypoint_slots[i] = copy_waypoint_slot(type(state.waypoint_slots) == "table" and state.waypoint_slots[i] or nil)
    end

    active_waypoint = copy_active_waypoint(state.active_waypoint)
    current_waypoint_index = sanitize_waypoint_index(state.current_waypoint_index, active_waypoint.index)
    tuned_vor_frequency_mhz = normalize_vor_frequency(sanitize_number(state.tuned_vor_frequency_mhz, waypoint_slots[current_waypoint_index].vor_frequency_mhz, vor_min_frequency_mhz, vor_max_frequency_mhz))
    set_offset_radial(sanitize_number(state.selected_offset_radial_deg, waypoint_slots[current_waypoint_index].offset_radial_deg))
    set_offset_distance(sanitize_number(state.selected_offset_distance_nm, waypoint_slots[current_waypoint_index].offset_distance_nm, 0, 999.9))
    active_rnav_edit_segment = sanitize_edit_segment(state.active_rnav_edit_segment)
    selected_vor_course_deg = normalize_bearing(sanitize_number(state.selected_vor_course_deg, 0))
    selected_heading_bug_deg = normalize_bearing(sanitize_number(state.selected_heading_bug_deg, 0))
    tuned_ndb_frequency_khz = sanitize_number(state.tuned_ndb_frequency_khz, 350, ndb_min_frequency_khz, ndb_max_frequency_khz)

    persist_nav_unit_state()
    return true
end

local function normalize_rmi_value(value)
    local wrapped = value
    while wrapped > 1 do
        wrapped = wrapped - 2
    end
    while wrapped < -1 do
        wrapped = wrapped + 2
    end
    return wrapped
end

--[[local function update_rmi_slew()
    local delta = target_rmi_value - current_rmi_value
    if delta > 1 then
        delta = delta - 2
    elseif delta < -1 then
        delta = delta + 2
    end

    local max_step = rmi_slew_rate_arg_per_second * update_time_step
    if math.abs(delta) <= max_step then
        set_rmi_needle(normalize_rmi_value(target_rmi_value))
    else
        local step = max_step
        if delta < 0 then
            step = -max_step
        end
        set_rmi_needle(normalize_rmi_value(current_rmi_value + step))
    end
end]]--

local function update_rmi_slew()

    local current_deg = current_rmi_value * 180
    local target_deg  = target_rmi_value  * 180

    -- Shortest path
    local delta = target_deg - current_deg
    if delta > 180 then
        delta = delta - 360
    elseif delta < -180 then
        delta = delta + 360
    end

    local turn_rate = 60 -- deg/sec
    local max_step = turn_rate * update_time_step

    -- 🔴 KEY: clamp step so we NEVER overshoot
    local step = math.max(-max_step, math.min(max_step, delta))

    current_deg = current_deg + step

    -- 🔴 KEY: normalize angle AFTER movement, not via your normalize function
    if current_deg > 180 then
        current_deg = current_deg - 360
    elseif current_deg < -180 then
        current_deg = current_deg + 360
    end

    local new_value = current_deg / 180

    set_rmi_needle(new_value)
end

local function update_adf_slew()
    local current_deg = current_adf_value * 180
    local target_deg  = target_adf_value  * 180

    local delta = target_deg - current_deg
    if delta > 180 then
        delta = delta - 360
    elseif delta < -180 then
        delta = delta + 360
    end

    local turn_rate = 60
    local max_step = turn_rate * update_time_step
    local step = math.max(-max_step, math.min(max_step, delta))

    current_deg = current_deg + step

    if current_deg > 180 then
        current_deg = current_deg - 360
    elseif current_deg < -180 then
        current_deg = current_deg + 360
    end

    set_adf_needle(current_deg / 180)
end

local function get_beacon_position(beacon)
    if type(beacon) ~= "table" then
        return nil, nil
    end

    if type(beacon.position) == "table" then
        local bx = beacon.position.x or beacon.position[1]
        -- Horizontal plane in DCS world coordinates is X/Z.
        -- Do NOT fall back to .y here; .y is altitude and causes lateral/nav bearing bias.
        local bz = beacon.position.z or beacon.position[3]
        if bx ~= nil and bz ~= nil then
            return bx, bz
        end
    end

    if beacon.x ~= nil and beacon.z ~= nil then
        return beacon.x, beacon.z
    end

    return nil, nil
end

local function get_beacon_distance_nm(beacon)
    local own_x, _, own_z = sensor_data.getSelfCoordinates()
    if own_x == nil or own_z == nil then
        return nil
    end

    local bx, bz = get_beacon_position(beacon)
    if bx == nil or bz == nil then
        return nil
    end

    local dx = bx - own_x
    local dz = bz - own_z
    return math.sqrt((dx * dx) + (dz * dz)) * 0.0005399568
end

local function is_beacon_within_range(beacon, max_range_nm)
    local distance_nm = get_beacon_distance_nm(beacon)
    if distance_nm == nil then
        return false
    end
    return distance_nm <= max_range_nm
end

local function get_tuned_vor_beacon(frequency_mhz)
    local vor_beacons = Get_VOR_beacons()
    if type(vor_beacons) ~= "table" then
        return nil
    end

    local tuned_frequency_hz = math.floor(((frequency_mhz or tuned_vor_frequency_mhz) * 1000000) + 0.5)
    local beacon = vor_beacons[tuned_frequency_hz]
    if not is_beacon_within_range(beacon, VOR_DME_MAX_RANGE_NM) then
        return nil
    end
    return beacon
end

local function get_beacon_course_deg_for_selection(beacon)
    if type(beacon) ~= "table" then
        return nil
    end

    local direction = beacon.direction or beacon.course or beacon.runway_course
    if type(direction) ~= "number" and type(beacon.position) == "table" then
        direction = beacon.position.direction
    end

    if type(direction) ~= "number" then
        return nil
    end

    if math.abs(direction) <= (2 * math.pi + 0.01) then
        direction = direction * RAD_TO_DEGREE
    end

    return normalize_bearing(direction)
end

local function get_tuned_ils_beacon(frequency_mhz)
    local ils_beacons = Get_ILS_beacons()
    if type(ils_beacons) ~= "table" then
        return nil
    end

    local tuned_frequency_hz = math.floor(((frequency_mhz or tuned_vor_frequency_mhz) * 1000000) + 0.5)
    local entry = ils_beacons[tuned_frequency_hz]
    if type(entry) ~= "table" then
        return nil
    end

    if entry.__is_collection ~= true then
        if not is_beacon_within_range(entry, ILS_LOCALIZER_MAX_RANGE_NM) then
            return nil
        end
        return entry
    end

    local own_x, _, own_z = sensor_data.getSelfCoordinates()
    local best_localizer = nil
    local best_localizer_dist_nm = math.huge
    local best_any = nil
    local best_any_dist_nm = math.huge

    for i = 1, #entry do
        local beacon = entry[i]
        if type(beacon) == "table" then
            local bx, bz = get_beacon_position(beacon)
            local dist_nm = 9999
            if own_x ~= nil and own_z ~= nil and bx ~= nil and bz ~= nil then
                local dx = bx - own_x
                local dz = bz - own_z
                dist_nm = math.sqrt((dx * dx) + (dz * dz)) * 0.0005399568
            end

            if dist_nm < best_any_dist_nm then
                best_any = beacon
                best_any_dist_nm = dist_nm
            end

            if beacon.type == BEACON_TYPE_ILS_LOCALIZER then
                local score = dist_nm
                local track_true = nil
                local vel_x, _, vel_z = sensor_data.getSelfVelocity()
                if vel_x ~= nil and vel_z ~= nil then
                    local gs_mps = math.sqrt((vel_x * vel_x) + (vel_z * vel_z))
                    if gs_mps > 5.0 then
                        track_true = normalize_bearing(math.deg(math.atan2(vel_x, vel_z)))
                    end
                end

                local beacon_course = get_beacon_course_deg_for_selection(beacon)
                if track_true ~= nil and beacon_course ~= nil then
                    local direct_err = math.abs(shortest_angle_delta(track_true, beacon_course))
                    local recip_err = math.abs(shortest_angle_delta(track_true, normalize_bearing(beacon_course + 180)))
                    local course_err = math.min(direct_err, recip_err)
                    score = score + (0.10 * course_err)
                end

                if score < best_localizer_dist_nm then
                    best_localizer = beacon
                    best_localizer_dist_nm = score
                end
            end
        end
    end

    local chosen = best_localizer or best_any
    if not is_beacon_within_range(chosen, ILS_LOCALIZER_MAX_RANGE_NM) then
        return nil
    end
    return chosen
end

local function is_ils_frequency_selected(freq_mhz)
    local freq_khz = math.floor((freq_mhz * 1000) + 0.5)
    if freq_khz < 108100 or freq_khz > 111950 then
        return false
    end

    -- ILS channels live on odd tenth blocks (e.g. 108.10/108.15, 108.30/108.35, ...).
    local tenth_digit = math.floor(freq_khz / 100) % 10
    return (tenth_digit % 2) == 1
end

local function get_beacon_display_name(beacon)
    if type(beacon) ~= "table" then
        return "UNKNOWN ILS"
    end

    if type(beacon.display_name) == "string" and beacon.display_name ~= "" then
        return beacon.display_name
    end

    if type(beacon.name) == "string" and beacon.name ~= "" then
        return beacon.name
    end

    if type(beacon.callsign) == "string" and beacon.callsign ~= "" then
        return beacon.callsign
    end

    return "UNKNOWN ILS"
end

local function get_ils_course_deg(beacon)
    if type(beacon) ~= "table" then
        return nil
    end

    local direction = beacon.direction or beacon.course or beacon.runway_course
    if type(direction) == "number" then
        -- Some beacon tables provide course in radians, others in degrees.
        if math.abs(direction) <= (2 * math.pi + 0.01) then
            direction = direction * RAD_TO_DEGREE
        end
        return normalize_bearing(direction)
    end

    if type(beacon.position) == "table" and type(beacon.position.direction) == "number" then
        local direction = beacon.position.direction
        if math.abs(direction) <= (2 * math.pi + 0.01) then
            direction = direction * RAD_TO_DEGREE
        end
        return normalize_bearing(direction)
    end

    return nil
end

local function get_beacon_altitude_m(beacon)
    if type(beacon) ~= "table" then
        return 0
    end

    if type(beacon.position) == "table" then
        local by = beacon.position.y or beacon.position.alt or beacon.position[2]
        if type(by) == "number" then
            return by
        end
    end

    if type(beacon.y) == "number" then
        return beacon.y
    end

    return 0
end

local function get_ils_inbound_course_magnetic(beacon)
    local ils_course_magnetic = get_ils_course_deg(beacon)
    if ils_course_magnetic == nil then
        return nil
    end

    -- DCS ILS/localizer course data is magnetic. Keep localizer deviation
    -- calculations fully magnetic to match SK60 cockpit navigation references.
    return normalize_bearing(ils_course_magnetic)
end

local function resolve_ils_front_course_deg(inbound_course_deg, beacon_x, beacon_z, own_x, own_z)
    if inbound_course_deg == nil or beacon_x == nil or beacon_z == nil or own_x == nil or own_z == nil then
        return inbound_course_deg
    end

    -- Resolve front/reciprocal using the same local-coordinate geometry frame
    -- used by DCS beacon position data (x/z plane).
    local dx = own_x - beacon_x
    local dz = own_z - beacon_z
    local bearing_from_beacon = normalize_bearing(math.deg(math.atan2(dz, dx)))

    local direct_course = normalize_bearing(inbound_course_deg)
    local reciprocal_course = normalize_bearing(inbound_course_deg + 180.0)
    local direct_err = math.abs(shortest_angle_delta(direct_course, bearing_from_beacon))
    local reciprocal_err = math.abs(shortest_angle_delta(reciprocal_course, bearing_from_beacon))

    if reciprocal_err < direct_err then
        return reciprocal_course
    end
    return direct_course
end

local function get_tuned_ils_glideslope_beacon(preferred_course_deg, frequency_mhz)
    local ils_beacons = Get_ILS_beacons()
    if type(ils_beacons) ~= "table" then
        return nil
    end

    local tuned_frequency_hz = math.floor(((frequency_mhz or tuned_vor_frequency_mhz) * 1000000) + 0.5)
    local entry = ils_beacons[tuned_frequency_hz]
    if type(entry) ~= "table" then
        return nil
    end

    local own_x, _, own_z = sensor_data.getSelfCoordinates()
    local best = nil
    local best_score = math.huge

    local function score_candidate(beacon)
        if type(beacon) ~= "table" or beacon.type ~= BEACON_TYPE_ILS_GLIDESLOPE then
            return
        end

        local score = 0
        local gs_course = get_ils_course_deg(beacon)
        if preferred_course_deg ~= nil and gs_course ~= nil then
            local course_err = math.abs(shortest_angle_delta(preferred_course_deg, normalize_bearing(gs_course)))
            local recip_err = math.abs(shortest_angle_delta(preferred_course_deg, normalize_bearing(gs_course + 180.0)))
            score = score + math.min(course_err, recip_err) * 10.0
        end

        local bx, bz = get_beacon_position(beacon)
        if own_x ~= nil and own_z ~= nil and bx ~= nil and bz ~= nil then
            local dx = bx - own_x
            local dz = bz - own_z
            local dist_nm = math.sqrt((dx * dx) + (dz * dz)) * 0.0005399568
            score = score + dist_nm
        end

        if score < best_score then
            best = beacon
            best_score = score
        end
    end

    if entry.__is_collection == true then
        for i = 1, #entry do
            score_candidate(entry[i])
        end
    else
        score_candidate(entry)
    end

    return best
end

local function calculate_ils_deviation(beacon, frequency_mhz)
    local beacon_x, beacon_z = get_beacon_position(beacon)
    if beacon_x == nil or beacon_z == nil then
        return 0, 0, 0, 0, nil, nil
    end

    local own_x, own_y, own_z = sensor_data.getSelfCoordinates()
    if own_x == nil or own_z == nil then
        return 0, 0, 0, 0, nil, nil
    end

    local own_geo = lo_to_geo_coords(own_x, own_z)
    local beacon_geo = lo_to_geo_coords(beacon_x, beacon_z)
    if own_geo == nil or beacon_geo == nil then
        return 0, 0, 0, 0, nil, nil
    end

    local inbound_course_deg = get_ils_inbound_course_magnetic(beacon)
    if inbound_course_deg == nil then
        return 0, 0, 0, 0, nil, nil
    end

    local resolved_front_course_deg = resolve_ils_front_course_deg(inbound_course_deg, beacon_x, beacon_z, own_x, own_z)

    local dx = own_x - beacon_x
    local dz = own_z - beacon_z
    local bearing_from_beacon_deg = normalize_bearing(math.deg(math.atan2(dz, dx)))

    -- Localizer CDI should represent angular displacement from the inbound
    -- front-course line using local x/z geometry to match DCS beacon data frame.
    local loc_delta_deg = shortest_angle_delta(resolved_front_course_deg, bearing_from_beacon_deg)

    -- Localizer full scale deflection is ±3 deg.
    local loc_norm = clamp(loc_delta_deg / 3.0, -1, 1)

    -- Compute GS from the dedicated glideslope transmitter geometry.
    -- This matches real ILS layout (GS near threshold, LOC at far end).
    local gs_error_deg = 999
    local gs_norm = 0
    local gs_beacon = get_tuned_ils_glideslope_beacon(resolved_front_course_deg, frequency_mhz)
    if gs_beacon ~= nil then
        local gs_x, gs_z = get_beacon_position(gs_beacon)
        if gs_x ~= nil and gs_z ~= nil then
            local horizontal_distance_m = math.sqrt((gs_x - own_x)^2 + (gs_z - own_z)^2)
            if horizontal_distance_m >= 1.0 then
                local gs_alt_m = get_beacon_altitude_m(gs_beacon)
                local own_alt_m = own_y or gs_alt_m
                local vertical_delta_m = own_alt_m - gs_alt_m
                local current_slope_deg = math.deg(math.atan2(vertical_delta_m, horizontal_distance_m))
                gs_error_deg = current_slope_deg - 3.0

                -- Treat large error as invalid/lost GS signal.
                if math.abs(gs_error_deg) <= 5.0 then
                    gs_norm = clamp((-gs_error_deg) / 0.7, -1, 1)
                else
                    gs_error_deg = 999
                    gs_norm = 0
                end
            end
        end
    end

    local bearing_to_station_true = normalize_bearing(getBearing(own_geo.lat, own_geo.lon, beacon_geo.lat, beacon_geo.lon))
    return loc_norm, gs_norm, loc_delta_deg, gs_error_deg, resolved_front_course_deg, bearing_to_station_true
end

local function update_ils_bar_slew()
    local max_step = ils_bar_slew_per_second * update_time_step

    local delta_loc = target_ils_loc_value - current_ils_loc_value
    if math.abs(delta_loc) <= max_step then
        current_ils_loc_value = target_ils_loc_value
    else
        current_ils_loc_value = current_ils_loc_value + (delta_loc > 0 and max_step or -max_step)
    end

    local delta_gs = target_ils_gs_value - current_ils_gs_value
    if math.abs(delta_gs) <= max_step then
        current_ils_gs_value = target_ils_gs_value
    else
        current_ils_gs_value = current_ils_gs_value + (delta_gs > 0 and max_step or -max_step)
    end

    ils_loc_dev:set(current_ils_loc_value)
    ils_gs_dev:set(current_ils_gs_value)
end

local function get_tuned_ndb_beacon()
    local ndb_beacons = Get_NDB_beacons()
    if type(ndb_beacons) ~= "table" then
        return nil
    end

    local tuned_frequency_hz = math.floor((tuned_ndb_frequency_khz * 1000) + 0.5)
    return ndb_beacons[tuned_frequency_hz]
end

local function geo_to_lo_coords(lat_deg, lon_deg)
    if type(Terrain) == "table" and type(Terrain.convertLatLonToMeters) == "function" then
        return Terrain.convertLatLonToMeters(lat_deg, lon_deg)
    end

    return nil, nil
end

local function calculate_vor_data(beacon, target_geo_override)
    local own_x, _, own_z = sensor_data.getSelfCoordinates()
    if own_x == nil or own_z == nil then
        return nil
    end

    local beacon_x, beacon_z = get_beacon_position(beacon)
    if beacon_x == nil or beacon_z == nil then
        return nil
    end

    local own_geo = lo_to_geo_coords(own_x, own_z)
    local beacon_geo = lo_to_geo_coords(beacon_x, beacon_z)
    if own_geo == nil or beacon_geo == nil then
        return nil
    end

    local target_geo = target_geo_override or beacon_geo
    local target_x = beacon_x
    local target_z = beacon_z
    if target_geo_override ~= nil then
        -- RNAV offset construction already knows the exact local-grid point.
        -- Preserve it instead of unnecessarily converting X/Z -> lat/lon -> X/Z;
        -- the latter can fail and send closing-speed calculation down its
        -- geographic fallback path with a mismatched bearing convention.
        target_x = target_geo_override.x
        target_z = target_geo_override.z
        if target_x == nil or target_z == nil then
            target_x, target_z = geo_to_lo_coords(target_geo.lat, target_geo.lon)
        end
    end

    local distance_nm = haversine(own_geo.lat, own_geo.lon, target_geo.lat, target_geo.lon)
    local bearing_true = normalize_bearing(getBearing(own_geo.lat, own_geo.lon, target_geo.lat, target_geo.lon))
    local bearing_magnetic = true_to_magnetic(bearing_true)
    return {
        distance_nm = distance_nm,
        bearing_true = bearing_true,
        bearing_magnetic = bearing_magnetic,
        target_geo = target_geo,
        target_x = target_x,
        target_z = target_z,
        beacon_geo = beacon_geo,
    }
end

local function calculate_closing_speed_to_target(target_geo, target_x, target_z)
    local own_x, _, own_z = sensor_data.getSelfCoordinates()
    local vel_x, _, vel_z = sensor_data.getSelfVelocity()
    if own_x == nil or own_z == nil or vel_x == nil or vel_z == nil or target_geo == nil or target_x == nil or target_z == nil then
        return nil
    end

    local gs_mps = math.sqrt((vel_x * vel_x) + (vel_z * vel_z))
    if gs_mps < 0.1 then
        return 0
    end

    -- DCS velocity and target positions are both in local X/Z coordinates.
    -- Project velocity onto the exact aircraft-to-waypoint vector so closure
    -- has the correct sign on either side of the VOR.
    local dx = target_x - own_x
    local dz = target_z - own_z
    local distance_m = math.sqrt((dx * dx) + (dz * dz))
    if distance_m < 1.0 then
        return 0
    end

    local closure_mps = ((vel_x * dx) + (vel_z * dz)) / distance_m
    if closure_mps < 0 then
        return 0
    end

    return closure_mps * 1.9438444924406 -- m/s -> knots
end

local function get_current_vor_station_data(frequency_mhz)
    local tuned_beacon = get_tuned_vor_beacon(frequency_mhz)
    if tuned_beacon == nil then
        return nil
    end

    local vor_data = calculate_vor_data(tuned_beacon)
    if vor_data == nil then
        return nil
    end

    local own_x, _, own_z = sensor_data.getSelfCoordinates()
    local beacon_x, beacon_z = get_beacon_position(tuned_beacon)
    if own_x == nil or own_z == nil or beacon_x == nil or beacon_z == nil then
        return nil
    end

    -- The CHK radial is the aircraft's current FROM radial out of the dialed VOR.
    -- Calculate the FROM radial in the same local X/Z frame as the beacon data,
    -- then rotate it into the cockpit magnetic-heading frame before driving RAD.
    local radial_grid = normalize_bearing(math.deg(math.atan2(own_z - beacon_z, own_x - beacon_x)))
    return {
        radial_deg = grid_to_magnetic(radial_grid),
        distance_nm = vor_data.distance_nm,
    }
end

local function update_rnav_display_values()
    local display_radial_deg = selected_offset_radial_deg
    local display_distance_nm = selected_offset_distance_nm

    if rnav_check_pressed then
        local current_vor_data = get_current_vor_station_data(tuned_vor_frequency_mhz)
        if current_vor_data ~= nil then
            display_radial_deg = current_vor_data.radial_deg
            display_distance_nm = current_vor_data.distance_nm
        end
    end

    rnav_display_frq:set(tuned_vor_frequency_mhz)
    rnav_display_rad:set(display_radial_deg)
    rnav_display_dst:set(clamp(display_distance_nm, 0, 999.9))
    rnav_display_wpt:set(current_waypoint_index)
end

local function get_offset_waypoint_geo(beacon, offset_radial_deg, offset_distance_nm)
    local beacon_x, beacon_z = get_beacon_position(beacon)
    if beacon_x == nil or beacon_z == nil then
        return nil
    end

    -- RAD is a VOR radial in the cockpit magnetic frame. Build the offset in
    -- DCS's local grid frame, using the inverse of the same grid-to-magnetic
    -- correction used by the RNAV CHK radial. Converting RAD as a geographic
    -- true bearing made the offset behave like a true radial in game.
    local radial_grid_deg = magnetic_to_grid(offset_radial_deg or selected_offset_radial_deg)
    local radial_grid_rad = radial_grid_deg * DEG_TO_RADIAN
    local distance_m = (offset_distance_nm or selected_offset_distance_nm) * 1852.0
    local waypoint_x = beacon_x + (math.cos(radial_grid_rad) * distance_m)
    local waypoint_z = beacon_z + (math.sin(radial_grid_rad) * distance_m)
    local waypoint_geo = lo_to_geo_coords(waypoint_x, waypoint_z)
    if waypoint_geo == nil then
        return nil
    end

    waypoint_geo.x = waypoint_x
    waypoint_geo.z = waypoint_z
    return waypoint_geo
end

function post_initialize()
    nav_system:listen_command(Keys.Nav_Course_Sel)
    nav_system:listen_command(Keys.Nav_Heading_Sel)
    nav_system:listen_command(Keys.Nav_Right_Knob_L)
    nav_system:listen_command(Keys.Nav_Right_Knob_S)
    nav_system:listen_command(Keys.Nav_RNAV_DAT_CYCLE)
    nav_system:listen_command(Keys.Nav_RNAV_WPT_CYCLE)
    nav_system:listen_command(Keys.Nav_RNAV_USE)
    nav_system:listen_command(Keys.Nav_RNAV_RTN)
    nav_system:listen_command(Keys.Nav_RNAV_CHK_PRESS)
    nav_system:listen_command(Keys.Nav_RNAV_CHK_RELEASE)
    nav_system:listen_command(Keys.Nav_VOR_MHz)
    nav_system:listen_command(Keys.Nav_VOR_005)
    nav_system:listen_command(Keys.Nav_ADF_100)
    nav_system:listen_command(Keys.Nav_ADF_1)
    nav_system:listen_command(Keys.Nav_ADF_PWR)
    nav_system:listen_command(Keys.Nav_DME_PWR)
    nav_system:listen_command(Keys.Nav_DME_PWR_ON)
    nav_system:listen_command(Keys.Nav_DME_PWR_OFF)
    nav_system:listen_command(Keys.Nav_RNAV_PWR)
    nav_system:listen_command(Keys.Nav_EADI_MODE_CYCLE)
    set_rnav_display_power(false)
    rnav_ils_mode:set(0)
    ils_bars_visible:set(0)
    ils_loc_dev:set(0)
    ils_gs_dev:set(0)
    current_ils_loc_value = 0
    target_ils_loc_value = 0
    current_ils_gs_value = 0
    target_ils_gs_value = 0
    eadi_ils_overlay_mode = 0
    eadi_ils_overlay_enable:set(0)
    eadi_ils_dots_enable:set(0)
    set_adf_display_power(false)
    set_dme_display_power(false)
    adf_display_freq:set(tuned_ndb_frequency_khz)
    dme_display_dist:set(0)
    dme_display_gs:set(0)
    dme_display_time:set(0)
    dme_data_valid:set(0)
    restore_nav_unit_state()
    adf_display_freq:set(tuned_ndb_frequency_khz)
    set_rnav_edit_segment_card()
    update_rnav_display_values()
    rnav_sel_blink:set(1)
    rnav_wpt_active:set(current_waypoint_index == active_waypoint.index and 1 or 0)
    rnav_wpt_pending:set(current_waypoint_index == active_waypoint.index and 0 or 1)
    set_selected_vor_course(selected_vor_course_deg)
    set_heading_bug(selected_heading_bug_deg)
    set_hsi_cdi(0)
    set_hsi_to_from(HSI_TO_FROM_OFF)
    set_rmi_needle(0)
    set_adf_needle(0)

    local birth = LockOn_Options.init_conditions.birth_place
    local is_hot_start = (birth == "GROUND_HOT" or birth == "AIR_HOT")
    if is_hot_start then
        set_rnav_display_power(true)
        set_adf_display_power(true)
        set_dme_display_power(true)
    end

    nav_debug_popup(string.format("NAV INIT: Tuned VOR %.2f MHz", tuned_vor_frequency_mhz))
end

function SetCommand(command, value)
    if command == Keys.Nav_VOR_MHz then
        local clicks = command_value_to_clicks(value)
        if clicks ~= 0 then
            if active_rnav_edit_segment == EDIT_SEGMENT_FRQ then
                tune_vor_frequency(vor_large_step_mhz * clicks)
            elseif active_rnav_edit_segment == EDIT_SEGMENT_RAD then
                set_offset_radial(selected_offset_radial_deg + (clicks * 10))
            else
                set_offset_distance(selected_offset_distance_nm + (clicks * 1.0))
            end
            save_current_waypoint_slot()
            persist_nav_unit_state()
        end
    elseif command == Keys.Nav_VOR_005 then
        local clicks = command_value_to_clicks(value)
        if clicks ~= 0 then
            if active_rnav_edit_segment == EDIT_SEGMENT_FRQ then
                tune_vor_frequency(vor_small_step_mhz * clicks)
            elseif active_rnav_edit_segment == EDIT_SEGMENT_RAD then
                set_offset_radial(selected_offset_radial_deg + clicks)
            else
                set_offset_distance(selected_offset_distance_nm + (clicks * 0.1))
            end
            save_current_waypoint_slot()
            persist_nav_unit_state()
        end
    elseif command == Keys.Nav_Course_Sel then
        local delta_degrees = course_knob_value_to_degrees(value)
        if delta_degrees ~= 0 then
            set_selected_vor_course(selected_vor_course_deg + delta_degrees)
            persist_nav_unit_state()
        end
    elseif command == Keys.Nav_Heading_Sel then
        local delta_degrees = heading_bug_knob_value_to_degrees(value)
        if delta_degrees ~= 0 then
            set_heading_bug(selected_heading_bug_deg + delta_degrees)
            persist_nav_unit_state()
        end
    elseif command == Keys.Nav_Right_Knob_L then
        local clicks = command_value_to_clicks(value)
        if clicks ~= 0 then
            if active_rnav_edit_segment == EDIT_SEGMENT_FRQ then
                tune_vor_frequency(vor_large_step_mhz * clicks)
            elseif active_rnav_edit_segment == EDIT_SEGMENT_RAD then
                set_offset_radial(selected_offset_radial_deg + (clicks * 10))
            else
                set_offset_distance(selected_offset_distance_nm + (clicks * 1.0))
            end
            save_current_waypoint_slot()
            persist_nav_unit_state()
        end
    elseif command == Keys.Nav_Right_Knob_S then
        local clicks = command_value_to_clicks(value)
        if clicks ~= 0 then
            if active_rnav_edit_segment == EDIT_SEGMENT_FRQ then
                tune_vor_frequency(vor_small_step_mhz * clicks)
            elseif active_rnav_edit_segment == EDIT_SEGMENT_RAD then
                set_offset_radial(selected_offset_radial_deg + clicks)
            else
                set_offset_distance(selected_offset_distance_nm + (clicks * 0.1))
            end
            save_current_waypoint_slot()
            persist_nav_unit_state()
        end
    elseif command == Keys.Nav_RNAV_DAT_CYCLE then
        if value == nil or value > 0 then
            cycle_rnav_edit_segment()
            persist_nav_unit_state()
        end
    elseif command == Keys.Nav_RNAV_WPT_CYCLE then
        local clicks = command_value_to_clicks(value)
        if clicks ~= 0 then
            cycle_waypoint_slot(clicks)
            persist_nav_unit_state()
        end
    elseif command == Keys.Nav_RNAV_USE then
        if value == nil or value > 0 then
            activate_current_waypoint_slot(true)
            persist_nav_unit_state()
        end
    elseif command == Keys.Nav_RNAV_RTN then
        if value == nil or value > 0 then
            return_to_active_waypoint(true)
            persist_nav_unit_state()
        end
    elseif command == Keys.Nav_RNAV_CHK_PRESS then
        if value == nil or value > 0 then
            rnav_check_pressed = true
        end
    elseif command == Keys.Nav_RNAV_CHK_RELEASE then
        rnav_check_pressed = false
    elseif command == Keys.Nav_ADF_100 then
        local clicks = command_value_to_clicks(value)
        if clicks ~= 0 then
            tune_ndb_frequency_large(ndb_large_step_khz * clicks)
            persist_nav_unit_state()
        end
    elseif command == Keys.Nav_ADF_1 then
        local clicks = command_value_to_clicks(value)
        if clicks ~= 0 then
            tune_ndb_frequency_small(ndb_small_step_khz * clicks)
            persist_nav_unit_state()
        end
    elseif command == Keys.Nav_ADF_PWR then
        local clicks = command_value_to_clicks(value)
        if clicks > 0 then
            if is_nav_units_power_available() then
                set_adf_display_power(true)
            else
                set_adf_display_power(false)
            end
        elseif clicks < 0 then
            set_adf_display_power(false)
        end
    elseif command == Keys.Nav_DME_PWR_ON then
        if is_nav_units_power_available() then
            set_dme_display_power(true)
        else
            set_dme_display_power(false)
        end
    elseif command == Keys.Nav_DME_PWR_OFF then
        set_dme_display_power(false)
    elseif command == Keys.Nav_DME_PWR then
        -- PTN_718 is a 2-position tumbler and may report either relative clicks
        -- (-1/+1) or absolute position (0/1) depending on interaction path.
        if value ~= nil and value >= 0 and value <= 1 then
            if value > 0.5 and is_nav_units_power_available() then
                set_dme_display_power(true)
            else
                set_dme_display_power(false)
            end
        else
            local clicks = command_value_to_clicks(value)
            if clicks > 0 then
                if is_nav_units_power_available() then
                    set_dme_display_power(true)
                else
                    set_dme_display_power(false)
                end
            elseif clicks < 0 then
                set_dme_display_power(false)
            end
        end
    elseif command == Keys.Nav_EADI_MODE_CYCLE then
        if value == nil or value > 0 then
            eadi_ils_overlay_mode = (eadi_ils_overlay_mode + 1) % 3
            if eadi_ils_overlay_mode == 0 then
    -- 0: OFF
    eadi_ils_overlay_enable:set(0)
    eadi_ils_dots_enable:set(0)

elseif eadi_ils_overlay_mode == 1 then
    -- 1: BARS ONLY
    eadi_ils_overlay_enable:set(1)
    eadi_ils_dots_enable:set(0)

elseif eadi_ils_overlay_mode == 2 then
    -- 2: BARS + DOTS
    eadi_ils_overlay_enable:set(1)
    eadi_ils_dots_enable:set(1)
end
        end
    elseif command == Keys.Nav_RNAV_PWR then
        local clicks = command_value_to_clicks(value)
        if clicks > 0 then
            if is_nav_units_power_available() then
                set_rnav_display_power(true)
            else
                set_rnav_display_power(false)
            end
        elseif clicks < 0 then
            set_rnav_display_power(false)
        end
    end
end

function update()
    enforce_nav_units_power_dependency()

    -- Keep cockpit argument animation synchronized with current power states.
    rnav_power_knob_anim:set(rnav_display_power)
    dme_power_knob_anim:set(dme_display_power)
    set_aircraft_draw_argument_value(rnav_power_knob_arg, rnav_display_power)
    set_aircraft_draw_argument_value(dme_power_knob_arg, dme_display_power)
    if type(set_cockpit_draw_argument_value) == "function" then
        set_cockpit_draw_argument_value(rnav_power_knob_arg, rnav_display_power)
        set_cockpit_draw_argument_value(dme_power_knob_arg, dme_display_power)
    end

    adf_display_enable:set(adf_display_power)
    adf_display_freq:set(tuned_ndb_frequency_khz)
    dme_display_enable:set(dme_display_power)

    local tuned_ndb = get_tuned_ndb_beacon()
    if tuned_ndb ~= nil then
        local ndb_data = calculate_vor_data(tuned_ndb)
        if ndb_data ~= nil then
            -- Match the RMI compass card/VOR needle convention: the ADF pointer
            -- must use magnetic bearing, not raw true/geodetic bearing.
            local adf_bearing_for_display = ndb_data.bearing_magnetic or true_to_magnetic(ndb_data.bearing_true)
            target_adf_value = bearing_to_rmi_argument(adf_bearing_for_display)
        else
            target_adf_value = current_adf_value
        end
    else
        target_adf_value = current_adf_value
    end
    update_adf_slew()

    rnav_display_enable:set(rnav_display_power)
    update_rnav_display_values()
    update_rnav_selection_indicator()
    set_selected_vor_course(selected_vor_course_deg)
    set_heading_bug(selected_heading_bug_deg)

    local ils_mode_active = is_ils_frequency_selected(active_waypoint.vor_frequency_mhz)
    local tuned_ils = ils_mode_active and get_tuned_ils_beacon(active_waypoint.vor_frequency_mhz) or nil
    if ils_mode_active then
        rnav_ils_mode:set(1)
        ils_bars_visible:set(1)
        local loc_norm, gs_norm, loc_delta_deg, gs_error_deg, loc_inbound_true, loc_bearing_true = 0, 0, 0, 0, nil, nil
        if tuned_ils ~= nil then
            loc_norm, gs_norm, loc_delta_deg, gs_error_deg, loc_inbound_true, loc_bearing_true = calculate_ils_deviation(tuned_ils, active_waypoint.vor_frequency_mhz)
        end

        if math.abs(loc_delta_deg) <= 30 then
            target_ils_loc_value = loc_norm
        else
            target_ils_loc_value = 0
        end

        if math.abs(gs_error_deg) <= 30 then
            target_ils_gs_value = gs_norm
        else
            target_ils_gs_value = 0
        end

        update_ils_bar_slew()
        if ils_debug_text_enabled and tuned_ils ~= nil then
            local tuned_frequency_hz = math.floor((active_waypoint.vor_frequency_mhz * 1000000) + 0.5)
            if last_announced_ils_frequency_hz ~= tuned_frequency_hz then
                last_announced_ils_frequency_hz = tuned_frequency_hz
                print_message_to_user(string.format(
                    "ILS Tuned: %.2f MHz - %s",
                    active_waypoint.vor_frequency_mhz,
                    get_beacon_display_name(tuned_ils)
                ))
            end
        else
            last_announced_ils_frequency_hz = nil
        end

        local hsi_ils_cdi_norm = clamp(loc_delta_deg / 3.0, -1, 1)
        set_hsi_cdi(hsi_ils_cdi_norm)

        local now = get_absolute_model_time()
        if ils_debug_text_enabled and now - last_ils_message_time >= ils_message_interval_seconds then
            last_ils_message_time = now
            local inbound_true = loc_inbound_true or 0
            local inbound_mag = true_to_magnetic(inbound_true)
            local bearing_true = loc_bearing_true or 0
            local bearing_mag = true_to_magnetic(bearing_true)
            print_message_to_user(string.format(
                "ILS DEV | LOC %+05.1f° | GS %+05.1f° | HSI %+04.1f° | CRS %03.0fT/%03.0fM | BRG %03.0fT/%03.0fM",
                loc_delta_deg,
                gs_error_deg,
                clamp(loc_delta_deg, -3, 3),
                inbound_true,
                inbound_mag,
                bearing_true,
                bearing_mag
            ))
        end
    else
        rnav_ils_mode:set(0)
        ils_bars_visible:set(0)
        target_ils_loc_value = 0
        target_ils_gs_value = 0
        update_ils_bar_slew()
        last_announced_ils_frequency_hz = nil
        last_ils_message_time = -10
    end

    local tuned_beacon = get_tuned_vor_beacon(active_waypoint.vor_frequency_mhz)
    local dme_source_beacon = tuned_beacon
    local dme_target_geo = nil
    if ils_mode_active and tuned_ils ~= nil then
        dme_source_beacon = tuned_ils
    elseif dme_source_beacon ~= nil then
        -- In RNAV/VOR mode the DME display is part of the selected waypoint solution,
        -- so range/time must use the radial+offset waypoint rather than the VOR station.
        dme_target_geo = get_offset_waypoint_geo(dme_source_beacon, active_waypoint.offset_radial_deg, active_waypoint.offset_distance_nm)
    elseif tuned_ils ~= nil then
        dme_source_beacon = tuned_ils
    end

    if dme_source_beacon ~= nil then
        local dme_data = calculate_vor_data(dme_source_beacon, dme_target_geo)
        if dme_data ~= nil then
            local closing_speed_kts = calculate_closing_speed_to_target(dme_data.target_geo, dme_data.target_x, dme_data.target_z)
            if closing_speed_kts == nil then
                closing_speed_kts = 0
            end

            local eta_min = 99
            if closing_speed_kts > 0.5 then
                eta_min = (dme_data.distance_nm / closing_speed_kts) * 60.0
            end

            dme_display_dist:set(clamp(dme_data.distance_nm, 0, 999.9))
            dme_display_gs:set(clamp(closing_speed_kts, 0, 999))
            dme_display_time:set(clamp(eta_min, 0, 99))
            dme_data_valid:set(1)
        else
            dme_data_valid:set(0)
        end
    else
        dme_data_valid:set(0)
    end

    if tuned_beacon == nil then
        if ils_mode_active and tuned_ils ~= nil then
            local ils_rmi_data = calculate_vor_data(tuned_ils)
            if ils_rmi_data ~= nil then
                local ils_bearing_for_display = ils_rmi_data.bearing_magnetic or true_to_magnetic(ils_rmi_data.bearing_true)
                target_rmi_value = bearing_to_rmi_argument(ils_bearing_for_display)
            else
                target_rmi_value = current_rmi_value
            end
        else
            target_rmi_value = current_rmi_value
        end

        if not ils_mode_active then
            set_hsi_cdi(0)
        end
        set_hsi_to_from(HSI_TO_FROM_OFF)
        update_rmi_slew()
        local now = get_absolute_model_time()
        if now - last_message_time >= message_interval_seconds then
            last_message_time = now
            if ils_mode_active then
                nav_debug_popup(string.format("ILS %.2f MHz active", active_waypoint.vor_frequency_mhz))
            else
                nav_debug_popup(string.format("VOR %.2f MHz: station not found", active_waypoint.vor_frequency_mhz))
            end
        end
        return
    end

    local offset_waypoint_geo = get_offset_waypoint_geo(tuned_beacon, active_waypoint.offset_radial_deg, active_waypoint.offset_distance_nm)
    local vor_data = calculate_vor_data(tuned_beacon, offset_waypoint_geo)
    if vor_data == nil then
        dme_data_valid:set(0)
        target_rmi_value = current_rmi_value
        set_hsi_cdi(0)
        set_hsi_to_from(HSI_TO_FROM_OFF)
        update_rmi_slew()
        local now = get_absolute_model_time()
        if now - last_message_time >= message_interval_seconds then
            last_message_time = now
            nav_debug_popup(string.format("VOR %.2f MHz: station data incomplete", active_waypoint.vor_frequency_mhz))
        end
        return
    end

    -- RMI should always point at the selected waypoint and must not be affected by HSI course selection.
    local vor_bearing_for_display = vor_data.bearing_magnetic or true_to_magnetic(vor_data.bearing_true)
    target_rmi_value = bearing_to_rmi_argument(vor_bearing_for_display)
    update_rmi_slew()
    if not ils_mode_active then
        local cdi_deviation_deg, to_from_value = calculate_hsi_course_data(selected_vor_course_deg, vor_bearing_for_display)
        local cdi_norm = clamp(cdi_deviation_deg / 10.0, -1, 1)
        set_hsi_cdi(cdi_norm)
        set_hsi_to_from(to_from_value)
    else
        set_hsi_to_from(HSI_TO_FROM_OFF)
    end
    local now = get_absolute_model_time()
    if now - last_message_time < message_interval_seconds then
        return
    end
    last_message_time = now

    nav_debug_popup(string.format(
        "VOR %.2f | BRG %03.0f° | DME %.1f NM",
        active_waypoint.vor_frequency_mhz,
        vor_bearing_for_display,
        vor_data.distance_nm
    ))
end

need_to_be_closed = false

-- SK60 shared cockpit integration
dofile(LockOn_Options.script_path .. "Multicrew/runtime.lua").install(22)
