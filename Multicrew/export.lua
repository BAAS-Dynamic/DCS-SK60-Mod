-- Optional Export.lua extension. Uses only the local cockpit's file mailbox.
-- Does not patch MissionScripting.lua or execute network-provided code.
if SK60MulticrewExport then return end
SK60MulticrewExport = true
local ok, config = pcall(dofile, lfs.writedir() .. "Config/SK60Multicrew.lua")
if not ok or type(config) ~= "table" or config.enabled ~= true then return end
assert(type(config.mod_path) == "string", "SK60 multicrew: mod_path is required")
local P = dofile(config.mod_path .. "/Multicrew/protocol.lua")
package.path = package.path .. ";./LuaSocket/?.lua"
package.cpath = package.cpath .. ";./LuaSocket/?.dll"
local socket = require("socket")
assert(type(config.host) == "string" and config.host:match("^%d+%.%d+%.%d+%.%d+$"), "SK60 multicrew: use a numeric IPv4 relay address")
assert(P.integer(config.port, 1, 65535), "SK60 multicrew: invalid port")
assert(type(config.token) == "string" and #config.token >= 24 and not config.token:find("REPLACE"), "SK60 multicrew: set a shared secret")
assert(type(config.room) == "string" and #config.room > 0 and #config.room <= 80, "SK60 multicrew: invalid room")
local folder = lfs.writedir() .. "Logs/SK60Multicrew/"
lfs.mkdir(folder)
local tcp, session, unit, seat, schema, connecting
local generation, ready, tx, partial, received = "0", false, "", "", {}
local tx_seq, out_ack, in_seq, in_ack, mailbox = 0, 0, 0, 0, nil
local net_seq = 0
local last_rx, next_connect, last_write, next_step, last_ping = 0, 0, 0, 0, 0
local last_mailbox, last_new_mailbox = nil, -100
local function disconnect(now)
    if tcp then tcp:close() end
    tcp = nil; ready = false; connecting = false
    tx = ""; partial = ""; received = {}; generation = "0"
    mailbox = nil; last_mailbox = nil; next_connect = now + 2
end
local function queue(line)
    if #tx + #line > 1048576 then return false end
    tx = tx .. line .. "\n"
    return true
end
local function write_mailbox(now)
    if not session then return end
    if mailbox == nil or (in_ack >= in_seq and (#received > 0 or not config.optimized or now - last_new_mailbox >= 0.25)) then
        in_seq = in_seq + 1
        local payload = #received > 0 and table.remove(received, 1) or "P"
        mailbox = generation .. "|" .. (ready and "1" or "0") .. "|" .. P.hex(payload)
        last_new_mailbox = now
    end
    -- Ack updates are independent of the mailbox's data sequence.
    local packet = P.pack(session, in_seq, out_ack, mailbox)
    if not config.optimized or packet ~= last_mailbox or now - last_write >= 0.25 then
        if P.write(folder .. "hook_rx.dat", packet) then last_mailbox = packet; last_write = now end
    end
end
local function start_connection(now)
    tcp = socket.tcp(); tcp:settimeout(0)
    local success, err = tcp:connect(config.host, config.port)
    if not success and err ~= "timeout" and err ~= "Operation already in progress" then disconnect(now); return end
    connecting = true
end
local function step()
    local now = socket.gettime()
    if now < next_step then return end
    next_step = now + 0.025
    local aircraft = LoGetSelfData()
    if not aircraft or (aircraft.Name ~= "SK-60" and aircraft.Name ~= "SK-60B") then
        disconnect(now); session = nil; return
    end
    local output = P.read(folder .. "cockpit_tx.dat")
    if not output then return end
    local p = P.split(output.body, "|")
    if #p ~= 4 or (p[1] ~= "0" and p[1] ~= "1") or not p[2]:match("^[0-9a-f]+$") then return end
    local current_unit = tostring(LoGetPlayerPlaneId())
    if output.session ~= session or current_unit ~= unit or p[1] ~= seat then
        disconnect(now)
        session, unit, seat, schema = output.session, current_unit, p[1], p[2]
        tx_seq = 0; out_ack = 0; in_seq = 0; in_ack = 0
    end
    in_ack = output.ack
    if not tcp and now >= next_connect then start_connection(now) end
    if tcp and connecting then
        if tcp:getpeername() then
            connecting = false; last_rx = now
            queue(table.concat({"H", P.hex(config.room), P.hex(config.token), seat, P.hex(unit), session, schema}, "|"))
        elseif now - next_connect > 5 then disconnect(now) end
    end
    if tcp and not connecting then
        if now - last_ping > 1 then queue("K"); last_ping = now end
        -- Read bounded work. LuaSocket partial lines must be retained.
        for _ = 1, 32 do
            local line, err, rest = tcp:receive("*l")
            local chunk = line or rest or ""
            partial = partial .. chunk
            if #partial > 2 * P.MAX_BYTES + 256 then disconnect(now); break end
            if not line then
                if err == "closed" then disconnect(now) end
                break
            end
            local parts = P.split(partial, "|"); partial = ""; last_rx = now
            if parts[1] == "R" and #parts == 2 and parts[2]:match("^[%w_-]+$") then
                generation = parts[2]; ready = true; received = {}; mailbox = nil; net_seq = 0
            elseif parts[1] == "D" and #parts == 4 and parts[2] == generation and ready then
                local data = P.unhex(parts[4])
                local number = P.integer(parts[3], 1, 2^52)
                if not data or not number or #data > P.MAX_BYTES then disconnect(now); break end
                if number > net_seq then
                    net_seq = number
                    if data:match("^S:[FDH]|") then
                        -- Deltas depend on earlier frames. Never coalesce them:
                        -- reset under backpressure so a fresh full state follows.
                        if #received >= 8 then disconnect(now); break end
                        received[#received + 1] = data
                    elseif data:sub(1, 2) == "S:" then
                        -- Latest full state replaces older waiting snapshots. Commands
                        -- are never coalesced; their ordering has side effects.
                        received = {data}
                    elseif data ~= "P" or #received == 0 then
                        if #received >= 64 then disconnect(now); break end
                        received[#received + 1] = data
                    end
                end
            elseif parts[1] == "W" then
                ready = false; generation = "0"; received = {}; mailbox = nil
            elseif parts[1] == "E" then disconnect(now); break
            end
        end
        if tcp and output.seq > out_ack then
            local payload = P.unhex(p[4])
            if payload and #payload <= P.MAX_BYTES then
                if payload == "X" then disconnect(now) end
                -- Old-generation commands are discarded, never replayed after reconnect.
                if ready and ((payload:sub(1, 2) ~= "C:" and not config.optimized) or p[3] == generation) then
                    tx_seq = tx_seq + 1
                    if not queue("D|" .. generation .. "|" .. tx_seq .. "|" .. P.hex(payload)) then disconnect(now) end
                end
                out_ack = output.seq
            end
        elseif not tcp then out_ack = output.seq end
        if tcp and #tx > 0 then
            local sent, err, last = tcp:send(tx)
            local count = sent or last or 0
            tx = tx:sub(count + 1)
            if err == "closed" then disconnect(now) end
        end
        if tcp and now - last_rx > 10 then disconnect(now) end
    else
        -- Keep cockpit alive while disconnected, but drop requests from this interval.
        out_ack = output.seq
    end
    write_mailbox(now)
end
local previous_frame, previous_stop = LuaExportAfterNextFrame, LuaExportStop
local last_previous_error = -100
function LuaExportAfterNextFrame()
    if previous_frame then
        local success = pcall(previous_frame)
        local now = socket.gettime()
        if not success and now - last_previous_error > 30 then
            last_previous_error = now
            if log and log.write then log.write("SK60Multicrew", log.ERROR, "Another Export AfterNextFrame callback failed; SK60 processing continues") end
        end
    end
    local success, err = pcall(step)
    if not success then
        disconnect(socket.gettime())
        if log and log.write then log.write("SK60Multicrew", log.ERROR, tostring(err)) end
    end
end
function LuaExportStop()
    disconnect(socket.gettime()); session = nil
    if previous_stop then pcall(previous_stop) end
end
