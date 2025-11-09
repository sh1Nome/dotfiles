-- キーマッピング設定

-- リーダーキーをスペースに設定
vim.g.mapleader = ' '

-- バッファ移動
vim.keymap.set('n', '<leader>h', ':bprevious<CR>')  -- 前のバッファへ
vim.keymap.set('n', '<leader>l', ':bnext<CR>')      -- 次のバッファへ

vim.keymap.set('n', '<leader>t', ':TableModeRealign<CR>')      -- テーブルを整形

-- 競合するためVSCodeのNeovim拡張機能上では無効化
if not vim.g.vscode then
  -- LSPキーマップ
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Goto Definition' })
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover' })

  -- <leader>pでmini.pickのファイル検索を起動
  vim.keymap.set('n', '<leader>p', ':Pick files<CR>')

  -- <leader>bでmini.pickのバッファ検索を起動
  vim.keymap.set('n', '<leader>b', ':Pick buffers<CR>')

  -- <leader>fでmini.pickの横断したあいまい検索を起動
  vim.keymap.set('n', '<leader>f', function()
    require('mini.pick').builtin.grep_live()
  end, { desc = 'Live grep (fuzzy find across files)' })

  -- <leader>eでmini.filesを起動（カレントディレクトリ or CWD）
  local MiniFiles = require('mini.files')
  -- mini.filesのトグル関数
  local minifiles_toggle = function(...)
    if not MiniFiles.close() then MiniFiles.open(...) end
  end
  vim.keymap.set('n', '<leader>e', function()
    local file = vim.fn.expand('%:p')
    local dir
    if file == '' or vim.fn.filereadable(file) == 0 then
      -- バッファが空、またはファイルが存在しない場合はCWDを使用
      dir = vim.fn.getcwd()
    else
      -- それ以外はカレントディレクトリを使用
      dir = vim.fn.fnamemodify(file, ':h')
    end
    minifiles_toggle(dir)
  end, { desc = 'Toggle mini.files (current dir or CWD)' })

  -- lazygitを開く
  vim.keymap.set('n', '<leader>g', ':LazyGit<CR>')

  -- <leader>dで差分を表示する
  vim.keymap.set('n', '<leader>d', function()
    if next(require('diffview.lib').views) == nil then
      vim.cmd('DiffviewOpen')
    else
      vim.cmd('DiffviewClose')
    end
  end)
end
