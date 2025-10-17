#!/usr/bin/env bash
set -euo pipefail

echo "Fetching latest versions..."

NGINX_VERSION=$(curl -s --connect-timeout 10 --retry 2 --retry-delay 5 "https://api.github.com/repos/nginx/nginx/releases/latest" | jq -r '.tag_name | sub("^release-"; "")')

OPENSSL_VERSION=$(curl -s --connect-timeout 10 --retry 2 --retry-delay 5 "https://api.github.com/repos/openssl/openssl/releases/latest" | jq -r '.tag_name | sub("^openssl-"; "")')

ZLIB_VERSION=$(curl -s --connect-timeout 10 --retry 2 --retry-delay 5 "https://api.github.com/repos/madler/zlib/releases/latest" | jq -r '.tag_name | sub("^v"; "")')

PCRE2_VERSION=$(curl -s --connect-timeout 10 --retry 2 --retry-delay 5 "https://api.github.com/repos/PCRE2Project/pcre2/releases/latest" | jq -r '.tag_name | sub("^pcre2-"; "")')

if [ -z "$NGINX_VERSION" ]; then
  echo "❌ Failed to fetch Nginx latest version, fallback to 1.29.2"
  NGINX_VERSION=1.29.2
else
  echo "✅ NGINX_VERSION=$NGINX_VERSION"
fi

if [ -z "$OPENSSL_VERSION" ]; then
  echo "❌ Failed to fetch OpenSSL latest version, fallback to 3.6.0"
  OPENSSL_VERSION=3.6.0
else
  echo "✅ OPENSSL_VERSION=$OPENSSL_VERSION"
fi

if [ -z "$ZLIB_VERSION" ]; then
  echo "❌ Failed to fetch zlib latest version, fallback to 1.3.1"
  PCRE2_VERSION=1.3.1
else
  echo "✅ ZLIB_VERSION=$ZLIB_VERSION"
fi

if [ -z "$PCRE2_VERSION" ]; then
  echo "❌ Failed to fetch PCRE2 latest version, fallback to 10.46"
  PCRE2_VERSION=10.46
else
  echo "✅ PCRE2_VERSION=$PCRE2_VERSION"
fi

{
  echo "NGINX_VERSION=${NGINX_VERSION}"
  echo "OPENSSL_VERSION=${OPENSSL_VERSION}"
  echo "ZLIB_VERSION=${ZLIB_VERSION}"
  echo "PCRE2_VERSION=${PCRE2_VERSION}"
} >> "$GITHUB_ENV"
