local wezterm = require("wezterm")
local mux = wezterm.mux

wezterm.on("gui-startup", function(cmd)
	if mux then
		local tab, pane, window = mux.spawn_window(cmd or {})
		window:gui_window():maximize()
	end
end)

config = wezterm.config_builder()
config = {
	font_size = 11,
	color_scheme = "Night Owl (Gogh)",
	window_background_opacity = 0.8,
	--window_decorations = "NONE",
	default_cursor_style = "SteadyBar",
	enable_wayland = true,
	tab_bar_at_bottom = true,
}

config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	-- splitting
	{
		mods = "LEADER",
		key = "v",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		mods = "LEADER",
		key = "h",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "f",
		mods = "LEADER",
		action = wezterm.action.TogglePaneZoomState,
	},
	-- rotate panes
	{
		mods = "LEADER",
		key = "Space",
		action = wezterm.action.RotatePanes("Clockwise"),
	},
	-- show the pane selection mode, but have it swap the active and selected panes
	{
		mods = "LEADER",
		key = "0",
		action = wezterm.action.PaneSelect({
			mode = "SwapWithActive",
		}),
	},
}

-- Create tab: CTRL+SHIFT+T
-- Go to next tab: CTRL+TAB
-- Go to previous tab: CTRL+SHIFT+TAB

return config
