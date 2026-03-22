local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- ウィンドウの外観
-- タイトルバーとボーダーを非表示
if wezterm.target_triple:find("windows") then
	config.window_decorations = "RESIZE"
else
	config.window_decorations = "NONE"
end

-- タブ
config.show_new_tab_button_in_tab_bar = false -- タブバーの「+」ボタンを非表示
config.show_close_tab_button_in_tabs = false -- タブバーの「x」ボタンを非表示
config.tab_max_width = 32 -- タブの最大幅

-- フォント
config.font = wezterm.font("Noto Sans Mono CJK JP") -- フォントを指定
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
