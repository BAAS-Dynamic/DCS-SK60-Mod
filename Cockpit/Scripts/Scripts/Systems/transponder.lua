dofile(LockOn_Options.script_path .. "command_defs.lua")

local dev = GetSelf()
make_default_activity(0.05)

local DIGIT_DRAW_ARGS = {200, 201, 202, 203}
local DIGIT_CLICK_ARGS = {205, 206, 207, 208}
local DIGIT_COMMANDS = {
    [Keys.TransponderDigit1] = 1,
    [Keys.TransponderDigit2] = 2,
    [Keys.TransponderDigit3] = 3,
    [Keys.TransponderDigit4] = 4,
}

local power = 0
local digits = {7, 0, 0, 0}
local ident = 0

local power_param = get_param_handle("XPDR_POWER")
local code_param = get_param_handle("XPDR_MODE_A_CODE")
local ident_param = get_param_handle("XPDR_IDENT")
local digit_params = {
    get_param_handle("XPDR_DIGIT_1"),
    get_param_handle("XPDR_DIGIT_2"),
    get_param_handle("XPDR_DIGIT_3"),
    get_param_handle("XPDR_DIGIT_4"),
}

local function set_cockpit_argument(argument, value)
    -- Transponder arguments belong to the cockpit EDM. Do not mirror them to
    -- the aircraft EDM: external damage arguments use some of the same
    -- numbers (notably 200-203 for the wings).
    if type(set_cockpit_draw_argument_value) == "function" then
        set_cockpit_draw_argument_value(argument, value)
    end
end

local function publish_state()
    power_param:set(power)
    code_param:set(digits[1] * 1000 + digits[2] * 100 + digits[3] * 10 + digits[4])
    ident_param:set(ident)
    set_cockpit_argument(204, power)
    set_cockpit_argument(209, ident)

    -- The model should animate each digit roll from 0.0 = 0 to 1.0 = 7.
    for index, argument in ipairs(DIGIT_DRAW_ARGS) do
        digit_params[index]:set(digits[index])
        set_cockpit_argument(argument, digits[index] / 7)
    end

    -- Digit click connectors are spring-centred so repeated wheel events never
    -- get stuck at an animation-argument limit.
    for _, argument in ipairs(DIGIT_CLICK_ARGS) do
        set_cockpit_argument(argument, 0)
    end
end

local function digit_step(value)
    if value > 0 then
        return 1
    elseif value < 0 then
        return -1
    end
    return 0
end

function post_initialize()
    dev:performClickableAction(Keys.TransponderPower, 0, true)
    publish_state()
end

function SetCommand(command, value)
    if command == Keys.TransponderPower then
        -- Treat either mouse button direction, or a key/button press, as one
        -- toggle. Ignore the centred initialization event.
        if value ~= 0 then
            power = 1 - power
        end
    elseif command == Keys.TransponderIdent then
        ident = value > 0.5 and 1 or 0
    else
        local digit_index = DIGIT_COMMANDS[command]
        if digit_index ~= nil then
            local step = digit_step(value)
            digits[digit_index] = (digits[digit_index] + step) % 8
        end
    end

    publish_state()
end

function update()
    publish_state()
end

dev:listen_command(Keys.TransponderPower)
dev:listen_command(Keys.TransponderDigit1)
dev:listen_command(Keys.TransponderDigit2)
dev:listen_command(Keys.TransponderDigit3)
dev:listen_command(Keys.TransponderDigit4)
dev:listen_command(Keys.TransponderIdent)

need_to_be_closed = false

-- SK60 shared cockpit integration
dofile(LockOn_Options.script_path .. "Multicrew/runtime.lua").install(26)
