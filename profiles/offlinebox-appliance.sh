#!/usr/bin/env bash
set -euo pipefail

main() {
  local action="${1:-}"

  case "$action" in
    install)
      printf 'ERROR: offlinebox-appliance install is coming in a future release.\n' >&2
      exit 1
      ;;
    upgrade|verify)
      printf 'ERROR: %s is coming in a future release.\n' "$action" >&2
      exit 1
      ;;
    *)
      printf 'ERROR: Unknown offlinebox-appliance action: %s\n' "$action" >&2
      exit 1
      ;;
  esac
}

main "$@"
