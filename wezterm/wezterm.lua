local w = require("wezterm")

local config = w.config_builder()

config.font = w.font("JetBrains Mono")
config.font_size = 16
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
			name = "WSL:NixOS",
			distribution = "NixOS",
			default_cwd = "/home/fng",
		},
	}
	config.default_domain = "WSL:NixOS"
	config.font_size = 12
end

return config
