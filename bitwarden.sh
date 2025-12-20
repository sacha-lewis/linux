#!/usr/bin/env bash
set -e

echo "=== Updating system ==="
sudo apt update && sudo apt upgrade -y

# -----------------------------
# Flatpak (Bitwarden)
# -----------------------------
echo "=== Installing Flatpak & Bitwarden ==="
sudo apt install -y flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.bitwarden.desktop