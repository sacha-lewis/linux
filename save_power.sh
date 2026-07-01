#!/usr/bin/env bash

echo "===== Save Power Mode ====="

# Gracefully stop Docker
echo "Stopping Docker..."
docker compose down >/dev/null 2>&1 || true
systemctl --user stop docker.service 2>/dev/null || true
systemctl --user stop docker-desktop.service 2>/dev/null || true

# Close development applications
echo "Closing PHPStorm..."
pkill -f phpstorm || true

echo "Closing JetBrains Toolbox..."
pkill -f jetbrains-toolbox || true

# Stop Fusuma
echo "Stopping Fusuma..."
pkill -f fusuma || true

# Close LocalSend
echo "Closing LocalSend..."
pkill -f localsend || true

# Pause KDE Connect
echo "Stopping KDE Connect..."
pkill -f kdeconnectd || true

echo ""
echo "✔ Save Power Mode enabled."