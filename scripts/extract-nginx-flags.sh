#!/usr/bin/env bash
# 保持 set -e，以便捕捉关键错误
set -e

echo "Working directory is $(pwd)"
echo "Fetching Nginx configure flags..."

# 1. 定义最终的回退参数 (Hardcoded Fallback)
# 这些参数已预先从 Ubuntu nginx-full 1.24.0 包中验证。
FALLBACK_FLAGS="--prefix=/usr/share/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/run/nginx.pid --lock-path=/run/lock/nginx.lock --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --with-compat --with-pcre-jit --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module --with-http_auth_request_module --with-http_v2_module --with-http_dav_module --with-http_slice_module --with-threads --with-stream --with-stream_ssl_module --with-stream_realip_module --with-stream_ssl_preread_module"

# 2. 设置临时目录和清理
TEMP_DIR="/tmp/nginx-source-flags"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR" || { echo "❌ FATAL: Could not enter temporary directory $TEMP_DIR"; exit 1; } 

# 3. 尝试运行 apt-get source
apt-get update -qq || true 
apt-get source -qq --yes nginx || true 

# 4. 检查结果并提取参数 (使用上一步的修复逻辑)
FLAGS=""
SOURCE_DIR_RAW=$(ls -d nginx-*/ 2>/dev/null | head -n 1)

if [ -n "$SOURCE_DIR_RAW" ]; then
    SOURCE_DIR_CLEAN=$(echo "$SOURCE_DIR_RAW" | sed 's/\/$//')
    DEBIAN_RULES_PATH="${TEMP_DIR}/${SOURCE_DIR_CLEAN}/debian/rules"
    
    if [ -f "$DEBIAN_RULES_PATH" ]; then
        echo "Found rules file: $DEBIAN_RULES_PATH"
        
        # 提取逻辑：尝试从 rules 文件中提取所有配置参数
        FLAGS_CANDIDATE=$(cat "$DEBIAN_RULES_PATH" | \
            grep -E '(--with|--add-module|--configure-args=|CONFARGS)' | \
            grep -v '#' | \
            tr -s ' ' '\n' | \
            grep '^--' | \
            tr '\n' ' ' | \
            sed 's/[[:space:]]*$//')
        
        # 检查提取结果是否有效
        if [ ${#FLAGS_CANDIDATE} -gt 50 ] && [[ "$FLAGS_CANDIDATE" != *--without* ]]; then
            # 只有在提取的参数长度足够长，且不包含残缺的 '--without' 字符串时，才使用它。
            FLAGS="$FLAGS_CANDIDATE"
        else
            echo "⚠️ Extracted flags ('$FLAGS_CANDIDATE') are too short or incomplete. Using hardcoded fallback."
        fi
    fi
fi

# 5. 检查最终结果并设置环境变量
if [[ -z "$FLAGS" ]]; then
    # 如果 FLAGS 仍然为空，使用硬编码回退值
    FLAGS="$FALLBACK_FLAGS"
    echo "⚠️ Final fallback activated. Using verified nginx-full defaults."
else
    echo "✅ NGINX_CONFIGURE_FLAGS=$FLAGS"
fi

# 6. 写入 GitHub ENV
# GITHUB_ENV 路径已通过 $1 传入。
if [ -n "$1" ]; then
    echo "NGINX_CONFIGURE_FLAGS=$FLAGS" >> "$1"
fi

# 7. 成功退出 (0)
exit 0
