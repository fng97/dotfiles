#!/usr/bin/env bash

set -euxo pipefail

mkdir -p "$HOME/.config"/{fish,wezterm,nvim,direnv}
mkdir -p "$HOME/.claude"
ln -sf "$PWD/fish/config.fish" "$HOME/.config/fish/config.fish"
ln -sf "$PWD/wezterm/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"
ln -sf "$PWD/nvim/init.lua" "$HOME/.config/nvim/init.lua"
ln -sf "$PWD/direnv/direnvrc" "$HOME/.config/direnv/direnvrc"
ln -sf "$PWD/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
ln -sf "$PWD/claude/settings.json" "$HOME/.claude/settings.json"
ln -sf "$PWD/Brewfile" "$HOME/.Brewfile"
ln -sf "$PWD/gitconfig" "$HOME/.gitconfig"
ln -sf "$PWD/gitignore" "$HOME/.gitignore"

# On Windows, symlinking to Windows home from WSL doesn't work because Wezterm can't access the WSL
# filesystem. Just overwrite the Windows home config each time.
if uname -r | grep --quiet WSL2; then
  # See https://superuser.com/a/1546688 for enabling $USERPROFILE.
  cp "$PWD/wezterm/wezterm.lua" "$USERPROFILE/.config/wezterm/wezterm.lua"
fi
