-- LSP設定

MiniDeps.later(function()
  require("mason").setup()
  require("mason-lspconfig").setup({
    -- ここに書かれたlsをMasonで入れると自動的に`vim.lsp.enable`される
    automatic_enable = {
      'lua_ls', -- Lua
      'gopls', -- Go
      'jdtls', -- Java
      'ts_ls', -- JavaScript, TypeScript
      'pyright' -- Python
    },
  })
end)
