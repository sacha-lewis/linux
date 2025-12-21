#!/usr/bin/env bash

# Base
sudo apt update
sudo apt install curl libfuse2

echo "=== Bitwarden ==="
./bitwarden.sh

echo "=== Docker ==="
./docker.sh

#echo "=== Firefox Developer ==="
#./firefox-developer.sh

echo "=== Jetbrains ==="
./jetbrains.sh

echo "=== Obsidian ==="
./obsidian

echo "=== Firefox addons === "
./firefox-addons


#
