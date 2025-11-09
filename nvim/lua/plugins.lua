-- プラグイン系設定

-- mini.nvimをインストール
local path_package = vim.fn.stdpath('data') .. '/site'
local mini_path = path_package .. '/pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = {
    'git', 'clone', '--filter=blob:none',
    'https://github.com/nvim-mini/mini.nvim', mini_path
  }
  vim.fn.system(clone_cmd)
  vim.cmd('packadd mini.nvim | helptags ALL')
  vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- mini.nvimのモジュールとプラグインを有効化
require('mini.deps').setup({ path = { package = path_package } })
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- 競合するためVSCodeのNeovim拡張機能上では無効化
if not vim.g.vscode then
  -- 即時ロード
  now(function()
    require('mini.notify').setup({
      -- `:lua MiniNotify.show_history()`で通知履歴を見れる
      -- 右下に表示
      window = { config = function()
        local has_statusline = vim.o.laststatus > 0
        local pad = vim.o.cmdheight + (has_statusline and 1 or 0)
        return { anchor = 'SE', col = vim.o.columns, row = vim.o.lines - pad }
      end }
    })
  end)

  -- 遅延ロード: 初回使用時で十分なもの
  later(function()
    require('mini.statusline').setup()  -- ステータスライン
    require('mini.tabline').setup()     -- タブライン
    require('mini.comment').setup()  -- コメント機能（gcc or gc）
    require('mini.pairs').setup()    -- 括弧補完
    require('mini.diff').setup()     -- 差分表示
    require('mini.files').setup()    -- ファイラー
    require('mini.pick').setup()     -- ファイル/バッファピック
    require('mini.animate').setup()  -- アニメーション
    require('mini.cursorword').setup()  -- カーソル下の単語ハイライト
    require('mini.indentscope').setup() -- インデントガイド

    -- 差分表示
    add({
      source = 'sindrets/diffview.nvim',
    })
    require('diffview').setup({
      use_icons = false,
    })

    -- lazygit
    add({
      source = 'kdheepak/lazygit.nvim',
    })

    -- lsp
    add({
      -- `:h lspconfig-all`ですべての設定を見る
      source = 'neovim/nvim-lspconfig'
    })
    add({
      -- `:Mason`でグラフィカルなステータスウィンドウを開く
      source = 'mason-org/mason.nvim',
    })
    add({
      source = 'mason-org/mason-lspconfig.nvim',
      depends = { 
        'mason-org/mason.nvim',
        'neovim/nvim-lspconfig'
      },
    })
  end)
end

now(function()
  -- vscodeの設定
  if vim.g.vscode then
    local vscode = require('vscode')
    vim.notify = vscode.notify  -- 通知
    -- バッファを削除したらvscodeのタブを閉じる
    vim.api.nvim_create_autocmd("BufDelete", {
      pattern = "*",
      callback = function()
        vscode.call('workbench.action.closeActiveEditor')
      end
    })
  end
end)

later(function()
  require('mini.jump').setup()     -- ジャンプ機能（f）
  require('mini.surround').setup()   -- サラウンド機能（sa, sr, sd）

  -- テーブル
  add({
    source = 'dhruvasagar/vim-table-mode',
  })
  vim.g.table_mode_corner = '|'
end)
