#!/usr/bin/env bash

set -euo pipefail

ENTER_BIND='enter:become(edit {1} --goto={2}:{3})'

if [[ "$EDITOR" == "vim" ]]; then
    ENTER_BIND='enter:become(vim {1} +{2})'
fi

# https://github.com/junegunn/fzf/blob/master/ADVANCED.md#using-fzf-as-interactive-ripgrep-launcher
RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case"
fzf --ansi --disabled \
    --bind "start:reload:$RG_PREFIX {q} || true" \
    --bind "change:reload:$RG_PREFIX {q} || true" \
    --bind "ctrl-g:unbind(change,ctrl-g)+change-prompt(fzf> )+enable-search+clear-query" \
    --color "hl:-1:underline,hl+:-1:underline:reverse" \
    --prompt 'ripgrep> ' \
    --delimiter : \
    --preview 'bat --color=always --theme=ansi --style=numbers {1} --highlight-line {2}' \
    --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
    --bind "$ENTER_BIND"
