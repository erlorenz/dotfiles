local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action

--FONT
config.font_size = 16.0
config.font = wezterm.font("JetBrains Mono")

--COLOR
config.color_scheme = "Gruvbox Material (Gogh)"
config.colors = {
	background = "#1d2021",
}

--WINDOW
config.audible_bell = "Disabled"
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"
config.window_padding = {
	left = "1cell",
	right = "1cell",
	top = "1cell",
	bottom = "0.5cell",
}
config.window_background_opacity = 1
config.enable_scroll_bar = true
config.scrollback_lines = 3000

--KEYBINDS
config.leader = { key = ";", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	-- Pane keybindings
	{ key = "s", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "v", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
	{ key = "q", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
	{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
	{ key = "o", mods = "LEADER", action = act.RotatePanes("Clockwise") },
}

return config
