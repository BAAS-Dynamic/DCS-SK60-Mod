local menus = data.menus

local parameters = {
	fighter = true,
	radar = false,
	ECM = false,
	refueling = false,
}

utils.verifyChunk(utils.loadfileIn('Scripts/UI/RadioCommandDialogPanel/Config/LockOnAirplane.lua', getfenv()))(parameters)
utils.verifyChunk(utils.loadfileIn('Scripts/UI/RadioCommandDialogPanel/Config/Common/ATC.lua', getfenv()))(5, {[Airbase.Category.AIRDROME] = true})
utils.verifyChunk(utils.loadfileIn('Scripts/UI/RadioCommandDialogPanel/Config/Common/AWACS.lua', getfenv()))(7, {tanker = false, radar = false})
utils.verifyChunk(utils.loadfileIn('Scripts/UI/RadioCommandDialogPanel/Config/Common/Ground Crew.lua', getfenv()))(8)

-- Wheel Choks and ladder
menus['Wheel chocks and ladder'] = {
	name = _('Wheel chocks and ladder'),
	items = {
		[1] = {
			name = _('Place ground equipment'), 		
			command = sendMessage.new(Message.wMsgLeaderGroundToggleWheelChocks, true)
		},
		[2] = {
			name = _('Remove ground equipment'),
			command = sendMessage.new(Message.wMsgLeaderGroundToggleWheelChocks, false)
		}
	}
}
menus['Ground Crew'].items[4] = { name = _('Wheel chocks and ladder'), submenu = menus['Wheel chocks and ladder']}