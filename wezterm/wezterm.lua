local w = require("wezterm")

local config = w.config_builder()

config.font = w.font("JetBrains Mono")
config.font_size = 14
config.window_decorations = "INTEGRATED_BUTTONS"

-- Switch between light and dark themes based on system theme. Colours taken from
-- https://github.com/Mofiqul/vscode.nvim
if w.gui.get_appearance():find("Dark") then
	config.colors = {
		ansi = {
			"#1f1f1f",
			"#f44747",
			"#608b4e",
			"#dcdcaa",
			"#569cd6",
			"#c678dd",
			"#56b6c2",
			"#d4d4d4",
		},
		background = "#1f1f1f",
		brights = {
			"#808080",
			"#f44747",
			"#608b4e",
			"#dcdcaa",
			"#569cd6",
			"#c678dd",
			"#56b6c2",
			"#d4d4d4",
		},
		cursor_bg = "#d4d4d4",
		cursor_border = "#d4d4d4",
		cursor_fg = "#1f1f1f",
		foreground = "#d4d4d4",
		selection_bg = "#dcdcaa",
		selection_fg = "#1f1f1f",
	}
else
	config.colors = {
		ansi = {
			"#ffffff",
			"#c72e0f",
			"#008000",
			"#795e25",
			"#007acc",
			"#af00db",
			"#56b6c2",
			"#000000",
		},
		background = "#ffffff",
		brights = {
			"#808080",
			"#c72e0f",
			"#008000",
			"#795e25",
			"#007acc",
			"#af00db",
			"#56b6c2",
			"#000000",
		},
		cursor_bg = "#000000",
		cursor_border = "#000000",
		cursor_fg = "#ffffff",
		foreground = "#000000",
		selection_bg = "#d7ba7d",
		selection_fg = "#ffffff",
	}
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
