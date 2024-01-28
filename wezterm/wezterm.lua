local wezterm = require 'wezterm'
local config = {}

config.font_size = 16.0
--config.color_scheme = "GruvboxDarkHard"
--config.color_scheme = "GruvboxDark"
config.color_scheme = "Gruvbox Material (Gogh)"
config.colors = {
  background = "#1d2021",
}


config.hide_tab_bar_if_only_one_tab = true
-- config.window_decorations = 'TITLE | RESIZE'
config.window_decorations = 'RESIZE'
config.window_padding = {
  left = '1cell',
  right = '1cell',
  top = '1cell',
  bottom = '0.5cell',
}
config.window_background_opacity = 1
config.enable_scroll_bar = true

return config


--             mocha = {
--                   rosewater = "#ea6962",
--                   flamingo = "#ea6962",
--                   red = "#ea6962",
--                   maroon = "#ea6962",
--                   pink = "#d3869b",
--                   mauve = "#d3869b",
--                   peach = "#e78a4e",
--                   yellow = "#d8a657",
--                   green = "#a9b665",
--                   teal = "#89b482",
--                   sky = "#89b482",
--                   sapphire = "#89b482",
--                   blue = "#7daea3",
--                   lavender = "#7daea3",
--                   text = "#ebdbb2",
--                   subtext1 = "#d5c4a1",
--                   subtext0 = "#bdae93",
--                   overlay2 = "#a89984",
--                   overlay1 = "#928374",
--                   overlay0 = "#595959",
--                   surface2 = "#4d4d4d",
--                   surface1 = "#404040",
--                   surface0 = "#292929",
--                   base = "#1d2021",
--                   mantle = "#191b1c",
--                   crust = "#141617",
--               }
