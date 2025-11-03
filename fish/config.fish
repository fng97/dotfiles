set fish_greeting

eval (/opt/homebrew/bin/brew shellenv)

set -x EDITOR nvim
set -x VISUAL nvim
set -x BROWSER open
set -x HOMEBREW_NO_ANALYTICS 1

direnv hook fish | source
