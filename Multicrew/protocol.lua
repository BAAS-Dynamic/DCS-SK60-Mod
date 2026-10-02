-- Data only. Never evaluate received Lua. Compatible with Lua 5.1.
local M = { VERSION = "SK60MC1", MAX_BYTES = 262144, MAX_COMMANDS = 64 }
function M.finite(n)
    return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
end
function M.hex(s)
    return (s:gsub(".", function(c) return string.format("%02x", string.byte(c)) end))
end
function M.unhex(s)
    if type(s) ~= "string" or #s % 2 ~= 0 or s:find("[^0-9a-f]") then return nil end
    return (s:gsub("..", function(c) return string.char(tonumber(c, 16)) end))
end
function M.split(s, separator)
    local out, start = {}, 1
    while true do
        local pos = s:find(separator, start, true)
        if not pos then out[#out + 1] = s:sub(start); return out end
        out[#out + 1] = s:sub(start, pos - 1)
        start = pos + #separator
    end
end
function M.integer(s, minimum, maximum)
    local n = tonumber(s)
    if not M.finite(n) or n % 1 ~= 0 or n < minimum or n > maximum then return nil end
    return n
end
-- A mailbox is self-delimiting, so a concurrent partial file read is discarded.
function M.pack(session, seq, ack, body)
    assert(session:match("^[%w_-]+$") and #body <= M.MAX_BYTES)
    return table.concat({M.VERSION, session, seq, ack, #body}, "|") .. "\n" .. body .. "\nEND"
end
function M.unpack(data)
    if type(data) ~= "string" or #data > M.MAX_BYTES + 160 then return nil end
    local header, body = data:match("^([^\n]+)\n(.*)\nEND$")
    if not header then return nil end
    local p = M.split(header, "|")
    if #p ~= 5 or p[1] ~= M.VERSION or not p[2]:match("^[%w_-]+$") or #p[2] > 80 then return nil end
    local seq, ack, size = M.integer(p[3], 1, 2^52), M.integer(p[4], 0, 2^52), M.integer(p[5], 0, M.MAX_BYTES)
    if not seq or not ack or size ~= #body then return nil end
    return {session = p[2], seq = seq, ack = ack, body = body}
end
function M.read(path)
    local file = io.open(path, "rb")
    if not file then return nil end
    local data = file:read(M.MAX_BYTES + 161)
    file:close()
    return M.unpack(data)
end
function M.write(path, packet)
    local temporary = path .. ".tmp"
    local file = io.open(temporary, "wb")
    if not file then return false end
    local ok, write_error = file:write(packet)
    local closed, close_error = file:close()
    if ok == false or closed == false or write_error or close_error then return false end
    -- DCS file wrappers can return no success value. Do not mistake that for
    -- failure: verify the closed temporary file before publishing it.
    if ok == nil or closed == nil then
        local check = io.open(temporary, "rb")
        if not check then return false end
        local data = check:read(M.MAX_BYTES + 161)
        check:close()
        if data ~= packet then return false end
    end
    -- Lua 5.1 on Windows cannot rename over an existing file. Publish a fully
    -- closed file, with a brief missing-file window rather than partial contents.
    -- Each mailbox has exactly one writer; a failed rename is retried next tick.
    if type(os.remove) ~= "function" or type(os.rename) ~= "function" then return false end
    pcall(os.remove, path)
    local success, result = pcall(os.rename, temporary, path)
    if not success then return false end
    if result then return true end
    -- Some wrappers also omit rename's return value; verify the destination.
    local published = io.open(path, "rb")
    if not published then return false end
    local data = published:read(M.MAX_BYTES + 161)
    published:close()
    return data == packet
end
function M.encode_values(values)
    local rows = {}
    for id, value in ipairs(values) do
        if M.finite(value) then rows[#rows + 1] = id .. ":n:" .. string.format("%.17g", value)
        elseif type(value) == "string" and #value <= 1024 then rows[#rows + 1] = id .. ":s:" .. M.hex(value)
        else return nil end
    end
    return table.concat(rows, ",")
end
function M.decode_values(body, count)
    local rows, values = M.split(body, ","), {}
    if #rows ~= count then return nil end
    for i, row in ipairs(rows) do
        local p = M.split(row, ":")
        if #p ~= 3 or tonumber(p[1]) ~= i then return nil end
        local value
        if p[2] == "n" then value = tonumber(p[3]); if not M.finite(value) then return nil end
        elseif p[2] == "s" and #p[3] <= 2048 then value = M.unhex(p[3])
        end
        if value == nil then return nil end
        values[i] = value
    end
    return values
end
function M.decode_commands(body, allowed)
    local out = {}
    if body == "" then return out end
    local rows = M.split(body, ",")
    if #rows > M.MAX_COMMANDS then return nil end
    for _, row in ipairs(rows) do
        local p = M.split(row, ":")
        local device, command, value = tonumber(p[1]), tonumber(p[2]), tonumber(p[3])
        if #p ~= 3 or not allowed[device] or not allowed[device][command] or not M.finite(value) or math.abs(value) > 1e9 then return nil end
        out[#out + 1] = {device, command, value}
    end
    return out
end
function M.encode_delta(values, count)
    local rows = {}
    for id = 1, count do
        local value = values[id]
        if value ~= nil then
            if M.finite(value) then rows[#rows+1] = id .. ":n:" .. string.format("%.17g", value)
            elseif type(value) == "string" and #value <= 1024 then rows[#rows+1] = id .. ":s:" .. M.hex(value)
            else return nil end
        end
    end
    return table.concat(rows, ",")
end
function M.decode_delta(body, count)
    local values, previous = {}, 0
    if body == "" then return values end
    for _, row in ipairs(M.split(body, ",")) do
        local parts = M.split(row, ":")
        local id = M.integer(parts[1], 1, count)
        if #parts ~= 3 or not id or id <= previous then return nil end
        local value
        if parts[2] == "n" then value = tonumber(parts[3]); if not M.finite(value) then return nil end
        elseif parts[2] == "s" and #parts[3] <= 2048 then value = M.unhex(parts[3]) end
        if value == nil then return nil end
        values[id] = value; previous = id
    end
    return values
end
return M
