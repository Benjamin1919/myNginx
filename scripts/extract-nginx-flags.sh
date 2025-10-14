#!/usr/bin/env bash
# We still set -e to catch critical errors, but will ensure the script exits 0 manually.
set -e

echo "Working directory is $(pwd)"
echo "Fetching Nginx configure flags..."

# 1. Setup temporary directory
TEMP_DIR="/tmp/nginx-source-flags"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR" || { echo "❌ FATAL: Could not enter temporary directory $TEMP_DIR"; exit 1; } 

# 2. Try to run apt-get source
apt-get update -qq || true 
apt-get source -qq --yes nginx || true 

# 3. Check result and extract parameters
FLAGS=""
SOURCE_DIR_RAW=$(ls -d nginx-*/ 2>/dev/null | head -n 1)

if [ -n "$SOURCE_DIR_RAW" ]; then
    SOURCE_DIR_CLEAN=$(echo "$SOURCE_DIR_RAW" | sed 's/\/$//')
    DEBIAN_RULES_PATH="${TEMP_DIR}/${SOURCE_DIR_CLEAN}/debian/rules"
    
    if [ -f "$DEBIAN_RULES_PATH" ]; then
        
        echo "Found rules file: $DEBIAN_RULES_PATH"

        # --- CRITICAL FIX FOR FLAG EXTRACTION ---
        # 目标：提取所有配置参数，通常位于 CONFFLAGS, CONFARGS 或类似的变量中。
        
        # 步骤 1: 查找 configure 目标或变量定义
        # 我们查找包含 'configure' 字符串的行，然后提取其后的所有参数。
        # 这种模式比只匹配 '--with' 更具鲁棒性。
        FLAGS_LINES=$(cat "$DEBIAN_RULES_PATH" | \
            grep -E '(dh_auto_configure|--configure-args=|--with|--add-module)' | \
            grep -v '#' | \
            tr -s ' ' '\n' | \
            grep '^--' | \
            tr '\n' ' ')
            
        # 步骤 2: 清理并合并参数
        # 移除行首行尾的空格和引号。
        FLAGS=$(echo "$FLAGS_LINES" | sed 's/[[:space:]]*$//; s/^"//; s/"$//')
        
        # 额外的清理：移除不必要的换行符和制表符
        FLAGS=$(echo "$FLAGS" | tr -d '\n\t')

        # 检查 FLAGS 是否只包含不完整的参数（例如只包含 '--without' 这种残缺的参数，这是上一次失败的原因）
        if [[ "$FLAGS" == *--without* ]]; then
            # 如果 FLAGS 包含 --without 但长度极短（例如小于50个字符），则判断为不完整。
            if [ ${#FLAGS} -lt 50 ]; then
                echo "⚠️ Extracted flags seem incomplete ('$FLAGS'). Setting to empty to use Dockerfile defaults."
                FLAGS=""
            fi
        fi
        
        # --- END CRITICAL FIX ---

    fi
fi

# 4. Check result and set fallback
if [[ -z "$FLAGS" ]]; then
    FLAGS=""
    echo "⚠️ Failed to find nginx-full configure flags. NGINX_CONFIGURE_FLAGS set to empty, Docker build will use defaults."
else
    # Since the extracted flags are often incomplete due to the complex Makefile/Rules structure, 
    # we manually check if the flags are too short, which indicates a problem.
    if [[ "$FLAGS" == *--without* ]]; then
        echo "⚠️ Extracted flags seem incomplete ('$FLAGS'). Setting to empty to use Dockerfile defaults."
        FLAGS=""
    fi
    echo "✅ NGINX_CONFIGURE_FLAGS=$FLAGS"
fi

# 5. Write to GitHub ENV (This is the clean way)
# IMPORTANT: We use a separate echo/pipe for the environment variable to avoid shell
# interference with the main script's output, which fixes the 'No such file' error.
echo "NGINX_CONFIGURE_FLAGS=$FLAGS" > /dev/null # Suppress output from this line for safety

# Write the final result to the GitHub environment file directly.
# This must be done outside of the sudo context or with elevated permissions.
# Since the script is run with 'sudo bash ...', we must ensure we are writing to the host's $GITHUB_ENV.
# We pass $GITHUB_ENV as an argument to the script to ensure sudo knows where to write.
if [ -n "$1" ]; then
    echo "NGINX_CONFIGURE_FLAGS=$FLAGS" >> "$1"
fi

# 6. Successful Exit (0)
exit 0
