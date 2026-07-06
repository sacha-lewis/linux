#!/usr/bin/env bash
set -euo pipefail

SOCK="$HOME/.bitwarden-ssh-agent.sock"
SOCK_ABS="$HOME/.bitwarden-ssh-agent.sock"
ENV_DIR="$HOME/.config/environment.d"
ENV_FILE="$ENV_DIR/bitwarden-ssh-agent.conf"
SSH_CONFIG="$HOME/.ssh/config"
BITWARDEN_APPIMAGE="$HOME/Applications/Bitwarden.AppImage"
BITWARDEN_AUTOSTART="$HOME/.config/autostart/bitwarden.desktop"

mkdir -p "$ENV_DIR" "$HOME/.ssh" "$HOME/.config/autostart" "$HOME/.local/share/applications"

echo "Writing desktop session environment..."
printf 'SSH_AUTH_SOCK=%s\n' "$SOCK_ABS" > "$ENV_FILE"

echo "Ensuring shell profiles export SSH_AUTH_SOCK..."
for profile in "$HOME/.bashrc" "$HOME/.profile"; do
    touch "$profile"
    if ! grep -Fq 'export SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock"' "$profile"; then
        printf '\nexport SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock"\n' >> "$profile"
    fi
done

echo "Ensuring OpenSSH uses Bitwarden as the identity agent..."
touch "$SSH_CONFIG"
if ! grep -Eq '^[[:space:]]*IdentityAgent[[:space:]]+.*\.bitwarden-ssh-agent\.sock' "$SSH_CONFIG"; then
    {
        printf '\nHost *\n'
        printf '    IdentityAgent ~/.bitwarden-ssh-agent.sock\n'
    } >> "$SSH_CONFIG"
fi
chmod 600 "$SSH_CONFIG"

if [ -x "$BITWARDEN_APPIMAGE" ]; then
    echo "Writing Bitwarden autostart entry..."
    cat > "$BITWARDEN_AUTOSTART" <<EOF
[Desktop Entry]
Type=Application
Name=Bitwarden
Comment=Bitwarden startup script
Exec=$BITWARDEN_APPIMAGE --autostart
StartupNotify=false
Terminal=false
EOF
else
    echo "Skipping Bitwarden autostart: $BITWARDEN_APPIMAGE was not found or is not executable."
fi

patch_exec_line() {
    local file="$1"
    local app_path="$2"
    local suffix="$3"

    [ -f "$file" ] || return 0
    [ -n "$app_path" ] || return 0

    if grep -Fq "Exec=env SSH_AUTH_SOCK=$SOCK_ABS" "$file"; then
        return 0
    fi

    echo "Patching $file"
    sed -i -E "s|^Exec=.*$|Exec=env SSH_AUTH_SOCK=$SOCK_ABS \"$app_path\" $suffix|" "$file"
}

echo "Finding PhpStorm launcher..."
PHPSTORM_BIN=""
if command -v phpstorm >/dev/null 2>&1; then
    PHPSTORM_BIN="$(command -v phpstorm)"
elif [ -x "$HOME/.local/share/JetBrains/Toolbox/apps/phpstorm/bin/phpstorm" ]; then
    PHPSTORM_BIN="$HOME/.local/share/JetBrains/Toolbox/apps/phpstorm/bin/phpstorm"
fi

for desktop in "$HOME"/.local/share/applications/jetbrains-phpstorm-*.desktop; do
    [ -e "$desktop" ] || continue
    patch_exec_line "$desktop" "$PHPSTORM_BIN" "%u"
done

echo "Finding JetBrains Toolbox launcher..."
TOOLBOX_BIN=""
if command -v jetbrains-toolbox >/dev/null 2>&1; then
    TOOLBOX_BIN="$(command -v jetbrains-toolbox)"
else
    TOOLBOX_BIN="$(find /var/home/linuxbrew/.linuxbrew/Caskroom/jetbrains-toolbox-linux -path '*/bin/jetbrains-toolbox' -type f -perm -111 2>/dev/null | sort -V | tail -n 1 || true)"
fi

patch_exec_line "$HOME/.local/share/applications/jetbrains-toolbox.desktop" "$TOOLBOX_BIN" "%u"
patch_exec_line "$HOME/.config/autostart/jetbrains-toolbox.desktop" "$TOOLBOX_BIN" "--minimize"

echo "Updating live desktop session environment if available..."
export SSH_AUTH_SOCK="$SOCK_ABS"
if command -v dbus-update-activation-environment >/dev/null 2>&1; then
    dbus-update-activation-environment --systemd SSH_AUTH_SOCK || true
fi
if command -v systemctl >/dev/null 2>&1; then
    systemctl --user import-environment SSH_AUTH_SOCK || true
fi

echo
echo "Done. Fully quit and reopen JetBrains Toolbox and PhpStorm."
echo "Current agent socket: $SOCK_ABS"
if [ -S "$SOCK_ABS" ] && command -v ssh-add >/dev/null 2>&1; then
    SSH_AUTH_SOCK="$SOCK_ABS" ssh-add -l || true
fi
