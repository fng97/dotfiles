local w = require("wezterm")

local config = w.config_builder()

config.font = w.font("JetBrains Mono")
config.font_size = 15
config.window_decorations = "INTEGRATED_BUTTONS"

-- Switch between light and dark themes based on system theme.
if w.gui.get_appearance():find("Dark") then
	config.color_scheme = "vscode-dark"
else
	config.color_scheme = "vscode-light"
end

-- On Windows, use NixOS-WSL
if w.target_triple == "x86_64-pc-windows-msvc" and w.running_under_wsl then
	config.wsl_domains = {
		{
			name = "WSL:Debian",
			distribution = "Debian",
			default_cwd = "/home/fngoncalves",
		},
	}
	config.default_domain = "WSL:Debian"
end

config.keys = {
	{ key = "h", mods = "ALT", action = w.action.ActivateTabRelative(-1) },
	{ key = "l", mods = "ALT", action = w.action.ActivateTabRelative(1) },
}

return config
