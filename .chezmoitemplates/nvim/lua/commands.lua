--- マークダウンテキストを指定形式に変換してクリップボードにコピーする
--- @param opts table ユーザーコマンドのオプション（line1, line2, fargs を含む）
local function pandoc_to_clipboard(opts)
	local format = opts.fargs[1]

	if not format or format == "" then
		vim.notify("Usage: PandocToClipboard <format>", vim.log.levels.ERROR)
		return
	end

	-- Get the range of lines
	local start_line = opts.line1
	local end_line = opts.line2

	-- Get the selected lines
	local lines = vim.fn.getline(start_line, end_line)
	local input_text = table.concat(lines, "\n")

	-- Run pandoc
	vim.system({ "pandoc", "-f", "markdown", "-t", format }, { stdin = input_text }, function(result)
		vim.schedule(function()
			if result.code ~= 0 then
				vim.notify("pandoc error: " .. result.stderr, vim.log.levels.ERROR)
				return
			end

			local output = result.stdout:gsub("\n$", "")

			-- Copy to clipboard registers
			vim.fn.setreg("+", output)
			vim.fn.setreg("*", output)

			vim.notify(string.format("Converted to %s and copied to clipboard", format), vim.log.levels.INFO)
		end)
	end)
end

vim.api.nvim_create_user_command("PandocToClipboard", pandoc_to_clipboard, {
	nargs = 1,
	range = true,
})

--- カレントバッファを指定形式に変換してブラウザで開く
local md_preview_formats = { "html5", "revealjs" }

--- @param opts table ユーザーコマンドのオプション（fargs を含む）
local function md_preview(opts)
	local format = opts.fargs[1] or "html5"

	if not vim.tbl_contains(md_preview_formats, format) then
		vim.notify("Unknown format: " .. format, vim.log.levels.ERROR)
		return
	end

	local lines = vim.fn.getline(1, "$")
	local input_text = table.concat(lines, "\n")
	local output_file = vim.fn.stdpath("data") .. "/preview.html"

	local resource_path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")

	vim.system({
		"pandoc",
		"--standalone",
		"--embed-resources",
		"--resource-path",
		resource_path,
		"-f",
		"markdown",
		"-t",
		format,
	}, { stdin = input_text }, function(result)
		vim.schedule(function()
			if result.code ~= 0 then
				vim.notify("pandoc error: " .. result.stderr, vim.log.levels.ERROR)
				return
			end

			local f = io.open(output_file, "w")
			if not f then
				vim.notify("Failed to write preview file", vim.log.levels.ERROR)
				return
			end
			f:write(result.stdout)
			f:close()

			local _, err = vim.ui.open(output_file)
			if err then
				vim.notify("Failed to open browser: " .. err, vim.log.levels.ERROR)
			end
		end)
	end)
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.api.nvim_buf_create_user_command(0, "MdPreview", md_preview, {
			nargs = "?",
			complete = function()
				return md_preview_formats
			end,
		})
	end,
})

-- 全プラグインをアップデートするコマンド
vim.api.nvim_create_user_command("PackUpdate", function()
	vim.pack.update()
end, { desc = "Update all plugins managed by vim.pack" })

-- 非アクティブなプラグインを削除するコマンド
vim.api.nvim_create_user_command("PackClean", function()
	-- 非アクティブなプラグイン名の一覧
	local inactive = vim.iter(vim.pack.get())
		:filter(function(x)
			return not x.active
		end)
		:map(function(x)
			return x.spec.name
		end)
		:totable()

	-- 非アクティブなプラグインがない
	if vim.tbl_isempty(inactive) then
		vim.notify("No inactive plugins to clean", vim.log.levels.INFO)
		return
	end

	-- プラグイン一覧を表示
	print("The following inactive plugins will be deleted:")
	for _, name in ipairs(inactive) do
		print("  - " .. name)
	end

	-- 確認
	local response = vim.fn.input("Continue? (y/n): ")

	if response ~= "y" then
		vim.notify("Cancelled", vim.log.levels.INFO)
		return
	end

	vim.pack.del(inactive)
	vim.notify(string.format("Deleted %d plugin(s)", #inactive), vim.log.levels.INFO)
end, { desc = "Delete all inactive plugins managed by vim.pack" })

-- プラグインのロードを待つコマンド群
-- laterのキューは登録順に実行されるため、init.luaのrequire順により
-- plugins.luaのプラグイン追加とlang.luaのlsp_actions構築が先に完了する
require("plugins").later(function()
	local lsp_actions = require("lang").lsp_actions

	-- Lコマンド定義
	vim.api.nvim_create_user_command("L", function(opts)
		local action = opts.args
		if action == "" then
			vim.notify(
				"Usage: :L <action>\nAvailable actions: " .. table.concat(vim.tbl_keys(lsp_actions), ", "),
				vim.log.levels.INFO
			)
			return
		end
		if lsp_actions[action] then
			lsp_actions[action]()
		else
			vim.notify("Unknown action: " .. action, vim.log.levels.ERROR)
		end
	end, {
		nargs = "?",
		complete = function(_, cmd, _)
			-- コマンド行から「:L 」の後の入力文字列を抽出
			local input = cmd:match("^%s*L%s+(%S*)$") or ""
			local actions = vim.tbl_keys(lsp_actions)
			if input == "" then
				return actions
			end
			return vim.tbl_filter(function(action)
				-- 入力で始まるアクション名をフィルタリング
				return action:find("^" .. input)
			end, actions)
		end,
	})

	vim.api.nvim_create_user_command("YankGitRemoteUrl", function(opts)
		require("yank-git-remote-url").yank(opts.range, opts.line1, opts.line2)
	end, { range = true, desc = "Copy remote URL to clipboard" })
end)
