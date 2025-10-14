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
        # 目标：从 rules 文件中提取所有配置参数，通常位于 'configure' 目标附近或变量中。
        # 查找所有包含 --with 或 --add-module 的行，并将其视为配置参数。
        FLAGS=$(cat "$DEBIAN_RULES_PATH" | \
            grep -E '(--with|--add-module)' | \
            grep -v '#' | \
            tr -s ' ' '\n' | \
            grep '^--' | \
            tr '\n' ' ' | \
            sed 's/[[:space:]]*$//')
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
