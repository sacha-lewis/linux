# Linux Installer

## ##################################### New Computer ############## 

Login to
www.github.com/sacha-lewis/linux
- Download as zip
- unzip
- run


Step by Step
- KDE plasma updates
- Open firefox
- Download github.com / linux
- run firefox add-ones
- install jetbrains
- Download this linux

Connect dark / light mode scripts to shortcuts




## #################################### Burn ISO to USB key #######
sudo dd if=kubuntu.iso of=/dev/sdX bs=16M status=progress oflag=sync

# Google Drive
# does not exist

## ################################################################################### Troubleshooting ##

# Phpstorm when in flatpak not starting
flatpak kill com.jetbrains.PhpStorm
rm ~/.var/app/com.jetbrains.PhpStorm/config/JetBrains/PhpStorm*/.lock
flatpak run com.jetbrains.PhpStorm

# Bitwarden when in flatpak desktop SSH agent (Flatpak).
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

# #################################### Phpstorm SSH-AGENT not working when using bitwarden in flatpak
rm -f ~/.var/app/com.jetbrains.PhpStorm/cache/JetBrains/PhpStorm*/.pid
rm -f ~/.var/app/com.jetbrains.PhpStorm/cache/JetBrains/PhpStorm*/.port
rm -f ~/.var/app/com.jetbrains.PhpStorm/config/JetBrains/PhpStorm*/.lock



# PHPstorm terminal cannot access docker
Settings → Tools → Terminal → Shell path
/usr/bin/flatpak-spawn --host /bin/bash





## ####################################################################### Window manager for xfce#########
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
