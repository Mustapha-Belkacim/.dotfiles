# .bash_profile -*- mode: sh -*-

# Load login settings and environment variables
if [[ -f ~/.profile ]]; then
  source ~/.profile
fi

# Load interactive settings
if [[ -f ~/.bashrc ]]; then
  source ~/.bashrc
fi

eval "$(/opt/homebrew/bin/brew shellenv)"

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --bash)"

export PATH="/opt/homebrew/opt/php@8.3/bin:$PATH"
export PATH="/opt/homebrew/opt/php@8.3/sbin:$PATH"

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
