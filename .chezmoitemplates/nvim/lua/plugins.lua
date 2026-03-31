-- プラグイン系設定 (vim.pack対応)

-- vim.packの初期化とConfig関数の定義
local Config = {}

-- mini.nvimをロード
vim.pack.add({ "https://github.com/nvim-mini/mini.nvim" })

-- ローディングヘルパーの定義
local misc = require("mini.misc")
Config.now = function(f)
	misc.safely("now", f)
end
Config.later = function(f)
	misc.safely("later", f)
end

-- プラグイン追加用の短縮記法
local add = vim.pack.add
local now, later = Config.now, Config.later

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
		require("mini.pairs").setup({
			mappings = {
				-- バッククオートを無効化
				-- マークダウンでコードブロックを書くときに邪魔になるため
				["`"] = false,
			},
		}) -- 括弧補完
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

		-- プラグイン一括追加: 自作, LSP, フォーマッタ
		add({
			"https://github.com/sh1Nome/mini-pick-preview.nvim",
			"https://github.com/sh1Nome/floatmemo.nvim",
			"https://github.com/sh1Nome/floatcli.nvim",
			"https://github.com/sh1Nome/yank-git-remote-url.nvim",
			"https://github.com/neovim/nvim-lspconfig",
			"https://github.com/mason-org/mason.nvim",
			"https://github.com/mason-org/mason-lspconfig.nvim",
			"https://github.com/stevearc/conform.nvim",
		})

		-- mini-pick-preview
		require("mini-pick-preview").setup()

		-- floatmemo
		require("floatmemo").setup({
			border = "single",
			extension = "md",
		})
		-- floatcli
		require("floatcli").setup()

		-- yank-git-remote-url
		require("yank-git-remote-url").setup({
			providers = {
				{
					match = function(host)
						return host:find("github") ~= nil
					end,
					build_url = function(host, repo_path, commit, rel_path, start_line, end_line)
						local base = ("https://%s/%s/blob/%s/%s"):format(host, repo_path, commit, rel_path)
						if not start_line then
							return base
						end
						if start_line == end_line then
							return base .. "#L" .. start_line
						end
						return base .. "#L" .. start_line .. "-L" .. end_line
					end,
				},
				{
					match = function(host)
						return host:find("gitlab") ~= nil
					end,
					build_url = function(host, repo_path, commit, rel_path, start_line, end_line)
						local base = ("https://%s/%s/-/blob/%s/%s"):format(host, repo_path, commit, rel_path)
						if not start_line then
							return base
						end
						if start_line == end_line then
							return base .. "#L" .. start_line
						end
						return base .. "#L" .. start_line .. "-" .. end_line
					end,
				},
			},
		})
		vim.api.nvim_create_user_command("YankGitRemoteUrl", function(opts)
			require("yank-git-remote-url").yank(opts.range, opts.line1, opts.line2)
		end, { range = true, desc = "Open current file on GitHub/GitLab" })
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

	-- プラグイン一括追加: dial, previm, md-table-align
	add({
		"https://github.com/monaqa/dial.nvim",
		"https://github.com/previm/previm",
		"https://github.com/sh1Nome/md-table-align.nvim",
	})

	-- <C-a>と<C-x>の拡張
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
			augend.constant.new({
				elements = { "[ ]", "[x]" }, -- マークダウンのチェックボックス
				word = false, -- 単語の境界になくてもマッチする
			}),
		},
	})

	-- マークダウンプレビュー
	if vim.fn.has("win32") == 1 then
		vim.g.previm_open_cmd = "start"
	else
		vim.g.previm_open_cmd = "xdg-open"
	end
end)

return Config
