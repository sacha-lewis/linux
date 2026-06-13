#!/usr/bin/env bash

set -euo pipefail

command="${1:-help}"

if [[ "$command" == "install" ]]; then
    sudo apt install snapper btrfs-assistant
    exit
fi

if [[ "$command" == "which" ]]; then
    which snapper
    exit
fi

if [[ "$command" == "init" ]]; then
    sudo snapper -c root create-config /
    sudo snapper list-configs
    exit
fi

if [[ "$command" == "create" ]]; then
    description="${2:-manual snapshot}"
    sudo snapper create --description "$description"
    exit
fi

if [[ "$command" == "delete" ]]; then
    snapshot_id="${2:?Usage: $0 delete SNAPSHOT_ID}"
    sudo snapper delete "$snapshot_id"
    exit
fi

if [[ "$command" == "rollback" ]]; then
    sudo snapper rollback
    exit
fi

if [[ "$command" == "verify-home-excluded" ]]; then
    sudo touch /root/test-root
    touch "$HOME/test-home"
    sudo snapper create --description "test files"
    sudo snapper status 1..2
    exit
fi

cat <<EOF
Usage: $0 COMMAND [ARGUMENT]

Commands:
  install
  which
  init
  create [DESCRIPTION]
  delete SNAPSHOT_ID
  rollback
  verify-home-excluded
  help
EOF
