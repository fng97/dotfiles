local wezterm = require("wezterm")
local config = {}

config.font = wezterm.font("JetBrains Mono")
config.color_scheme = "tokyonight"
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"

config.wsl_domains = {
	{
		name = "WSL:Ubuntu",
		distribution = "Ubuntu",
	},
}

config.default_domain = "WSL:Ubuntu"

return config
