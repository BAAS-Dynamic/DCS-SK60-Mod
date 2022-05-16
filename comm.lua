local parameters = {
	fighter = true,
	radar = true,
	ECM = true,
	refueling = true,
}

utils.verifyChunk(utils.loadfileIn('Scripts/UI/RadioCommandDialogPanel/Config/LockOnAirplane.lua', getfenv()))(parameters)

-- set the rocket configration
menus['Weapon Config'] = {
	name = _('Rocket Configuration'),
	items = {
		[1] = {
			name = _('Fire in Pairs'), 		
			command = 5059
		},
		[2] = {
			name = _('Fire in Single'),
			command = 5058
		},
		[3] = {
			name = _('Fire All'),
			command = 5057
		}
	}
}

menus['Install Gunsight'] = {
	name = _('Gunsight Installation'),
	items = {
		[1] = {
			name = _('Install'), 		
			command = 5062
		},
		[2] = {
			name = _('Uninstall'),
			command = 5063
		}
	}
}

menus['Ground Crew'].items[4] = { name = _('Weapon Configuration'), submenu = menus['Weapon Config']}
menus['Ground Crew'].items[5] = { name = _('Gunsight Installation'), submenu = menus['Install Gunsight']}