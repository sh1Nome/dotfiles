local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- ウィンドウの外観
-- タイトルバーとボーダーを非表示
if wezterm.target_triple:find("windows") then
	config.window_decorations = "RESIZE"
else
	config.window_decorations = "NONE"
end
config.window_background_opacity = 0.85 -- 背景の透明度（0.0-1.0）

-- タブ
config.show_new_tab_button_in_tab_bar = false -- タブバーの「+」ボタンを非表示

-- フォント
config.font_size = 11 -- フォントサイズ

-- IME
config.use_ime = true -- 日本語入力の有効化

-- シェル設定
if wezterm.target_triple:find("windows") then
	config.default_prog = { "C:\\Progra~1\\Git\\bin\\bash.exe" } -- Windows環境でGit Bashを使用
else
	config.default_prog = { "bash" } -- Unix環境でbashを使用
end

return config
