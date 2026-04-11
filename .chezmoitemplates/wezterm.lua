local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

{{ if eq .chezmoi.os "linux" -}}
{{   if (.chezmoi.kernel.osrelease | lower | contains "microsoft") -}}
-- WSL: launch into Ubuntu by default
config.default_domain = "WSL:Ubuntu"

{{   end -}}
{{ end -}}
-- FONT
config.font_size = 14.0
config.font = wezterm.font("JetBrains Mono")

-- COLOR
config.color_scheme = "Tokyo Night"

-- WINDOW
config.audible_bell = "Disabled"
config.use_fancy_tab_bar = false
config.window_decorations = "RESIZE"
config.window_padding = {
  left = "1cell",
  right = "1cell",
  top = "1cell",
  bottom = "0.5cell",
}
config.enable_scroll_bar = true
config.scrollback_lines = 50000

-- LEADER (Ctrl+B, 1 second timeout)
config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
  -- Pane splits (leader)
  { key = "h", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "v", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = false }) },

  -- Pane navigation (Ctrl+Alt+Arrows)
  { key = "LeftArrow",  mods = "CTRL|ALT", action = act.ActivatePaneDirection("Left") },
  { key = "RightArrow", mods = "CTRL|ALT", action = act.ActivatePaneDirection("Right") },
  { key = "UpArrow",    mods = "CTRL|ALT", action = act.ActivatePaneDirection("Up") },
  { key = "DownArrow",  mods = "CTRL|ALT", action = act.ActivatePaneDirection("Down") },

  -- Pane resize (Ctrl+Alt+Shift+Arrows)
  { key = "LeftArrow",  mods = "CTRL|ALT|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },
  { key = "RightArrow", mods = "CTRL|ALT|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },
  { key = "UpArrow",    mods = "CTRL|ALT|SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) },
  { key = "DownArrow",  mods = "CTRL|ALT|SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) },

  -- Tab controls (leader)
  { key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "k", mods = "LEADER", action = act.CloseCurrentTab({ confirm = false }) },
  { key = "r", mods = "LEADER", action = act.PromptInputLine({
    description = "Rename tab:",
    action = wezterm.action_callback(function(window, pane, line)
      if line then
        window:active_tab():set_title(line)
      end
    end),
  }) },

  -- Tab by number (Alt+1-9)
  { key = "1", mods = "ALT", action = act.ActivateTab(0) },
  { key = "2", mods = "ALT", action = act.ActivateTab(1) },
  { key = "3", mods = "ALT", action = act.ActivateTab(2) },
  { key = "4", mods = "ALT", action = act.ActivateTab(3) },
  { key = "5", mods = "ALT", action = act.ActivateTab(4) },
  { key = "6", mods = "ALT", action = act.ActivateTab(5) },
  { key = "7", mods = "ALT", action = act.ActivateTab(6) },
  { key = "8", mods = "ALT", action = act.ActivateTab(7) },
  { key = "9", mods = "ALT", action = act.ActivateTab(8) },

  -- Prev/next tab (Alt+Left/Right)
  { key = "LeftArrow",  mods = "ALT", action = act.ActivateTabRelative(-1) },
  { key = "RightArrow", mods = "ALT", action = act.ActivateTabRelative(1) },

  -- Move tab (Alt+Shift+Left/Right)
  { key = "LeftArrow",  mods = "ALT|SHIFT", action = act.MoveTabRelative(-1) },
  { key = "RightArrow", mods = "ALT|SHIFT", action = act.MoveTabRelative(1) },

  -- Reload config (leader+q)
  { key = "q", mods = "LEADER", action = act.ReloadConfiguration },

  -- Copy mode (leader+[)
  { key = "[", mods = "LEADER", action = act.ActivateCopyMode },
}

-- Copy mode vi keybindings
config.key_tables = {
  copy_mode = wezterm.gui.default_key_tables().copy_mode,
}

return config
