#!/usr/bin/env bash
# Output the latest stable Nginx version number
set -euo pipefail

HTML=$(curl -fsSL https://nginx.org/en/download.html)
# match nginx-<version>.tar.gz where <version> is x.y.z and prefer the highest stable version
VER=$(echo "$HTML" | grep -oP 'nginx-\K[0-9]+\.[0-9]+\.[0-9]+(?=\.tar\.gz)' | sort -V | tail -1)
if [ -z "$VER" ]; then
echo "1.29.2"
else
echo "$VER"
fi
