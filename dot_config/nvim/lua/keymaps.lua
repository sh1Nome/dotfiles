-- キーマッピング設定

-- リーダーキーをスペースに設定
vim.g.mapleader = ' '

-- バッファ移動
vim.keymap.set('n', '<leader>h', ':bprevious<CR>', { desc = 'Previous buffer' }) -- 前のバッファへ
vim.keymap.set('n', '<leader>l', ':bnext<CR>', { desc = 'Next buffer' }) -- 次のバッファへ
vim.keymap.set('n', '<leader>t', ':MdTableAlign<CR>', { desc = 'Align a markdown table' }) -- マークダウンのテーブルを整形

-- 競合するためVSCodeのNeovim拡張機能上では無効化
if not vim.g.vscode then
  -- LSPキーマップ
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Goto Definition' })
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover' })

  -- floatmemoを開く
  vim.keymap.set('n', '<leader>m', ':FloatmemoToggle<CR>', { desc = 'Toggle floatmemo' })

  -- <leader>pでmini.pickのファイル検索を起動
  vim.keymap.set('n', '<leader>p', ':Pick files<CR>', { desc = 'Pick files' })

  -- <leader>fでmini.pickの横断したあいまい検索を起動
  vim.keymap.set('n', '<leader>f', function()
    require('mini.pick').builtin.grep_live()
  end, { desc = 'Live grep' })

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
  end, { desc = 'Toggle file explorer' })

  -- <leader>nでmini.notifyの履歴を表示
  vim.keymap.set('n', '<leader>n', function()
    MiniNotify.show_history()
  end, { desc = 'Show notifications' })

  -- lazygitを開く
  vim.keymap.set('n', '<leader>g', ':LazyGit<CR>', { desc = 'LazyGit' })
end

-- mini.align用のキーマップ設定を返す関数
local function get_mini_align_mappings()
  return {
    start = '<leader>a',
    start_with_preview = '',
  }
end

return { get_mini_align_mappings = get_mini_align_mappings }
