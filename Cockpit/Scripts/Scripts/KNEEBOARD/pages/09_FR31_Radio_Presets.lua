dofile(LockOn_Options.common_script_path .. "KNEEBOARD/indicator/definitions.lua")
dofile(LockOn_Options.script_path .. "FR31/FR31_kneeboard_data.lua")
SetScale(FOV)

local data = FR31_get_kneeboard_data()
local page_material = MakeMaterial(nil, {229, 228, 205, 255})
local title_font = {0.0072, 0.0072, -0.0009, 0.0}
local header_font = {0.0056, 0.0056, -0.0009, 0.0}
local item_font = {0.0047, 0.0047, -0.0009, 0.0}
local detail_font = {0.0038, 0.0038, -0.0009, 0.0}

local background = CreateElement "ceMeshPoly"
background.name = "fr31_presets_page_2_background"
background.primitivetype = "triangles"
background.vertices = {{-1.0, 1.5}, {1.0, 1.5}, {1.0, -1.5}, {-1.0, -1.5}}
background.indices = {0, 1, 2, 0, 2, 3}
background.material = page_material
Add(background)

local function add_text(name, value, x, y, font)
    local text = CreateElement "ceStringPoly"
    text.name = name
    text.material = "font_kneeboard"
    text.init_pos = {x, y, 0}
    text.value = value
    text.alignment = "LeftCenter"
    text.stringdefs = font or item_font
    text.use_mipfilter = true
    Add(text)
end

local function format_frequency(freq_hz)
    if freq_hz == nil then
        return "---.--"
    end
    local frequency = string.format("%.3f", freq_hz / 1E6)
    local compact_frequency = string.gsub(frequency, "0$", "")
    return compact_frequency
end

add_text("fr31_page_2_title", "FR31 RADIO PRESETS (PAGE 2)", -0.90, 1.36, title_font)
add_text("fr31_page_2_theatre", "THEATRE: " .. data.theatre, -0.90, 1.23, header_font)
add_text("fr31_page_2_bas_header", "BAS AIRFIELD GROUPS (CONTINUED)", -0.90, 1.06, header_font)

local groups = {}
for group,_ in pairs(data.bas) do
    if type(group) == "number" and group >= 1 and group <= 999 then
        groups[#groups + 1] = group
    end
end
table.sort(groups)

local FIRST_GROUP_INDEX = 12
local PAGE_CAPACITY = 11
for index = FIRST_GROUP_INDEX, math.min(#groups, FIRST_GROUP_INDEX + PAGE_CAPACITY - 1) do
    local group = groups[index]
    local preset = data.bas[group]
    local row = index - FIRST_GROUP_INDEX
    local top = 0.91 - (row * 0.185)

    add_text(
        "fr31_page_2_bas_name_" .. group,
        string.format("%03d  %s", group, string.upper(tostring(preset.name or "UNNAMED"))),
        -0.90,
        top,
        item_font
    )
    add_text(
        "fr31_page_2_bas_frequencies_" .. group,
        string.format(
            "A: %s  B: %s  C: %s  C2: %s  D: %s",
            format_frequency(preset.A),
            format_frequency(preset.B),
            format_frequency(preset.C),
            format_frequency(preset.C2),
            format_frequency(preset.D)
        ),
        -0.86,
        top - 0.075,
        detail_font
    )
end

if #groups < FIRST_GROUP_INDEX then
    add_text("fr31_page_2_bas_empty", "NO ADDITIONAL BAS GROUPS", -0.90, 0.91, item_font)
elseif #groups > FIRST_GROUP_INDEX + PAGE_CAPACITY - 1 then
    add_text("fr31_page_2_bas_overflow", "ADDITIONAL BAS GROUPS REQUIRE ANOTHER PAGE", -0.90, -1.35, detail_font)
end
