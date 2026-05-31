# Digi Display Linux Architecture

## Philosophy

The solution is divided into two distinct stages:

### Stage 1 - Bootstrap

Purpose: Ensure permanent remote access to the machine regardless of the state of the application layer.

Responsibilities:

* Install and configure SSH.
* Install and configure AutoSSH.
* Install undoLogic public keys.
* Create a reverse tunnel to hello.digi-display.com.
* Register basic machine information.
* Create and enable a dedicated bootstrap systemd service.
* Provide a recovery path if Tailscale, Docker, applications, or updates fail.

The bootstrap layer should remain small, stable, and rarely modified.

The bootstrap layer should not install application software.

Examples of software NOT belonging in bootstrap:

* Firefox
* Docker
* Tailscale
* Codex
* Digital Signage software
* Application services

The bootstrap layer's only responsibility is connectivity and recovery.

### Stage 2 - Provisioning

Purpose: Convert the machine into a specific role.

Possible profiles:

* Development Workstation
* Digital Signage Player
* OfflineBox Appliance
* Kiosk Device

Provisioning may install:

* Firefox
* Tailscale
* Docker
* tmux
* Kitty
* Starship
* Bitwarden
* Development tools
* Digital Signage software

Provisioning scripts may evolve over time.

### Recovery Philosophy

If Tailscale fails:

* Bootstrap remains operational.
* AutoSSH tunnel remains operational.
* Administrator connects through hello.digi-display.com.
* Repairs are performed remotely.

Bootstrap must never depend on Tailscale.

Bootstrap must never depend on application services.

### Future Expansion

Possible future features:

* Device registration API
* Heartbeat monitoring
* Screenshot service
* Remote reboot
* Remote configuration
* Central dashboard

These features belong above the bootstrap layer and should not be required for machine recovery.
