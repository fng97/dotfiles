#!/usr/bin/env bash

set -euo pipefail

if [[ "${1:-}" == "--all" ]]; then
    files=(rg --files --hidden --no-ignore)
else
    files=(git ls-files)
fi

file=$("${files[@]}" | fzf \
    --preview 'bat --color=always --theme=ansi --style=numbers {}' \
    --preview-window 'right,60%')

[[ -n "$file" ]] && edit "$file"
