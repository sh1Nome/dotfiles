-- -------------------------------
-- プラグイン系
-- -------------------------------
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
-- mini.nvimのモジュールを有効化
require('mini.deps').setup({ path = { package = path_package } })  -- mini.deps
require('mini.jump').setup()     -- ジャンプ機能（f）
require('mini.jump2d').setup()     -- ジャンプ機能（<CR>）

-- 競合するためVSCodeのNeovim拡張機能上では無効化
if not vim.g.vscode then
  require('mini.comment').setup()  -- コメント機能（gcc or gc）
  require('mini.pairs').setup()    -- 括弧補完
  require('mini.diff').setup()     -- 差分表示
  require('mini.files').setup()    -- ファイラー
  require('mini.pick').setup()     -- ファイル/バッファピック
  require('mini.animate').setup()  -- アニメーション
  require('mini.starter').setup() -- スタート画面
  require('mini.statusline').setup()  -- ステータスライン
  require('mini.tabline').setup()     -- タブライン
  require('mini.cursorword').setup()  -- カーソル下の単語ハイライト
  require('mini.indentscope').setup() -- インデントガイド
end

-- -------------------------------
-- システム系
-- -------------------------------
vim.opt.fileencoding = "utf-8"  -- 文字エンコード
vim.opt.backup = false          -- バックアップファイルを作成禁止
vim.opt.swapfile = false        -- スワップファイルを作成禁止
vim.opt.backspace = { "indent", "eol", "start" }  -- バックスペース有効化
vim.opt.clipboard = { "unnamed", "unnamedplus" }  -- システムクリップボードを利用

-- windowsのときはgit bashを開く
if vim.fn.has('win32') == 1 then
    vim.opt.shell = 'C:\\Progra~1\\Git\\bin\\bash.exe'
    vim.opt.shellcmdflag = '-c'
end

-- -------------------------------
-- 表示系
-- -------------------------------
vim.opt.showcmd = true  -- コマンドを表示
vim.opt.number = true  -- 行番号を表示
vim.opt.relativenumber = true  -- 相対行番号を表示（現在行は絶対表示）
vim.opt.showmatch = true  -- 対応する括弧をハイライト
vim.opt.softtabstop = 4  -- タブキー押下時の文字幅
vim.opt.tabstop = 4      -- タブ文字の表示幅
vim.opt.shiftwidth = 4   -- インデント幅
vim.opt.list = true      -- 不可視文字を表示
vim.opt.listchars = { space = "·", tab = "▸ ", eol = "¬", nbsp = "_" }  -- 不可視文字の表示方法
vim.opt.laststatus = 2   -- ステータスラインを常に表示
vim.opt.ruler = true     -- ルーラー（カーソル位置）を表示
vim.opt.showmode = true  -- モード表示を有効化
vim.opt.scrolloff = 3    -- 常に3行のスクロールオフセットを確保
vim.opt.cursorline = true  -- カーソル行をハイライト
vim.opt.expandtab = true   -- タブをスペースに変換
vim.opt.showtabline = 2    -- タブラインを常に表示

-- -------------------------------
-- 検索系
-- -------------------------------
vim.opt.ignorecase = true  -- 大文字小文字を区別しない
vim.opt.incsearch = true   -- 入力中に検索開始
vim.opt.hlsearch = true    -- 検索結果をハイライト

-- -------------------------------
-- キーマッピング
-- -------------------------------
-- リーダーキーをスペースに設定
vim.g.mapleader = ' '

-- バッファ移動
vim.keymap.set('n', '<leader>h', ':bprevious<CR>')  -- 前のバッファへ
vim.keymap.set('n', '<leader>l', ':bnext<CR>')      -- 次のバッファへ

-- 競合するためVSCodeのNeovim拡張機能上では無効化
if not vim.g.vscode then
  -- <leader>fでmini.pickのファイル検索を起動
  vim.keymap.set('n', '<leader>f', ':Pick files<CR>')
  -- <leader>fでmini.pickのファイル検索を起動
  vim.keymap.set('n', '<leader>b', ':Pick buffers<CR>')
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
end
