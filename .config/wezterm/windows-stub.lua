-- Windows-side stub. COPY ONCE to:  C:\Users\<you>\.wezterm.lua
-- (see WORK-SETUP.md). It never needs to change again.
--
-- It loads the real, yadm-synced config from inside WSL. Reading \\wsl$
-- automatically boots the WSL VM if it isn't running (~1-2s once per
-- Windows boot), and the real config then defaults every pane into WSL.
--
-- If your distro isn't Ubuntu, run `wsl -l` in PowerShell and fix the path.

local ok, config = pcall(dofile, "\\\\wsl$\\Ubuntu\\home\\erik\\.config\\wezterm\\wezterm.lua")
if ok and type(config) == "table" then
  return config
end

-- Fallback: WSL unreachable (broken install, first boot). Plain wezterm
-- with a warning in the tab title so it's obvious something is off.
local wezterm = require("wezterm")
wezterm.log_error("Could not load config from WSL: " .. tostring(config))
return { window_decorations = "TITLE | RESIZE" }
