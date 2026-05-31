# Digi Display Linux Architecture

## Review Status

This document is the planning and verification reference for the repo.
Programming should wait until this README has been reviewed and approved.

`AGENTS.md` remains the source of repository working style: small changes,
minimal diffs, clear verification, and no unrelated refactors. Its CakePHP
sections are not part of this project unless this repo later adds CakePHP code.

## Purpose

This repo defines the Linux setup flow for Digi Display machines. The system is
split into a small recovery-first initialize layer and a separate provisioning
layer that turns a machine into a specific role.

The main design rule is simple: permanent remote recovery must continue working
even when Tailscale, Docker, application services, updates, or role-specific
software fail.

## Core Development Rules

All future work in this repo should follow these rules before code is changed:

* Keep changes small, targeted, and task-focused.
* Preserve existing conventions in touched files.
* Avoid unrelated refactors unless explicitly requested.
* Keep diffs minimal and reviewable.
* Prefer readable, maintainable shell scripts over clever shortcuts.
* Keep top-level scripts short and easy to scan.
* Move repeated or complex logic into clearly named helper functions.
* Do not revert unrelated user changes.
* Clearly state assumptions, blockers, limitations, and verification steps.

The CakePHP and `sourceFiles/` rules in `AGENTS.md` are legacy guidance from
other SetupCase work and should be ignored for this Linux setup repo.

## Implementation Recommendation

Use Bash as the primary language.

Bash is the best default for this repo because the work is mostly Linux machine
setup:

* Installing apt packages.
* Creating users, directories, and permissions.
* Installing SSH keys.
* Writing systemd service files.
* Enabling and restarting services.
* Calling common Linux tools such as `ssh`, `autossh`, `systemctl`, `curl`,
  `apt`, `flatpak`, and `docker`.

Python is not part of the MVP install path. It may be introduced after MVP for
helper tasks where structured data makes the script simpler:

* Building or validating JSON registration payloads.
* Reading or writing machine state files.
* Producing detailed verification reports.
* Talking to a future registration API.

The initialize layer should stay as close to standard Linux shell tooling as
possible.

## Proposed Command Model

Use two main entry points so the recovery layer and role setup remain separate:

```bash
sudo ./initialize.sh install
./provision.sh install development-workstation
```

MVP behavior:

* `install` creates missing configuration and installs missing dependencies.
* `upgrade` and `verify` should exist as reserved command hooks, but return an
  error until they are implemented:

```text
ERROR: upgrade is coming in a future release.
ERROR: verify is coming in a future release.
```

Reserved future commands:

```bash
sudo ./initialize.sh upgrade
sudo ./initialize.sh verify

./provision.sh upgrade development-workstation
./provision.sh verify development-workstation
```

Initialize commands should be safe to rerun. Provisioning commands should be safe
to rerun whenever practical, but role-specific installers may document manual
steps when unavoidable.

Provisioning should be run without `sudo`. Profile scripts should ask for
`sudo` only when a specific installer needs elevated privileges.

## Architecture

The solution is divided into two distinct stages.

## Stage 1 - Initialize

Purpose: ensure permanent remote access to the machine regardless of the state
of the application layer.

Initialize responsibilities:

* Install and configure SSH.
* Install and configure AutoSSH.
* Install undoLogic public keys.
* Create a reverse tunnel to `hello.digi-display.com`.
* Create and enable a dedicated initialize systemd service.
* Provide a recovery path if Tailscale, Docker, applications, or updates fail.

The initialize layer must remain small, stable, and rarely modified.

The initialize layer must not install application software.

Software that does not belong in initialize:

* Firefox
* Docker
* Tailscale
* Codex
* Digital Signage software
* Application services

The initialize layer's only responsibility is connectivity and recovery.

## Stage 2 - Provisioning

Purpose: convert the machine into a specific role after initialize recovery is in
place.

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

Provisioning scripts may evolve over time. They should not become dependencies
of the initialize recovery path.

## Recovery Philosophy

If Tailscale fails:

* Initialize remains operational.
* AutoSSH tunnel remains operational.
* Administrator connects through `hello.digi-display.com`.
* Repairs are performed remotely.

Initialize must never depend on Tailscale.

Initialize must never depend on application services.

## Confirmed MVP Decisions

* Initialize entry point: `sudo ./initialize.sh install`.
* Initialize configuration files may live in the repo root.
* Systemd services and long-running service identifiers should use the
  `Digi-Display_*` prefix so they are easy to identify.
* Initialize service name: `Digi-Display_Initialize.service`.
* Initialize service install location:
  `/etc/systemd/system/Digi-Display_Initialize.service`.
* Reverse SSH tunnel port is hard-coded in the repo-root
  `initialize.config.json` file for MVP.
* MVP reverse SSH tunnel port: `2222`.
* Dynamic or per-device tunnel port assignment is deferred until scaling
  requires it.
* Initialize does not send machine information to a server during MVP.
* Machine registration and registration APIs are post-MVP work.
* Initial provisioning profiles: Development Workstation, Digital Signage
  Player, OfflineBox Appliance, and Kiosk Device.
* Development Workstation is the first wired provisioning profile for MVP.
* Digital Signage Player, OfflineBox Appliance, and Kiosk Device exist as
  reserved profile names until their installers are defined.
* Existing installer scripts should stay modular and separate.
* Profile scripts should orchestrate existing installers instead of absorbing
  all installer logic.
* Python helpers are not part of MVP.
* Python may be introduced after MVP for registration, API, reporting, or other
  structured-data helper work.

MVP initialize config shape:

```json
{
  "authorized_keys_file": "initialize.authorized_keys",
  "local_admin_user": "auto",
  "reverse_tunnel": {
    "host": "hello.digi-display.com",
    "remote_user": "digi-display",
    "remote_port": 2222,
    "local_host": "127.0.0.1",
    "local_port": 22,
    "ssh_key_path": "/root/.ssh/Digi-Display_Initialize"
  }
}
```

Port `2222` must be available on `hello.digi-display.com`. When more than one
device needs a reverse tunnel at the same time, each device will need a unique
remote port.

## MVP File Layout

The MVP structure is:

```text
initialize.authorized_keys
initialize.config.json
initialize.sh
initialize/
    Digi-Display_Initialize
    lib.sh
    install-service.sh
    install-ssh.sh
    install-autossh.sh
    install-keys.sh
    systemd/
        Digi-Display_Initialize.service
provision.sh
profiles/
    development-workstation.sh
    signage-player.sh
    offlinebox-appliance.sh
    kiosk-device.sh
```

Existing installer scripts should stay modular. Profile scripts should call the
needed installers for each role.

## Script Design Rules

Shell scripts should follow these repo conventions:

* Use `#!/usr/bin/env bash`.
* Use `set -euo pipefail` for new scripts unless a specific section needs
  custom error handling.
* Use clear function names.
* Keep public entry points short.
* Put detailed logic in helper functions.
* Make scripts safe to rerun whenever practical.
* Validate required commands before using them.
* Fail clearly when required configuration is missing.
* Avoid hidden network assumptions.
* Keep initialize scripts independent from provisioning scripts.
* Avoid interactive editors or manual pauses inside automation scripts.
* Prefer explicit commands over clever shell shortcuts.

## Verification Plan

Every future programming change should include verification notes.

Initialize verification should confirm:

* SSH is installed and enabled.
* AutoSSH is installed and configured.
* Public keys are present with correct permissions.
* The reverse tunnel service exists.
* The reverse tunnel service is enabled.
* Recovery access does not require Tailscale.

Provisioning verification should confirm:

* The selected profile installs only its intended packages.
* The provisioning script can be rerun safely where practical.
* Application software does not become an initialize dependency.
* Errors are visible and actionable.

If automated testing is not available, manual verification must be listed in the
change summary.

## Future Expansion

Possible future features:

* Machine information registration
* Device registration API
* Heartbeat monitoring
* Python helper scripts for structured data tasks
* Screenshot service
* Remote reboot
* Remote configuration
* Central dashboard

These features belong above the initialize layer and should not be required for
machine recovery.
