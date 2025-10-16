#!/usr/bin/env bash
set -euo pipefail

echo "Fetching latest Nginx and OpenSSL versions..."

NGINX_VERSION=$(curl -s --connect-timeout 10 --retry 2 --retry-delay 5 "https://api.github.com/repos/nginx/nginx/releases" | grep -Po '"tag_name":\s*"release-\K[0-9.]+' | sort -V | tail -1)

OPENSSL_VERSION=$(curl -s --connect-timeout 10 --retry 2 --retry-delay 5 "https://api.github.com/repos/openssl/openssl/releases" | grep -Po '"tag_name":\s*"openssl-\K[0-9A-Za-z.\-]+' | grep -Evi '(alpha|beta)' | sort -V | tail -1)

if [ -z "$NGINX_VERSION" ]; then
  echo "❌ Failed to fetch Nginx latest versions, fallback to 1.29.2"
  NGINX_VERSION=1.29.2
else
  echo "✅ NGINX_VERSION=$NGINX_VERSION"
fi

if [ -z "$OPENSSL_VERSION" ]; then
  echo "❌ Failed to fetch OpenSSL latest versions, fallback to 3.6.0"
  OPENSSL_VERSION=3.6.0
else
  echo "✅ OPENSSL_VERSION=$OPENSSL_VERSION"
fi

{
  echo "NGINX_VERSION=${NGINX_VERSION}"
  echo "OPENSSL_VERSION=${OPENSSL_VERSION}"
} >> "$GITHUB_ENV"
