#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/lib.sh"

SERVICE_NAME="Digi-Display_Initialize.service"
SERVICE_SOURCE="$SCRIPT_DIR/systemd/$SERVICE_NAME"
SERVICE_TARGET="/etc/systemd/system/$SERVICE_NAME"
ENV_DIR="/etc/Digi-Display"
ENV_FILE="$ENV_DIR/initialize.env"
RUNNER_SOURCE="$SCRIPT_DIR/Digi-Display_Initialize"
RUNNER_TARGET="/usr/local/bin/Digi-Display_Initialize"

shell_quote() {
  local value="$1"

  printf '%q' "$value"
}

write_environment_file() {
  local remote_host="$1"
  local remote_user="$2"
  local remote_port="$3"
  local local_host="$4"
  local local_port="$5"
  local ssh_key_path="$6"

  install -d -m 755 "$ENV_DIR"

  {
    printf 'DIGI_DISPLAY_REMOTE_HOST=%s\n' "$(shell_quote "$remote_host")"
    printf 'DIGI_DISPLAY_REMOTE_USER=%s\n' "$(shell_quote "$remote_user")"
    printf 'DIGI_DISPLAY_REMOTE_PORT=%s\n' "$(shell_quote "$remote_port")"
    printf 'DIGI_DISPLAY_LOCAL_HOST=%s\n' "$(shell_quote "$local_host")"
    printf 'DIGI_DISPLAY_LOCAL_PORT=%s\n' "$(shell_quote "$local_port")"
    printf 'DIGI_DISPLAY_SSH_KEY_PATH=%s\n' "$(shell_quote "$ssh_key_path")"
  } > "$ENV_FILE"

  chmod 600 "$ENV_FILE"
}

ensure_tunnel_key() {
  local ssh_key_path="$1"
  local key_dir
  local key_comment

  key_dir="$(dirname "$ssh_key_path")"
  key_comment="Digi-Display_Initialize $(hostname 2>/dev/null || printf 'unknown-host')"

  install -d -m 700 "$key_dir"

  if [[ -f "$ssh_key_path" ]]; then
    chmod 600 "$ssh_key_path"
    [[ -f "$ssh_key_path.pub" ]] && chmod 644 "$ssh_key_path.pub"
    log_info "Reverse tunnel SSH key already exists: $ssh_key_path"
    return
  fi

  ssh-keygen -t ed25519 -f "$ssh_key_path" -N "" -C "$key_comment"
  chmod 600 "$ssh_key_path"
  chmod 644 "$ssh_key_path.pub"

  log_info "Created reverse tunnel SSH key: $ssh_key_path"
  log_warn "Authorize this public key on the tunnel server before expecting the service to stay connected: $ssh_key_path.pub"
}

install_systemd_service() {
  require_file "$SERVICE_SOURCE"
  require_file "$RUNNER_SOURCE"

  install -m 755 "$RUNNER_SOURCE" "$RUNNER_TARGET"
  install -m 644 "$SERVICE_SOURCE" "$SERVICE_TARGET"
  systemctl daemon-reload
  systemctl enable "$SERVICE_NAME"
}

restart_systemd_service() {
  if systemctl restart "$SERVICE_NAME"; then
    log_info "Initialize service restarted: $SERVICE_NAME"
    return
  fi

  log_warn "Initialize service did not start cleanly."
  log_warn "Confirm the reverse tunnel public key is authorized on the server, then run:"
  log_warn "  sudo systemctl restart $SERVICE_NAME"
}

main() {
  local config_file="${1:-$REPO_DIR/initialize.config.json}"
  local remote_host
  local remote_user
  local remote_port
  local local_host
  local local_port
  local ssh_key_path

  require_root
  require_file "$config_file"
  ensure_command systemctl
  ensure_command ssh-keygen

  remote_host="$(json_required_string host "$config_file")"
  remote_user="$(json_required_string remote_user "$config_file")"
  remote_port="$(json_required_number remote_port "$config_file")"
  local_host="$(json_required_string local_host "$config_file")"
  local_port="$(json_required_number local_port "$config_file")"
  ssh_key_path="$(json_required_string ssh_key_path "$config_file")"

  validate_port remote_port "$remote_port"
  validate_port local_port "$local_port"

  ensure_tunnel_key "$ssh_key_path"
  write_environment_file "$remote_host" "$remote_user" "$remote_port" "$local_host" "$local_port" "$ssh_key_path"
  install_systemd_service
  restart_systemd_service

  log_info "Reverse tunnel target: ${remote_user}@${remote_host}:${remote_port} -> ${local_host}:${local_port}"
}

main "$@"
