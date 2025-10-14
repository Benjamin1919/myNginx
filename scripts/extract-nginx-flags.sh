#!/usr/bin/env bash
# 禁用 'e' 选项，让脚本自己处理错误，避免 apt-get source 或 cd 失败导致意外退出
set -u

echo "Working directory is $(pwd)"
echo "Fetching Nginx configure flags..."

# 1. 设置临时目录和清理
TEMP_DIR="/tmp/nginx-source-flags"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR" || { echo "❌ 无法进入临时目录 $TEMP_DIR"; exit 1; } 

# 2. 尝试运行 apt-get source
apt-get update -qq || true # 允许 update 失败
# 使用 || true 确保即使权限警告出现，脚本也不会中断
apt-get source -qq --yes nginx || true 

# 3. 检查结果并提取参数
FLAGS=""
# 查找源码目录名称，例如 nginx-1.24.0。
SOURCE_DIR_RAW=$(ls -d nginx-*/ 2>/dev/null | head -n 1)

if [ -n "$SOURCE_DIR_RAW" ]; then
    # 获取干净的目录名（移除尾随斜杠）
    SOURCE_DIR_CLEAN=$(echo "$SOURCE_DIR_RAW" | sed 's/\/$//')
    DEBIAN_RULES_PATH="${TEMP_DIR}/${SOURCE_DIR_CLEAN}/debian/rules"
    
    # 检查 rules 文件是否存在
    if [ -f "$DEBIAN_RULES_PATH" ]; then
        
        echo "Found rules file: $DEBIAN_RULES_PATH"
        
        # 提取 configure 参数。
        # 注意：使用 cat 读取文件内容，然后用 grep 提取，更加稳健。
        FLAGS=$(cat "$DEBIAN_RULES_PATH" | grep -oP '(?<=--configure-args=).*' | tail -1 | sed 's/"//g')
        
    fi
fi

# 4. 检查结果并设置环境变量
if [[ -z "$FLAGS" ]]; then
    FLAGS=""
    echo "⚠️ 未能找到 nginx-full 的 configure 参数。NGINX_CONFIGURE_FLAGS 已设置为空值，Docker 构建将使用默认参数。"
else
    echo "✅ NGINX_CONFIGURE_FLAGS=$FLAGS"
fi

# 5. 写入 GitHub 环境变量 (无论是否为空)
echo "NGINX_CONFIGURE_FLAGS=$FLAGS" >> "$GITHUB_ENV"

# 6. 成功退出 (0)
exit 0
