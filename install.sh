#!/usr/bin/env bash

set -euxo pipefail

mkdir -p "$HOME/.config"/{fish,ghostty/themes,nvim,direnv}
mkdir -p "$HOME/.local/bin"
ln -sf "$PWD/fish/config.fish" "$HOME/.config/fish/config.fish"
ln -sf "$PWD/ghostty/config" "$HOME/.config/ghostty/config"
ln -sf "$PWD/ghostty/themes/vscode-dark" "$HOME/.config/ghostty/themes/vscode-dark"
ln -sf "$PWD/ghostty/themes/vscode-light" "$HOME/.config/ghostty/themes/vscode-light"
ln -sf "$PWD/nvim/init.lua" "$HOME/.config/nvim/init.lua"
ln -sf "$PWD/direnv/direnvrc" "$HOME/.config/direnv/direnvrc"
ln -sf "$PWD/feeds.txt" "$HOME/.config/feeds.txt"
ln -sf "$PWD/Brewfile" "$HOME/.Brewfile"
ln -sf "$PWD/gitconfig" "$HOME/.gitconfig"
ln -sf "$PWD/gitignore" "$HOME/.gitignore"
ln -sf "$PWD/feeds.py" "$HOME/.local/bin/feeds"
