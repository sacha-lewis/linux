#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

chromium_command_exists() {
  command_exists chromium || command_exists chromium-browser || [[ -x /snap/bin/chromium ]]
}

apt_package_exists() {
  local package_name="$1"

  apt-cache show "$package_name" >/dev/null 2>&1
}

resolve_chromium_package() {
  local package_name

  for package_name in chromium chromium-browser; do
    if apt_package_exists "$package_name"; then
      printf '%s\n' "$package_name"
      return
    fi
  done

  log_info "Refreshing apt package cache before looking for Chromium."
  apt-get update

  for package_name in chromium chromium-browser; do
    if apt_package_exists "$package_name"; then
      printf '%s\n' "$package_name"
      return
    fi
  done

  fail "Could not find a Chromium apt package. Tried: chromium chromium-browser"
}

main() {
  local package_name

  require_root

  if chromium_command_exists; then
    log_info "Chromium is already installed."
    return
  fi

  if ! command_exists apt-get; then
    fail "apt-get is required. This installer currently targets Debian/Ubuntu-based Linux."
  fi

  ensure_command apt-cache

  package_name="$(resolve_chromium_package)"
  install_apt_packages "$package_name"

  if ! chromium_command_exists; then
    fail "Chromium package installed, but no chromium command was found."
  fi

  log_info "Chromium is installed."
}

main "$@"
