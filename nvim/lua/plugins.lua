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
-- `:DepsUpdate`でプラグインをアップデート
-- `:DepsClean`で不要なプラグインを削除
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
    require('mini.statusline').setup() -- ステータスライン
    require('mini.tabline').setup() -- タブライン
    require('mini.comment').setup() -- コメント機能（gcc or gc）
    require('mini.pairs').setup() -- 括弧補完
    require('mini.diff').setup() -- 差分表示
    require('mini.files').setup() -- ファイラー
    require('mini.pick').setup() -- ファイル/バッファピック
    require('mini.animate').setup() -- アニメーション
    require('mini.cursorword').setup() -- カーソル下の単語ハイライト
    require('mini.indentscope').setup() -- インデントガイド
    require('mini.completion').setup({}) -- 補完

    local miniclue = require('mini.clue') -- キーマップを表示
    miniclue.setup({
      -- リーダーキーのみトリガー
      triggers = {
        { mode = 'n', keys = '<Leader>' },
        { mode = 'x', keys = '<Leader>' },
      },
      window = {
        delay = 0, -- 遅延なしで表示
      },
    })

    -- lazygit
    add({
      source = 'kdheepak/lazygit.nvim',
    })

    -- floatmemo
    add({
      source = 'sh1Nome/floatmemo.nvim',
    })
    require('floatmemo').setup()

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
    add({
      -- フォーマット
      source = 'stevearc/conform.nvim',
    })
  end)
end

now(function()
  -- vscodeの設定
  if vim.g.vscode then
    local vscode = require('vscode')
    vim.notify = vscode.notify -- 通知
    -- `:bd`でバッファを削除したらvscodeのタブを閉じる
    vim.api.nvim_create_autocmd("CmdlineLeave", {
      pattern = ":",
      callback = function()
        local cmd = vim.fn.getcmdline()
        if cmd:match("^bd") then
          vscode.call('workbench.action.closeActiveEditor')
        end
      end
    })
  end
end)

later(function()
  require('mini.jump').setup() -- ジャンプ機能（f）
  require('mini.surround').setup() -- サラウンド機能（sa, sr, sd）
  require('mini.align').setup({
    mappings = require('keymaps').get_mini_align_mappings(),
  }) -- 整列

  add({
    source = 'sh1Nome/md-table-align.nvim', -- mdのテーブルを整形
  })
end)
