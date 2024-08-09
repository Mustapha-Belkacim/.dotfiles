#!/usr/bin/env bash

# oh-my-bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
# homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install stow
# oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
brew install --cask docker
brew install --cask iterm2
brew install fd
brew install rg
brew install fzf
brew install htop
brew install bat
brew install exa
brew install tldr
brew install trash-cli
brew install vifm
brew install lazygit
brew install --cask karabiner-elements
brew install --cask finicky
brew install --cask insomnia
brew install gawk
brew install fdupes
brew install git-delta
brew install terminal-notifier
# ble.sh
git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git
make -C ble.sh install PREFIX=~/.local
