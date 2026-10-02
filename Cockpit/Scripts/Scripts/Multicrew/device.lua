local root = LockOn_Options.script_path .. "../../Multicrew/"
local P = dofile(root .. "protocol.lua")
local schema = dofile(root .. "schema.lua")
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
    read_only:set(config.one_way == true and 1 or 0)
    clear_queues(); status(0)
end
local function apply_state(data)
    local values = P.decode_values(data, #handles)
    if not values then return false end
    for i, value in ipairs(values) do handles[i]:set(value) end
    -- These controls use direct cockpit draw calls, not parameter gauges.
    if type(set_cockpit_draw_argument_value) == "function" then
        local direct = {[735]="PTN_735", [736]="RNAV_EDIT_SEGMENT_CARD", [718]="PTN_718",
            [345]="HSI_TACAN", [346]="HSI_ADF", [752]="HSI_COURSE_NEEDLE", [753]="HSI_HEADING_BUG", [742]="HSI_CDI"}
        for argument, name in pairs(direct) do set_cockpit_draw_argument_value(argument, get_param_handle(name):get()) end
        for i = 1, 4 do
            local digit = get_param_handle("XPDR_DIGIT_" .. i):get()
            set_cockpit_draw_argument_value(199 + i, digit / 7)
            set_cockpit_draw_argument_value(204 + i, 0)
        end
        set_cockpit_draw_argument_value(204, get_param_handle("XPDR_POWER"):get())
        set_cockpit_draw_argument_value(209, get_param_handle("XPDR_IDENT"):get())
        local names = {"FR33_DIAL_100MHZ", "FR33_DIAL_10MHZ", "FR33_DIAL_1MHZ", "FR33_DIAL_100KHZ", "FR33_DIAL_10KHZ", "FR33_DIAL_1KHZ"}
        for i, name in ipairs(names) do set_cockpit_draw_argument_value(949 + i, get_param_handle(name):get()) end
    end
    -- Native radio communicators are local objects, not transferable pointers.
    -- SRS reads the copied FR31/FR33 parameters; DCS radios also need tuning.
    for _, radio in ipairs({{6, "FR31_FREQ_HZ", 225e6, 399.975e6}, {24, "FR33_FREQ_HZ", 118e6, 135.975e6}}) do
        local frequency = get_param_handle(radio[2]):get()
        if P.finite(frequency) and frequency >= radio[3] and frequency <= radio[4] then
            pcall(function() GetDevice(radio[1]):set_frequency(frequency) end)
        end
    end
    return true
end
local function apply_commands(data)
    local commands = P.decode_commands(data, schema.allowed)
    if not commands then return false end
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
                elseif payload:sub(1, 2) == "S:" and apply_state(payload:sub(3)) then last_snapshot = time; status(1)
                end
            end
        end
    end
    if time - last_receive > 2 then peer_ready = false; clear_queues(); status(0) end
    if role:get() == 1 and time - last_snapshot > 2 then clear_queues(); status(0) end
    if pending then
        -- Update the receive acknowledgement without changing the outstanding body.
        local packet = P.read(folder .. "cockpit_tx.dat")
        if packet and packet.session == session then
            P.write(folder .. "cockpit_tx.dat", P.pack(session, seq, ack, packet.body))
        end
        return
    end
    local payload, consumed = "P", {}
    if get_param_handle("MC_OVERFLOW"):get() == 1 then
        status(0); clear_queues(); payload = "X" -- reset link to release held controls
    elseif role:get() == 0 then
        local values = {}
        for i, h in ipairs(handles) do values[i] = h:get() end
        local body = P.encode_values(values)
        if body then payload = "S:" .. body end
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
    seq = seq + 1
    local body = role:get() .. "|" .. schema.fingerprint .. "|" .. generation .. "|" .. P.hex(payload)
    pending = P.write(folder .. "cockpit_tx.dat", P.pack(session, seq, ack, body))
    if pending then for _, q in pairs(consumed) do q:set("") end end
end
