function exportRadioSK60(_data, SR)
    _data.capabilities = { dcsPtt = false, dcsIFF = true, dcsRadioSwitch = false, intercomHotMic = false, desc = "" }

    -- The SK 60 only exposes a civil Mode A transponder. SRS represents that
    -- code as Mode 3; status 2 makes the IDENT indicator flash.
    local transponder_power = get_param_handle("XPDR_POWER"):get()
    local transponder_ident = get_param_handle("XPDR_IDENT"):get()
    _data.iff = {
        status = transponder_power > 0.5 and (transponder_ident > 0.5 and 2 or 1) or 0,
        mode1 = -1,
        mode2 = -1,
        -- This packed parameter is published whenever a code wheel moves.
        mode3 = get_param_handle("XPDR_MODE_A_CODE"):get(),
        mode4 = false,
        control = 0, -- cockpit/DCS controls the transponder, not the SRS overlay
        expansion = false,
        mic = -1,
    }

   -- INTERCOM
    _data.radios[1].name = "Intercom"
    _data.radios[1].freq = 100.0
    _data.radios[1].modulation = 2
    _data.radios[1].volume = 1.0
    _data.radios[1].model = SR.RadioModels.Intercom

   -- COMM1 / FR31. Read the logical control head rather than its native UHF
   -- backing device so SRS can use both of the real FR31 frequency bands.
    _data.radios[2].name = "FR31"
    _data.radios[2].freq = get_param_handle("FR31_FREQ_HZ"):get()
    _data.radios[2].modulation = get_param_handle("FR31_MODULATION"):get()
    _data.radios[2].secFreq = 121.5 * 1000000
    _data.radios[2].volume = 1.0
    _data.radios[2].freqMin = 104 * 1000000
    _data.radios[2].freqMax = 407.975 * 1000000

   -- COMM2 / FR33. Read the logical control head just like the manual SRS
   -- module. A fixed value here can override that module when both register.
    _data.radios[3].name = "FR33"
    _data.radios[3].freq = get_param_handle("FR33_FREQ_HZ"):get()
    _data.radios[3].modulation = 0
    _data.radios[3].secFreq = 121.5 * 1000000
    _data.radios[3].volume = 1.0
    _data.radios[3].freqMin = 118 * 1000000
    _data.radios[3].freqMax = 135.975 * 1000000

    return _data;
end


local result = { }

function result.register(SR)
    -- SRS indexes exporters by the DCS unit type (Name), not DisplayName.
    SR.exporters["SK-60"] = exportRadioSK60
end

return result
