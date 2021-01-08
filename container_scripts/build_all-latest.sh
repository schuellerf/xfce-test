#!/usr/bin/env bash

MAIN_BRANCH=${MAIN_BRANCH:-last_tag}

# Just a wrapper call to be able to override if needed
MY_DIR=$(dirname $(readlink -f $0))
${MY_DIR}/build_all.sh

