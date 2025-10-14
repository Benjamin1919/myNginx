#!/usr/bin/env bash

# 脚本开始时打印工作目录，用于调试
echo "Working directory is $(pwd)"
echo "Fetching Nginx configure flags..."

# 1. 设置临时目录并进入
TEMP_DIR="/tmp/nginx-source-flags"
# 确保目录不存在就创建，并强制清理旧的残留文件
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

# 使用 root 权限进入目录
cd "$TEMP_DIR" || { echo "❌ 无法进入临时目录 $TEMP_DIR"; exit 1; } 

# 2. 尝试运行 apt-get source
apt-get update -qq

# 在当前目录下载并解压源码。
# 使用 || true 确保脚本在 apt-get source 失败时仍能继续，以便设置空 FLAGS
apt-get source -qq --yes nginx || true 

# 3. 检查结果并提取参数
FLAGS=""
# 查找源码目录名称，例如 nginx-1.24.0。使用 ls -d 匹配目录名并移除可能的尾随斜杠
# **关键修改：使用 readlink -f 来获取绝对路径并清理名称**
SOURCE_DIR_RAW=$(ls -d nginx-*/ 2>/dev/null | head -n 1)

if [ -n "$SOURCE_DIR_RAW" ]; then
    # 获取绝对路径，并去除尾随的斜杠 (/)，确保路径干净
    SOURCE_DIR_CLEAN=$(echo "$SOURCE_DIR_RAW" | sed 's/\/$//')
    
    # 检查 debian 目录是否存在
    if [ -d "${SOURCE_DIR_CLEAN}/debian" ]; then
        
        echo "Found Debian source directory: ${SOURCE_DIR_CLEAN}/debian"
        
        # 临时进入 debian 目录
        cd "${SOURCE_DIR_CLEAN}/debian" || exit 1
        
        # 提取 configure 参数
        FLAGS=$(grep -oP '(?<=--configure-args=).*' rules | tail -1 | sed 's/"//g')
        
        # 返回到临时目录
        cd - >/dev/null  
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
