-- These gauges have one presentation owner. Native/local writers may still
-- update the source handles, but cannot overwrite a follower's received value.
local M = {}
M.names = {
    "QNH_x1K", "QNH_x100", "QNH_x10", "QNH_x1",
    "FR33_DIAL_100MHZ", "FR33_DIAL_10MHZ", "FR33_DIAL_1MHZ",
    "FR33_DIAL_100KHZ", "FR33_DIAL_10KHZ", "FR33_DIAL_1KHZ",
    "XPDR_DIGIT_1", "XPDR_DIGIT_2", "XPDR_DIGIT_3", "XPDR_DIGIT_4",
    "EFM_LEFT_THRUST_A", "EFM_RIGHT_THRUST_A",
}
M.selected = {}
-- Match mainpanel_init.lua's digit scales. Reapply the received presentation
-- each tick, also when a delta/heartbeat contains no changed digit values.
M.draw = {
    QNH_x1K={434,1}, QNH_x100={435,1}, QNH_x10={436,1}, QNH_x1={437,1},
    FR33_DIAL_100MHZ={950,1}, FR33_DIAL_10MHZ={951,1}, FR33_DIAL_1MHZ={952,1},
    FR33_DIAL_100KHZ={953,1}, FR33_DIAL_10KHZ={954,1}, FR33_DIAL_1KHZ={955,1},
    XPDR_DIGIT_1={200,7}, XPDR_DIGIT_2={201,7}, XPDR_DIGIT_3={202,7}, XPDR_DIGIT_4={203,7},
}
for _, name in ipairs(M.names) do M.selected[name] = true end
function M.parameter(name)
    return M.selected[name] and ("MC_PANEL_" .. name) or name
end
function M.new()
    local sources, outputs, received = {}, {}, {}
    for _, name in ipairs(M.names) do
        sources[name] = get_param_handle(name)
        outputs[name] = get_param_handle(M.parameter(name))
    end
    return {
        accept = function(name, value)
            if M.selected[name] then received[name] = value end
        end,
        update = function(follower)
            for _, name in ipairs(M.names) do
                local value = follower and received[name] or sources[name]:get()
                -- Freeze on link loss; a full snapshot replaces all cached values.
                if type(value) == "number" and value == value and math.abs(value) < math.huge then
                    if outputs[name]:get() ~= value then outputs[name]:set(value) end
                    if follower and received[name] ~= nil then
                        -- The seat API need not be ready when mainpanel_init runs.
                        -- Keep its original source gauge correct as well as the alias.
                        if sources[name]:get() ~= value then sources[name]:set(value) end
                        local draw = M.draw[name]
                        if draw and type(set_cockpit_draw_argument_value) == "function" then
                            set_cockpit_draw_argument_value(draw[1], value / draw[2])
                        end
                    end
                end
            end
        end,
    }
end
return M
