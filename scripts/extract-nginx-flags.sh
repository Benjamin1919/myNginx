#!/usr/bin/env bash
# Attempt to pull Debian packaging for nginx and extract the ./configure invocation from debian/rules
set -euo pipefail

# Ensure apt source repos are available (workflow already enabled deb-src)
sudo apt-get update
# download packaging source into current dir
apt-get source nginx || true
# The source dir will be like nginx-<version>
SRCDIR=$(ls -d nginx-* 2>/dev/null | head -n1 || true)
if [ -z "$SRCDIR" ]; then
echo "# Could not retrieve nginx packaging source; using conservative defaults"
exit 0
fi
if [ -f "$SRCDIR/debian/rules" ]; then
# extract the configure line
CFG=$(sed -n '/configure/{:a;N;/\)/!ba;p}' $SRCDIR/debian/rules | tr '\n' ' ' | sed 's/.*configure //')
# Clean up make variables and tabs
CFG=$(echo "$CFG" | sed -E 's/\$\([^)]+\)//g' | sed -E 's/\s+/ /g')
echo "$CFG"
else
echo "# debian/rules not found; cannot extract flags"
fi
