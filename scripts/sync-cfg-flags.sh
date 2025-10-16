#!/usr/bin/env bash
set -euo pipefail

CONFIGURE_FLAGS=$(tr '\n' ' ' < configure/parameters.txt | xargs)

echo "CONFIGURE_FLAGS='$CONFIGURE_FLAGS'" >> $GITHUB_ENV
