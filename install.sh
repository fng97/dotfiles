#!/usr/bin/env bash

set -euxo pipefail

mkdir -p "$HOME/.config"/{fish,nvim,wezterm,wezterm/colors,direnv}

ln -sf "$PWD/fish/config.fish" "$HOME/.config/fish/config.fish"
ln -sf "$PWD/wezterm/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"
ln -sf "$PWD/wezterm/colors/vscode-nvim-light.toml" \
  "$HOME/.config/wezterm/colors/vscode-nvim-light.toml"
ln -sf "$PWD/wezterm/colors/vscode-nvim-dark.toml" \
  "$HOME/.config/wezterm/colors/vscode-nvim-dark.toml"
ln -sf "$PWD/nvim/init.lua" "$HOME/.config/nvim/init.lua"
ln -sf "$PWD/direnv/direnvrc" "$HOME/.config/direnv/direnvrc"
ln -sf "$PWD/Brewfile" "$HOME/.Brewfile"
ln -sf "$PWD/gitconfig" "$HOME/.gitconfig"
ln -sf "$PWD/gitignore" "$HOME/.gitignore"
