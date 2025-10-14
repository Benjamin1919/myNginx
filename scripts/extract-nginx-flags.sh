#!/usr/bin/env bash
set -e

# 从 nginx-full 包中提取 configure 参数
#apt-get update -qq
apt-get source -qq nginx
cd nginx-*/debian || exit 1
FLAGS=$(grep -oP '(?<=--configure-args=).*' rules | tail -1 | sed 's/"//g')

if [[ -z "$FLAGS" ]]; then
  echo "❌ 未找到 nginx-full 的 configure 参数"
  echo "NGINX_CONFIGURE_FLAGS=" >> $GITHUB_ENV
  exit 1
fi

echo "✅ NGINX_CONFIGURE_FLAGS=$FLAGS"

echo "NGINX_CONFIGURE_FLAGS=$FLAGS" >> $GITHUB_ENV
