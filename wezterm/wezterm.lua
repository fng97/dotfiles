local wezterm = require("wezterm")
local config = {}

config.font = wezterm.font("JetBrains Mono")
config.color_scheme = "Catppuccin Latte"
config.hide_tab_bar_if_only_one_tab = true

config.wsl_domains = {
	{
		name = "WSL:Ubuntu",
		distribution = "Ubuntu",
	},
}

config.default_domain = "WSL:Ubuntu"

return config
