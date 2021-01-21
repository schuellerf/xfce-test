#!/usr/bin/env bash

# fixing to xfce-4.14 mainly for garcon needing newer Automake
# not available in ubuntu 18.04 (by default)
MAIN_BRANCH=${MAIN_BRANCH:-xfce-4.14.0}

# Just a wrapper call to be able to override if needed
MY_DIR=$(dirname $(readlink -f $0))
${MY_DIR}/build_all.sh

