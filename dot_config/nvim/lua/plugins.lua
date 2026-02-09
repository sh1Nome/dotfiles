-- プラグイン系設定

-- mini.nvimをインストール
local path_package = vim.fn.stdpath("data") .. "/site"
local mini_path = path_package .. "/pack/deps/start/mini.nvim"
if not vim.loop.fs_stat(mini_path) then
	vim.cmd('echo "Installing `mini.nvim`" | redraw')
	local clone_cmd = {
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/nvim-mini/mini.nvim",
		mini_path,
	}
	vim.fn.system(clone_cmd)
	vim.cmd("packadd mini.nvim | helptags ALL")
	vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- mini.nvimのモジュールとプラグインを有効化
-- `:DepsUpdate`でプラグインをアップデート
-- `:DepsClean`で不要なプラグインを削除
require("mini.deps").setup({ path = { package = path_package } })
local add, now, later = require("mini.deps").add, require("mini.deps").now, require("mini.deps").later

-- 競合するためVSCodeのNeovim拡張機能上では無効化
if not vim.g.vscode then
	-- 即時ロード
	now(function()
		require("mini.notify").setup({
			-- `:lua MiniNotify.show_history()`で通知履歴を見れる
			-- 右下に表示
			window = {
				config = function()
					local has_statusline = vim.o.laststatus > 0
					local pad = vim.o.cmdheight + (has_statusline and 1 or 0)
					return { anchor = "SE", col = vim.o.columns, row = vim.o.lines - pad }
				end,
			},
		})
	end)

	-- 遅延ロード: 初回使用時で十分なもの
	later(function()
		require("mini.icons").setup() -- アイコン
		require("mini.statusline").setup() -- ステータスライン
		require("mini.diff").setup() -- 差分表示
		require("mini.files").setup({
			mappings = require("keymaps").get_mini_files_mappings(),
		}) -- ファイラー
		require("mini.pick").setup({
			window = {
				config = {
					width = math.floor((vim.o.columns - 8) / 2),
				},
			},
		}) -- ピッカー
		local animate = require("mini.animate") -- アニメーション
		animate.setup({
			cursor = {
				-- 50ミリ秒の線形アニメーション
				timing = animate.gen_timing.linear({ duration = 50, unit = "total" }),
				-- すべてのカーソル移動に対してアニメーション
				path = animate.gen_path.line({
					predicate = function()
						return true
					end,
				}),
			},
			scroll = {
				-- 50ミリ秒の線形アニメーション
				timing = animate.gen_timing.linear({ duration = 50, unit = "total" }),
			},
		})
		require("mini.cursorword").setup() -- カーソル下の単語ハイライト
		require("mini.indentscope").setup({
			draw = {
				delay = 0, -- 遅延なし
				animation = require("mini.indentscope").gen_animation.none(), -- アニメーションを無効化
			},
			options = {
				indent_at_cursor = false, -- カーソル列を無視
			},
		}) -- インデントガイド
		require("mini.completion").setup() -- 補完
		require("mini.cmdline").setup() -- コマンドライン
		require("mini.trailspace").setup() -- 末尾の空白をハイライト
		require("mini.visits").setup() -- ファイルアクセス履歴追跡
		require("mini.git").setup() -- `:Git`コマンドを追加
		-- 括弧補完
		require("mini.pairs").setup({
			mappings = {
				-- バッククオートを無効化
				-- マークダウンでコードブロックを書くときに邪魔になるため
				["`"] = false,
			},
		})
		require("mini.extra").setup() -- 追加

		require("mini.clue").setup({
			-- リーダーキーのみトリガー
			triggers = {
				{ mode = "n", keys = "<Leader>" }, -- ノーマルモード
				{ mode = "x", keys = "<Leader>" }, -- ビジュアルモード
			},
			window = {
				delay = 0, -- 遅延なしで表示
			},
		}) -- キーマップを表示

		-- mini-pick-preview
		add({
			source = "sh1Nome/mini-pick-preview.nvim",
			depends = { "nvim-mini/mini.nvim" },
		})
		require("mini-pick-preview").setup()

		-- floatmemo
		add({
			source = "sh1Nome/floatmemo.nvim",
		})
		require("floatmemo").setup({
			border = "single",
			extension = "md",
		})
		-- floatcli
		add({
			source = "sh1Nome/floatcli.nvim",
		})
		require("floatcli").setup()

		-- lsp
		add({
			-- `:h lspconfig-all`ですべての設定を見る
			source = "neovim/nvim-lspconfig",
		})
		add({
			-- `:Mason`でグラフィカルなステータスウィンドウを開く
			source = "mason-org/mason.nvim",
		})
		add({
			source = "mason-org/mason-lspconfig.nvim",
			depends = {
				"mason-org/mason.nvim",
				"neovim/nvim-lspconfig",
			},
		})
		add({
			-- フォーマット
			source = "stevearc/conform.nvim",
		})
	end)
end

now(function()
	-- vscodeの設定
	if vim.g.vscode then
		local vscode = require("vscode")
		vim.notify = vscode.notify -- 通知
		-- `:bd`でバッファを削除したらvscodeのタブを閉じる
		vim.api.nvim_create_autocmd("CmdlineLeave", {
			pattern = ":",
			callback = function()
				local cmd = vim.fn.getcmdline()
				if cmd:match("^bd") then
					vscode.call("workbench.action.closeActiveEditor")
				end
			end,
		})
	end
end)

later(function()
	-- サラウンド機能（sa, sr, sd）
	require("mini.surround").setup({
		custom_surroundings = {
			-- 左括弧は全角、右括弧は半角
			["("] = {
				input = { "（().-()）" },
				output = { left = "（", right = "）" },
			},
			["["] = {
				input = { "「().-()」" },
				output = { left = "「", right = "」" },
			},
			["{"] = {
				input = { "｛().-()｝" },
				output = { left = "｛", right = "｝" },
			},
			["<"] = {
				input = { "＜().-()＞" },
				output = { left = "＜", right = "＞" },
			},
		},
	})
	require("mini.align").setup({
		mappings = require("keymaps").get_mini_align_mappings(),
	}) -- 整列

	add({
		source = "monaqa/dial.nvim", -- <C-a>と<C-x>の拡張
	})
	local augend = require("dial.augend")
	require("dial.config").augends:register_group({
		default = {
			-- nvimのデフォルト動作に近づける`nrformats (default "bin,hex")`
			augend.integer.alias.decimal_int,
			augend.integer.alias.hex,
			augend.integer.alias.binary,
			-- ここからカスタム
			augend.constant.alias.bool, -- true, false
			augend.constant.alias.Bool, -- True, False
			augend.constant.new({ elements = { "あり", "なし" } }),
			augend.constant.new({
				elements = { "[ ]", "[x]" }, -- マークダウンのチェックボックス
				word = false, -- 単語の境界になくてもマッチする
			}),
		},
	})

	-- マークダウンプレビュー
	add({
		source = "previm/previm",
	})
	if vim.fn.has("win32") == 1 then
		vim.g.previm_open_cmd = "start"
	else
		vim.g.previm_open_cmd = "xdg-open"
	end

	add({
		source = "sh1Nome/md-table-align.nvim", -- mdのテーブルを整形
	})
end)
