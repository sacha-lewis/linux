#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/lib.sh"

resolve_local_admin_user() {
  local configured_user="$1"

  if [[ "$configured_user" != "auto" ]]; then
    printf '%s\n' "$configured_user"
    return
  fi

  if [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
    printf '%s\n' "$SUDO_USER"
    return
  fi

  printf 'root\n'
}

install_authorized_keys() {
  local key_file="$1"
  local target_user="$2"
  local target_home
  local target_group
  local ssh_dir
  local authorized_keys
  local installed_count=0
  local key_line

  target_home="$(getent passwd "$target_user" | cut -d: -f6)"
  target_group="$(id -gn "$target_user")"

  if [[ -z "$target_home" ]]; then
    fail "Could not determine home directory for user: $target_user"
  fi

  ssh_dir="$target_home/.ssh"
  authorized_keys="$ssh_dir/authorized_keys"

  install -d -m 700 -o "$target_user" -g "$target_group" "$ssh_dir"
  touch "$authorized_keys"
  chown "$target_user:$target_group" "$authorized_keys"
  chmod 600 "$authorized_keys"

  while IFS= read -r key_line || [[ -n "$key_line" ]]; do
    key_line="${key_line%$'\r'}"

    [[ -z "$key_line" ]] && continue
    [[ "$key_line" =~ ^[[:space:]]*# ]] && continue

    if ! grep -Fqx "$key_line" "$authorized_keys"; then
      printf '%s\n' "$key_line" >> "$authorized_keys"
    fi

    installed_count=$((installed_count + 1))
  done < "$key_file"

  if (( installed_count == 0 )); then
    fail "No SSH public keys found in $key_file. Add undoLogic public keys before running initialize."
  fi

  chown "$target_user:$target_group" "$authorized_keys"
  chmod 600 "$authorized_keys"

  log_info "Installed $installed_count SSH public key(s) for local user: $target_user"
}

main() {
  local config_file="${1:-$REPO_DIR/initialize.config.json}"
  local authorized_keys_file
  local configured_user
  local target_user

  require_root
  require_file "$config_file"

  authorized_keys_file="$(json_required_string authorized_keys_file "$config_file")"
  authorized_keys_file="$(resolve_repo_path "$REPO_DIR" "$authorized_keys_file")"
  configured_user="$(json_required_string local_admin_user "$config_file")"
  target_user="$(resolve_local_admin_user "$configured_user")"

  require_file "$authorized_keys_file"

  if ! getent passwd "$target_user" >/dev/null; then
    fail "Configured local admin user does not exist: $target_user"
  fi

  install_authorized_keys "$authorized_keys_file" "$target_user"
}

main "$@"
