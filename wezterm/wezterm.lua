-- For WSL: Copy this to ~/.config/wezterm (Windows user)

local w = require("wezterm")

local config = w.config_builder()

config.font = w.font("JetBrains Mono")
config.font_size = 20
config.window_decorations = "INTEGRATED_BUTTONS"

-- Switch between light and dark themes based on system theme.
config.color_scheme_dirs = { "~/.config/wezterm/colors" }
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

-- ALT + hjkl pane movement (fallback to tab switching on l/h)
local function alt_nav(key)
	local direction_keys = {
		h = "Left",
		j = "Down",
		k = "Up",
		l = "Right",
	}
	local direction = direction_keys[key]

	return {
		key = key,
		mods = "ALT",
		action = w.action_callback(function(win, pane)
			local tab = win:active_tab()

			-- If no pane exists in a given direction we're at the edge of the window. In this case fall back
			-- to moving tabs in that direction.
			if tab:get_pane_direction(direction) then
				win:perform_action({ ActivatePaneDirection = direction }, pane)
			else
				-- This questionable ternary syntax means go left on "h" else go right
				win:perform_action({ ActivateTabRelative = key == "h" and -1 or 1 }, pane)
			end
		end),
	}
end

config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
	{ key = "|", mods = "LEADER", action = w.action.SplitHorizontal },
	{ key = "-", mods = "LEADER", action = w.action.SplitVertical },

	alt_nav("h"),
	alt_nav("j"),
	alt_nav("k"),
	alt_nav("l"),
}

return config
