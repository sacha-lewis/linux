#!/usr/bin/env bash
set -e

JETBRAINS_VERSION="1.28.1.15219"
INSTALL_DIR="$HOME/.local/share/JetBrains/Toolbox"
BIN_DIR="$HOME/.local/bin"

echo "=== JetBrains Toolbox installer ==="

# Ensure required tools exist
command -v curl >/dev/null 2>&1 || {
  echo "curl is required but not installed."
  exit 1
}

# Ensure local bin exists and is in PATH
mkdir -p "$BIN_DIR"
if ! echo "$PATH" | grep -q "$BIN_DIR"; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
  export PATH="$HOME/.local/bin:$PATH"
fi

# Skip if already installed
if [ -d "$INSTALL_DIR" ]; then
  echo "JetBrains Toolbox already installed at:"
  echo "  $INSTALL_DIR"
  exit 0
fi

TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

echo "Downloading JetBrains Toolbox $JETBRAINS_VERSION..."
curl -L -o toolbox.tar.gz \
  "https://download.jetbrains.com/toolbox/jetbrains-toolbox-${JETBRAINS_VERSION}.tar.gz"

echo "Extracting..."
tar -xzf toolbox.tar.gz

echo "Installing..."
./jetbrains-toolbox-*/jetbrains-toolbox &

echo "Toolbox launched."
echo "Use Toolbox UI to install PhpStorm."
