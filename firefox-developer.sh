#!/usr/bin/env bash
set -e

echo "=== Firefox Developer Edition installer ==="

INSTALL_DIR="/opt/firefox-developer"
BIN_LINK="/usr/local/bin/firefox-dev"
DESKTOP_FILE="/usr/share/applications/firefox-developer.desktop"
TMP_FILE="/tmp/firefox-dev.tar.xz"

# Must be run with sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run with sudo:"
  echo "  sudo ./install-firefox-developer.sh"
  exit 1
fi

# Skip if already installed
if [ -d "$INSTALL_DIR" ]; then
  echo "Firefox Developer Edition already installed at:"
  echo "  $INSTALL_DIR"
  exit 0
fi

echo "Downloading Firefox Developer Edition..."
curl -fL \
  "https://download.mozilla.org/?product=firefox-devedition-latest&os=linux64&lang=en-US" \
  -o "$TMP_FILE"

echo "Verifying archive format..."
if ! file "$TMP_FILE" | grep -q "XZ compressed data"; then
  echo "ERROR: Downloaded file is not a valid XZ archive."
  rm -f "$TMP_FILE"
  exit 1
fi

echo "Extracting..."
tar -xJf "$TMP_FILE" -C /opt

mv /opt/firefox "$INSTALL_DIR"

echo "Creating binary symlink..."
ln -sf "$INSTALL_DIR/firefox" "$BIN_LINK"

echo "Creating desktop entry..."
cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Version=1.0
Name=Firefox Developer Edition
GenericName=Web Browser
Comment=Firefox Developer Edition
Exec=/opt/firefox-developer/firefox -P dev-edition-default
Icon=/opt/firefox-developer/browser/chrome/icons/default/default128.png
Terminal=false
Type=Application
Categories=Development;WebBrowser;
StartupWMClass=firefoxdeveloperedition
EOF

chmod 644 "$DESKTOP_FILE"

echo "Updating desktop database..."
update-desktop-database || true

echo ""
echo "=== Firefox Developer Edition installed successfully ==="
echo "Launch via App Menu or:"
echo "  firefox-dev"
