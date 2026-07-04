-- LSP + completion. Servers are native (vim.lsp.enable), completion is
-- blink.cmp — no Mason, no nvim-cmp.
--
-- Servers are plain binaries installed by GLOBAL MISE (~/.config/mise/
-- config.toml), so the same binaries serve nvim, Claude Code, and anything
-- else on every machine. nvim-lspconfig (loaded in plugins.lua) only
-- provides the per-server config data; vim.lsp.enable() does the rest:
-- it starts the right server when a matching filetype opens.

-- === Completion (blink.cmp) ===============================================

require("blink.cmp").setup({
  keymap = {
    -- "enter" preset: Enter accepts the selected item, plain Enter is a
    -- newline when nothing is selected — the VS Code feel. C-e dismisses.
    -- <C-Space> (from the preset) summons the menu / toggles docs: the
    -- hammer key lives on.
    preset = "enter",
    -- Tab/S-Tab walk the menu (and jump snippet placeholders when inside one)
    ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
    ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
  },
  completion = {
    documentation = { auto_show = true }, -- docs panel beside the menu, like VS Code
  },
  signature = { enabled = true }, -- param hints popup while typing a call
})

-- Advertise blink's extra client capabilities to every server
-- (must run before vim.lsp.enable below)
vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })

-- === Servers ==============================================================

-- Tweak a server before enabling it with vim.lsp.config(name, {...}).
-- lua_ls needs to know it's running inside nvim, or it flags `vim` as
-- an undefined global in this very config.
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = { library = { vim.env.VIMRUNTIME } },
    },
  },
})

vim.lsp.enable({
  "gopls",        -- Go         (mise: gopls)
  "vtsls",        -- TS/JS      (mise: npm:@vtsls/language-server)
  "lua_ls",       -- Lua        (mise: lua-language-server)
  "basedpyright", -- Python     (mise: npm:basedpyright)
})

-- Show diagnostic message text at the end of the line (off by default
-- since 0.11; without it you only get the gutter sign)
vim.diagnostic.config({ virtual_text = true })

-- === Per-buffer LSP behavior ==============================================

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))

    -- Format-on-save for servers that support it (gopls also organizes
    -- imports via its formatting). Remove per-project by :autocmd! if noisy.
    if client:supports_method("textDocument/formatting") then
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = ev.buf,
        callback = function()
          vim.lsp.buf.format({ bufnr = ev.buf, id = client.id, timeout_ms = 1000 })
        end,
      })
    end
  end,
})
