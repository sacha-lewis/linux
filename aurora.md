Immutable OS
--------------------
Docker Engine
GitHub CLI
System services

Persistent host apps
--------------------
JetBrains Toolbox
PHPStorm
Bitwarden

Flatpaks
--------------------
Chrome
Firefox
LocalSend

Distroboxes
--------------------
Ubuntu 22
Ubuntu 24

Docker
--------------------
Apache
MariaDB
Redis






# Install Jetbrains Toolbox
ujust install-jetbrains-toolbox

# Install Bitwarden
- Download appImage
- Put into ~/Applications

# Install Chrome
flatpak install flathub com.google.Chrome


#codex
curl -fsSL https://chatgpt.com/codex/install.sh | sh









1. Immutable image

Things that rarely change:

Docker
GitHub CLI
Tailscale
Virtualization support

2. Host-installed developer tools

Managed by helper scripts (ujust or your own later):

JetBrains Toolbox
PHPStorm
Bitwarden

These update independently of the OS.

3. Flatpaks

Everything else.





Immutable OS
↓
Persistent user applications
↓
Flatpaks
↓
Distroboxes








## HOST
✓ Docker Engine
✓ JetBrains Toolbox
✓ PHPStorm
✓ Bitwarden
✓ GitHub CLI
✓ Tailscale
✓ VirtualBox (if needed)

## Flatpak
✓ Chrome
✓ Firefox
✓ LocalSend
✓ Obsidian
✓ Spotify
✓ Discord

## Distrobox
- Ubuntu 22
- PHP 8.1
- Composer
- Node

## Ubuntu 24
- PHP 8.4
- Composer
- Node
- Docker
- Apache
- MariaDB
- Redis
- Mailhog