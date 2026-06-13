#!/bin/bash
set -e

URL="https://bitwarden.com/download/?app=desktop&platform=linux&variant=deb"
TMP_DEB="/tmp/bitwarden.deb"

echo "🔽 Resolving latest Bitwarden .deb download..."

# Follow redirects properly and extract final file
FINAL_URL=$(curl -Ls -o /dev/null -w %{url_effective} "$URL")

echo "⬇️ Downloading from: $FINAL_URL"
wget -O "$TMP_DEB" "$FINAL_URL"

echo "📦 Installing Bitwarden..."
sudo apt install -y "$TMP_DEB"

echo "🧹 Cleaning up..."
rm -f "$TMP_DEB"

echo "✅ Bitwarden installed successfully."