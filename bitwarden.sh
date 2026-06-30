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

# Ensure the ssh-agents are connected with PHPStorm

export SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock"

# If keys appear, configure PhpStorm’s SSH authentication as OpenSSH config and authentication agent. For
# ssh-add -L

#reliable GUI launching, add this to ~/.ssh/config:
# Host *
#   IdentityAgent ~/.bitwarden-ssh-agent.sock


# What I changed:
#
#  - Created .ssh/config:1:
#
#    Host *
#        IdentityAgent ~/.bitwarden-ssh-agent.sock
#
#  - Added desktop/session env file: .config/environment.d/bitwarden-ssh-agent.conf:1
#  - Added SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock" to .profile:7 and .bashrc:5
#  - Imported the new SSH_AUTH_SOCK into the current KDE/systemd user session.
#
#  Verification:
#
#  - Bitwarden SSH agent is running at /home/sacha-lewis/.bitwarden-ssh-agent.sock.
#  - ssh-add -l against that socket works and shows 6 loaded keys.
#  - ssh -G github.com now resolves identityagent /home/sacha-lewis/.bitwarden-ssh-agent.sock.
#
#  Important: PhpStorm is still running with the old env:
#
#  SSH_AUTH_SOCK=/run/user/1000/openssh_agent
#
#  So close PhpStorm fully and reopen it from Toolbox/KDE. Existing PhpStorm processes cannot pick up the new agent socket. If it still fails after restart, check
#  PhpStorm Git setting: Settings -> Version Control -> Git -> SSH executable should be Native, and SSH/deployment configs should use OpenSSH config or authentication
#  agent.
#
