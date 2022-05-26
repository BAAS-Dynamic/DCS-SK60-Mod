local count = 0
local function counter()
	count = count + 1
	return count
end
-------DEVICE ID----------
devices = {}
devices["ELECTRIC_SYSTEM"]			= counter()
devices["PRISURFACE"]         		= counter()
devices["CANOPY"]         			= counter()
devices["BREAK_SYSTEM"]				= counter()
devices["WEAPON_SYSTEM"]			= counter()
devices["UHF_RADIO"]				= counter()
devices["INTERCOM"]					= counter()
devices["RADAR_RAW"]				= counter()
devices["HUD_DCMS"]					= counter()
devices["BASIC_FLIGHT_INS"]			= counter()
devices["CLOCK"]					= counter()
devices["GEAR_SYSTEM"]				= counter()
devices["LIGHT_SYSTEM"]				= counter()
devices["SOUND_SYSTEM"]     		= counter()	--14