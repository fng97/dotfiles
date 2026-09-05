#!/usr/bin/env bash

set -euo pipefail

# https://github.com/junegunn/fzf/blob/master/ADVANCED.md#using-fzf-as-interactive-ripgrep-launcher
RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case"
fzf --ansi --disabled \
    --bind "start:reload:$RG_PREFIX {q} || true" \
    --bind "change:reload:$RG_PREFIX {q} || true" \
    --bind 'enter:become(edit {1} --goto={2}:{3})' \
    --delimiter : \
    --preview 'bat --color=always --theme=ansi --style=numbers {1} --highlight-line {2}' \
    --preview-window 'right,60%,+{2}+3/3,~3'
