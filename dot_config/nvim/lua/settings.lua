-- エディタ設定

-- システム系
vim.opt.fileencoding = "utf-8" -- 文字エンコード
vim.opt.backup = false -- バックアップファイルを作成禁止
vim.opt.swapfile = false -- スワップファイルを作成禁止
vim.opt.backspace = { "indent", "eol", "start" } -- バックスペース有効化
vim.opt.clipboard = { "unnamedplus" } -- システムクリップボードを利用（xclipなどが必要）
vim.opt.updatetime = 1000 -- カーソル停止と判定されるまでの時間(ms)

-- Windowsのときはgit bashを開く
if vim.fn.has("win32") == 1 then
	vim.opt.shell = "C:\\Progra~1\\Git\\bin\\bash.exe"
	vim.opt.shellcmdflag = "-c"
	vim.opt.shellxquote = ""
end

-- 表示系
vim.opt.showcmd = true -- コマンドを表示
vim.opt.number = true -- 行番号を表示
vim.opt.relativenumber = true -- 相対行番号を表示（現在行は絶対表示）
vim.api.nvim_create_autocmd("TermOpen", { -- ターミナルでも常時相対行番号を表示
	callback = function()
		vim.opt_local.number = true
		vim.opt_local.relativenumber = true
	end,
})
vim.api.nvim_create_autocmd("FileType", { -- ヘルプページでも行番号を表示
	pattern = "help",
	callback = function()
		vim.opt_local.number = true
		vim.opt_local.relativenumber = true
	end,
})
vim.opt.showmatch = true -- 対応する括弧をハイライト
vim.opt.softtabstop = 2 -- タブキー押下時の文字幅
vim.opt.tabstop = 2 -- タブ文字の表示幅
vim.opt.shiftwidth = 2 -- インデント幅
vim.opt.pumheight = 10 -- ポップアップメニューの最大行数
vim.opt.list = true -- 不可視文字を表示
vim.opt.listchars = { space = "·", tab = "▸ ", eol = "¬", nbsp = "_" } -- 不可視文字の表示方法
vim.opt.laststatus = 2 -- ステータスラインを常に表示
vim.opt.ruler = true -- ルーラー（カーソル位置）を表示
vim.opt.showmode = true -- モード表示を有効化
vim.opt.scrolloff = 3 -- 常に3行のスクロールオフセットを確保
vim.opt.cursorline = true -- カーソル行をハイライト
vim.opt.expandtab = true -- タブをスペースに変換
vim.opt.wrap = false -- 行末で折り返さない
vim.opt.colorcolumn = "80" -- 80文字目に縦線を表示
vim.api.nvim_set_hl(0, "Normal", { bg = "none" }) -- 通常のテキスト背景を透明化
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" }) -- フロートウィンドウの背景を透明化
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" }) -- フロートボーダーの背景を透明化
vim.api.nvim_set_hl(0, "Visual", { fg = "#000000", bg = "#CC6600" }) -- ビジュアルモード選択時のハイライト
vim.api.nvim_create_autocmd("TextYankPost", { -- ヤンクした範囲をハイライト
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- 検索系
vim.opt.ignorecase = true -- 大文字小文字を区別しない
vim.opt.incsearch = true -- 入力中に検索開始
vim.opt.hlsearch = true -- 検索結果をハイライト
vim.cmd("packadd nohlsearch") -- 自動で:nohlsearchを実行
