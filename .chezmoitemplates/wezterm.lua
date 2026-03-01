local wezterm = require("wezterm")
local config = wezterm.config_builder()

{{ if eq .chezmoi.os "linux" -}}
{{   if (.chezmoi.kernel.osrelease | lower | contains "microsoft") -}}
-- WSL: launch into Ubuntu by default
config.default_domain = "WSL:Ubuntu"

{{   end -}}
{{ end -}}
-- FONT
config.font_size = 13.0
config.font = wezterm.font("JetBrains Mono")

-- COLOR
config.color_scheme = "Tokyo Night"

-- WINDOW
config.audible_bell = "Disabled"
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_padding = {
  left = "1cell",
  right = "1cell",
  top = "1cell",
  bottom = "0.5cell",
}
config.enable_scroll_bar = true
config.scrollback_lines = 50000

return config
