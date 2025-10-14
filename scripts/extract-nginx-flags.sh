#!/usr/bin/env bash

echo "Fetching Nginx configure flags..."

# 1. 设置临时目录并进入
TEMP_DIR="/tmp/nginx-source-flags"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

cd "$TEMP_DIR" || { echo "❌ 无法进入临时目录 $TEMP_DIR"; exit 1; } 

# 2. 尝试运行 apt-get source
# 再次更新源列表，确保 deb-src 生效
apt-get update -qq

# 在当前目录下载并解压源码。移除了不支持的 '-D' 选项。
# 注意：如果权限警告 (W: Download is performed unsandboxed...) 再次出现，请忽略它，只要 exit code 不是 100 即可。
apt-get source -qq --yes nginx || { 
    echo "❌ apt-get source 失败，可能缺少 'deb-src' 源或权限问题。"; 
    FLAGS=""; 
}

# 3. 检查结果并提取参数
FLAGS=""
# 查找源码目录名称，例如 nginx-1.24.0。使用通配符匹配目录。
SOURCE_DIR=$(ls -d nginx-*/ 2>/dev/null | head -n 1)

if [ -n "$SOURCE_DIR" ] && [ -d "${SOURCE_DIR}/debian" ]; then
    # 成功找到源码包，进入 debian 目录
    cd "${SOURCE_DIR}/debian" || exit 1
    
    # 提取 configure 参数
    FLAGS=$(grep -oP '(?<=--configure-args=).*' rules | tail -1 | sed 's/"//g')
    
    # 返回到临时目录，方便清理（非必需，但良好习惯）
    cd ../.. >/dev/null
else
    # 下载失败或源码目录结构不符
    FLAGS=""
fi


# 4. 检查结果并设置环境变量
if [[ -z "$FLAGS" ]]; then
    # 如果 FLAGS 为空，给出警告
    FLAGS=""
    echo "⚠️ 未能找到 nginx-full 的 configure 参数。NGINX_CONFIGURE_FLAGS 已设置为空值，Docker 构建将使用默认参数。"
else
    # 成功找到参数
    echo "✅ NGINX_CONFIGURE_FLAGS=$FLAGS"
fi

# 5. 写入 GitHub 环境变量 (无论是否为空)
echo "NGINX_CONFIGURE_FLAGS=$FLAGS" >> "$GITHUB_ENV"

# 6. 退出：成功退出 (0) 以确保 CI 流程继续执行 Build 步骤
exit 0
