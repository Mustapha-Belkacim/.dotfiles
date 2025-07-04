#!/usr/bin/env bash

# homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew update
brew upgrade

# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)

# Install GNU core utilities (those that come with macOS are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils
ln -s "${BREW_PREFIX}/bin/gsha256sum" "${BREW_PREFIX}/bin/sha256sum"

# Install a modern version of Bash.
brew install bash
brew install bash-completion2

# Switch to using brew-installed bash as default shell
if ! fgrep -q "${BREW_PREFIX}/bin/bash" /etc/shells; then
  echo "${BREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells
  chsh -s "${BREW_PREFIX}/bin/bash"
fi

# oh-my-bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
# oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
brew install --cask docker
brew install --cask iterm2
brew install fd
brew install ripgrep
brew install fzf
# To install useful key bindings and fuzzy completion:
${BREW_PREFIX}/opt/fzf/install
brew install htop
brew install bat
brew install lsd
brew install eza
brew install tldr
brew install trash-cli
brew install vim --with-override-system-vi
brew install neovim
brew install vifm
brew install neovim
brew install lazygit
brew install --cask karabiner-elements
brew install --cask finicky
brew install --cask insomnia
brew install --cask rectangle
# raycast can replace rectangle
brew install --cask raycast
brew install --cask alacritty --no-quarantine
brew install gawk
brew install fdupes
brew install git-delta
brew install terminal-notifier
brew install font-hack-nerd-font
brew install superfile
brew install stow
brew install tmux
brew install zoxide
brew install --cask orbstack
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# ble.sh
git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git
make -C ble.sh install PREFIX=~/.local
# autocomplete fo zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

brew cleanup
