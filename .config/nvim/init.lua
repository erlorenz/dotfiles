-- Entry point. Kept tiny on purpose: each concern lives in its own module
-- under lua/, and this file just loads them in order.
--
-- Load order matters:
--   1. leader keys must be set before any keymaps or plugins reference them
--   2. options before plugins (some plugins read options at setup time)
--   3. plugins before lsp (lsp.lua uses nvim-lspconfig's server definitions)

-- <Space> as leader: it does nothing useful in normal mode by default,
-- and it's the easiest key to hit from home row.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("options")
require("keymaps")
require("plugins")
require("lsp")
