#!/usr/bin/env bash
# Extract Debian nginx-full configure flags
set -euo pipefail

sudo apt-get update
apt-get source nginx || true

SRCDIR=$(ls -d nginx-* | head -n1 || true)
if [ -z "$SRCDIR" ]; then
  echo "# Could not retrieve nginx packaging source"
  exit 1
fi

RULES="$SRCDIR/debian/rules"

if [ -f "$RULES" ]; then
  COMMON=$(sed -n '/common_configure_flags/,/=/p' "$RULES" | grep -E '(^\\s*--|\\\\$)' | tr '\\n' ' ')
  FULL=$(sed -n '/full_configure_flags/,/=/p' "$RULES" | grep -E '(^\\s*--|\\\\$)' | tr '\\n' ' ')
  FLAGS="$COMMON $FULL"
  echo "$FLAGS" | tr -s ' ' | sed 's/^ *//; s/ *$//'
else
  echo "# debian/rules not found"
fi
