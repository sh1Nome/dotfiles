local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- ウィンドウの外観
-- タイトルバーとボーダーを非表示
if wezterm.target_triple:find("windows") then
	config.window_decorations = "RESIZE"
else
	config.window_decorations = "NONE"
end
config.window_background_opacity = 0.75 -- 背景の透明度（0.0-1.0）

-- タブ
config.show_new_tab_button_in_tab_bar = false -- タブバーの「+」ボタンを非表示
config.tab_bar_at_bottom = true -- タブバーをウィンドウの下に表示
config.use_fancy_tab_bar = false -- レトロなタブバーを使用する
local inactive_tab = {
	bg_color = "#5c6d74", -- 非アクティブなタブの背景色
	fg_color = "#ffffff", -- 非アクティブなタブの文字色
}
config.colors = {
	tab_bar = {
		background = "none",

		-- アクティブタブ
		active_tab = {
			-- タブの背景色
			bg_color = "#ae8b2d",
			-- タブの文字色
			fg_color = "#ffffff",
		},

		-- 非アクティブなタブ
		inactive_tab = inactive_tab,
		inactive_tab_hover = inactive_tab,
	},
}

-- フォント
config.font_size = 11 -- フォントサイズ
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" } -- リガチャを無効化

-- IME
config.use_ime = true -- 日本語入力の有効化

-- シェル設定
if wezterm.target_triple:find("windows") then
	config.default_prog = { "C:\\Progra~1\\Git\\bin\\bash.exe" } -- Windows環境でGit Bashを使用
else
	config.default_prog = { "bash" } -- Unix環境でbashを使用
end

return config
