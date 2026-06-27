-- キーマッピング設定

-- リーダーキーをスペースに設定
vim.g.mapleader = " "

vim.keymap.set("n", "<leader>t", function()
	require("md-table-align").align_table()
end, { desc = "Align a markdown table" }) -- マークダウンのテーブルを整形

-- VSCode Neovimとの競合回避
if vim.g.vscode then
	local vscode = require("vscode")
	-- VSCode Neovim用のLSPキーマップ
	-- gd, KはVSCode Neovimでデフォルトで使えるため未設定
	vim.keymap.set("n", "gr", function()
		vscode.call("editor.action.referenceSearch.trigger")
	end, { desc = "References" })
else
	-- LSPキーマップ
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Goto Definition" })
	vim.keymap.set("n", "gr", function()
		require("mini.extra").pickers.lsp({ scope = "references" })
	end, { desc = "References" })
	vim.keymap.set("n", "K", function()
		-- vim.fn.line(".") は 1 始まり、vim.diagnostic.get() の lnum は 0 始まり
		local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
		if #diagnostics > 0 then
			vim.diagnostic.open_float({ border = "single" })
		else
			vim.lsp.buf.hover({ border = "single" })
		end
	end, { desc = "Hover or show diagnostics" })

	-- floatmemoを開く
	vim.keymap.set("n", "<leader>m", function()
		require("floatmemo").toggle()
	end, { desc = "Toggle floatmemo" })

	-- gitリポジトリかどうかを判定
	local function is_git_repo()
		local result = vim.system({ "git", "rev-parse", "--git-dir" }, { text = true }):wait()
		return result.code == 0
	end

	-- mini.pickのファイル検索を起動（gitリポジトリならgit、そうでないならrg）
	vim.keymap.set("n", "<leader>p", function()
		local tool = is_git_repo() and "git" or "rg"
		require("mini.pick").builtin.files({ tool = tool })
	end, { desc = "Pick files (S-Tab: show keymaps)" })

	-- mini.pickの横断したあいまい検索を起動（gitリポジトリならgit、そうでないならrg）
	vim.keymap.set("n", "<leader>f", function()
		local tool = is_git_repo() and "git" or "rg"
		require("mini.pick").builtin.grep_live({ tool = tool })
	end, { desc = "Live grep (C-o: glob, S-Tab: show keymaps)" })

	-- 最近訪問したファイルを起動
	vim.keymap.set("n", "<leader>v", function()
		require("mini.extra").pickers.visit_paths()
	end, { desc = "Pick visited files (S-Tab: show keymaps)" })

	-- mini.pickのヘルプ検索を起動
	vim.keymap.set("n", "<leader>h", function()
		require("mini.pick").builtin.help()
	end, { desc = "Help (S-Tab: show keymaps)" })

	-- mini.pickの最後のpickerを再開
	vim.keymap.set("n", "<leader>r", function()
		require("mini.pick").builtin.resume()
	end, { desc = "Resume picker (S-Tab: show keymaps)" })

	-- zk-nvim
	vim.keymap.set("n", "<leader>zn", function()
		vim.cmd("ZkNew")
	end, { desc = "zk new" })
	vim.keymap.set("n", "<leader>zt", function()
		vim.cmd("ZkIndex")
		vim.cmd("ZkTags")
	end, { desc = "zk tag" })
	vim.keymap.set("n", "<leader>zl", function()
		vim.cmd("ZkIndex")
		vim.cmd("ZkNotes")
	end, { desc = "zk list" })

	-- mini.filesを起動
	vim.keymap.set("n", "<leader>e", function()
		-- mini.filesをトグルする（開いているバッファ）
		if not require("mini.files").close() then
			local buf_name = vim.api.nvim_buf_get_name(0)
			-- URL形式のバッファ名はローカルファイルシステムのパスではないため、空文字列を渡す
			if buf_name:match("^[a-z]+://") then
				buf_name = ""
			end
			require("mini.files").open(buf_name, false)
			-- mini.filesを開いたらcwdを表示する
			require("mini.files").reveal_cwd()
		end
	end, { desc = "Toggle file explorer" })

	-- mini.notifyの履歴を表示
	vim.keymap.set("n", "<leader>n", function()
		require("mini.notify").show_history()
	end, { desc = "Show notifications" })

	-- スニペットを選択して展開
	vim.keymap.set("n", "<leader>s", function()
		require("mini.snippets").expand({ match = false })
	end, { desc = "Pick and expand snippets" })

	-- floatcliの設定
	-- bashを開く
	vim.keymap.set("n", "<leader>b", function()
		require("floatcli").open({
			commands = { "bash" },
		})
	end, { desc = "Float shell" })

	-- quickfixウィンドウが開いているか判定
	local function is_quickfix_open()
		return vim.iter(vim.fn.getwininfo()):any(function(wininfo)
			return wininfo.quickfix == 1
		end)
	end

	-- quickfixのトグル
	vim.keymap.set("n", "<leader>q", function()
		if is_quickfix_open() then
			vim.cmd("cclose")
		else
			vim.cmd("copen")
		end
	end, { desc = "Toggle quickfix" })

	-- quickfixウィンドウから出たら自動的に閉じる
	vim.api.nvim_create_autocmd("WinEnter", {
		callback = function()
			local current_win = vim.api.nvim_get_current_win()
			local current_win_quickfix = vim.fn.getwininfo(current_win)[1].quickfix
			if is_quickfix_open() and current_win_quickfix ~= 1 then
				vim.cmd("cclose")
			end
		end,
	})
end

-- mini.align用のキーマップ設定を返す関数
local function get_mini_align_mappings()
	return {
		start = "<leader>a",
		start_with_preview = "",
	}
end

-- mini.files用のキーマップ設定を返す関数
local function get_mini_files_mappings()
	return {
		go_in = "",
		go_in_plus = "<CR>",
		go_out = "",
		go_out_plus = "-",
	}
end

-- mini.pick用のキーマップ設定を返す関数
local function get_mini_pick_mappings()
	return {
		choose_marked = "<C-q>",
	}
end

return {
	get_mini_align_mappings = get_mini_align_mappings,
	get_mini_files_mappings = get_mini_files_mappings,
	get_mini_pick_mappings = get_mini_pick_mappings,
}
