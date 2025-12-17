#!/usr/bin/env bash

set -euxo pipefail

mkdir -p "$HOME/.config"/{fish,nvim,direnv}
rm -rf "$HOME/.config/wezterm"
ln -sf "$PWD/fish/config.fish" "$HOME/.config/fish/config.fish"
ln -sf "$PWD/wezterm" "$HOME/.config"
ln -sf "$PWD/nvim/init.lua" "$HOME/.config/nvim/init.lua"
ln -sf "$PWD/direnv/direnvrc" "$HOME/.config/direnv/direnvrc"
ln -sf "$PWD/Brewfile" "$HOME/.Brewfile"
ln -sf "$PWD/gitconfig" "$HOME/.gitconfig"
ln -sf "$PWD/gitignore" "$HOME/.gitignore"

# On Windows, symlinking wouldn't work because Wezterm can't access the WSL filesystem. Just
# overwrite the Windows home config each time.
if uname -r | grep --quiet WSL2; then
  # See https://superuser.com/a/1546688 for enabling $USERPROFILE.
  rsync --recursive --delete "$PWD/wezterm" "$USERPROFILE/.config"
fi
