#!/usr/bin/env bash

set -euxo pipefail

mkdir -p "$HOME/.config"/{fish,ghostty}
mkdir -p "$HOME/.local/bin"
ln -sf "$PWD/fish/config.fish" "$HOME/.config/fish/config.fish"
ln -sf "$PWD/ghostty/config" "$HOME/.config/ghostty/config"
ln -sf "$PWD/feeds.txt" "$HOME/.config/feeds.txt"
ln -sf "$PWD/Brewfile" "$HOME/.Brewfile"
ln -sf "$PWD/gitconfig" "$HOME/.gitconfig"
ln -sf "$PWD/gitignore" "$HOME/.gitignore"
ln -sf "$PWD/feeds.py" "$HOME/.local/bin/feeds"
ln -sf "$PWD/edit_fzf_grep.sh" "$HOME/.local/bin/edit_fzf_grep"
ln -sf "$PWD/edit_fzf_file.sh" "$HOME/.local/bin/edit_fzf_file"
ln -sf "$PWD/vimrc" "$HOME/.vimrc"
