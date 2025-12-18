local wezterm = require('wezterm')

local config = wezterm.config_builder()

config.use_ime = true

config.initial_cols = 120
config.initial_rows = 28

config.window_background_opacity = 0.85

config.font_size = 11

if wezterm.target_triple:find("windows") then
  config.default_prog = {"C:\\Progra~1\\Git\\bin\\bash.exe"}
else
  config.default_prog = {"bash"}
end

return config
