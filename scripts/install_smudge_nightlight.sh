#!/bin/bash

set -e

echo "==> Installing nightlight..."

if command -v nightlight &>/dev/null; then
  echo "nightlight already installed."
  exit 0
fi

TMP=$(mktemp)
curl -fsSL https://github.com/smudge/nightlight/releases/download/v1.0.0/nightlight.arm64 -o "$TMP"
sudo mv "$TMP" /usr/local/bin/nightlight
sudo chmod +x /usr/local/bin/nightlight

echo "nightlight installed."

echo "==> Configuring nightlight schedule..."
nightlight schedule start
nightlight temp 55
echo "nightlight schedule set (sunset to sunrise)."
