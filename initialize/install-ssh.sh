#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

find_ssh_service() {
  if systemctl list-unit-files --no-legend ssh.service 2>/dev/null | grep -q '^ssh\.service'; then
    printf 'ssh\n'
    return
  fi

  if systemctl list-unit-files --no-legend sshd.service 2>/dev/null | grep -q '^sshd\.service'; then
    printf 'sshd\n'
    return
  fi

  fail "Could not find ssh.service or sshd.service after installing OpenSSH."
}

main() {
  local service_name

  require_root
  install_apt_packages openssh-server openssh-client
  ensure_command systemctl

  service_name="$(find_ssh_service)"
  enable_and_restart_service "$service_name"

  log_info "SSH service enabled and restarted: $service_name"
}

main "$@"
