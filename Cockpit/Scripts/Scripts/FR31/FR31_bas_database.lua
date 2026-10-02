-- Selects the FR31 BAS database for the terrain used by the current mission.
-- Terrain files return a group table and are named after the value returned by
-- DCS's get_terrain_related_data("name") API (for example, Caucasus.lua).

local BAS_DATABASE_PATH = LockOn_Options.script_path .. "FR31/BAS/"
local DEFAULT_DATABASE_NAME = "default"
local DATABASE_ALIASES = {
    afghanistan = "Afghanistan",
    caucasus = "Caucasus",
    channel = "TheChannel",
    coldwargermany = "GermanyCW",
    falklands = "Falklands",
    germanycw = "GermanyCW",
    iraq = "Iraq",
    kola = "Kola",
    marianaislands = "MarianaIslands",
    marianaislandswwii = "MarianaIslandsWWII",
    marianas = "MarianaIslands",
    marianaswwii = "MarianaIslandsWWII",
    nevada = "Nevada",
    normandy = "Normandy",
    normandy2 = "Normandy",
    normandy20 = "Normandy",
    persiangulf = "PersianGulf",
    sinai = "SinaiMap",
    sinaimap = "SinaiMap",
    southatlantic = "Falklands",
    syria = "Syria",
    thechannel = "TheChannel",
}
local DATABASE_DISPLAY_NAMES = {
    Falklands = "South Atlantic",
    GermanyCW = "Cold War Germany",
    MarianaIslands = "Marianas",
    MarianaIslandsWWII = "Marianas WWII",
    Normandy = "Normandy 2.0",
    PersianGulf = "Persian Gulf",
    SinaiMap = "Sinai",
    TheChannel = "The Channel",
}

local function get_mission_theatre()
    -- mission.theatre is the canonical identifier stored in the .miz. Some
    -- newer terrains return a different display/internal name through
    -- get_terrain_related_data("name"), so prefer the mission value when DCS
    -- exposes the mission loader in this Lua state.
    if do_mission_file ~= nil then
        pcall(do_mission_file, "mission")
    end

    if type(mission) == "table" and type(mission.theatre) == "string" and mission.theatre ~= "" then
        return mission.theatre
    end

    return nil
end

local function get_current_theatre()
    local theatre = get_mission_theatre()
    if theatre == nil and get_terrain_related_data ~= nil then
        theatre = get_terrain_related_data("name")
    end

    if type(theatre) ~= "string" or theatre == "" then
        return nil
    end

    -- DCS does not use one consistent public/display name for every terrain.
    -- Resolve known normalized names first (notably Kola/KolaMap), then retain
    -- the sanitized API value so future terrain files can still be discovered.
    local normalized_theatre = string.gsub(theatre, "[^%w_%-]", "")
    if normalized_theatre == "" then
        return nil
    end

    local alias_key = string.lower(string.gsub(theatre, "[^%w]", ""))
    if string.find(alias_key, "kola", 1, true) ~= nil then
        return "Kola"
    end

    return DATABASE_ALIASES[alias_key] or normalized_theatre
end

function FR31_get_bas_database_name()
    return get_current_theatre()
end

-- Expose a readable name for consumers such as the kneeboard while keeping
-- DCS's canonical identifiers for database filenames.
function FR31_get_bas_theatre()
    local database_name = FR31_get_bas_database_name()
    return DATABASE_DISPLAY_NAMES[database_name] or database_name
end

local function load_database(name)
    local filename = BAS_DATABASE_PATH .. name .. ".lua"
    local chunk = loadfile(filename)
    if chunk == nil then
        return nil
    end

    local database = chunk()
    if type(database) ~= "table" then
        return nil
    end

    return database
end


function FR31_load_bas_database()
    local theatre = FR31_get_bas_database_name()
    local database = nil

    if theatre ~= nil then
        database = load_database(theatre)
    end

    if database == nil then
        database = load_database(DEFAULT_DATABASE_NAME)
    end

    return database or {}
end
