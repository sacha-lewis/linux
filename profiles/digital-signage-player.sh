#!/usr/bin/env bash
set -euo pipefail

main() {
  local action="${1:-}"

  case "$action" in
    install)
      printf 'ERROR: digital-signage-player install is coming in a future release.\n' >&2
      exit 1
      ;;
    upgrade|verify)
      printf 'ERROR: %s is coming in a future release.\n' "$action" >&2
      exit 1
      ;;
    *)
      printf 'ERROR: Unknown digital-signage-player action: %s\n' "$action" >&2
      exit 1
      ;;
  esac
}

main "$@"
