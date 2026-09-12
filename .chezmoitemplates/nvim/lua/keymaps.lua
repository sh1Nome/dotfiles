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
		require("fzf-lua").lsp_references()
	end, { desc = "References" })
	vim.keymap.set("n", "K", function()
		vim.lsp.buf.hover({ border = "single" })
	end, { desc = "Hover or show diagnostics" })

	-- floatmemoを開く
	vim.keymap.set("n", "<leader>m", function()
		require("floatmemo").toggle()
	end, { desc = "Toggle floatmemo" })

	-- fzf-luaのファイル検索を起動
	vim.keymap.set("n", "<leader>p", function()
		require("fzf-lua").files()
	end, { desc = "Pick files" })

	-- fzf-lua で tgrep を使った検索を起動
	-- mise shims をキルしても tgrep 本体がキルできないことがあるので、tgrep の場所を保存
	local tgrep_cwd = vim.fn.getcwd()
	local tgrep_command = ""
	local resolve_ok, resolve_result = pcall(function()
		return vim.system({ "mise", "which", "tgrep" }, { cwd = tgrep_cwd, text = true }):wait()
	end)
	if resolve_ok and resolve_result.code == 0 then
		tgrep_command = vim.trim(resolve_result.stdout or "")
	end

	vim.keymap.set("n", "<leader>f", function()
		if tgrep_command == "" then
			vim.notify("Failed to resolve tgrep executable with mise", vim.log.levels.ERROR)
			return
		end

		local server
		local start_ok, start_error = pcall(function()
			-- index 作成から .git を除外
			server = vim.system(
				{ tgrep_command, "serve", ".", "--exclude", ".git" },
				{ cwd = tgrep_cwd, detach = true, stderr = false, stdout = false }
			)
		end)
		if not start_ok then
			vim.notify(("Failed to start tgrep server: %s"):format(tostring(start_error)), vim.log.levels.ERROR)
		end

		require("fzf-lua").live_grep({
			cmd = vim.fn.shellescape(tgrep_command) .. " --vimgrep --smart-case --color=always",
			cwd = tgrep_cwd,
			hidden = true,
			actions = {
				-- actions.grep_lgrep をそのまま呼び出すとバグるのでカスタム
				["ctrl-r"] = {
					function()
						require("fzf-lua").grep({
							resume = true,
							multiprocess = 1,
						})
					end,
				},
				-- zellij と競合するので無効化
				["ctrl-g"] = false,
			},
			file_icons = false,
			no_esc = true,
			rg_glob = false,
			prompt = "tgrep> ",
			winopts = {
				on_close = function()
					-- 同一プロジェクトの picker 同時起動は対象外のため、共有所有権を管理しない。
					if server and not server:is_closing() then
						server:kill("sigterm")
					end
				end,
			},
		})
	end, { desc = "tgrep" })

	-- fzf-luaのヘルプ検索を起動
	vim.keymap.set("n", "<leader>h", function()
		require("fzf-lua").helptags()
	end, { desc = "Help" })

	-- fzf-luaの最後のpickerを再開
	vim.keymap.set("n", "<leader>r", function()
		require("fzf-lua").resume()
	end, { desc = "Resume picker" })

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

return {
	get_mini_align_mappings = get_mini_align_mappings,
	get_mini_files_mappings = get_mini_files_mappings,
}
