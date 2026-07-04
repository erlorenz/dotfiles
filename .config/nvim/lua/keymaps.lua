-- General keymaps (plugin-specific maps live next to their plugin setup in
-- plugins.lua; LSP maps in lsp.lua). vim.keymap.set(mode, lhs, rhs, opts) —
-- `desc` makes mappings self-documenting (shown by :map and pickers).
--
-- Worth knowing — these are BUILT-IN since 0.11, no config needed:
--   grn  - rename symbol            (VS Code F2)
--   grr  - list references          (VS Code Shift+F12)
--   gri  - go to implementation
--   gra  - code action              (VS Code Ctrl+.)
--   K    - hover docs               (VS Code mouse-hover)
--   gd   - go to definition (classic vim, works via LSP tagfunc)
--   ]d [d - next/prev diagnostic
--   <C-w>v / <C-w>s - split vertical/horizontal; <C-w>hjkl - move between

local map = vim.keymap.set

-- <Esc> also clears leftover search highlighting (the yellow matches that
-- stick around after /searching)
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Move between window splits with Ctrl+hjkl instead of the two-step <C-w>h.
-- These are nvim splits; WezTerm pane moves are on Ctrl+Alt+arrows, so the
-- two never collide.
map("n", "<C-h>", "<C-w>h", { desc = "Focus split left" })
map("n", "<C-j>", "<C-w>j", { desc = "Focus split down" })
map("n", "<C-k>", "<C-w>k", { desc = "Focus split up" })
map("n", "<C-l>", "<C-w>l", { desc = "Focus split right" })

-- Move selected lines up/down and reindent (VS Code Alt+Up/Down, but for a
-- visual selection). The '> markers mean "end of selection".
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep the selection when indenting in visual mode, so you can hit > or <
-- repeatedly (by default the selection drops after one shift)
map("v", "<", "<gv", { desc = "Dedent and reselect" })
map("v", ">", ">gv", { desc = "Indent and reselect" })

-- Diagnostics in a list you can jump through (VS Code "Problems" panel)
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

-- Quality-of-life
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Save file" })
