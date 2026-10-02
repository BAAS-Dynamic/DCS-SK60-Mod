local root = LockOn_Options.script_path .. "../../Multicrew/"
local P = dofile(root .. "protocol.lua")
local schema = dofile(root .. "schema.lua")
local State = dofile(root .. "state_sync.lua")
local Display = dofile(root .. "display_contract.lua")
local Panel = dofile(root .. "panel_state.lua")
local panel = Panel.new()
local record = dofile(root .. "trace.lua").new("panel", 400)
record("loaded", schema.fingerprint, LockOn_Options.script_path)
local trace_ticks = 0
local enabled, role, connected = get_param_handle("MC_ENABLED"), get_param_handle("MC_ROLE"), get_param_handle("MC_CONNECTED")
enabled:set(0); role:set(-1); connected:set(0)
local read_only = get_param_handle("MC_READ_ONLY")
read_only:set(0)
get_param_handle("MC_OVERFLOW"):set(0)
make_default_activity(0.05)
need_to_be_closed = false
local handles, queues = {}, {}
for i, name in ipairs(schema.parameters) do handles[i] = get_param_handle(name) end
for id in pairs(schema.allowed) do
    queues[id] = {tx = get_param_handle("MC_TX_" .. id), rx = get_param_handle("MC_RX_" .. id)}
end
local session, folder, seq, ack, last_rx, generation = nil, nil, 0, 0, 0, "0"
local pending, last_receive, last_snapshot, time, peer_ready = false, -100, -100, 0, false
local last_status = nil
local applied_revision = nil
local optimized, published_ack, last_body, last_idle = false, -1, nil, -100
local sender, receiver = State.sender(#handles), State.receiver(#handles)
local ids, radio_cache = {}, {}
for i, name in ipairs(schema.parameters) do ids[name] = i end
local function clear_queues()
    for _, q in pairs(queues) do q.tx:set(""); q.rx:set("") end
end
local function status(value)
    connected:set(value)
    if value == 1 then enabled:set(1) end
    if value ~= last_status then
        last_status = value
        if type(print_message_to_user) == "function" then
            print_message_to_user(value == 1 and "SK60 multicrew: shared cockpit connected" or
                "SK60 multicrew: waiting for peer; pilot retains control")
        end
    end
end
function post_initialize()
    if type(lfs) ~= "table" and type(require) == "function" then
        local ok, module = pcall(require, "lfs")
        if ok then lfs = module end
    end
    if type(lfs) ~= "table" or type(io) ~= "table" or type(get_player_crew_index) ~= "function" then return end
    local ok, config = pcall(dofile, lfs.writedir() .. "Config/SK60Multicrew.lua")
    if not ok or type(config) ~= "table" or config.enabled ~= true then return end
    local seat = get_player_crew_index()
    if seat ~= 0 and seat ~= 1 then return end
    folder = lfs.writedir() .. "Logs/SK60Multicrew/"
    lfs.mkdir(folder)
    -- Local incarnation, never a credential. Prevent stale files from another sortie.
    session = tostring(os.time()) .. "_" .. tostring({}):gsub("[^%w]", "")
    role:set(seat); enabled:set(config.auto_server == true and 0 or 1)
    record("initialized", "seat=" .. tostring(seat), "optimized=" .. tostring(config.optimized))
    read_only:set(config.one_way == true and 1 or 0)
    optimized = config.optimized == true
    clear_queues(); status(0)
end
local function apply_state(data, decoded)
    local values = decoded or P.decode_values(data, #handles)
    if not values then return false end
    -- Validate the whole frame before enabling or changing any display.
    local checked = {}
    for i, value in pairs(values) do
        value = Display.normalize(schema.parameters[i], value)
        if value == nil then return false end
        if Panel.selected[schema.parameters[i]] and not P.finite(value) then return false end
        checked[i] = value
    end
    values = checked
    for i, value in pairs(values) do
        if handles[i]:get() ~= value then handles[i]:set(value) end
        panel.accept(schema.parameters[i], value)
        if schema.parameters[i] == "FR33_FREQ_HZ" or schema.parameters[i] == "XPDR_MODE_A_CODE" then
            record("received", schema.parameters[i], value)
        end
    end
    local function touched(name) return values[ids[name]] ~= nil end
    -- These controls use direct cockpit draw calls, not parameter gauges.
    if type(set_cockpit_draw_argument_value) == "function" then
        local direct = {[735]="PTN_735", [736]="RNAV_EDIT_SEGMENT_CARD", [718]="PTN_718",
            [345]="HSI_TACAN", [346]="HSI_ADF", [752]="HSI_COURSE_NEEDLE", [753]="HSI_HEADING_BUG", [742]="HSI_CDI"}
        for argument, name in pairs(direct) do
            if touched(name) then set_cockpit_draw_argument_value(argument, get_param_handle(name):get()) end
        end
        for i = 1, 4 do
            if touched("XPDR_DIGIT_" .. i) then
                set_cockpit_draw_argument_value(204 + i, 0)
            end
        end
        if touched("XPDR_POWER") then set_cockpit_draw_argument_value(204, get_param_handle("XPDR_POWER"):get()) end
        if touched("XPDR_IDENT") then set_cockpit_draw_argument_value(209, get_param_handle("XPDR_IDENT"):get()) end
    end
    -- Native radio communicators are local objects, not transferable pointers.
    -- SRS reads the copied FR31/FR33 parameters; DCS radios also need tuning.
    -- The FR31 control head/SRS also support VHF, but its native ARC-164
    -- communicator must remain on UHF, matching Systems/fr31_radio.lua.
    for _, radio in ipairs({{6, "FR31_FREQ_HZ", 223e6, 407.975e6}, {24, "FR33_FREQ_HZ", 118e6, 135.975e6}}) do
        local frequency = get_param_handle(radio[2]):get()
        local in_band = P.finite(frequency) and frequency >= radio[3] and frequency <= radio[4]
        if touched(radio[2]) and radio_cache[radio[1]] ~= frequency and in_band then
            local ok = pcall(function() GetDevice(radio[1]):set_frequency(frequency) end)
            if ok then radio_cache[radio[1]] = frequency end
        end
    end
    return true
end
local function apply_commands(data)
    local commands = P.decode_commands(data, schema.copilot_allowed)
    if not commands then return false end
    for _, c in ipairs(commands) do if math.abs(c[3]) > 1 then return false end end
    -- Preserve ordering within each system; do not overwrite an unconsumed batch.
    for id, q in pairs(queues) do
        local rows, current = {}, q.rx:get()
        if type(current) == "string" and current ~= "" then rows[1] = current end
        for _, c in ipairs(commands) do
            if c[1] == id then rows[#rows + 1] = id .. ":" .. c[2] .. ":" .. string.format("%.17g", c[3]) end
        end
        local joined = table.concat(rows, ",")
        if joined ~= "" and #P.split(joined, ",") > P.MAX_COMMANDS then return false end
    end
    for _, c in ipairs(commands) do
        local q = queues[c[1]].rx
        local old = q:get(); if type(old) ~= "string" then old = "" end
        local row = c[1] .. ":" .. c[2] .. ":" .. string.format("%.17g", c[3])
        q:set(old == "" and row or old .. "," .. row)
    end
    return true
end
function update()
    if connected:get() == 1 then trace_ticks = trace_ticks + 1 end
    -- Observe BEFORE applying the receive buffer, so competing writes remain visible.
    if connected:get() == 1 and trace_ticks % 20 == 0 then
        for _, item in ipairs({{"FR33_DIAL_1MHZ",952}, {"XPDR_DIGIT_1",200}}) do
            local actual = "unavailable"
            if type(get_cockpit_draw_argument_value) == "function" then
                local ok, value = pcall(get_cockpit_draw_argument_value, item[2])
                if ok then actual = value end
            end
            record("display", item[1], "source=" .. tostring(get_param_handle(item[1]):get()),
                "buffer=" .. tostring(get_param_handle(Panel.parameter(item[1])):get()),
                "draw=" .. tostring(actual), "seat=" .. tostring(role:get()),
                "connected=" .. tostring(connected:get()))
        end
    end
    panel.update(enabled:get() == 1 and role:get() == 1)
    if not session then return end
    time = time + 0.05
    -- A seat change needs a new sortie/session; never silently become the master.
    if get_player_crew_index() ~= role:get() then status(0); clear_queues(); return end
    local input = P.read(folder .. "hook_rx.dat")
    if input and input.session == session then
        if input.ack == seq then pending = false end
        if input.seq > last_rx then
            local parts = P.split(input.body, "|")
            local payload = #parts == 3 and P.unhex(parts[3]) or nil
            if payload and parts[1]:match("^[%w_-]+$") and (parts[2] == "0" or parts[2] == "1") then
                last_rx = input.seq; ack = input.seq; last_receive = time
                if generation ~= parts[1] then
                    generation = parts[1]; clear_queues(); status(0)
                    sender.reset(); receiver.reset(); radio_cache = {}; applied_revision = nil
                    get_param_handle("MC_OVERFLOW"):set(0)
                end
                peer_ready = parts[2] == "1"
                if not peer_ready then clear_queues(); status(0)
                elseif role:get() == 0 then
                    if payload == "P" or (payload:sub(1, 2) == "C:" and apply_commands(payload:sub(3))) then
                        status(1)
                    elseif payload:sub(1, 2) == "C:" then
                        status(0); get_param_handle("MC_OVERFLOW"):set(1)
                    end
                elseif payload:sub(1, 2) == "S:" then
                    local data = payload:sub(3)
                    local values = optimized and receiver.decode(data) or nil
                    if (not optimized or values) and apply_state(data, values) then
                        last_snapshot = time; status(1)
                        applied_revision = optimized and tonumber(data:match("^[FDH]|(%d+)|")) or nil
                    elseif optimized then
                        status(0); get_param_handle("MC_OVERFLOW"):set(1)
                    end
                end
            end
        end
    end
    if time - last_receive > 2 then peer_ready = false; clear_queues(); status(0) end
    if role:get() == 1 and time - last_snapshot > 2 then clear_queues(); status(0) end
    panel.update(enabled:get() == 1 and role:get() == 1)
    if pending then
        -- Update the receive acknowledgement without changing the outstanding body.
        local packet = P.read(folder .. "cockpit_tx.dat")
        if packet and packet.session == session and (not optimized or published_ack ~= ack) then
            if P.write(folder .. "cockpit_tx.dat", P.pack(session, seq, ack, packet.body)) then published_ack = ack end
        end
        return
    end
    local payload, consumed = "P", {}
    local candidate = nil
    if get_param_handle("MC_OVERFLOW"):get() == 1 then
        status(0); clear_queues(); payload = "X" -- reset link to release held controls
    elseif role:get() == 0 then
        if not optimized or peer_ready then
            local values = {}
            for i, h in ipairs(handles) do
                local value = Display.normalize(schema.parameters[i], h:get())
                if value == nil then status(0); return end
                values[i] = value
            end
            if optimized then
                candidate = sender.prepare(values, time)
                payload = candidate and candidate.payload or nil
            else
                local body = P.encode_values(values)
                if body then payload = "S:" .. body end
            end
        end
    elseif connected:get() == 1 and read_only:get() ~= 1 then
        local rows, count = {}, 0
        for _, id in ipairs(schema.device_order) do
            local q = queues[id].tx
            local data = q:get()
            if type(data) == "string" and data ~= "" then
                local n = #P.split(data, ",")
                if count + n <= P.MAX_COMMANDS then rows[#rows + 1] = data; count = count + n; consumed[id] = q end
            end
        end
        if #rows > 0 then payload = "C:" .. table.concat(rows, ",") end
    end
    if optimized and payload == "P" and time - last_idle < 0.5 then payload = nil end
    if payload == "P" and role:get() == 1 and connected:get() == 1 and applied_revision then
        payload = "A:" .. applied_revision
    end
    if not payload then
        if last_body and published_ack ~= ack then
            if P.write(folder .. "cockpit_tx.dat", P.pack(session, seq, ack, last_body)) then published_ack = ack end
        end
        return
    end
    seq = seq + 1
    local body = role:get() .. "|" .. schema.fingerprint .. "|" .. generation .. "|" .. P.hex(payload)
    pending = P.write(folder .. "cockpit_tx.dat", P.pack(session, seq, ack, body))
    if pending then
        last_body = body; published_ack = ack
        if payload == "P" or payload:sub(1,2) == "A:" then last_idle = time end
        if candidate then sender.commit(candidate) end
        for _, q in pairs(consumed) do q:set("") end
    end
end
