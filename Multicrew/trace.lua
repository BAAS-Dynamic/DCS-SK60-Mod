-- Local, bounded diagnostics. No network addresses, credentials or payloads.
local M = {}
function M.new(name, limit)
    local path, count = nil, 0
    limit = limit or 256
    if type(io) == "table" and type(io.open) == "function" then
        pcall(function()
            local fs = lfs
            if type(fs) ~= "table" and type(require) == "function" then fs = require("lfs") end
            if type(fs) ~= "table" then return end
            local folder = fs.writedir() .. "Logs/SK60Multicrew/"
            fs.mkdir(folder)
            path = folder .. "trace-" .. name .. ".txt"
            local file = io.open(path, "w")
            if file then file:close() else path = nil end
        end)
    end
    return function(event, ...)
        if not path or count >= limit then return end
        count = count + 1
        local fields = {tostring(count), tostring(event)}
        if type(get_absolute_model_time) == "function" then
            local ok, now = pcall(get_absolute_model_time)
            if ok then fields[#fields+1] = "time=" .. tostring(now) end
        end
        for _, value in ipairs({...}) do
            fields[#fields+1] = tostring(value):gsub("[\r\n\t]", " "):sub(1,120)
        end
        local row = table.concat(fields, "\t"):sub(1,1000) .. "\n"
        local ok = pcall(function()
            local file = io.open(path, "a")
            if not file then return end
            file:write(row); file:close()
        end)
        if not ok then path = nil end
    end
end
return M
