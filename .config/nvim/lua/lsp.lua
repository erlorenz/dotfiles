-- LSP + completion, all native — no Mason, no nvim-cmp.
--
-- Servers are plain binaries installed by GLOBAL MISE (~/.config/mise/
-- config.toml), so the same binaries serve nvim, Claude Code, and anything
-- else on every machine. nvim-lspconfig (loaded in plugins.lua) only
-- provides the per-server config data; vim.lsp.enable() does the rest:
-- it starts the right server when a matching filetype opens.

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
  "basedpyright", -- Python     (mise: pipx:basedpyright)
})

-- Show diagnostic message text at the end of the line (off by default
-- since 0.11; without it you only get the gutter sign)
vim.diagnostic.config({ virtual_text = true })

-- === Completion (VS Code muscle memory, zero plugins) =====================

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))

    if client:supports_method("textDocument/completion") then
      -- autotrigger: the menu pops up on its own as you type (VS Code style),
      -- driven by the server's trigger characters (".", ":", etc.)
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })

      -- Ctrl+Space summons/refreshes the menu on demand — the VS Code
      -- binding. NOT a nvim default (vim natives use <C-x><C-o>); mapped
      -- here because it's hammered constantly. Terminals send Ctrl+Space
      -- as NUL and WezTerm passes it through fine on mac + WSL.
      vim.keymap.set("i", "<C-Space>", vim.lsp.completion.get,
        { buffer = ev.buf, desc = "Trigger completion" })
    end

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

-- Menu navigation, VS Code-flavored. Native pum keys still work too:
-- <C-n>/<C-p> next/prev, <C-y> accept, <C-e> dismiss.
local function pum(vscode_key, fallback)
  return function()
    return vim.fn.pumvisible() == 1 and vscode_key or fallback
  end
end
-- Tab / Shift+Tab walk the menu when it's open, otherwise behave normally
vim.keymap.set("i", "<Tab>", pum("<C-n>", "<Tab>"), { expr = true })
vim.keymap.set("i", "<S-Tab>", pum("<C-p>", "<S-Tab>"), { expr = true })
-- Enter accepts the highlighted item when the menu is open (with
-- 'noselect' nothing is highlighted until you Tab/arrow to it, so plain
-- Enter-for-newline still works while the menu is merely visible)
vim.keymap.set("i", "<CR>", function()
  return vim.fn.complete_info({ "selected" }).selected ~= -1 and "<C-y>" or "<CR>"
end, { expr = true })
