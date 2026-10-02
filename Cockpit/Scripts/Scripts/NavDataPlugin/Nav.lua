-- ========================== Caffeine Simulations Nav System ==========================
-- Developed by Hayds_93, 2024 for Caffeine Simulations and the T-38C
-- Free to use and modify under the GPL3 License, see the README for more info
-- This module is available for PUBLIC mods only, thank you
-- =====================================================================================

package.path = package.path..";"..LockOn_Options.script_path.."NavDataPlugin/?.lua"

local ok = pcall(require, "Nav_Utils")
if not ok then
    dofile(LockOn_Options.script_path.."NavDataPlugin/Nav_Utils.lua")
end
local Terrain = require('terrain') -- DCS terrain module

local aircraftType = get_aircraft_type() -- this enables me to only use some features for the T-38C

local rawAirportData = get_terrain_related_data("Airdromes")
local beaconsFile = get_terrain_related_data("beaconsFile")

do_mission_file("mission") -- Load the mission file
local theatre = mission.theatre -- map name string

if beaconsFile then
    local f = loadfile(beaconsFile)
    if f then
        f()
    end
end

local ILS_beacons = {}
local TCN_beacons = {}
local VOR_beacons = {}
local NDB_beacons = {}

local FilteredAirportData   = {} -- Data filtered for relevant info and has extra info added from /additionalData
local ICAO                  = {} -- Data from the ICAO data file
local Radios                = {}


local function GetRunwayData(airport)
   -- unlike radios, this loads only the runway data for the specific roadnet
    local runwayList = Terrain.getRunwayList(airport)
    local runways = {}

    for i, v in pairs(runwayList) do
        runways[i] = {
            runwayLength = calculateRunwayLength(v.edge1x, v.edge1y, v.edge2x, v.edge2y),
            name = v.edge1name .."-"..v.edge2name,
            runwayEnd1 = getAirportLocation({x=v.edge1x, y=v.edge1y}),
            runwayEnd2 = getAirportLocation({x=v.edge2x, y=v.edge2y})
        }
    end

   -- Sort runways by length, largest first
    table.sort(runways, function(a, b)
        return a.runwayLength > b.runwayLength
    end)

    return runways
end

local function getAirportRadios(radio)
   -- set the specific radio frequencies for the airport
    if not radio or not radio[1] then return nil end
    if Radios[radio[1]] then return Radios[radio[1]]
    else return nil end
end

local function loadAirports()
-- Load all airport data at mission start
    for i, v in pairs(rawAirportData) do
        FilteredAirportData[v.display_name] = {
            name = v.display_name,
            ICAO = v.code,
            runways = GetRunwayData(v.roadnet),
            position = getAirportLocation(v.reference_point),
            radioid = v.radio,
            radios = getAirportRadios(v.radio),
            isCivilian = v.civilian,
            beacons = v.beacons,
        }
        if aircraftType == "T-38C" then
           -- this is boolean, however for my use I am converting to "CIV" or "MIL" or "BOTH"
            FilteredAirportData[v.display_name].isCivilian = getCivilianStatus(v.civilian)
        end
    end
end

local function deepMerge(target, source)
   -- this is a recursive function to merge tables only for values that are updated
    for key, value in pairs(source) do
        if type(value) == "table" and type(target[key]) == "table" then
            deepMerge(target[key], value)
        else
            target[key] = value
        end
    end
end

local function loadICAOData()
    local ICAODataPath = LockOn_Options.script_path .. "Systems/NavDataPluginExtra/"..theatre.."/"..theatre.."_ICAO.lua"

    local f = loadfile(ICAODataPath)
    if f then
        local dataModule = f()
        ICAO = dataModule.getICAOList()
    else
        print_message_to_user("Warning: No ICAO data file found for theatre: " .. theatre)
    end
end

local function loadAdditionalData()
    local additionalDataPath = LockOn_Options.script_path .. "Systems/NavDataPluginExtra/"..theatre.."/"..theatre..".lua"
    local additionalData = {}
    local f = loadfile(additionalDataPath)
    if f then
        local AirportData = f()
        additionalData = AirportData
    else
        print_message_to_user("Warning: No additional data file found for theatre: " .. theatre)
    end
    return additionalData
end


local function supplementAirportData()
    local additionalData = loadAdditionalData()
    for airportName, data in pairs(additionalData) do
        if FilteredAirportData[airportName] then
            deepMerge(FilteredAirportData[airportName], data)
        else
            print_message_to_user("Warning: Airport " .. airportName .. " not found in FilteredAirportData table")
        end
    end
end


local function loadRadios()
   -- this loads every radio frequency for every airport even for a specific roadnet
    local _, firstAirport = next(rawAirportData)
    local radioList = Terrain.getRadio(firstAirport.roadnet )
    for i, v in pairs(radioList) do
       -- Initialize the radio entry in the Radios table
        Radios[v.radioId] = {
            radioId = v.radioId,
            uniform = nil,
            victor = nil,
        }

       -- Check if the frequency data exists
        if v.frequency then

            for _, freqTable in pairs(v.frequency) do
               -- Convert the frequency to the desired format
                if freqTable[2] then

                    local freq = freqTable[2] / 1000000
                   -- Assign to the correct category based on the frequency value
                    if freq >= 225.0 then
                        Radios[v.radioId].uniform = freq
                    elseif freq >= 118.0 and freq < 225.0 then
                        Radios[v.radioId].victor = freq -- TODO test and fix for other maps
                    end
                end
            end
        else
            print_message_to_user("Warning: No frequency data available for radioId: ".. v.radioId)
        end
    end
end

local function normalizeFrequencyHz(rawFrequency)
    if type(rawFrequency) == "number" then
        return rawFrequency
    end

    if type(rawFrequency) == "table" then
        if type(rawFrequency.frequency) == "number" then
            return rawFrequency.frequency
        end
        if type(rawFrequency[1]) == "number" then
            return rawFrequency[1]
        end
        if type(rawFrequency[2]) == "number" then
            return rawFrequency[2]
        end
    end

    return nil
end

local function addVORBeacon(beaconData)
    if type(beaconData) ~= "table" then
        return
    end

    local beaconType = beaconData.type
    if beaconType ~= BEACON_TYPE_VOR and beaconType ~= BEACON_TYPE_VOR_DME and beaconType ~= BEACON_TYPE_VORTAC then
        return
    end

    local frequencyHz = normalizeFrequencyHz(beaconData.frequency)
    if frequencyHz == nil then
        return
    end

    VOR_beacons[frequencyHz] = beaconData
end

local function addILSBeacon(beaconData)
    if type(beaconData) ~= "table" then
        return
    end

    local frequencyHz = normalizeFrequencyHz(beaconData.frequency)
    if frequencyHz == nil then
        return
    end

    local beaconType = beaconData.type
    local is_ils_type = (beaconType == BEACON_TYPE_ILS_LOCALIZER or beaconType == BEACON_TYPE_ILS_GLIDESLOPE)
    local is_ils_freq_band = (frequencyHz >= 108100000 and frequencyHz <= 111950000)
    if (not is_ils_type) and (not is_ils_freq_band) then
        return
    end

    local existing = ILS_beacons[frequencyHz]
    if existing == nil then
        ILS_beacons[frequencyHz] = beaconData
        return
    end

    if existing.__is_collection == true then
        existing[#existing + 1] = beaconData
        return
    end

   -- Keep all colliding entries for a frequency. Selection (localizer preference + nearest)
   -- is performed at use-site so maps with reused ILS frequencies still resolve correctly.
    ILS_beacons[frequencyHz] = {
        existing,
        beaconData,
        __is_collection = true,
    }
end

local function addNDBBeacon(beaconData)
    if type(beaconData) ~= "table" then
        return
    end

    local beaconType = beaconData.type
    if beaconType ~= BEACON_TYPE_HOMER
        and beaconType ~= BEACON_TYPE_AIRPORT_HOMER
        and beaconType ~= BEACON_TYPE_AIRPORT_HOMER_WITH_MARKER
        and beaconType ~= BEACON_TYPE_ILS_FAR_HOMER
        and beaconType ~= BEACON_TYPE_ILS_NEAR_HOMER
        and beaconType ~= BEACON_TYPE_BROADCAST_STATION then
        return
    end

    local frequencyHz = normalizeFrequencyHz(beaconData.frequency)
    if frequencyHz == nil then
        return
    end

    NDB_beacons[frequencyHz] = beaconData
end

local function loadVORBeacons()
    VOR_beacons = {}

    if type(beacons) == "table" then
        for _, beaconData in pairs(beacons) do
            addVORBeacon(beaconData)
        end
    end

    if type(Airdrome) == "table" then
        for _, airportData in pairs(Airdrome) do
            if type(airportData) == "table" and type(airportData.airdrome) == "table" then
                for _, beaconData in pairs(airportData.airdrome) do
                    addVORBeacon(beaconData)
                end
            end
        end
    end
end

local function loadILSBeacons()
    ILS_beacons = {}

    if type(beacons) == "table" then
        for _, beaconData in pairs(beacons) do
            addILSBeacon(beaconData)
        end
    end

    if type(Airdrome) == "table" then
        for _, airportData in pairs(Airdrome) do
            if type(airportData) == "table" and type(airportData.airdrome) == "table" then
                for _, beaconData in pairs(airportData.airdrome) do
                    addILSBeacon(beaconData)
                end
            end
        end
    end
end

local function loadNDBBeacons()
    NDB_beacons = {}

    if type(beacons) == "table" then
        for _, beaconData in pairs(beacons) do
            addNDBBeacon(beaconData)
        end
    end

    if type(Airdrome) == "table" then
        for _, airportData in pairs(Airdrome) do
            if type(airportData) == "table" and type(airportData.airdrome) == "table" then
                for _, beaconData in pairs(airportData.airdrome) do
                    addNDBBeacon(beaconData)
                end
            end
        end
    end
end



function sortAirportsByDistance(ownPos)
    local sortedAirportList = {}

    for i, v in pairs(FilteredAirportData) do
        local distanceToPlayerNM = haversine(ownPos[1], ownPos[2], v.position.lat, v.position.lon)
        local bearingToPlayer = getBearing(ownPos[1], ownPos[2], v.position.lat, v.position.lon)

       -- v.distanceToPlayerFeet = distanceToPlayerFeet
        v.distanceToPlayerNM = distanceToPlayerNM
        v.bearingToPlayer = bearingToPlayer

        table.insert(sortedAirportList, v)
    end

    table.sort(sortedAirportList, function(a, b)
        return a.distanceToPlayerNM < b.distanceToPlayerNM
    end)
    return sortedAirportList
end


function sortAirportsByDistanceMetric(ownPos)
    local sortedAirportList = {}

    for i, v in pairs(FilteredAirportData) do
       -- Calculate the distance using metric coordinates (in meters)
        local deltaX = v.position.x - ownPos[1]
        local deltaY = v.position.y - ownPos[2]
        local distanceToPlayer = math.sqrt(deltaX^2 + deltaY^2) / 1852 -- Convert meters to nautical miles

       -- Calculate the bearing in degrees using atan2
        local bearingToPlayer = math.deg(math.atan2(deltaY, deltaX))
        if bearingToPlayer < 0 then
            bearingToPlayer = bearingToPlayer + 360
        end

       -- Assign calculated values to the airport
        v.distanceToPlayerNM = distanceToPlayer -- Distance in nautical miles
        v.bearingToPlayer = bearingToPlayer

        table.insert(sortedAirportList, v)
    end

   -- Sort the list by distance
    table.sort(sortedAirportList, function(a, b)
        return a.distanceToPlayerNM < b.distanceToPlayerNM
    end)
    return sortedAirportList
end


function Get_ILS_beacons()
    return ILS_beacons
end

function Get_TCN_beacons()
    return TCN_beacons
end

function Get_VOR_beacons()
    return VOR_beacons
end

function Get_NDB_beacons()
    return NDB_beacons
end

function getAirports()
    return FilteredAirportData
end

function getICAOData()
    return ICAO
end

loadRadios()
loadAirports()
loadILSBeacons()
loadVORBeacons()
loadNDBBeacons()

-- these will only load if NavDataPluginExtra exists
supplementAirportData()
loadICAOData()


