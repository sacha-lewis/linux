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



## Aurora DX
### Provides things every developer needs.
Docker
Distrobox
Tailscale
GitHub CLI

## undoLogic Workstation
### Provides things every undoLogic employee needs.
PHPStorm
Bitwarden
NoMachine










# Install Jetbrains Toolbox
ujust install-jetbrains-toolbox

# Install Bitwarden
- Download appImage
- Put into ~/Applications

# Install Chrome
flatpak install flathub com.google.Chrome

# codex
curl -fsSL https://chatgpt.com/codex/install.sh | sh

# Tailscale
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up








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






Platform (Aurora DX)

Maintained by Universal Blue.

Docker
Distrobox
Tailscale
Virtualization
Company Standard

Maintained by undoLogic.

PHPStorm
Bitwarden
NoMachine

Every employee gets these.

Personal

Each developer chooses.

Spotify
Discord
Steam
...
Project

Specific to one project.

Ubuntu 22 Distrobox
Ubuntu 24 Distrobox
Docker Compose
This is why I like your vision

Earlier today you said something that stuck with me:

"I have a junior programmer."

Now imagine onboarding her.

Instead of saying:

Install Docker.

Install PHPStorm.

Install Bitwarden.

Install NoMachine.

Install Tailscale.

Install...

You hand her a laptop.

She signs in.

Everything is already there.

Or if she buys a replacement laptop:

Install Aurora DX.
Sign into GitHub (or your company bootstrap).
Run one command.
ujust setup-undologic

Ten minutes later she's productive.