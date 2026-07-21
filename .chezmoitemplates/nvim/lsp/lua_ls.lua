-- lua_lsの追加設定。`vim.lsp.enable("lua_ls")`で読み込み、nvim-lspconfigの既定設定にマージする
-- Neovimランタイムの型情報を読ませ、`vim`グローバルの警告解消とhoverを有効化する
return {
	settings = {
		Lua = {
			runtime = {
				-- NeovimのLuaはLuaJIT(Lua 5.1相当)のため標準ライブラリの解釈を合わせる
				version = "LuaJIT",
				-- `require("keymaps")`のようなNeovim流のモジュール解決を教える(:h lua-module-load)
				path = { "lua/?.lua", "lua/?/init.lua" },
			},
			workspace = {
				-- サードパーティライブラリ検出時のプロンプトを抑止
				checkThirdParty = false,
				-- VIMRUNTIMEに加えプラグインの型も解決する
				-- rtpではなくvim.pack.get()を見るため、遅延ロード前のプラグインも拾える
				library = (function()
					local lib = { vim.env.VIMRUNTIME }
					for _, plugin in ipairs(vim.pack.get()) do
						table.insert(lib, plugin.path)
					end
					return lib
				end)(),
			},
		},
	},
}
