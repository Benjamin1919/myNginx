#!/usr/bin/env bash
set -euo pipefail

CONFIGURE_FLAGS_RAW=$(tr '\n' ' ' < configure/parameters.txt | xargs)

echo "CONFIGURE_FLAGS_RAW=$CONFIGURE_FLAGS_RAW" >> $GITHUB_ENV
