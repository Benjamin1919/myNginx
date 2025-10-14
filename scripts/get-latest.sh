#!/usr/bin/env bash
set -e

echo "Fetching latest Nginx and OpenSSL versions..."

# 获取最新 Nginx 版本
NGINX_VERSION=$(curl -s --connect-timeout 10 --retry 2 "https://github.com/nginx/nginx/releases" | grep -oP 'releases/tag/release-\K[0-9.]+' | sort -V | tail -1)

# 获取最新 OpenSSL 版本
OPENSSL_VERSION=$(curl -s --connect-timeout 10 --retry 2 "https://github.com/openssl/openssl/releases" | grep -oP 'releases/tag/openssl-\K[0-9.]+' | sort -V | tail -1)

if [[ -z "$NGINX_VERSION" || -z "$OPENSSL_VERSION" ]]; then
  echo "❌ 获取版本失败"
  exit 1
fi

echo "✅ NGINX_VERSION=$NGINX_VERSION"
echo "✅ OPENSSL_VERSION=$OPENSSL_VERSION"

# 写入 GitHub 环境变量
echo "NGINX_VERSION=$NGINX_VERSION" >> $GITHUB_ENV
echo "OPENSSL_VERSION=$OPENSSL_VERSION" >> $GITHUB_ENV
