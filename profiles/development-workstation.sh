#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

run_script() {
  local script_path="$1"

  if [[ ! -f "$script_path" ]]; then
    printf 'ERROR: Installer not found: %s\n' "$script_path" >&2
    exit 1
  fi

  bash "$script_path"
}

run_script_with_sudo() {
  local script_path="$1"

  if [[ ! -f "$script_path" ]]; then
    printf 'ERROR: Installer not found: %s\n' "$script_path" >&2
    exit 1
  fi

  if [[ "${EUID}" -eq 0 ]]; then
    bash "$script_path"
    return
  fi

  sudo bash "$script_path"
}

install_profile() {
  if [[ "${EUID}" -eq 0 ]]; then
    printf 'ERROR: Run development-workstation provisioning without sudo. The profile will ask for sudo only where needed.\n' >&2
    exit 1
  fi

  run_script "$REPO_DIR/bitwarden.sh"
  run_script_with_sudo "$REPO_DIR/docker.sh"
  run_script "$REPO_DIR/jetbrains.sh"
  run_script "$REPO_DIR/obsidian.sh"
  run_script "$REPO_DIR/firefox-addons.sh"
}

main() {
  local action="${1:-}"

  case "$action" in
    install)
      install_profile
      ;;
    upgrade|verify)
      printf 'ERROR: %s is coming in a future release.\n' "$action" >&2
      exit 1
      ;;
    *)
      printf 'ERROR: Unknown development-workstation action: %s\n' "$action" >&2
      exit 1
      ;;
  esac
}

main "$@"
