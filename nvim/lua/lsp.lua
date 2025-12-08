-- LSP設定
MiniDeps.later(function()
  local lsp_actions

  if vim.g.vscode then
    -- VSCode環境: VSCodeコマンドのみ使用
    local vscode = require('vscode')
    lsp_actions = {
      ['type-def'] = function() vscode.call('editor.action.goToTypeDefinition') end,
      ['refs'] = function() vscode.call('editor.action.referenceSearch.trigger') end,
      ['impl'] = function() vscode.call('editor.action.goToImplementation') end,
      ['code-action'] = function() vscode.call('editor.action.codeAction') end,
      ['rename'] = function() vscode.call('editor.action.rename') end,
      ['diag'] = function() vscode.call('editor.action.showHover') end,
      ['format'] = function() vscode.call('editor.action.formatDocument') end,
    }
  else
    -- Neovim環境: LSP + conform を使用
    require("mason").setup()
    require("mason-lspconfig").setup({
      -- ここに書かれたlsをMasonで入れると自動的に`vim.lsp.enable`される
      automatic_enable = {
        'lua_ls', -- Lua
        'gopls', -- Go
        'jdtls', -- Java
        'ts_ls', -- JavaScript, TypeScript
        'pyright', -- Python
      },
    })

    -- 個別のフォーマッター設定
    local conform = require("conform")
    conform.setup({
      formatters_by_ft = {
        sql = { "sql_formatter" },
      },
      default_format_opts = {
        -- フォーマッターがない場合はLSPのフォーマットを実行
        lsp_format = "fallback",
      }
    })

    -- LSP操作のテーブル定義
    lsp_actions = {
      ['type-def'] = vim.lsp.buf.type_definition,
      ['refs'] = vim.lsp.buf.references,
      ['impl'] = vim.lsp.buf.implementation,
      ['code-action'] = vim.lsp.buf.code_action,
      ['rename'] = vim.lsp.buf.rename,
      ['diag'] = vim.diagnostic.open_float,
      ['format'] = conform.format,
    }
  end

  -- Lspコマンド定義
  vim.api.nvim_create_user_command('Lsp', function(opts)
    local action = opts.args
    if action == '' then
      vim.notify('Usage: :Lsp <action>\nAvailable actions: ' .. table.concat(vim.tbl_keys(lsp_actions), ', '), vim.log.levels.INFO)
      return
    end
    if lsp_actions[action] then
      lsp_actions[action]()
    else
      vim.notify('Unknown action: ' .. action, vim.log.levels.ERROR)
    end
  end, {
    nargs = '?',
    complete = function()
      return vim.tbl_keys(lsp_actions)
    end
  })
end)
