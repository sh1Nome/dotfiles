-- LSP設定
local M = {}

-- lsp_actionsはlater内で構築されるため、later実行後にのみ有効
require("plugins").later(function()
	if vim.g.vscode then
		-- VSCode環境: VSCodeコマンドのみ使用
		local vscode = require("vscode")
		M.lsp_actions = {
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
		vim.lsp.enable({
			"lua_ls",
			"gopls",
			"jdtls",
			"ts_ls",
			"pyright",
			"clangd",
			"rust_analyzer",
			"zk",
		})

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
		M.lsp_actions = {
			["type-def"] = function()
				require("fzf-lua").lsp_typedefs()
			end,
			["impl"] = function()
				require("fzf-lua").lsp_implementations()
			end,
			["code-action"] = vim.lsp.buf.code_action,
			["rename"] = vim.lsp.buf.rename,
			["diag"] = function()
				require("fzf-lua").diagnostics_document()
			end,
			["format"] = conform.format,
			["symbol"] = function()
				require("fzf-lua").lsp_document_symbols()
			end,
		}
	end
end)

return M
