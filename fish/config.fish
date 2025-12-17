set fish_greeting

set --export EDITOR nvim
set --export VISUAL nvim
set --export BROWSER open
set --export HOMEBREW_NO_ANALYTICS 1

if test (uname) = "Darwin"
  eval (/opt/homebrew/bin/brew shellenv)
else
  eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
end

if uname -r | grep --quiet WSL2
  set --export BROWSER explorer.exe
end

direnv hook fish | source
