#!/usr/bin/env bash
set -e

echo "=== Docker Engine & docker-compose installer ==="

# Must be run with sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run with sudo:"
  echo "  sudo ./docker.sh"
  exit 1
fi

USER_NAME=${SUDO_USER}
USER_HOME=$(getent passwd "$USER_NAME" | cut -d: -f6)

echo "Installing prerequisites..."
apt update
apt install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release

# -----------------------------
# Docker GPG key
# -----------------------------
if [ ! -f /usr/share/keyrings/docker.gpg ]; then
  echo "Adding Docker GPG key..."
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | gpg --dearmor -o /usr/share/keyrings/docker.gpg
fi

# -----------------------------
# Docker APT repository
# -----------------------------
if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
  echo "Adding Docker repository..."
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" \
    > /etc/apt/sources.list.d/docker.list
fi

# -----------------------------
# Install Docker
# -----------------------------
echo "Installing Docker packages..."
apt update
apt install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

# -----------------------------
# Enable Docker at boot
# -----------------------------
systemctl enable docker
systemctl start docker

# -----------------------------
# Non-root Docker access
# -----------------------------
if ! getent group docker >/dev/null; then
  groupadd docker
fi

usermod -aG docker "$USER_NAME"

echo ""
echo "=== Docker installation complete ==="
echo "User '$USER_NAME' added to docker group."
echo "Log out and log back in for group changes to take effect."
