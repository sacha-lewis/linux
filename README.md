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

Use Python only for helper tasks where structured data makes the script simpler:

* Building or validating JSON registration payloads.
* Reading or writing machine state files.
* Producing detailed verification reports.
* Talking to a future registration API.

Python should not be required for the critical initialize path unless the target
OS already guarantees Python 3. The initialize layer should stay as close to
standard Linux shell tooling as possible.

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
* Register basic machine information.
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

## Proposed Work Before Programming

Before implementing code, review and confirm these work items:

* Define the exact initialize script entry point.
* Define where initialize configuration will live.
* Define the systemd service name and unit file location.
* Define how the reverse SSH tunnel port will be assigned.
* Define what machine information is registered during initialize.
* Define whether registration is local-only at first or sent to an API.
* Define which provisioning profiles are needed first.
* Define whether existing scripts should be kept as separate installers or
  grouped under profile scripts.
* Confirm whether Python helpers are allowed outside the initialize-critical
  path.

No implementation should begin until these choices are reviewed.

## Proposed File Layout

The exact file layout should be confirmed before programming. A likely structure
is:

```text
initialize.sh
initialize/
    install-ssh.sh
    install-autossh.sh
    install-keys.sh
    register-machine.sh
    systemd/
        digi-display-initialize.service
provision.sh
profiles/
    development-workstation.sh
    signage-player.sh
    offlinebox-appliance.sh
    kiosk-device.sh
```

Existing installer scripts may be reused or moved only after review.

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

* Device registration API
* Heartbeat monitoring
* Screenshot service
* Remote reboot
* Remote configuration
* Central dashboard

These features belong above the initialize layer and should not be required for
machine recovery.
