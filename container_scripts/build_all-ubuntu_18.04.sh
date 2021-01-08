#!/usr/bin/env bash

# Just a wrapper call to be able to override if needed
MY_DIR=$(dirname $(readlink -f $0))
${MY_DIR}/build_all.sh

