#!/usr/bin/env bash

apt update

# oh my bash
bash -c "$(wget https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh -O -)" --unattended
# ble.sh
git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git
make -C ble.sh install PREFIX=~/.local
echo 'source ~/.local/share/blesh/ble.sh' >>~/.bashrc
apt install stow
apt install fd-find
apt install ripgrep
apt install fzf
apt install htop
apt install bat
apt install exa
apt install vifm
apt install neofetch
apt install tldr
apt install ncdu
apt install jhead
apt install trash-cli
apt install ffmpeg
apt install fdupes
apt install cmus
apt install tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

#programming
# lazygit
add-apt-repository ppa:lazygit-team/release
apt update
apt install lazygit
apt install heroku
apt install inotify-tools
apt install nasm
apt install golang-go
apt install python3
pip install ipython
pip install bpython
pip install ptpython
pip install virtualenvwrapper
pip install pipenv
# rust
curl --proto '=https' --tlsv1.3 https://sh.rustup.rs -sSf | sh
cargo install git-delta
cargo install --locked yazi-fm yazi-cli
cargo install --locked zellij
docker
docker-compose

# Graphical programs
# google-chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb
apt install gimp
# Fluxgui
add-apt-repository ppa:nathan-renniewaldock/flux
apt update
apt install fluxgui
# vs code
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
apt install code
apt install keepassxc
apt install stellarium
# safe eyes
add-apt-repository ppa:slgobinath/safeeyes && apt update && apt install safeeyes
apt install texlive-full
apt install texstudio
# subilme text
# scan tailor
# scan tailor advanced
# gscan2pdf
add-apt-repository ppa:jeffreyratcliffe/ppa && apt update && apt install gscan2pdf
ocrfeeder
kile
# timeshift
add-apt-repository -y ppa:teejee2008/timeshift && apt update && apt install timeshift
apt install -y filelight
apt install flameshot
apt install virtualbox
# Mega Sync
curl https://mega.nz/linux/MEGAsync/xUbuntu_20.04/amd64/megasync_4.5.3-2.1_amd64.deb -o /tmp/megasync.deb
apt install /tmp/megasync.deb
# Mega Sync Dolphin intergration
curl https://mega.nz/linux/MEGAsync/xUbuntu_20.04/amd64/dolphin-megasync_4.1.1+4.1_amd64.deb -o /tmp/dolphin-megasync.deb
apt install /tmp/dolphin-megasync.deb
# Mega cli
curl https://mega.nz/linux/MEGAsync/xUbuntu_20.04/amd64/megacmd_1.4.0-5.1_amd64.deb -o /tmp/megacmd.deb
apt install /tmp/megacmd.deb
# speedcrunch
wget https://bitbucket.org/heldercorreia/speedcrunch/downloads/SpeedCrunch-0.12-linux64.deb
dpkg -i SpeedCrunch-0.12-linux64.deb

# OBS studio
add-apt-repository ppa:obsproject/obs-studio
apt install obs-studio

# fix open-fprintd issues in kde ubuntu
# apt remove fprintd
# add-apt-repository ppa:uunicorn/open-fprintd
# apt-get update
# apt install open-fprintd fprintd-clients python3-validity

apt autoremove
