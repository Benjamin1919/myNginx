#!/usr/bin/env bash

CONFIGURE_FLAGS=$(cat configure/parameters.txt | xargs)

echo "CONFIGURE_FLAGS=$CONFIGURE_FLAGS" >> $GITHUB_ENV
