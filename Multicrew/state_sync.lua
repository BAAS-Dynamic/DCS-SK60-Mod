-- Lossless, ordered panel deltas. Prepare/commit follows successful file publish.
local P = dofile(LockOn_Options.script_path .. "../../Multicrew/protocol.lua")
local M = {}
function M.sender(count)
    local cache, revision, last_full, last_sent = {}, 0, -100, -100
    local obj = {}
    function obj.reset() cache = {}; revision = 0; last_full = -100; last_sent = -100 end
    function obj.prepare(values, now)
        if #values ~= count then return nil end
        local changed, n = {}, 0
        for i = 1, count do
            local v = values[i]
            if not P.finite(v) and not (type(v) == "string" and #v <= 1024) then return nil end
            if cache[i] ~= v then changed[i] = v; n = n + 1 end
        end
        local full = revision == 0 or now - last_full >= 5 or n > count * 0.6
        if not full and n == 0 and now - last_sent < 0.5 then return nil end
        local kind = full and "F" or (n > 0 and "D" or "H")
        local next_revision = revision + (kind == "H" and 0 or 1)
        local data = full and P.encode_values(values) or (kind == "H" and "" or P.encode_delta(changed, count))
        if not data then return nil end
        return {payload = "S:" .. kind .. "|" .. next_revision .. "|" .. data,
            values = full and values or changed, full = full, revision = next_revision, time = now}
    end
    function obj.commit(frame)
        for i,v in pairs(frame.values) do cache[i] = v end
        revision = frame.revision; last_sent = frame.time
        if frame.full then last_full = frame.time end
    end
    return obj
end
function M.receiver(count)
    local revision, ready = 0, false
    local obj = {}
    function obj.reset() revision = 0; ready = false end
    function obj.decode(body)
        local kind, raw_revision, data = body:match("^([FDH])|(%d+)|(.*)$")
        local incoming = raw_revision and P.integer(raw_revision, 1, 2^52)
        if not incoming then return nil end
        if kind == "F" then
            if ready and incoming <= revision then return nil end
            local values = P.decode_values(data, count)
            if not values then return nil end
            revision = incoming; ready = true; return values
        end
        if not ready then return nil end
        if kind == "H" then
            if incoming ~= revision or data ~= "" then ready = false; return nil end
            return {}
        end
        if incoming ~= revision + 1 then ready = false; return nil end
        local values = P.decode_delta(data, count)
        if not values or next(values) == nil then ready = false; return nil end
        revision = incoming; return values
    end
    return obj
end
return M
