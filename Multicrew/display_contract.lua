-- Reviewed display boundaries. Numeric-looking strings may become numbers in
-- DCS parameter handles, so the indicators must also have safe numeric formats.
local M = {}
M.text = {L_EADI_DISPLAY_TL1=true, L_EADI_DISPLAY_TL2=true,
    L_EADI_DISPLAY_BR1=true}
M.frequency = {RADIO_DSP_UPPER_TEXT=true, RADIO_DSP_LOWER_TEXT=true}
M.numeric = {LEADI_DIS_ENABLE=true, RADIO_DSP_ENABLE=true, ELEV_TRIM_DIGTAL=true}
function M.normalize(name, value)
    if M.text[name] then
        -- Zero is the uninitialised DCS handle value, not display text.
        if type(value) == "number" and value == 0 then return " " end
        if type(value) ~= "string" then return nil end
        if #value > 1024 or value:find("%z") then return nil end
        if tonumber(value) then return " " end
    elseif M.frequency[name] then
        if type(value) == "string" then
            if #value > 1024 or value:find("%z") then return nil end
            -- Canonicalise before the Lua setter does so implicitly. The radio
            -- indicator uses %.3f for numbers and %s for text (editing marks).
            value = tonumber(value) or value
        elseif type(value) ~= "number" then return nil end
    elseif M.numeric[name] then
        if type(value) ~= "number" then return nil end
    end
    if type(value) == "number" and (value ~= value or math.abs(value) == math.huge) then return nil end
    return value
end
return M
