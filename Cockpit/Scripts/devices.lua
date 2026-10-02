local count = 0
local function counter()
	count = count + 1
	return count
end
-------DEVICE ID----------
devices = {}
-- Keep the original SK60 device IDs stable. SRS and the EFM depend on fixed
-- numeric IDs for the native UHF radio and sound system.
devices["ELECTRIC_SYSTEM"]			= counter() --1
devices["PRISURFACE"]         		= counter() --2
devices["CANOPY"]         			= counter() --3
devices["BREAK_SYSTEM"]				= counter() --4
devices["WEAPON_SYSTEM"]			= counter() --5
devices["UHF_RADIO"]				= counter() --6
devices["INTERCOM"]					= counter() --7
devices["RADAR_RAW"]				= counter() --8
devices["HUD_DCMS"]					= counter() --9
devices["BASIC_FLIGHT_INS"]			= counter() --10
devices["CLOCK"]					= counter() --11
devices["GEAR_SYSTEM"]				= counter() --12
devices["LIGHT_SYSTEM"]				= counter() --13
devices["SOUND_SYSTEM"]     		= counter()	--14
devices["WARNING_SYSTEM"]			= counter() --15
--devices["IPAD_SYSTEM"]				= counter() --16
devices["General_Device"]			= counter() --16 reserved legacy slot
devices["MENU_SYSTEM"]				= counter() --17
devices["UP_LINK"]					= counter() --18
devices["MISCELANIOUS"]				= counter() --19
devices["animations"]               = counter() --20
devices["gunsight"]                 = counter() --21
devices["NAV_SYSTEM"]               = counter() --22
devices["FR31_RADIO"]               = counter() --23 FR31 controller
devices["VHF_RADIO"]                = counter() --24 native FR33 backing radio
devices["FR33_RADIO"]               = counter() --25 FR33 controller
devices["TRANSPONDER"]              = counter() --26 transponder controller

devices["MULTICREW"] = counter() --27 appended; preserve all existing IDs
