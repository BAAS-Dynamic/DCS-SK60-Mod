-- ========================== Caffeine Simulations Nav System ==========================
-- Developed by Hayds_93, 2024 for Caffeine Simulations and the T-38C
-- Free to use and modify under the GPL3 License, see the README for more info
-- This module is available for PUBLIC mods only, thank you
-- =====================================================================================

-- DCS Lua doesnt seem to like the new functions... I think its pre 5.3?
---@diagnostic disable: deprecated

-- Beacon constants, from Beacons.lua
BEACON_TYPE_NULL = 0
BEACON_TYPE_VOR = 1
BEACON_TYPE_DME = 2
BEACON_TYPE_VOR_DME = 3
BEACON_TYPE_TACAN = 4
BEACON_TYPE_VORTAC = 5
BEACON_TYPE_RSBN = 128
BEACON_TYPE_BROADCAST_STATION = 1024

BEACON_TYPE_HOMER = 8
BEACON_TYPE_AIRPORT_HOMER = 4104
BEACON_TYPE_AIRPORT_HOMER_WITH_MARKER = 4136
BEACON_TYPE_ILS_FAR_HOMER = 16408
BEACON_TYPE_ILS_NEAR_HOMER = 16424

BEACON_TYPE_ILS_LOCALIZER = 16640
BEACON_TYPE_ILS_GLIDESLOPE = 16896

BEACON_TYPE_PRMG_LOCALIZER = 33024
BEACON_TYPE_PRMG_GLIDESLOPE = 33280

BEACON_TYPE_ICLS_LOCALIZER = 131328
BEACON_TYPE_ICLS_GLIDESLOPE = 131584

BEACON_TYPE_NAUTICAL_HOMER = 65536

BEACON_TYPE_TACAN_RANGE = 262144


-- Haversine formula to calculate the distance between two points on the Earth
function haversine(lat1, lon1, lat2, lon2)
    local R = 3440.07 -- Earth's radius in nautical miles
    local dLat = math.rad(lat2 - lat1)
    local dLon = math.rad(lon2 - lon1)
    local a = math.sin(dLat/2) * math.sin(dLat/2) +
              math.cos(math.rad(lat1)) * math.cos(math.rad(lat2)) *
              math.sin(dLon/2) * math.sin(dLon/2)
    local c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
    local distance = R * c -- Distance in nautical miles
    return distance
end

function calculateRunwayLength(edge1x, edge1y, edge2x, edge2y)
   -- calculate length of runway in feet from start to finish coords from roadnet
    local edge1xy = lo_to_geo_coords(edge1x, edge1y)
    local edge2xy = lo_to_geo_coords(edge2x, edge2y)

    local distanceInNM = haversine(edge1xy.lat, edge1xy.lon, edge2xy.lat, edge2xy.lon)

    return distanceInNM * 6076.12 -- Convert nautical miles to feet
end


-- Function to calculate the bearing from the player to an airport (or any point)
function getBearing(lat1, lon1, lat2, lon2)
   -- Convert degrees to radians
    local function degToRad(deg)
        return deg * math.pi / 180
    end

   -- Convert radians to degrees
    local function radToDeg(rad)
        return rad * 180 / math.pi
    end

   -- Convert latitudes and longitudes to radians
    local lat1_rad = degToRad(lat1)
    local lon1_rad = degToRad(lon1)
    local lat2_rad = degToRad(lat2)
    local lon2_rad = degToRad(lon2)

   -- Calculate the differences between the two points
    local dLon = lon2_rad - lon1_rad

   -- Calculate the bearing
    local y = math.sin(dLon) * math.cos(lat2_rad)
    local x = math.cos(lat1_rad) * math.sin(lat2_rad) - math.sin(lat1_rad) * math.cos(lat2_rad) * math.cos(dLon)
    local bearing_rad = math.atan2(y, x)

   -- Convert bearing from radians to degrees
    local bearing_deg = (radToDeg(bearing_rad) + 360) % 360  -- Normalize to 0-360 degrees

    return bearing_deg
end


function getCivilianStatus(civilian)
   -- this function is largely only relevant to the T-38C
    if civilian then
        return "CIV"
    else
        return "MIL"
    end
end


function getAirportLocation(reference_point)
   -- convert metric coords to something useful (DMM i think)
    local location = lo_to_geo_coords(reference_point.x, reference_point.y)
    location.x = reference_point.x
    location.y = reference_point.y
    return location
end


-- Recursively print nested tables with indentation
function printTableContents(tbl, indent)
    indent = indent or ""

    for key, value in pairs(tbl) do
        local output = indent .. tostring(key) .. ": "

        if type(value) == "table" then
            print_message_to_user(output .. "{")
            printTableContents(value, indent .. "  ")  -- Recursively print nested tables with indentation
            print_message_to_user(indent .. "}")
        else
            print_message_to_user(output .. tostring(value))
        end
    end
end

function roundToTwoSignificantFigures(num)
    if num == 0 then
        return 0
    end

    local d = math.ceil(math.log10(math.abs(num)))
    local power = 2 - d
    local magnitude = 10^(power)
    local shifted = math.floor(num * magnitude + 0.5)

    return shifted / magnitude
end





