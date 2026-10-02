local DbOption = require('Options.DbOption')
local i18n = require('i18n')
local _ = i18n.ptranslate

return {
	-- Kept for compatibility with existing configurations; it is no longer
	-- presented in the SK-60 Special Options panel.
	NWS_Coupled_Separate_Input_Device = DbOption.new():setValue(true):checkbox(),
	PitchTrimMode = DbOption.new():setValue(0):combo({
		DbOption.Item(_('Instant / Conventional')):Value(0),
		DbOption.Item(_('Central Position Trimmer')):Value(1),
		DbOption.Item(_('Force Feedback')):Value(2),
	}),
}
