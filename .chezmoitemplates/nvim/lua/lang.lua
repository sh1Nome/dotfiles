-- LSP設定
require("plugins").later(function()
	local lsp_actions

	if vim.g.vscode then
		-- VSCode環境: VSCodeコマンドのみ使用
		local vscode = require("vscode")
		lsp_actions = {
			["type-def"] = function()
				vscode.call("editor.action.goToTypeDefinition")
			end,
			["impl"] = function()
				vscode.call("editor.action.goToImplementation")
			end,
			["code-action"] = function()
				vscode.call("editor.action.codeAction")
			end,
			["rename"] = function()
				vscode.call("editor.action.rename")
			end,
			["diag"] = function()
				vscode.call("editor.action.showHover")
			end,
			["format"] = function()
				vscode.call("editor.action.formatDocument")
			end,
			["symbol"] = function()
				vscode.call("workbench.action.gotoSymbol")
			end,
		}
	else
		-- Neovim環境: LSP + conform を使用
		-- `:h lspconfig-all`ですべての設定を見る
		-- `:Mason`でグラフィカルなステータスウィンドウを開く
		-- 使用中の LSP
		-- lua_ls, gopls, jdtls, ts_ls, pyright, clangd, rust-analyzer
		require("mason").setup({
			ui = {
				border = "single",
			},
		})
		require("mason-lspconfig").setup()

		-- 個別のフォーマッター設定
		local conform = require("conform")
		conform.setup({
			formatters_by_ft = {
				sql = { "sql_formatter" },
				lua = { "stylua" },
				typescript = { "prettier" },
				javascript = { "prettier" },
				vue = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				jsonc = { "prettier" },
			},
			default_format_opts = {
				-- フォーマッターがない場合はLSPのフォーマットを実行
				lsp_format = "fallback",
			},
		})

		-- LSP操作のテーブル定義
		lsp_actions = {
			["type-def"] = function()
				require("mini.extra").pickers.lsp({ scope = "type_definition" })
			end,
			["impl"] = function()
				require("mini.extra").pickers.lsp({ scope = "implementation" })
			end,
			["code-action"] = vim.lsp.buf.code_action,
			["rename"] = vim.lsp.buf.rename,
			["diag"] = function()
				require("mini.extra").pickers.diagnostic({ scope = "current" })
			end,
			["format"] = conform.format,
			["symbol"] = function()
				require("mini.extra").pickers.lsp({ scope = "document_symbol" })
			end,
		}
	end

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
end)
