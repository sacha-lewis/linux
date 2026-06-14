#!/bin/bash

command="${1:-help}"
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
assets_dir="$script_dir/assets"

CONFIG_FILES=(
    "plasma-org.kde.plasma.desktop-appletsrc"
    "plasmarc"
    "kwinrc"
    "kdeglobals"
    "kglobalshortcutsrc"
)

copy_config_files() {
    local source_dir="$1"
    local destination_dir="$2"
    local status=0

    mkdir -p "$destination_dir"

    for file in "${CONFIG_FILES[@]}"; do
        if [[ ! -f "$source_dir/$file" ]]; then
            printf 'Missing file: %s\n' "$source_dir/$file" >&2
            status=1
            continue
        fi

        cp -- "$source_dir/$file" "$destination_dir/$file" || status=1
    done

    return "$status"
}

if [[ "$command" == "backup" ]]; then
    copy_config_files "$HOME/.config" "$assets_dir"
    exit $?
fi

if [[ "$command" == "restore" ]]; then
    copy_config_files "$assets_dir" "$HOME/.config"
    exit $?
fi

cat <<EOF
Usage: $0 COMMAND

Back up or restore KDE Plasma configuration files.

Commands:
  backup   Copy files from ~/.config to assets
  restore  Copy files from assets to ~/.config
EOF
