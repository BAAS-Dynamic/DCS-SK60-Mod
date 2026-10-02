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

    _data.radios[1].name = "Intercom"
    _data.radios[1].freq = 100.0
    _data.radios[1].modulation = 2 --Special intercom modulation
    _data.radios[1].volume = 1.0
    _data.radios[1].volMode = 1
    _data.radios[1].model = SR.RadioModels.Intercom

    -- Read the logical FR31 state rather than the native UHF backing device.
    -- This preserves the VHF selection for SRS while DCS keeps its in-game
    -- communicator on the last valid UHF channel.
    _data.radios[2].name = "FR31"
    _data.radios[2].freq = get_param_handle("FR31_FREQ_HZ"):get()
    _data.radios[2].modulation = get_param_handle("FR31_MODULATION"):get()
    _data.radios[2].secFreq = 121.5 * 1000000
    _data.radios[2].volume = 1.0
    _data.radios[2].volMode = 1
    _data.radios[2].freqMin = 104 * 1000000
    _data.radios[2].freqMax = 407.975 * 1000000
	
	    -- COMM2 / FR33. Native VHF radio device ID is fixed at 24.
    _data.radios[3].name = "FR33"
    _data.radios[3].freq = get_param_handle("FR33_FREQ_HZ"):get()
    _data.radios[3].modulation = 0
    _data.radios[3].secFreq = 121.5 * 1000000
    _data.radios[3].volume = 1.0
    _data.radios[3].freqMin = 118 * 1000000
    _data.radios[3].freqMax = 135.975 * 1000000

  --[[ -- Expansion Radio - Server Side Controlled
    _data.radios[3].name = "AN/ARC-186(V)"
    _data.radios[3].freq = 124.8 * 1000000 --116,00-151,975 MHz
    _data.radios[3].modulation = 0
    _data.radios[3].secFreq = 121.5 * 1000000
    _data.radios[3].volume = 1.0
    _data.radios[3].freqMin = 116 * 1000000
    _data.radios[3].freqMax = 151.975 * 1000000
    _data.radios[3].expansion = true
    _data.radios[3].volMode = 1
    _data.radios[3].freqMode = 1
    _data.radios[3].model = SR.RadioModels.AN_ARC186

    -- Expansion Radio - Server Side Controlled
    _data.radios[4].name = "AN/ARC-186(V)FM"
    _data.radios[4].freq = 30.0 * 1000000 
    _data.radios[4].modulation = 1
    _data.radios[4].volume = 1.0
    _data.radios[4].freqMin = 30 * 1000000
    _data.radios[4].freqMax = 76 * 1000000
    _data.radios[4].volMode = 1
    _data.radios[4].freqMode = 1
    _data.radios[4].expansion = true
    _data.radios[4].model = SR.RadioModels.AN_ARC186 ]]--

    _data.control = 0;
    _data.selected = 1

    if SR.getAmbientVolumeEngine()  > 10 then
        -- engine on

        local _door = SR.getButtonPosition(38)

        if _door < 0.9 then 
            _data.ambient = {vol = 0.3,  abType = 'sk60' }
        else
            _data.ambient = {vol = 0.15,  abType = 'sk60' }
        end 
    
    else
        -- engine off
        _data.ambient = {vol = 0, abType = 'sk60' }
    end

    return _data

end

local result = {
    register = function(SR)
        SR.exporters["SK-60"] = exportRadioSK60
    end,
}
return result
