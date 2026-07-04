-- Core editor settings. Every option here earns a comment saying what it
-- does and why it's on, so future-me actually understands this file.
-- Browse everything with :help option-list, or :help 'optionname'.

-- === UI ===================================================================

vim.o.number = true         -- absolute line number on the current line
vim.o.relativenumber = true -- relative numbers elsewhere: makes counts for
                            -- motions readable, e.g. see "7" next to a line
                            -- and jump with 7j
vim.o.signcolumn = "yes"    -- always show the gutter (LSP/git signs), so the
                            -- text doesn't shift when signs appear
vim.o.cursorline = true     -- highlight the line the cursor is on
vim.o.scrolloff = 8         -- keep 8 lines visible above/below the cursor
                            -- when scrolling, so context is always there
vim.o.wrap = false          -- don't soft-wrap long lines (code reads better;
                            -- toggle per-buffer with :set wrap when needed)
vim.o.termguicolors = true  -- 24-bit color; WezTerm supports it everywhere
vim.o.winborder = "rounded" -- rounded borders on floating windows (hover
                            -- docs, etc.) — new in 0.11

-- === Editing ==============================================================

vim.o.expandtab = true      -- insert spaces when pressing <Tab>...
vim.o.shiftwidth = 2        -- ...2 of them for indents (>> << ==)
vim.o.tabstop = 2           -- ...and render real tab chars as 2 wide.
                            -- Languages with strong conventions (Go = tabs)
                            -- get fixed up by their LSP/ftplugin anyway.
vim.o.smartindent = true    -- auto-indent new lines based on syntax
vim.o.undofile = true       -- persist undo history to disk: undo survives
                            -- closing and reopening a file
vim.o.updatetime = 250      -- ms of idle before CursorHold / swap write;
                            -- makes gitsigns and diagnostics feel snappier

-- === Search ===============================================================

vim.o.ignorecase = true     -- case-insensitive search...
vim.o.smartcase = true      -- ...unless the query contains an uppercase
                            -- letter (then it's case-sensitive). Best combo.
vim.o.inccommand = "split"  -- live preview of :s/substitutions in a split

-- === Completion ===========================================================

-- blink.cmp (lsp.lua) draws its own menu and ignores this; it still shapes
-- the rare native ins-completion contexts (<C-x> chords):
--   menuone  - show the menu even for a single match
--   noselect - don't preselect anything; typing keeps narrowing
--   fuzzy    - fuzzy-match against typed text
vim.o.completeopt = "menuone,noselect,fuzzy"

-- === System integration ===================================================

vim.o.clipboard = "unnamedplus" -- yank/paste use the system clipboard, so
                                -- y and p interop with everything else.
                                -- Over SSH this uses OSC52 automatically.
if vim.fn.has("wsl") == 1 then
  -- On WSL, skip the win32yank.exe dance: copy via OSC52 escape codes,
  -- which WezTerm forwards to the Windows clipboard. (Pasting INTO nvim
  -- works regardless via the terminal's own paste, Ctrl+Shift+V.)
  vim.g.clipboard = "osc52"
end
vim.o.mouse = "a"               -- mouse works in all modes (resize splits,
                                -- click to move); scrolling feels native
vim.o.confirm = true            -- :q with unsaved changes asks to save
                                -- instead of erroring
