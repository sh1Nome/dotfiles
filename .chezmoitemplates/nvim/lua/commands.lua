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
