#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$REPO_DIR/initialize.config.json"

source "$REPO_DIR/initialize/lib.sh"

usage() {
  cat <<USAGE
Usage:
  sudo ./initialize.sh install
  sudo ./initialize.sh upgrade
  sudo ./initialize.sh verify
USAGE
}

future_release() {
  local action="$1"

  log_error "$action is coming in a future release."
  exit 1
}

install_initialize() {
  require_root
  require_file "$CONFIG_FILE"

  "$REPO_DIR/initialize/install-ssh.sh"
  "$REPO_DIR/initialize/install-autossh.sh"
  "$REPO_DIR/initialize/install-keys.sh" "$CONFIG_FILE"
  "$REPO_DIR/initialize/install-service.sh" "$CONFIG_FILE"
  "$REPO_DIR/initialize/install-git-delta.sh" "$CONFIG_FILE"

  log_info "Initialize install complete."
  log_info "Service: Digi-Display_Initialize.service"
  log_info "Config: $CONFIG_FILE"
}

main() {
  local action="${1:-}"

  case "$action" in
    install)
      install_initialize
      ;;
    upgrade|verify)
      future_release "$action"
      ;;
    ""|-h|--help|help)
      usage
      ;;
    *)
      usage
      fail "Unknown initialize action: $action"
      ;;
  esac
}

main "$@"
