#!/usr/bin/env bash

echo "Fetching Nginx configure flags..."

# 1. 尝试运行 apt-get source

# 确保在运行 apt-get source 之前更新源列表
apt-get update -qq

# 将 nginx 源码下载到 /tmp，避免权限和目录冲突
mkdir -p /tmp/nginx-source
apt-get source -qq --yes -D /tmp/nginx-source nginx || { echo "❌ apt-get source 失败。"; FLAGS=""; }

# 假设下载成功，进入源码目录。如果失败，FLAGS保持为空。
if [ -d /tmp/nginx-source/nginx-*/debian ]; then
    cd /tmp/nginx-source/nginx-*/debian || exit 1
    # 提取 configure 参数
    FLAGS=$(grep -oP '(?<=--configure-args=).*' rules | tail -1 | sed 's/"//g')
else
    FLAGS=""
fi

# 2. 检查结果并设置环境变量
if [[ -z "$FLAGS" ]]; then
    # 如果 FLAGS 为空，则将其保持为空，并给出警告
    FLAGS=""
    echo "⚠️ 未能找到 nginx-full 的 configure 参数。环境变量 NGINX_CONFIGURE_FLAGS 已设置为空值，Docker 构建将使用默认参数。"
else
    # 成功找到参数
    echo "✅ NGINX_CONFIGURE_FLAGS=$FLAGS"
fi

# 3. 写入 GitHub 环境变量 (无论是否为空)
echo "NGINX_CONFIGURE_FLAGS=$FLAGS" >> $GITHUB_ENV

# 4. 退出：成功退出 (0) 以确保 CI 流程继续执行 Build 步骤
exit 0
