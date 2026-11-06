-- Local menu input only: do not route this through multicrew or SRS PTT.
local M = {}

function M.install()
    local menu_command = 1172
    local request = get_param_handle("FR31_MENU_REQUEST")
    local result = get_param_handle("FR31_MENU_RESULT")
    local old_command, old_update = SetCommand, update
    local waiting = false
    local elapsed = 0

    local function diagnostic(message)
        if log and log.write then
            log.write("SK60RadioMenu", log.INFO, message)
        end
    end

    request:set(0)
    result:set(0)
    GetSelf():listen_command(menu_command)

    function SetCommand(command, value)
        if command ~= menu_command then
            if old_command then return old_command(command, value) end
            return
        end
        -- This legacy keybind has no value_down, so DCS may supply zero.
        -- It has no release binding: zero is a menu press, not a PTT release.
        if waiting then return end
        diagnostic("INPUT command=1172 value=" .. tostring(value))
        local ok, err = pcall(function()
            local intercom = GetDevice(devices.INTERCOM)
            intercom:set_communicator(devices.UHF_RADIO)
            intercom:make_setup_for_communicator(devices.UHF_RADIO)
        end)
        if not ok then
            diagnostic("INTERCOM_SETUP_FAILED " .. tostring(err))
            return
        end
        result:set(0)
        request:set(1)
        waiting = true
        elapsed = 0
    end

    function update()
        if old_update then old_update() end
        if not waiting then return end
        local status = result:get()
        if status ~= 0 then
            diagnostic("EFM_RESULT=" .. tostring(status)
                .. " (1=PTT dispatched, -1=not ready, -2=missing API, -3=no communicator)")
            waiting = false
        else
            elapsed = elapsed + 0.05
            if elapsed >= 2 then
                request:set(0)
                waiting = false
                diagnostic("EFM_TIMEOUT: no acknowledgement; check installed FM DLL")
            end
        end
    end
end

return M
