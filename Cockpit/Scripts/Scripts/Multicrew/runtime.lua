-- Installed only on shared system devices. Local seat equipment is not wrapped.
local M = {}
function M.install(id)
    local enabled = get_param_handle("MC_ENABLED")
    local role = get_param_handle("MC_ROLE")
    local connected = get_param_handle("MC_CONNECTED")
    local tx = get_param_handle("MC_TX_" .. id)
    local rx = get_param_handle("MC_RX_" .. id)
    local protocol = dofile(LockOn_Options.script_path .. "../../Multicrew/protocol.lua")
    local schema = dofile(LockOn_Options.script_path .. "../../Multicrew/schema.lua")
    local original_command, original_update = SetCommand, update
    local held, replaying = {}, false
    local releases = schema.release[id] or {}
    local function execute(command, value)
        if schema.native[id] and schema.native[id][command] then
            replaying = true
            dispatch_action(nil, command, value)
            replaying = false
        elseif original_command then original_command(command, value) end
    end
    if id == 9 then
        -- These cockpit switches are consumed by the EFM, not HUD Lua logic.
        for command in pairs(schema.native[9]) do GetSelf():listen_command(command) end
    end
    tx:set(""); rx:set("")
    local function follower() return enabled:get() == 1 and role:get() == 1 end
    function SetCommand(command, value)
        if follower() then
            if get_param_handle("MC_READ_ONLY"):get() == 1 then return end
            -- No speculative toggles and no replay after an offline interval.
            if connected:get() ~= 1 or not schema.allowed[id][command] then return end
            value = value or 0
            if not protocol.finite(value) then return end
            local queued = tx:get()
            if type(queued) ~= "string" then queued = "" end
            if #protocol.split(queued, ",") >= protocol.MAX_COMMANDS then
                get_param_handle("MC_OVERFLOW"):set(1)
                connected:set(0)
                return
            end
            local row = id .. ":" .. command .. ":" .. string.format("%.17g", value)
            tx:set(queued == "" and row or queued .. "," .. row)
            return
        end
        if not replaying then
            held[command] = nil
            if releases[command] then held[releases[command][1]] = nil end
        end
        if original_command then return original_command(command, value) end
    end
    function update()
        if follower() then return end
        if connected:get() ~= 1 then
            for command, value in pairs(held) do execute(command, value) end
            held = {}
        end
        local queued = rx:get()
        if type(queued) == "string" and queued ~= "" then
            rx:set("") -- consume before executing; dispatch can re-enter a device
            local commands = protocol.decode_commands(queued, schema.allowed)
            if commands and original_command then
                for _, c in ipairs(commands) do
                    if c[1] == id then
                        held[c[2]] = nil
                        local release = releases[c[2]]
                        if release and (release[1] ~= c[2] or c[3] > release[2]) then
                            held[release[1]] = release[2]
                        end
                        execute(c[2], c[3])
                    end
                end
            end
        end
        if original_update then return original_update() end
    end
end
return M
