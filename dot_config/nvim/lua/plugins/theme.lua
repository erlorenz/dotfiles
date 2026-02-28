return {
  -- { "folke/tokyonight.nvim" },
  {
    "adibhanna/yukinord.nvim",
    lazy = false,
    priority = 1000,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      -- colorscheme = "tokyonight",
      colorscheme = "yukinord",
    },
  },
}
