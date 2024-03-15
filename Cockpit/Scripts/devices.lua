local count = 0
local function counter()
	count = count + 1
	return count
end
-------DEVICE ID----------
devices = {}
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
devices["IPAD_SYSTEM"]				= counter() --16
devices["MENU_SYSTEM"]				= counter() --17
devices["UP_LINK"]					= counter() --18
devices["MISCELANIOUS"]				= counter() --19
devices["animations"]               = counter() --20
devices["gunsight"]                 = counter()