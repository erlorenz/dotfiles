-- Single WezTerm config for all machines (synced via yadm).
--   macOS:   read directly from ~/.config/wezterm/wezterm.lua
--   Windows: a set-once stub in the Windows user folder (see
--            windows-stub.lua next to this file) loads this file over \\wsl$
--   Linux:   read directly (dev boxes, if ever running the GUI there)

local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- PLATFORM: on Windows, open every window/tab/pane straight into WSL.
-- No tmux anywhere — panes are native, so nothing is translated through
-- extra layers. (Reading \\wsl$ in the stub already booted WSL by the
-- time this runs.)
if wezterm.target_triple:find("windows") then
  config.wsl_domains = wezterm.default_wsl_domains()
  if #config.wsl_domains > 0 then
    config.default_domain = config.wsl_domains[1].name
  end
end

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

-- LEADER (Ctrl+A, 1 second timeout).
-- Moved off Ctrl+B so WezTerm's OWN muxing and herdr can coexist: herdr keeps
-- its default Ctrl+B prefix, WezTerm muxing lives on Ctrl+A. Run herdr inside
-- WezTerm and you can A/B the two — Ctrl+B drives herdr, Ctrl+A drives WezTerm.
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
  -- Ctrl+A is also shell "beginning of line" (emacs bindkey). leader+a sends a
  -- literal Ctrl+A through, so double-tapping Ctrl+A still jumps to line start.
  { key = "a", mods = "LEADER", action = act.SendKey({ key = "a", mods = "CTRL" }) },

  -- Pane splits (leader) — core tmux bindings, matching herdr's overrides:
  --   %  (shift+5) -> side-by-side panes     " (shift+') -> stacked panes
  { key = "%", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = '"', mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
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

  -- Workspaces (~ tmux sessions), on the tmux muscle-memory keys:
  -- leader+s  choose from a fuzzy list        (tmux: leader+s)
  -- leader+$  rename current workspace        (tmux: leader+$)
  -- leader+(/)  prev/next workspace           (tmux: leader+(/))
  -- leader+W  create/switch to named workspace (type a new or existing name)
  { key = "s", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES", title = "Workspaces" }) },
  { key = "$", mods = "LEADER", action = act.PromptInputLine({
    description = "Rename workspace:",
    action = wezterm.action_callback(function(_, _, line)
      if line and line ~= "" then
        wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
      end
    end),
  }) },
  { key = "(", mods = "LEADER", action = act.SwitchWorkspaceRelative(-1) },
  { key = ")", mods = "LEADER", action = act.SwitchWorkspaceRelative(1) },
  { key = "W", mods = "LEADER", action = act.PromptInputLine({
    description = "Workspace name:",
    action = wezterm.action_callback(function(window, pane, line)
      if line and line ~= "" then
        window:perform_action(act.SwitchToWorkspace({ name = line }), pane)
      end
    end),
  }) },
}

-- Show the active workspace in the top-right, so you always know which
-- "session" you're in (only interesting once you have more than one)
wezterm.on("update-status", function(window, _)
  window:set_right_status(wezterm.format({
    { Foreground = { Color = "#7aa2f7" } },
    { Text = " " .. window:active_workspace() .. "  " },
  }))
end)

-- Copy mode vi keybindings
config.key_tables = {
  copy_mode = wezterm.gui.default_key_tables().copy_mode,
}

return config
