-- Plugins via vim.pack — Neovim 0.12's built-in plugin manager. No lazy.nvim.
--
-- How it works:
--   * vim.pack.add() clones anything missing into
--     ~/.local/share/nvim/site/pack/core/opt/ and loads it. Already-installed
--     plugins just load. Remove a line = plugin gone from the session
--     (:lua vim.pack.del({'name'}) deletes it from disk).
--   * Exact versions are recorded in ~/.config/nvim/nvim-pack-lock.json —
--     committed to dotfiles, so every machine gets identical plugin versions.
--   * Update everything with :lua vim.pack.update()  (review buffer opens;
--     apply with :write). Roll back by restoring the lockfile and running
--     :lua vim.pack.update(nil, { target = 'lockfile' })
--
-- Philosophy: 6 plugins. Add a new one only when a real need is felt.
-- Most future wants have a tiny mini.* module (statusline -> mini.statusline,
-- surround -> mini.surround, autopairs -> mini.pairs, icons -> mini.icons).

-- nvim-treesitter (main branch) compiles parsers; after the plugin itself
-- updates, parsers must be recompiled. This hook runs :TSUpdate for that.
-- Hooks must be registered BEFORE the vim.pack.add() call that triggers them.
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    if ev.data.spec.name == "nvim-treesitter" and ev.data.kind == "update" then
      vim.schedule(function() vim.cmd("TSUpdate") end)
    end
  end,
})

vim.pack.add({
  -- Colorscheme: matches the WezTerm theme so terminal and editor agree
  "https://github.com/folke/tokyonight.nvim",

  -- Treesitter: real parsing for syntax highlighting and indentation.
  -- The rewritten 'main' branch is the maintained one ('master' is frozen).
  -- Needs the tree-sitter CLI + a C compiler (both come from global mise).
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },

  -- Picker: fuzzy find files / grep / buffers / help. Zero dependencies,
  -- uses ripgrep under the hood. The minimal telescope alternative.
  "https://github.com/nvim-mini/mini.pick",

  -- Git gutter signs, hunk operations, line blame
  "https://github.com/lewis6991/gitsigns.nvim",

  -- File explorer as a normal editable buffer: rename = edit a line,
  -- delete = dd, create = o + type a name, then :w applies it all
  "https://github.com/stevearc/oil.nvim",

  -- LSP server definitions (data only — nvim's native LSP client does the
  -- work; this ships tested configs for hundreds of servers). Used by lsp.lua.
  "https://github.com/neovim/nvim-lspconfig",
}, {
  -- don't prompt before the initial clone: this list is version-controlled,
  -- and a prompt would hang the headless bootstrap on a new machine
  confirm = false,
})

-- === Colorscheme ==========================================================

vim.cmd.colorscheme("tokyonight-night")

-- === Treesitter ===========================================================

-- Languages to keep parsers installed for (install() skips ones present).
-- nvim ships c, lua, vim, vimdoc, query, markdown parsers out of the box.
local ts_langs = {
  "go", "gomod", "gosum",
  "javascript", "typescript", "tsx", "jsdoc",
  "python", "ruby",
  "json", "yaml", "toml",
  "html", "css",
  "bash", "dockerfile", "sql",
  "markdown_inline", "gitcommit", "diff",
}
require("nvim-treesitter").install(ts_langs)

-- The main branch doesn't auto-enable anything: turn on highlighting and
-- treesitter-based indentation per buffer when a filetype has a parser.
vim.api.nvim_create_autocmd("FileType", {
  callback = function(ev)
    if vim.treesitter.language.get_lang(ev.match) and pcall(vim.treesitter.start, ev.buf) then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

-- === mini.pick ============================================================

require("mini.pick").setup()

-- Muscle-memory map from VS Code:
--   <leader>f  ~ Cmd/Ctrl+P        (find file)
--   <leader>/  ~ Ctrl+Shift+F      (search in project, live)
--   <leader>b  ~ Ctrl+Tab-ish      (open buffers)
vim.keymap.set("n", "<leader>f", "<cmd>Pick files<CR>", { desc = "Find files" })
vim.keymap.set("n", "<leader>/", "<cmd>Pick grep_live<CR>", { desc = "Grep project" })
vim.keymap.set("n", "<leader>b", "<cmd>Pick buffers<CR>", { desc = "Find buffers" })
vim.keymap.set("n", "<leader>h", "<cmd>Pick help<CR>", { desc = "Search help" })
vim.keymap.set("n", "<leader>r", "<cmd>Pick resume<CR>", { desc = "Resume last picker" })

-- === gitsigns =============================================================

require("gitsigns").setup({
  on_attach = function(bufnr)
    local gs = require("gitsigns")
    local function bmap(mode, l, r, desc)
      vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
    end
    -- ]h / [h jump between changed hunks, like scrolling the VS Code gutter
    bmap("n", "]h", function() gs.nav_hunk("next") end, "Next git hunk")
    bmap("n", "[h", function() gs.nav_hunk("prev") end, "Prev git hunk")
    bmap("n", "<leader>gp", gs.preview_hunk, "Preview hunk diff")
    bmap("n", "<leader>gr", gs.reset_hunk, "Reset (revert) hunk")
    bmap("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
    bmap("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
  end,
})

-- === oil ==================================================================

require("oil").setup({
  view_options = { show_hidden = true }, -- dotfiles matter in this house
})
-- "-" opens the parent directory of the current file (then "-" again keeps
-- going up; <CR> enters a dir/file; edit the listing like text and :w)
vim.keymap.set("n", "-", "<cmd>Oil<CR>", { desc = "File explorer (parent dir)" })
