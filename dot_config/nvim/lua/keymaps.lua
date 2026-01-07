-- キーマッピング設定

-- リーダーキーをスペースに設定
vim.g.mapleader = " "

-- バッファ移動
vim.keymap.set("n", "<leader>h", ":bprevious<CR>", { desc = "Previous buffer" }) -- 前のバッファへ
vim.keymap.set("n", "<leader>l", ":bnext<CR>", { desc = "Next buffer" }) -- 次のバッファへ
vim.keymap.set("n", "<leader>t", ":MdTableAlign<CR>", { desc = "Align a markdown table" }) -- マークダウンのテーブルを整形
vim.keymap.set("n", "<C-a>", function()
	require("dial.map").manipulate("increment", "normal")
end)
vim.keymap.set("n", "<C-x>", function()
	require("dial.map").manipulate("decrement", "normal")
end)
vim.keymap.set("x", "<C-a>", function()
	require("dial.map").manipulate("increment", "visual")
end)
vim.keymap.set("x", "<C-x>", function()
	require("dial.map").manipulate("decrement", "visual")
end)

-- 競合するためVSCodeのNeovim拡張機能上では無効化
if not vim.g.vscode then
	-- LSPキーマップ
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Goto Definition" })
	vim.keymap.set("n", "K", function()
		vim.lsp.buf.hover({ border = "single" })
	end, { desc = "Hover" })

	-- floatmemoを開く
	vim.keymap.set("n", "<leader>m", ":FloatmemoToggle<CR>", { desc = "Toggle floatmemo" })

	-- mini.pickのファイル検索を起動
	vim.keymap.set("n", "<leader>p", ":Pick files<CR>", { desc = "Pick files" })

	-- mini.pickのバッファ検索を起動
	vim.keymap.set("n", "<leader>b", ":Pick buffers<CR>", { desc = "Pick buffers" })

	-- mini.pickの横断したあいまい検索を起動
	vim.keymap.set("n", "<leader>f", function()
		require("mini.pick").builtin.grep_live()
	end, { desc = "Live grep" })

	-- mini.filesを起動
	vim.keymap.set("n", "<leader>e", function()
		local MiniFiles = require("mini.files")
		-- mini.filesをトグルする（開いているバッファ）
		if not MiniFiles.close() then
			local buf_name = vim.api.nvim_buf_get_name(0)
			-- URL形式のバッファ名はローカルファイルシステムのパスではないため、空文字列を渡す
			if buf_name:match("^[a-z]+://") then
				buf_name = ""
			end
			MiniFiles.open(buf_name, false)
		end
		-- mini.filesを開いたらcwdを表示する
		MiniFiles.reveal_cwd()
	end, { desc = "Toggle file explorer" })

	-- mini.notifyの履歴を表示
	vim.keymap.set("n", "<leader>n", function()
		MiniNotify.show_history()
	end, { desc = "Show notifications" })

	-- floatcliの設定
	-- bashを開く
	vim.keymap.set("n", "<leader>s", function()
		require("floatcli").open({
			commands = { "bash" },
		})
	end, { desc = "Float shell" })
	-- マークダウンをプレビューする（markdown ファイルのみ）
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "markdown",
		callback = function()
			vim.keymap.set("n", "<leader>r", function()
				-- 開いているバッファのパスの区切り文字を置換（Windows用）
				local buf = vim.api.nvim_buf_get_name(0):gsub("\\", "/")
				require("floatcli").open({
					commands = { "glow -t '" .. buf .. "'" },
				})
			end, { desc = "Preview markdown", buffer = true })
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
