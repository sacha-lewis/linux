#!/bin/bash

#!/usr/bin/env bash

urls=(
  "https://addons.mozilla.org/en-US/firefox/addon/bitwarden-password-manager/"
  "https://addons.mozilla.org/en-US/firefox/addon/darkreader/"
  "https://addons.mozilla.org/en-US/firefox/addon/raindropio/"
)

for url in "${urls[@]}"; do
  xdg-open "$url" >/dev/null 2>&1 &
  sleep 0.5
done
