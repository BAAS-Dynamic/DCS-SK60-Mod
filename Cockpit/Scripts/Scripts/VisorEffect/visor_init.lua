dofile(LockOn_Options.common_script_path .. "devices_defs.lua")

-- A HELMET indicator is attached to the player's view and is rendered for
-- each VR eye, unlike a cockpit screen-space indicator fixed to a viewport.
indicator_type = indicator_types.HELMET
purposes = {render_purpose.GENERAL, render_purpose.HUD_ONLY_VIEW}

page_subsets = {
	[1] = LockOn_Options.script_path .. "VisorEffect/visor_page.lua",
}

pages = {
	{1},
}

init_pageID = 1
use_parser = false
