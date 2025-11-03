set fish_greeting

if test (uname) = "Darwin"
  eval (/opt/homebrew/bin/brew shellenv)
end

set -x EDITOR nvim
set -x VISUAL nvim
set -x BROWSER open
set -x HOMEBREW_NO_ANALYTICS 1

direnv hook fish | source
