#!/bin/bash

sudo apt update
sudo apt install curl flatpak tmux nano copyq git-delta libfuse2 tree

# configure flatpakm
flatpak remote-add --if-not-exists flathub \
https://flathub.org/repo/flathub.flatpakrepo
