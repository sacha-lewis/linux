#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/lib.sh"

configure_git_delta() {
  local target_user="$1"
  local target_home
  local target_group
  local git_config

  target_home="$(getent passwd "$target_user" | cut -d: -f6)"
  target_group="$(id -gn "$target_user")"

  if [[ -z "$target_home" ]]; then
    fail "Could not determine home directory for user: $target_user"
  fi

  git_config="$target_home/.gitconfig"

  HOME="$target_home" git config --global core.pager delta
  HOME="$target_home" git config --global interactive.diffFilter 'delta --color-only'
  HOME="$target_home" git config --global delta.navigate true
  HOME="$target_home" git config --global delta.side-by-side true
  HOME="$target_home" git config --global delta.line-numbers true

  chown "$target_user:$target_group" "$git_config"

  log_info "Git Delta configured for local user: $target_user"
}

main() {
  local config_file="${1:-$REPO_DIR/initialize.config.json}"
  local configured_user
  local target_user

  require_root
  require_file "$config_file"

  install_apt_packages git git-delta
  ensure_command git
  ensure_command delta

  configured_user="$(json_required_string local_admin_user "$config_file")"
  target_user="$(resolve_local_admin_user "$configured_user")"

  if ! getent passwd "$target_user" >/dev/null; then
    fail "Configured local admin user does not exist: $target_user"
  fi

  configure_git_delta "$target_user"
}

main "$@"
