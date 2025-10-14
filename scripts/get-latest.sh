#!/usr/bin/env bash
set -e

# 获取最新Nginx版本
NGINX_VERSION=$(curl -s https://nginx.org/en/download.html | grep -oP 'nginx-\K[0-9.]+(?=\.tar\.gz)' | sort -V | tail -1)

# 获取最新OpenSSL版本
OPENSSL_VERSION=$(curl -s https://www.openssl.org/source/ | grep -oP 'openssl-\K[0-9.]+(?=\.tar\.gz)' | sort -V | tail -1)

echo "NGINX_VERSION=$NGINX_VERSION"
echo "OPENSSL_VERSION=$OPENSSL_VERSION"

# 将结果写入环境文件（供GitHub Actions使用）
echo "NGINX_VERSION=$NGINX_VERSION" >> $GITHUB_ENV
echo "OPENSSL_VERSION=$OPENSSL_VERSION" >> $GITHUB_ENV
