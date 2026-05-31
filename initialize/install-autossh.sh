#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

main() {
  require_root
  install_apt_packages autossh
  ensure_command autossh

  log_info "AutoSSH is installed."
}

main "$@"
