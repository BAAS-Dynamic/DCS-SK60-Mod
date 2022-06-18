
dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")

local gps_receiver 	    = GetSelf()

local update_time_step = 0.02
make_default_activity(update_time_step)

-- gps_system
local gps_receiver_lat = get_param_handle("GPS_REC_LAT")
local gps_receiver_lon = get_param_handle("GPS_REC_LON")
local gps_receiver_alt = get_param_handle("GPS_REC_ALT")
-- mission route system
local mission_route_points_num = get_param_handle("MISSION_WP_NUM")

local sensor_data = get_base_data()
local ias_conversion_to_knots = 1.9504132
local ias_conversion_to_kmh =  1.9504132 -- easily convert to knots -- 3.6 
local DEGREE_TO_RAD  = 0.0174532925199433
local RAD_TO_DEGREE  = 57.29577951308233
local METER_TO_INCH = 3.2808

-- gps_receiver:listen_command(Keys.COM_Freq_Swap)

local pos_x_loc, pos_y_loc, alt, coord
-- get mission route table from lua
local waypoints = {}

function updateGPS()
    pos_x_loc, alt, pos_y_loc= sensor_data.getSelfCoordinates()
    coord = lo_to_geo_coords(pos_x_loc, pos_y_loc)
    -- temp_dbg:set(coord.lat)
    gps_receiver_lat:set(coord.lat)
    gps_receiver_lon:set(coord.lon)
    gps_receiver_alt:set(alt)
end

-- 只有上行至EFM链路
function uploadRouteToEFM()
    if waypoints ~= nil then
        -- have way points, upload to efm
        mission_route_points_num:set(#waypoints)
        local route_coord
        local uplink_handle
        for i, point_item in pairs(waypoints) do
            route_coord = lo_to_geo_coords(point_item.x, point_item.y)
            uplink_handle = get_param_handle("MISSION_WP_"..tostring(i-1).."_LAT")
            uplink_handle:set(route_coord.lat)
            uplink_handle = get_param_handle("MISSION_WP_"..tostring(i-1).."_LON")
            uplink_handle:set(route_coord.lon)
            uplink_handle = get_param_handle("MISSION_WP_"..tostring(i-1).."_ALT")
            uplink_handle:set(point_item.alt)
            uplink_handle = get_param_handle("MISSION_WP_"..tostring(i-1).."_ES")
            uplink_handle:set(point_item.speed)
            uplink_handle = get_param_handle("MISSION_WP_"..tostring(i-1).."_COMMENT")
            uplink_handle:set("Mission Act: "..point_item.action)
        end
    else
        mission_route_points_num:set(0)
    end
end

function post_initialize()
    updateGPS()
    -- collect the waypoint data from mission
    waypoints = get_mission_route()
end

function SetCommand(command,value)

end

local is_ingame_init = 0

function update()
    if get_elec_dc_status() then

    end

    if get_elec_ac_status() then
        -- update the receiver status from lua
        updateGPS()
    end

    if is_ingame_init == 0 then
        uploadRouteToEFM()
        updateGPS()
        is_ingame_init = 1
    end
end


need_to_be_closed = false

--[[
function debug_display()
    local coord_waypoint
    print_message_to_user("Way point size is "..#waypoints)
    for i,v in pairs(waypoints) do
        for j,value in pairs(v) do 
            if type(value) ~= "table" then
                print_message_to_user("Waypoint "..i.." value "..j.." is "..tostring(value))
            end
        end
        coord_waypoint = lo_to_geo_coords(waypoints[i].x, waypoints[i].y)
        print_message_to_user("Waypoint 1 Target position is lat: "..coord_waypoint.lat.."; lon: "..coord_waypoint.lon)
    end
    is_get_mission_route = 1
end
]]--