#manual
fn lock = FN + ESC (confirm light changing)

# init
sudo apt update
sudo apt install curl flatpak tmux nano copyq git-delta


flatpak remote-add --if-not-exists flathub \
https://flathub.org/repo/flathub.flatpakrepo

flatpak install flathub com.bitwarden.desktop
flatpak update
flatpak list

# Bitwarden for Firefox
https://addons.mozilla.org/en-US/firefox/addon/bitwarden-password-manager/

# Dark mode
https://addons.mozilla.org/en-US/firefox/addon/darkreader/

# disable passwords on firefox
# Manual for now

# ################################################## PhpStorm
flatpak install flathub com.jetbrains.PhpStorm

wget https://download.jetbrains.com/toolbox/jetbrains-toolbox-latest.tar.gz
tar -xzf jetbrains-toolbox-latest.tar.gz
cd jetbrains-toolbox-*
./jetbrains-toolbox




# Tailscale
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up

# Google Drive
# does not exist

# Obsidian
flatpak install flathub md.obsidian.Obsidian

# terminal
sudo apt install guake

# codex
curl -fsSL https://chatgpt.com/codex/install.sh | sh

# Teams

# Chromium

# RDP (server)
sudo apt install xrdp -y

# RDP (Client)
sudo apt install remmina remmina-plugin-rdp -y

# Chromium
sudo apt install chromium-browser


# docker
sudo apt remove docker docker-engine docker.io containerd runc
sudo apt update
sudo apt install -y ca-certificates curl gnupg

#keyring
sudo install -m 0755 -d /etc/apt/keyrings


curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
| sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg


echo \
"deb [arch=$(dpkg --print-architecture) \
signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo $VERSION_CODENAME) stable" \
| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


sudo apt update

sudo apt install -y \
docker-ce \
docker-ce-cli \
containerd.io \
docker-buildx-plugin \
docker-compose-plugin

sudo usermod -aG docker $USER

# reload or logout / login
newgrp docker


# test
docker run hello-world


# docker compose
docker compose version

# test docker compose (no more hyphen)
docker compose up -d

# start at boot
sudo systemctl enable docker
sudo systemctl start docker
# verify it will start at login
systemctl status docker






#####################
## Troubleshooting ##
#####################

# Phpstorm not starting
flatpak kill com.jetbrains.PhpStorm
rm ~/.var/app/com.jetbrains.PhpStorm/config/JetBrains/PhpStorm*/.lock
flatpak run com.jetbrains.PhpStorm

# Bitwarden desktop SSH agent (Flatpak).
export SSH_AUTH_SOCK="$HOME/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock"
# Create config
touch ~/.ssh/config
Host *
IdentityAgent ~/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock
# permissions
chmod 600 ~/.ssh/config

tmux set-environment -g SSH_AUTH_SOCK \
"$HOME/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock"

source ~/.bashrc

# Phpstorm SSH-AGENT not working
rm -f ~/.var/app/com.jetbrains.PhpStorm/cache/JetBrains/PhpStorm*/.pid
rm -f ~/.var/app/com.jetbrains.PhpStorm/cache/JetBrains/PhpStorm*/.port
rm -f ~/.var/app/com.jetbrains.PhpStorm/config/JetBrains/PhpStorm*/.lock



# PHPstorm terminal cannot access docker
Settings → Tools → Terminal → Shell path
/usr/bin/flatpak-spawn --host /bin/bash





######## Window manager ###########
#!/bin/bash

# Get active window
WIN=$(xdotool getactivewindow)

# Get screen dimensions
WIDTH=$(xdpyinfo | awk '/dimensions/{print $2}' | cut -d'x' -f1)
HEIGHT=$(xdpyinfo | awk '/dimensions/{print $2}' | cut -d'x' -f2)

# Left 30%
NEW_WIDTH=$((WIDTH * 30 / 100))

wmctrl -ir $WIN -b remove,maximized_vert,maximized_horz
wmctrl -ir $WIN -e 0,0,0,$NEW_WIDTH,$HEIGHT



sudo dd if=kubuntu.iso of=/dev/sdX bs=16M status=progress oflag=sync



