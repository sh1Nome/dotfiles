-- LSP設定
MiniDeps.later(function()
  local conform = require("conform")

  if not vim.g.vscode then
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
    conform.setup({
      formatters_by_ft = {
        sql = { "sql_formatter" },
      },
      default_format_opts = {
        -- フォーマッターがない場合はLSPのフォーマットを実行
        lsp_format = "fallback",
      }
    })
  end

  -- VSCode と Neovim 両環境対応のラッパー関数
  local function with_vscode_fallback(vscode_command, nvim_function)
    return function()
      if vim.g.vscode then
        require('vscode').call(vscode_command)
      else
        nvim_function()
      end
    end
  end

  -- LSP操作のテーブル定義
  local lsp_actions = {
    ['type-def'] = with_vscode_fallback('editor.action.goToTypeDefinition', vim.lsp.buf.type_definition),
    ['refs'] = with_vscode_fallback('editor.action.referenceSearch.trigger', vim.lsp.buf.references),
    ['impl'] = with_vscode_fallback('editor.action.goToImplementation', vim.lsp.buf.implementation),
    ['code-action'] = with_vscode_fallback('editor.action.codeAction', vim.lsp.buf.code_action),
    ['rename'] = with_vscode_fallback('editor.action.rename', vim.lsp.buf.rename),
    ['diag'] = with_vscode_fallback('editor.action.showHover', vim.diagnostic.open_float),
    ['format'] = with_vscode_fallback('editor.action.formatDocument', conform.format),
  }

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
