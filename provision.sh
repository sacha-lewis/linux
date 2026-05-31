#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<USAGE
Usage:
  ./provision.sh install development-workstation
  ./provision.sh install digital-signage-player
  ./provision.sh install offlinebox-appliance
  ./provision.sh install kiosk-device
USAGE
}

error() {
  printf 'ERROR: %s\n' "$*" >&2
}

future_release() {
  local action="$1"

  error "$action is coming in a future release."
  exit 1
}

profile_script_for() {
  local profile="$1"

  case "$profile" in
    development-workstation)
      printf '%s\n' "$REPO_DIR/profiles/development-workstation.sh"
      ;;
    digital-signage-player)
      printf '%s\n' "$REPO_DIR/profiles/digital-signage-player.sh"
      ;;
    offlinebox-appliance)
      printf '%s\n' "$REPO_DIR/profiles/offlinebox-appliance.sh"
      ;;
    kiosk-device)
      printf '%s\n' "$REPO_DIR/profiles/kiosk-device.sh"
      ;;
    *)
      return 1
      ;;
  esac
}

main() {
  local action="${1:-}"
  local profile="${2:-}"
  local profile_script

  case "$action" in
    install)
      ;;
    upgrade|verify)
      future_release "$action"
      ;;
    ""|-h|--help|help)
      usage
      exit 0
      ;;
    *)
      usage
      error "Unknown provision action: $action"
      exit 1
      ;;
  esac

  if [[ -z "$profile" ]]; then
    usage
    error "Missing provision profile."
    exit 1
  fi

  if ! profile_script="$(profile_script_for "$profile")"; then
    usage
    error "Unknown provision profile: $profile"
    exit 1
  fi

  bash "$profile_script" "$action"
}

main "$@"
