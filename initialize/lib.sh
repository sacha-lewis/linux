#!/usr/bin/env bash

log_info() {
  printf 'INFO: %s\n' "$*"
}

log_warn() {
  printf 'WARN: %s\n' "$*" >&2
}

log_error() {
  printf 'ERROR: %s\n' "$*" >&2
}

fail() {
  log_error "$*"
  exit 1
}

require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    fail "This command must be run with sudo."
  fi
}

require_file() {
  local file_path="$1"

  if [[ ! -f "$file_path" ]]; then
    fail "Required file not found: $file_path"
  fi
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

resolve_repo_path() {
  local repo_dir="$1"
  local configured_path="$2"

  if [[ "$configured_path" = /* ]]; then
    printf '%s\n' "$configured_path"
    return
  fi

  printf '%s/%s\n' "$repo_dir" "$configured_path"
}

json_string() {
  local key="$1"
  local file_path="$2"

  sed -nE 's/^[[:space:]]*"'"$key"'"[[:space:]]*:[[:space:]]*"([^"]*)".*$/\1/p' "$file_path" | head -n 1
}

json_number() {
  local key="$1"
  local file_path="$2"

  sed -nE 's/^[[:space:]]*"'"$key"'"[[:space:]]*:[[:space:]]*([0-9]+).*$/\1/p' "$file_path" | head -n 1
}

json_required_string() {
  local key="$1"
  local file_path="$2"
  local value

  value="$(json_string "$key" "$file_path")"

  if [[ -z "$value" ]]; then
    fail "Missing required string config value: $key"
  fi

  printf '%s\n' "$value"
}

json_required_number() {
  local key="$1"
  local file_path="$2"
  local value

  value="$(json_number "$key" "$file_path")"

  if [[ -z "$value" ]]; then
    fail "Missing required numeric config value: $key"
  fi

  printf '%s\n' "$value"
}

validate_port() {
  local name="$1"
  local port="$2"

  if ! [[ "$port" =~ ^[0-9]+$ ]]; then
    fail "$name must be numeric. Current value: $port"
  fi

  if (( port < 1 || port > 65535 )); then
    fail "$name must be between 1 and 65535. Current value: $port"
  fi
}

install_apt_packages() {
  local missing_packages=()
  local package_name

  require_root

  if ! command_exists apt-get; then
    fail "apt-get is required. This installer currently targets Debian/Ubuntu-based Linux."
  fi

  for package_name in "$@"; do
    if ! dpkg-query -W -f='${Status}' "$package_name" 2>/dev/null | grep -q 'install ok installed'; then
      missing_packages+=("$package_name")
    fi
  done

  if (( ${#missing_packages[@]} == 0 )); then
    log_info "Required apt packages already installed: $*"
    return
  fi

  export DEBIAN_FRONTEND=noninteractive
  log_info "Installing apt packages: ${missing_packages[*]}"
  apt-get update
  apt-get install -y "${missing_packages[@]}"
}

enable_and_restart_service() {
  local service_name="$1"

  require_root

  systemctl enable "$service_name"
  systemctl restart "$service_name"
}

ensure_command() {
  local command_name="$1"

  if ! command_exists "$command_name"; then
    fail "Required command not found: $command_name"
  fi
}
